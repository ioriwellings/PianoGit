//
//  MidiKeyboard.m
//  MidiLineTest
//
//  Created by zhengyw on 14-5-16.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//


#import "MidiKeyboard.h"


static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon)
{
    //Reads the source/device's name which is allocated in the MidiSetupWithSource function.
    const char *source = connRefCon;
    
    
    //Extracting the data from the MIDI packets receieved.
    MIDIPacket *packet = (MIDIPacket *)pktlist->packet;
	Byte note = packet->data[1] & 0x7F;
    Byte velocity = packet->data[2] & 0x7F;
    
    for (int i=0; i < pktlist->numPackets; i++) {
        
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
        
		if ((midiCommand == 0x09) || //note on
			(midiCommand == 0x08)) { //note off
            
            if (velocity == 0) continue;
            
            NSLog(@"MyMIDIReadProc %s - NOTE : %d | %d", source, note, velocity);
            
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setObject:[NSNumber numberWithInteger:note] forKey:kNAMIDI_NoteKey];
            [info setObject:[NSNumber numberWithInteger:velocity] forKey:kNAMIDI_VelocityKey];
            NSNotification* notification = [NSNotification notificationWithName:kNAMIDIDatas object:nil userInfo:info];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
		}
        
        //After we are done reading the data, move to the next packet.
        packet = MIDIPacketNext(packet);
        
	}
}

static void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {

    NSLog(@"the MyMIDINotifyProc is [%d]", message->messageID);

    
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setObject:[NSNumber numberWithInteger:message->messageID] forKey:kNAMIDI_MessageID];
    NSNotification* notification = [NSNotification notificationWithName:kNAMIDINotification
                                                                 object:nil userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    
    MidiKeyboard *mkb = (__bridge MidiKeyboard*)refCon;
    if (message->messageID == kMIDIMsgObjectAdded && ![mkb isConnect]) {
        [mkb connectMidiDevice];
        
    } else if (message->messageID == kMIDIMsgObjectRemoved && [mkb isConnect]) {
        [mkb disconnectMidiDevice];
    } else if (message->messageID == kMIDIMsgIOError) {

        MIDIRestart();
        [mkb connectMidiDevice];
    }
    
}


@implementation MidiKeyboard
    static MidiKeyboard *_mkb = nil;

+ (MidiKeyboard*)sharedMidiKeyboard
{
    @synchronized(self)
    {
        if (_mkb == nil)
            _mkb = [[self alloc] init];
    }
    return _mkb;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        client = 0;
        MIDIClientCreate(CFSTR("NNAudio MIDI Handler"), MyMIDINotifyProc,
                         (__bridge void *)self, &client);
        
        outputPort = 0;
        MIDIOutputPortCreate(client, CFSTR("Output port"), &outputPort);
        
        inPort = 0;
        MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, nil, &inPort);
        
        src = 0;
        isConnect = FALSE;
    }
    
    return self;
}

-(BOOL)sendData:(Byte)note andVelocity:(Byte)velocity {
    
    Byte status = 0x90;
    Byte message[3] = {status, note, velocity};
    int length = 3;
    
    
    Byte buffer[1024];
	MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
	MIDIPacket *packet = MIDIPacketListInit(packet_list);
	
	OSStatus result;
    
	packet = MIDIPacketListAdd(
                               packet_list,
                               sizeof(buffer),
                               packet,
                               0,
                               length,
                               message);
	
    
    
    result = MIDISend(outputPort, outEndpoint, packet_list);
    NSLog(@"======= Sendding midi %d", result);
    
    return TRUE;
}

-(BOOL)sendClearData:(Byte)velocity {
    
    Byte status = 0x90;
    Byte message[3];
    int length = 3;
    
    for(int i = 20; i < 109; i++){

        message[0] = status;
        message[1] = i;
        message[2] = velocity;
        
        Byte buffer[1024];
        MIDIPacketList *packet_list = (MIDIPacketList *)buffer;
        MIDIPacket *packet = MIDIPacketListInit(packet_list);
        
        OSStatus result;
        
        packet = MIDIPacketListAdd(
                                   packet_list,
                                   sizeof(buffer),
                                   packet,
                                   0,
                                   length,
                                   message);

        result = MIDISend(outputPort, outEndpoint, packet_list);
        NSLog(@" clear data is %d", i);
    }

    return TRUE;
}

-(NSString*)getDisplayName:(MIDIObjectRef) object
{
    // Returns the display name of a given MIDIObjectRef as an NSString
    CFStringRef name = nil;
    if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
        return nil;
    return (NSString *)name;
}

- (BOOL) isConnect {
    return isConnect;
}

-(void) disconnectMidiDevice {
    MIDIPortDisconnectSource(inPort, src);
}


- (BOOL)connectMidiDevice {
    
    BOOL result = FALSE;
    isConnect = FALSE;
    
    
    ItemCount destCount = MIDIGetNumberOfDestinations();
    NSLog(@"====dest count [%ld]", destCount);
    for (ItemCount i = 0 ; i < destCount ; ++i) {
        
        // Grab a reference to a destination endpoint
        MIDIEndpointRef dest = MIDIGetDestination(i);
        if (dest != 0) {
            NSLog(@"  Destination: %@", [self getDisplayName:dest]);
        }
    }
    
    
	ItemCount sourceCount = MIDIGetNumberOfSources();
    NSLog(@"====source count [%ld]", sourceCount);
	for (ItemCount i = 0; i < sourceCount; ++i) {
        
        src = MIDIGetSource(i);
        NSString * name = [self getDisplayName:src];
        if (src != 0) {
            NSLog(@"  Source: %@", [self getDisplayName:src]);
        }
        
        NSRange range = [name rangeOfString:@"Session 1"];//判断字符串是否包含
        if (range.length >0) {
            continue;
        }
        
        outEndpoint = MIDIGetDestination(i);
        OSStatus err = MIDIPortConnectSource(inPort, src, NULL);
        NSLog(@"MIDIPortConnectSource code: %d", err);
        
        isConnect = TRUE;
        result = TRUE;
	}
    
    return result;
}


+(id)allocWithZone:(NSZone *)zone {
    
    @synchronized(self){
        
        if (!_mkb) {
            
            _mkb = [super allocWithZone:zone]; //确保使用同一块内存地址
            return _mkb;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self; //确保copy对象也是唯一
}



-(id)retain {
    return self; //确保计数唯一
}

- (id)autorelease {
    return self;//确保计数唯一
} 



- (oneway void)release {
    //重写计数释放方法
}

-(void)dealloc {
    
    if (outputPort)
    {
        MIDIPortDispose(outputPort);
    }
    
    if (inPort)
    {
        MIDIPortDispose(inPort);
    }
    
    if (client)
    {
        MIDIClientDispose(client);
    }
    
    [super dealloc];
    
    NSLog(@"midikeyboard is dealloc!");
}

@end
