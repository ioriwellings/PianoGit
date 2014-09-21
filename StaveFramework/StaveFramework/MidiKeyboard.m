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
    NSLog(@"MyMIDIReadProc  start %lu", pktlist->numPackets);
    
    
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
            
            NSLog(@"99999999999999999999 %s - NOTE : %d | %d", source, note, velocity);
            
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setObject:[NSNumber numberWithInteger:note] forKey:kNAMIDI_NoteKey];
            [info setObject:[NSNumber numberWithInteger:velocity] forKey:kNAMIDI_VelocityKey];
            NSNotification* notification = [NSNotification notificationWithName:kNAMIDIDatas object:nil userInfo:info];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
		} else {
            
//            NSLog(@"%s - CNTRL  : %d | %d", source, note, velocity);
        }
        
        //After we are done reading the data, move to the next packet.
        packet = MIDIPacketNext(packet);
        
	}
}

static void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
//    NSNotification* notification = [NSNotification notificationWithName:kNAMIDINotification
//                                                                 object:[NSNumber numberWithShort:message->messageID]];
//    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    NSLog(@" MyMIDINotifyProc is %lu", message->messageID);
}


@implementation MidiKeyboard

- (id)init
{
    self = [super init];
    inPort = 0;
    src = 0;
    MIDIRestart();
    return self;
}

- (void) listSources
{
    unsigned long sourceCount = MIDIGetNumberOfSources();
    for (int i=0; i<sourceCount; i++) {
        MIDIEndpointRef source = MIDIGetSource(i);
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(source, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
        NSLog(@"Source %d - %s", i, endpointNameC);
    }
}

-(void) unSetupMIDI {
    MIDIPortDisconnectSource(inPort, src);
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
    NSLog(@"======= Sendding midi %lu", result);
    
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

- (BOOL)setupMIDI {
    
    BOOL result = FALSE;
//    [self listSources];
    client = 0;
    outputPort = 0;
    inPort = 0;
    
	OSStatus err = MIDIClientCreate(CFSTR("NNAudio MIDI Handler"), MyMIDINotifyProc, nil, &client);
	NSLog(@"MIDIClientCreate error code: %lu", err);
    
    
	err = MIDIOutputPortCreate(client, CFSTR("Output port"), &outputPort);
    NSLog(@"MIDIOutputPortCreate error code: %lu", err);
    
    
	err = MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, nil, &inPort);
    NSLog(@"MIDIInputPortCreate error code: %lu", err);
    
	
    
    
    ItemCount destCount = MIDIGetNumberOfDestinations();
    for (ItemCount i = 0 ; i < destCount ; ++i) {
        
        // Grab a reference to a destination endpoint
        MIDIEndpointRef dest = MIDIGetDestination(i);
        if (dest != NULL) {
            NSLog(@"  Destination: %@", [self getDisplayName:dest]);
        }
    }
    
    
    
    
    
	ItemCount sourceCount = MIDIGetNumberOfSources();
    NSLog(@"====count [%lu]", sourceCount);
	for (ItemCount i = 0; i < sourceCount; ++i) {
        
        src = MIDIGetSource(i);

        NSString * name = [self getDisplayName:src];

        if (src != NULL) {
            NSLog(@"  Source: %@", name);
        }
        
        NSRange range = [name rangeOfString:@"Session 1"];//判断字符串是否包含
        if (range.length >0) {
            
            NSLog(@"  yyyyyyyyyyyyyy");
            continue;
        }
        
        outEndpoint = MIDIGetDestination(i);
        OSStatus err = MIDIPortConnectSource(inPort, src, NULL);
        NSLog(@"MIDIPortConnectSource error code: %lu", err);
        
        result = TRUE;
	}
    
    NSLog(@"==== setupMIDI");
    
    return result;
}

-(void)dealloc {
    
    [self unSetupMIDI];
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
    
     NSLog(@"==== dealloc");
}

@end
