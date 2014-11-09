//
//  MidiKeyboard.h
//  MidiLineTest
//
//  Created by zhengyw on 14-5-16.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

static NSString* kNAMIDIDatas = @"kNAMIDIDatas";
static NSString* kNAMIDINotification = @"kNAMIDINotification";

static NSString* kNAMIDI_NoteKey = @"kNAMIDI_NoteKey";
static NSString* kNAMIDI_MessageID = @"kNAMIDI_MessageID";
static NSString* kNAMIDI_VelocityKey = @"kNAMIDI_VelocityKey";



@interface MidiKeyboard : NSObject {
    MIDIPortRef inPort;
    MIDIPortRef outputPort;
    MIDIClientRef client;
    MIDIEndpointRef src;
    MIDIEndpointRef outEndpoint;
    BOOL isConnect;
}

+ (MidiKeyboard*)sharedMidiKeyboard;
- (BOOL) connectMidiDevice;
- (void) disconnectMidiDevice;
- (BOOL) sendData:(Byte)note andVelocity:(Byte)velocity;
- (BOOL) sendClearData:(Byte)velocity;
- (BOOL) isConnect;
@end
