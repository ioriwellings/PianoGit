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
    NSNotification* notification = [NSNotification notificationWithName:kNAMIDINotification
                                                                 object:[NSNumber numberWithShort:message->messageID]];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@implementation MidiKeyboard

- (id)init
{
    self = [super init];
    inPort = 0;
    src = 0;
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

- (BOOL)setupMIDI {
    
    BOOL result = FALSE;
//    [self listSources];
    client = 0;
    
    
	MIDIClientCreate(CFSTR("NNAudio MIDI Handler"), MyMIDINotifyProc, nil, &client);
	
	MIDIOutputPortCreate(client, CFSTR("Output port"), &outputPort);
	MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, nil, &inPort);
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
    NSLog(@"====count [%lu]", sourceCount);
	for (int i = 0; i < sourceCount; ++i) {
        outEndpoint = MIDIGetDestination(i);
        src = MIDIGetSource(i);
        CFStringRef endpointName = NULL;
        MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName);
        char endpointNameC[255];
        CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
        NSLog(@"Source %d - %s", i, endpointNameC);
        if (strcmp("Session 1", endpointNameC) == 0) {
            continue;
        }
        
        MIDIPortConnectSource(inPort, src, NULL);
        result = TRUE;
	}
    
    NSLog(@"==== setupMIDI");
    
    return result;
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
}

@end
