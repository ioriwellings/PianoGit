/*
 * Copyright (c) 2007-2012 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import "MidiFile.h"
#import "TempoSignature.h"
#import <Foundation/NSAutoreleasePool.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <assert.h>
#include <stdio.h>
#include <sys/stat.h>
#include <math.h>


/* This file contains the classes for parsing and modifying MIDI music files */

/* Midi file format.
 *
 * The Midi File format is described below.  The description uses
 * the following abbreviations.
 *
 * u1     - One byte
 * u2     - Two bytes (big endian)
 * u4     - Four bytes (big endian)
 * varlen - A variable length integer, that can be 1 to 4 bytes. The 
 *          integer ends when you encounter a byte that doesn't have 
 *          the 8th bit set (a byte less than 0x80).
 * len?   - The length of the data depends on some code
 *          
 *
 * The Midi files begins with the main Midi header
 * u4 = The four ascii characters 'MThd'
 * u4 = The length of the MThd header = 6 bytes
 * u2 = 0 if the file contains a single track
 *      1 if the file contains one or more simultaneous tracks
 *      2 if the file contains one or more independent tracks
 * u2 = number of tracks
 * u2 = if >  0, the number of pulses per quarter note
 *      if <= 0, then ???
 *
 * Next come the individual Midi tracks.  The total number of Midi
 * tracks was given above, in the MThd header.  Each track starts
 * with a header:
 *
 * u4 = The four ascii characters 'MTrk'
 * u4 = Amount of track data, in bytes.
 * 
 * The track data consists of a series of Midi events.  Each Midi event
 * has the following format:
 *
 * varlen  - The time between the previous event and this event, measured
 *           in "pulses".  The number of pulses per quarter note is given
 *           in the MThd header.
 * u1      - The Event code, always betwee 0x80 and 0xFF
 * len?    - The event data.  The length of this data is determined by the
 *           event code.  The first byte of the event data is always < 0x80.
 *
 * The event code is optional.  If the event code is missing, then it
 * defaults to the previous event code.  For example:
 *
 *   varlen, eventcode1, eventdata,
 *   varlen, eventcode2, eventdata,
 *   varlen, eventdata,  // eventcode is eventcode2
 *   varlen, eventdata,  // eventcode is eventcode2
 *   varlen, eventcode3, eventdata,
 *   ....
 *
 *   How do you know if the eventcode is there or missing? Well:
 *   - All event codes are between 0x80 and 0xFF
 *   - The first byte of eventdata is always less than 0x80.
 *   So, after the varlen delta time, if the next byte is between 0x80
 *   and 0xFF, its an event code.  Otherwise, its event data.
 *
 * The Event codes and event data for each event code are shown below.
 *
 * Code:  u1 - 0x80 thru 0x8F - Note Off event.
 *             0x80 is for channel 1, 0x8F is for channel 16.
 * Data:  u1 - The note number, 0-127.  Middle C is 60 (0x3C)
 *        u1 - The note velocity.  This should be 0
 * 
 * Code:  u1 - 0x90 thru 0x9F - Note On event.
 *             0x90 is for channel 1, 0x9F is for channel 16.
 * Data:  u1 - The note number, 0-127.  Middle C is 60 (0x3C)
 *        u1 - The note velocity, from 0 (no sound) to 127 (loud).
 *             A value of 0 is equivalent to a Note Off.
 *
 * Code:  u1 - 0xA0 thru 0xAF - Key Pressure
 * Data:  u1 - The note number, 0-127.
 *        u1 - The pressure.
 *
 * Code:  u1 - 0xB0 thru 0xBF - Control Change
 * Data:  u1 - The controller number
 *        u1 - The value
 *
 * Code:  u1 - 0xC0 thru 0xCF - Program Change
 * Data:  u1 - The program number.
 *
 * Code:  u1 - 0xD0 thru 0xDF - Channel Pressure
 *        u1 - The pressure.
 *
 * Code:  u1 - 0xE0 thru 0xEF - Pitch Bend
 * Data:  u2 - Some data
 *
 * Code:  u1     - 0xFF - Meta Event
 * Data:  u1     - Metacode
 *        varlen - Length of meta event
 *        u1[varlen] - Meta event data.
 *
 *
 * The Meta Event codes are listed below:
 *
 * Metacode: u1         - 0x0  Sequence Number
 *           varlen     - 0 or 2
 *           u1[varlen] - Sequence number
 *
 * Metacode: u1         - 0x1  Text
 *           varlen     - Length of text
 *           u1[varlen] - Text
 *
 * Metacode: u1         - 0x2  Copyright
 *           varlen     - Length of text
 *           u1[varlen] - Text
 *
 * Metacode: u1         - 0x3  Track Name
 *           varlen     - Length of name
 *           u1[varlen] - Track Name
 *
 * Metacode: u1         - 0x58  Time Signature
 *           varlen     - 4 
 *           u1         - numerator
 *           u1         - log2(denominator)
 *           u1         - clocks in metronome click
 *           u1         - 32nd notes in quarter note (usually 8)
 *
 * Metacode: u1         - 0x59  Key Signature
 *           varlen     - 2
 *           u1         - if >= 0, then number of sharps
 *                        if < 0, then number of flats * -1
 *           u1         - 0 if major key
 *                        1 if minor key
 *
 * Metacode: u1         - 0x51  Tempo
 *           varlen     - 3  
 *           u3         - quarter note length in microseconds
 */


/* Return a string representation of a Midi event */
static const char* eventName(int ev) {
    if (ev >= EventNoteOff && ev < EventNoteOff + 16)
        return "NoteOff";
    else if (ev >= EventNoteOn && ev < EventNoteOn + 16) 
        return "NoteOn";
    else if (ev >= EventKeyPressure && ev < EventKeyPressure + 16) 
        return "KeyPressure";
    else if (ev >= EventControlChange && ev < EventControlChange + 16) 
        return "ControlChange";
    else if (ev >= EventProgramChange && ev < EventProgramChange + 16) 
        return "ProgramChange";
    else if (ev >= EventChannelPressure && ev < EventChannelPressure + 16)
        return "ChannelPressure";
    else if (ev >= EventPitchBend && ev < EventPitchBend + 16)
        return "PitchBend";
    else if (ev == MetaEvent)
        return "MetaEvent";
    else if (ev == SysexEvent1 || ev == SysexEvent2)
        return "SysexEvent";
    else
        return "Unknown";
}

/** Write a variable length number to the buffer at the given offset.
 * Return the number of bytes written.
 */
static int varlenToBytes(int num, u_char *buf, int offset) {
    u_char b1 = (u_char) ((num >> 21) & 0x7F);
    u_char b2 = (u_char) ((num >> 14) & 0x7F);
    u_char b3 = (u_char) ((num >>  7) & 0x7F);
    u_char b4 = (u_char) (num & 0x7F);

    if (b1 > 0) {
        buf[offset]   = (u_char)(b1 | 0x80);
        buf[offset+1] = (u_char)(b2 | 0x80);
        buf[offset+2] = (u_char)(b3 | 0x80);
        buf[offset+3] = b4;
        return 4;
    }
    else if (b2 > 0) {
        buf[offset]   = (u_char)(b2 | 0x80);
        buf[offset+1] = (u_char)(b3 | 0x80);
        buf[offset+2] = b4;
        return 3;
    }
    else if (b3 > 0) {
        buf[offset]   = (u_char)(b3 | 0x80);
        buf[offset+1] = b4;
        return 2;
    }
    else {
        buf[offset] = b4;
        return 1;
    }
}

/** Write a 4-byte integer to buf[offset : offset+4] */
static void intToBytes(int value, u_char *buf, int offset) {
    buf[offset] = (u_char)( (value >> 24) & 0xFF );
    buf[offset+1] = (u_char)( (value >> 16) & 0xFF );
    buf[offset+2] = (u_char)( (value >> 8) & 0xFF );
    buf[offset+3] = (u_char)( value & 0xFF );
}

/** Write the given buffer to the given file.
 *  If an error occurs, set error = 1.
 */
static void dowrite(int fd, u_char *buf, int len, int *error) {
    int n = 0;
    int offset = 0;
    do {
        n = write(fd, &buf[offset], len - offset);
        if (n > 0) {
            offset += n;
        }
        else if (n == 0) {
            *error = 1;
            return;
        }
        else if (n == -1 && errno == EINTR) {
        }
        else if (n == -1) {
            *error = 1;
            return;
        }
    }
    while (offset < len);
}

/** @class MidiFile
 *
 * The MidiFile class contains the parsed data from the Midi File.
 * It contains:
 * - All the tracks in the midi file, including all MidiNotes per track.
 * - The time signature (e.g. 4/4, 3/4, 6/8)
 * - The number of pulses per quarter note.
 * - The tempo (number of microseconds per quarter note).
 *
 * The constructor takes a filename as input, and upon returning,
 * contains the parsed data from the midi file.
 *
 * The methods readTrack() and readMetaEvent() are helper functions called
 * by the constructor during the parsing.
 *
 * After the MidiFile is parsed and created, the user can retrieve the 
 * tracks and notes by using the method tracks and [tracks notes].
 *
 * There are two methods for modifying the midi data based on the menu
 * options selected:
 *
 * - changeMidiNotes()
 *   Apply the menu options to the parsed MidiFile.  This uses the helper functions:
 *     splitTrack()
 *     combineToTwoTracks()
 *     shiftTime()
 *     transpose()
 *     roundStartTimes()
 *     roundDurations()
 *
 * - changeSound()
 *   Apply the menu options to the MIDI music data, and save the modified midi data
 *   to a file, for playback.  This uses the helper functions:
 *     addTempoEvent()
 *     changeSoundPerChannel
 */

@implementation MidiFile

/** Get the list of tracks (MidiTrack) */
- (Array*)tracks {
    return tracks;
}

/** Get the time signature */
- (TimeSignature*)time {
    return timesig;
}

/** Get the file name */
- (NSString*)filename {
    return filename;
}

/** Get the total length (in pulses) of the song */
- (int)totalpulses {
    return totalpulses;
}

/** add by yizhq start */
- (int)quarternote {
    return quarternote;
}

/** add by yizhq end */

/** add by sunlie start */
-(Array*)beatarray {
    return beatarray;
}

-(Array*)tonearray {
    return tonearray;
}
-(Array*)tempoarray {
    return tempoarray;
}
/** add by sunlie end */

/** Parse the given Midi file, and return an instance of this MidiFile
 * class.  After reading the midi file, this object will contain:
 * - The raw list of midi events
 * - The Time Signature of the song
 * - All the tracks in the song which contain notes. 
 * - The number, starttime, and duration of each note.
 */
- (id)initWithFile:(NSString*)path {
    const char *hdr;
    int len;

    filename = [path retain];
    /** add by sunlie start */
    controlList = [Array new:10];
    controlList2 = [Array new:20];
    controlList3 = [Array new:10];
    controlList4 = [Array new:10];
    controlList5 = [Array new:20];
    controlList6 = [Array new:20];
    controlList7 = [Array new:20];
    controlList8 = [Array new:20];
    controlList9 = [Array new:10];
    controlList10 = [Array new:10];
    controlList11 = [Array new:10];
    controlList12 = [Array new:10];
    controlList13 = [Array new:10];
    controlList14 = [Array new:10];
    controlList15 = [Array new:10];
    controlList16 = [Array new:10];
    controlList17 = [Array new:10];
    controlList18 = [Array new:10];
    controlList19 = [Array new:10];
    /** add by sunlie end */
    tracks = [Array new:5];
    trackPerChannel = NO;

    /** add by sunlie start */
    beatarray = [Array new:5];
    tonearray = [Array new:5];
    tempoarray = [Array new:5];
    /** add by sunlie end */
    
    MidiFileReader *file = [[MidiFileReader alloc] initWithFile:filename];
    hdr = [file readAscii:4];
    if (strncmp(hdr, "MThd", 4) != 0) {
		[file release];
        MidiFileException *e =
           [MidiFileException init:@"Bad MThd header" offset:0];
        @throw e;
    }
    len = [file readInt];
    if (len !=  6) {
        [file release];
        MidiFileException *e =
           [MidiFileException init:@"Bad MThd len" offset:4];
        @throw e;
    }
    trackmode = [file readShort];
    int num_tracks = [file readShort];
    quarternote = [file readShort];

    events = [Array new:num_tracks];
    for (int tracknum = 0; tracknum < num_tracks; tracknum++) {
        Array *trackevents = [self readTrack:file];
        MidiTrack *track = 
          [[MidiTrack alloc] initWithEvents:trackevents andTrack:tracknum];
        [events add:trackevents];
        [trackevents release];
        [track setNumber:tracknum];
        if ([[track notes] count] > 0) {
            /** add by sunlie start */
            if ([controlList count ] > 0) {
                [track setControlList:controlList];
            }
            
            if ([controlList2 count] > 0) {
                [track setControlList2:controlList2];
            }
            
            if ([controlList3 count] > 0) {
                [track setControlList3:controlList3];
            }
            
            if ([controlList4 count] > 0) {
                [track setControlList4:controlList4];
            }
            
            if ([controlList5 count] > 0) {
                [track setControlList5:controlList5];
            }
            
            if ([controlList6 count] > 0) {
                [track setControlList6:controlList6];
            }
            if ([controlList7 count] > 0) {
                [track setControlList7:controlList7];
            }
            if ([controlList8 count] > 0) {
                [track setControlList8:controlList8];
            }
            if ([controlList9 count] > 0) {
                [track setControlList9:controlList9];
            }
            if ([controlList10 count] > 0) {
                [track setControlList10:controlList10];
            }
            if ([controlList11 count] > 0) {
                [track setControlList11:controlList11];
            }
            if ([controlList12 count] > 0) {
                [track setControlList12:controlList12];
            }
            if ([controlList13 count] > 0) {
                [track setControlList13:controlList13];
            }
            if ([controlList14 count] > 0) {
                [track setControlList14:controlList14];
            }
            if ([controlList15 count] > 0) {
                [track setControlList15:controlList15];
            }
            if ([controlList16 count] > 0) {
                [track setControlList16:controlList16];
            }
            if ([controlList17 count] > 0) {
                [track setControlList17:controlList17];
            }
            if ([controlList18 count] > 0) {
                [track setControlList18:controlList18];
            }
            if ([controlList19 count] > 0) {
                [track setControlList19:controlList19];
            }
            /** add by sunlie end */
            [tracks add:track];
        }
        [track release];
    }

    /* Get the length of the song in pulses */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *last = [[track notes] get:([[track notes] count] -1) ];
        if (totalpulses < [last startTime] + [last duration]) {
            totalpulses = [last startTime] + [last duration];
        }
    }

    /** add by sunlie start */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *tr = [tracks get:tracknum];
        [tr setTotalpulses:totalpulses];
    }
    /** add by sunlie end */
    /* If we only have one track with multiple channels, then treat
     * each channel as a separate track.
     */
    if ([tracks count] == 1 && [MidiFile hasMultipleChannels:[tracks get:0]]) {
        Array *trackevents = [events get:[[tracks get:0] number] ];
        Array* newtracks = [MidiFile splitChannels:[tracks get:0] withEvents:trackevents];
        trackPerChannel = YES;
        [tracks release];
        tracks = newtracks;
    }

    [MidiFile checkStartTimes:tracks];

    /* Determine the time signature */
    int tempo = 0;
    int numer = 0;
    int denom = 0;
    /** add by sunlie start */
    int starttime = 0;
    int tone = 0;
    char tmp;
    /** add by sunlie end */
    for (int tracknum = 0; tracknum < [events count]; tracknum++) {
        Array *eventlist = [events get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            if ([mevent metaevent] == MetaEventTempo) {
                tempo = [mevent tempo];
                TempoSignature *tempoSig = [[TempoSignature alloc] initWithNumerator:tempo andStarttime:[mevent startTime]];
                [tempoarray add:tempoSig];
                [tempoSig release];
            }
            /** modify by sunlie start */
            if ([mevent metaevent] == MetaEventTimeSignature) {
                numer = [mevent numerator];
                denom = [mevent denominator];
                starttime = [mevent startTime];
                BeatSignature *beat = [[BeatSignature alloc] initWithNumerator:numer andDenominator:denom andStarttime:starttime];
                [beatarray add:beat];
                [beat release];
            }
            if ([mevent metaevent] == MetaEventKeySignature) {
                int size = [tonearray count];
                int a;
                ToneSignature *tonesig;
                /** modify by yizhq start */
                tmp = [mevent metavalue][0];
                tone = tmp;
                tmp = [mevent metavalue][1];
                a = tmp;
                /** modify by yizhq end */
                starttime = [mevent startTime];
                if (size == 0) {
                    tonesig = [[ToneSignature alloc] initWithTone:tone andStarttime:starttime];
                    [tonearray add:tonesig];
                    [tonesig release];
                }
                if (size > 0) {
                    ToneSignature *t =[tonearray get:(size-1)];
                    if ([t tone] != tone) {
                        tonesig = [[ToneSignature alloc] initWithTone:tone andStarttime:starttime];
                        [tonearray add:tonesig];
                        [tonesig release];
                    }
                }
            }
            /** modify by sunlie end */
        }
    }

    if (tempo == 0) {
        tempo = 500000; /* 500,000 microseconds = 0.05 sec */
    }
    /** modify by sunlie start */
//    if (numer == 0) {
//        numer = 4; denom = 4;
//    }
    if ([beatarray count] > 0) {
        BeatSignature *beat = [beatarray get:0];
        numer = [beat numerator];
        denom = [beat denominator];
//        if ([beat tempo] != 0) {
//            tempo = [beat tempo];
//        }
    } else {
        numer = 4;
        denom = 4;
    }
    /** modify by sunlie end */
    timesig = [[TimeSignature alloc] initWithNumerator:numer
                     andDenominator:denom
                     andQuarter:quarternote
                     andTempo:tempo];

    
    [file release];
    return self;
}

- (void)dealloc
{
    if(beatarray)[beatarray release];
    if(tonearray)[tonearray release];
    [filename release];
    [tracks release];
    [timesig release];
    [events release];
    /** add by sunlie start */
    [controlList release];
    [controlList2 release];
    [controlList3 release];
    [controlList4 release];
    [controlList5 release];
    [controlList6 release];
    [controlList7 release];
    [controlList8 release];
    [controlList9 release];
    [controlList10 release];
    [controlList11 release];
    [controlList12 release];
    [controlList13 release];
    [controlList14 release];
    [controlList15 release];
    [controlList16 release];
    [controlList17 release];
    [controlList18 release];
    [controlList19 release];
    /** add by sunlie end */
    [super dealloc];
}

/** Parse a single track into a list of MidiEvents.
 * Entering this function, the file offset should be at the start of
 * the MTrk header.  Upon exiting, the file offset should be at the
 * start of the next MTrk header.
 */
- (Array*)readTrack:(MidiFileReader*)file {
    Array *result = [Array new:20];
    int starttime = 0;
    const char *hdr = [file readAscii:4];

    if (strncmp(hdr, "MTrk", 4) != 0) {
        MidiFileException *e =
           [MidiFileException init:@"Bad MTrk header" offset:([file offset] -4)];
        @throw e;
    }
    int tracklen = [file readInt];
    int trackend = tracklen + [file offset];

    int eventflag = 0;
    
    /** add by sunlie start */
    int ctrecord1 = 0;
    int ctrecord2 = 0;
    int ctrecord3 = 0;
    int ctrecord4 = 0;
    int preValue4 = -1;
    int preStart4 = -1;
    int ctrecord5 = 0;
    int ctrecord6 = 0;
    int ctrecord7 = 0;
    int ctrecord8 = 0;
    int preValue8 = -1;
    int preTime8 = -1;
    int ctrecord9 = 0;
    int preValue9 = -1;
    int preTime9 = -1;
    int ctrecord10 = 0;
    int preValue10 = -1;
    int preTime10 = -1;
    int ctrecord11 = 0;
    int preValue11 = -1;
    int preStart11 = -1;
    int ctrecord12 = 0;
    int preValue12 = -1;
    int preStart12 = -1;
    int ctrecord13 = 0;
    int ctrecord14 = 0;
    int ctrecord15 = 0;
    int preValue15 = -1;
    int preStart15 = -1;
    int ctrecord16 = 0;
    int ctrecord17 = 0;
    int ctrecord18 = 0;
    int ctrecord19 = 0;
    
    [controlList clear];
    [controlList2 clear];
    [controlList3 clear];
    [controlList4 clear];
    [controlList5 clear];
    [controlList6 clear];
    [controlList7 clear];
    [controlList8 clear];
    [controlList9 clear];
    [controlList10 clear];
    [controlList11 clear];
    [controlList12 clear];
    [controlList13 clear];
    [controlList14 clear];
    [controlList15 clear];
    [controlList16 clear];
    [controlList17 clear];
    [controlList18 clear];
    [controlList19 clear];
    /** add by sunlie end */

    while ([file offset] < trackend) {
        /* If the midi file is truncated here, we can still recover.
         * Just return what we've parsed so far.
         */
        int startoffset, deltatime;
        u_char peekevent;
        @try {
            startoffset = [file offset];
            deltatime = [file readVarlen];
            starttime += deltatime;
            peekevent = [file peek];
        }
        @catch (MidiFileException* e) {
            return result;
        } 

        MidiEvent *mevent = [[MidiEvent alloc] init];
        [result add:mevent];
        [mevent setDeltaTime:deltatime];
        [mevent setStartTime:starttime];

        if (peekevent >= EventNoteOff) {
            [mevent setHasEventflag:YES];
            eventflag = [file readByte];
            /* printf("Read new event %d %s\n", eventflag, eventName(eventflag)); */
        }

        /**
        printf("offset %d:event %d %s delta %d\n",
               startoffset, eventflag, eventName(eventflag), [mevent deltatime]);
        **/

        if (eventflag >= EventNoteOn && eventflag < EventNoteOn + 16) {
            [mevent setEventFlag:EventNoteOn];
            [mevent setChannel:(u_char)(eventflag - EventNoteOn)];
            [mevent setNotenumber:[file readByte]];
            [mevent setVelocity:[file readByte]];
        }
        else if (eventflag >= EventNoteOff && eventflag < EventNoteOff + 16) {
            [mevent setEventFlag:EventNoteOff];
            [mevent setChannel:(u_char)(eventflag - EventNoteOff)];
            [mevent setNotenumber:[file readByte]];
            [mevent setVelocity:[file readByte]];
        }
        else if (eventflag >= EventKeyPressure && 
                 eventflag < EventKeyPressure + 16) {
            [mevent setEventFlag:EventKeyPressure];
            [mevent setChannel:(u_char)(eventflag - EventKeyPressure)];
            [mevent setNotenumber:[file readByte]];
            [mevent setKeyPressure:[file readByte]];
        }
        else if (eventflag >= EventControlChange && 
                 eventflag < EventControlChange + 16) {
            [mevent setEventFlag:EventControlChange];
            [mevent setChannel:(u_char)(eventflag - EventControlChange)];
            [mevent setControlNum:[file readByte]];
            [mevent setControlValue:[file readByte]];

            /** add by sunlie start */
            if ([mevent controlNum] == 3) {
                int value = [mevent controlValue];
                if (value < 20) {
                    if (ctrecord1 == 127) {
                        ControlData *cdata = [controlList get:[controlList count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord1 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord1 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList add:data];
                        [data release];
                        ctrecord1 = 127;
                    }
                    
                }
            }
            if ([mevent controlNum] == 9) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord2 == 127) {
                        cdata = [controlList2 get:[controlList2 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord2 = 0;
                    } else if (ctrecord2 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList2 add:data];
                        [data release];
                        ctrecord2 = 127;
                    }
                }
//                if (value < 20) {
//                    if (ctrecord2 == 127) {
//                        cdata = [controlList2 get:[controlList2 count]-1];
//                        [cdata setEndtime:[mevent startTime]];
//                        ctrecord2 = 0;
//                    }
//                } else if (value > 110 && value <= 127) {
//                    if (ctrecord2 == 0) {
//                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
//                        [controlList2 add:data];
//                        ctrecord2 = 127;
//                    }
//                    
//                }
            }
            if ([mevent controlNum] == 14) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord3 == 127) {
                        cdata = [controlList3 get:[controlList3 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord3 = 0;
                    } else if (ctrecord3 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList3 add:data];
                        [data release];
                        ctrecord3 = 127;
                    }
                } else if (value == 0) {
                    if (ctrecord3 == 64) {
                        cdata = [controlList3 get:[controlList3 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord3 = 0;
                    } else if (ctrecord3 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList3 add:data];
                        [data release];
                        ctrecord3 = 64;
                    }
                }
                
//                if ([mevent startTime] - preStart3 > 50 || preStart3 == -1) {
//                    if (preValue3 == -1) {
//                        preValue3 = value;
//                        preStart3 = [mevent startTime];
//                    }
//                    
//                    if (preValue3 >= 10 && preValue3 <=64) {
//                        if (ctrecord3 != 64) {
//                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue3 andStarttime:preStart3 andEndtime:0];
//                            [controlList3 add:data];
//                            ctrecord3 = 64;
//                        }
//                        
//                    } else if (preValue3 > 64 && preValue3 <= 127) {
//                        if (ctrecord3 != 127) {
//                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue3 andStarttime:preStart3 andEndtime:0];
//                            [controlList3 add:data];
//                            ctrecord3 = 127;
//                        }
//                    }
//                }
//                
//                if (value < 10) {
//                    if (ctrecord3 != 0) {
//                        if ([controlList3 count] > 0 && [[controlList3 get:[controlList3 count]-1] endtime] == 0) {
//                            [[controlList3 get:[controlList3 count]-1] setEndtime:[mevent startTime]];
//                            ctrecord3 = 0;
//                        }
//                    }
//                }
//                
//                preStart3 = [mevent startTime];
//                preValue3 = value;
            }
            if ([mevent controlNum] == 15) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preStart4 > 50 || preStart4 == -1) {
                    if (preValue4 == -1) {
                        preValue4 = value;
                        preStart4 = [mevent startTime];
                    }
                    
                    if (preValue4 >= 10 && preValue4 <=64) {
                        if (ctrecord4 != 64) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue4 andStarttime:preStart4 andEndtime:0];
                            [controlList4 add:data];
                            [data release];
                            ctrecord4 = 64;
                        }
                        
                    } else if (preValue4 > 64 && preValue4 <= 127) {
                        if (ctrecord4 != 127) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue4 andStarttime:preStart4 andEndtime:0];
                            [controlList4 add:data];
                            [data release];
                            ctrecord4 = 127;
                        }
                    }
                }
                
                if (value < 10) {
                    if (ctrecord4 != 0) {
                        if ([controlList4 count] > 0 && [[controlList4 get:[controlList4 count]-1] endtime] == 0) {
                            [[controlList4 get:[controlList4 count]-1] setEndtime:[mevent startTime]];
                            ctrecord4 = 0;
                        }
                    }
                }
                
                preStart4 = [mevent startTime];
                preValue4 = value;
            }
            if ([mevent controlNum] == 64) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value < 20) {
                    if (ctrecord5 == 127) {
                        cdata = [controlList5 get:[controlList5 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord5 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord5 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList5 add:data];
                        [data release];
                        ctrecord5 = 127;
                    }
                    
                }
            }
            
            if ([mevent controlNum] == 20) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value < 20) {
                    if (ctrecord6 == 127) {
                        cdata = [controlList6 get:[controlList6 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord6 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord6 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList6 add:data];
                        [data release];
                        ctrecord6 = 127;
                    }
                    
                }
            }
            
            if ([mevent controlNum] == 21) {
                int value = [mevent controlValue];
                if (value < 20) {
                    if (ctrecord7 == 127) {
                        ControlData *cdata = [controlList7 get:[controlList7 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord7 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord7 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList7 add:data];
                        [data release];
                        ctrecord7 = 127;
                    }
                    
                }
            }
            
            if ([mevent controlNum] == 7) {
                int value = [mevent controlValue];
                int start = [mevent startTime];

                if (value == preValue8 && start - preTime8 > quarternote) {
                    
                    if ([controlList8 count] > 0) {
                        [[controlList8 get:[controlList8 count]-1] setEndtime:preTime8];
                        [[controlList8 get:[controlList8 count]-1] setCValue:ctrecord8];
                    }
                    ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:start andEndtime:0];
                    [controlList8 add:data];
                    [data release];
                } else if (value < preValue8) {
                    ctrecord8 = -1;
                } else if (value > preValue8) {
                    ctrecord8 = 1;
                }
                preValue8 = value;
                preTime8 = start;
            }
            
            if ([mevent controlNum] == 22) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preTime9 > 50 || preTime9 == -1) {
                    if (preValue9 == -1) {
                        preValue9 = value;
                        preTime9 = [mevent startTime];
                    }
                    
                    if (preValue9 >= 21 && preValue9 <=45) {
                        if (ctrecord9 != 1) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue9 andStarttime:preTime9 andEndtime:0];
                            [controlList9 add:data];
                            [data release];
                            ctrecord9 = 1;
                        }
                        
                    } else if (preValue9 > 46 && preValue9 <= 70) {
                        if (ctrecord9 != 2) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue9 andStarttime:preTime9 andEndtime:0];
                            [controlList9 add:data];
                            [data release];
                            ctrecord9 = 2;
                        }
                    } else if (preValue9 > 71 && preValue9 <= 95) {
                        if (ctrecord9 != 3) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue9 andStarttime:preTime9 andEndtime:0];
                            [controlList9 add:data];
                            [data release];
                            ctrecord9 = 3;
                        }
                    } else if (preValue9 > 96 && preValue9 <= 127) {
                        if (ctrecord9 != 4) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue9 andStarttime:preTime9 andEndtime:0];
                            [controlList9 add:data];
                            [data release];
                            ctrecord9 = 4;
                        }
                    }
                }
                
                if (value < 20) {
                    if (ctrecord9 != 0) {
                        if ([controlList9 count] > 0 && [[controlList9 get:[controlList9 count]-1] endtime] == 0) {
                            [[controlList9 get:[controlList9 count]-1] setEndtime:[mevent startTime]];
                            ctrecord9 = 0;
                        }
                    }
                }
                
                preTime9 = [mevent startTime];
                preValue9 = value;
            }
            
            if ([mevent controlNum] == 23) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preTime10 > 50 || preTime10 == -1) {
                    if (preValue10 == -1) {
                        preValue10 = value;
                        preTime10 = [mevent startTime];
                    }
                    
                    if (preValue10 >= 21 && preValue10 <=50) {
                        if (ctrecord10 != 1) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue10 andStarttime:preTime10 andEndtime:0];
                            [controlList10 add:data];
                            [data release];
                            ctrecord10 = 1;
                        }
                        
                    } else if (preValue10 > 51 && preValue10 <= 80) {
                        if (ctrecord10 != 2) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue10 andStarttime:preTime10 andEndtime:0];
                            [controlList10 add:data];
                            [data release];
                            ctrecord10 = 2;
                        }
                    } else if (preValue10 > 81 && preValue10 <= 127) {
                        if (ctrecord10 != 3) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue10 andStarttime:preTime10 andEndtime:0];
                            [controlList10 add:data];
                            [data release];
                            ctrecord10 = 3;
                        }
                    }
                }
                
                if (value < 20) {
                    if (ctrecord10 != 0) {
                        if ([controlList10 count] > 0 && [[controlList10 get:[controlList10 count]-1] endtime] == 0) {
                            [[controlList10 get:[controlList10 count]-1] setEndtime:[mevent startTime]];
                            ctrecord10 = 0;
                        }
                    }
                }
                
                preTime10 = [mevent startTime];
                preValue10 = value;
            }
            
            if ([mevent controlNum] == 24) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preStart11 > 50 || preStart11 == -1) {
                    if (preValue11 == -1) {
                        preValue11 = value;
                        preStart11 = [mevent startTime];
                    }
                    
                    if (preValue11 >= 10 && preValue11 <=64) {
                        if (ctrecord11 != 64) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue11 andStarttime:preStart11 andEndtime:0];
                            [controlList11 add:data];
                            [data release];
                            ctrecord11 = 64;
                        }
                        
                    } else if (preValue11 > 64 && preValue11 <= 127) {
                        if (ctrecord11 != 127) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue11 andStarttime:preStart11 andEndtime:0];
                            [controlList11 add:data];
                            [data release];
                            ctrecord11 = 127;
                        }
                    }
                }
                
                if (value < 10) {
                    if (ctrecord11 != 0) {
                        if ([controlList11 count] > 0 && [[controlList11 get:[controlList11 count]-1] endtime] == 0) {
                            [[controlList11 get:[controlList11 count]-1] setEndtime:[mevent startTime]];
                            ctrecord11 = 0;
                        }
                    }
                }
                
                preStart11 = [mevent startTime];
                preValue11 = value;
            }
            
            if ([mevent controlNum] == 25) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preStart12 > 50 || preStart12 == -1) {
                    if (preValue12 == -1) {
                        preValue12 = value;
                        preStart12 = [mevent startTime];
                    }
                    
                    if (preValue12 >= 10 && preValue12 <=64) {
                        if (ctrecord12 != 64) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue12 andStarttime:preStart12 andEndtime:0];
                            [controlList12 add:data];
                            [data release];
                            ctrecord12 = 64;
                        }
                        
                    } else if (preValue12 > 64 && preValue12 <= 127) {
                        if (ctrecord12 != 127) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue12 andStarttime:preStart12 andEndtime:0];
                            [controlList12 add:data];
                            [data release];
                            ctrecord12 = 127;
                        }
                    }
                }
                
                if (value < 10) {
                    if (ctrecord12 != 0) {
                        if ([controlList12 count] > 0 && [[controlList12 get:[controlList12 count]-1] endtime] == 0) {
                            [[controlList12 get:[controlList12 count]-1] setEndtime:[mevent startTime]];
                            ctrecord12 = 0;
                        }
                    }
                }
                
                preStart12 = [mevent startTime];
                preValue12 = value;
            }
            
            if ([mevent controlNum] == 26) {
                int value = [mevent controlValue];
                if (value < 20) {
                    if (ctrecord13 == 127) {
                        ControlData *cdata = [controlList13 get:[controlList13 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord13 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord13 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList13 add:data];
                        [data release];
                        ctrecord13 = 127;
                    }
                    
                }
            }
            
            if ([mevent controlNum] == 28) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord14 == 127) {
                        cdata = [controlList14 get:[controlList14 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord14 = 0;
                    } else if (ctrecord14 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList14 add:data];
                        [data release];
                        ctrecord14 = 127;
                    }
                }
//                if (value < 20) {
//                    if (ctrecord14 == 127) {
//                        cdata = [controlList14 get:[controlList14 count]-1];
//                        [cdata setEndtime:[mevent startTime]];
//                        ctrecord14 = 0;
//                    }
//                }
//                if (value > 110) {
//                    if (ctrecord14 == 0) {
//                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
//                        [controlList14 add:data];
//                        ctrecord14 = 127;
//                    }
//                    
//                }
            }
            
            if ([mevent controlNum] == 29) {
                int value = [mevent controlValue];
                
                if ([mevent startTime] - preStart15 > 50 || preStart15 == -1) {
                    if (preValue15 == -1) {
                        preValue15 = value;
                        preStart15 = [mevent startTime];
                    }
                    
                    if (preValue15 >= 21 && preValue15 <=50) {
                        if (ctrecord15 != 50) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue15 andStarttime:preStart15 andEndtime:0];
                            [controlList15 add:data];
                            [data release];
                            ctrecord15 = 50;
                        }
                        
                    } else if (preValue15 > 51 && preValue15 <= 80) {
                        if (ctrecord15 != 127) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue15 andStarttime:preStart15 andEndtime:0];
                            [controlList15 add:data];
                            [data release];
                            ctrecord15 = 127;
                        }
                    } else if (preValue15 > 81 && preValue15 <= 127) {
                        if (ctrecord15 != 127) {
                            ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:preValue15 andStarttime:preStart15 andEndtime:0];
                            [controlList15 add:data];
                            [data release];
                            ctrecord15 = 127;
                        }
                    }
                }
                
                if (value < 20) {
                    if (ctrecord15 != 0) {
                        if ([controlList15 count] > 0 && [[controlList15 get:[controlList15 count]-1] endtime] == 0) {
                            [[controlList15 get:[controlList15 count]-1] setEndtime:[mevent startTime]];
                            ctrecord15 = 0;
                        }
                    }
                }
                
                preStart15 = [mevent startTime];
                preValue15 = value;
            }
            if ([mevent controlNum] == 30) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord16 == 127) {
                        cdata = [controlList16 get:[controlList16 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord16 = 0;
                    } else if (ctrecord16 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList16 add:data];
                        [data release];
                        ctrecord16 = 127;
                    }
                }
            }
            
            if ([mevent controlNum] == 85) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord17 == 127) {
                        cdata = [controlList17 get:[controlList17 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord17 = 0;
                    } else if (ctrecord17 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList17 add:data];
                        [data release];
                        ctrecord17 = 127;
                    }
                }
            }
            
            if ([mevent controlNum] == 86) {
                int value = [mevent controlValue];
                ControlData *cdata;
                if (value == 127) {
                    if (ctrecord18 == 127) {
                        cdata = [controlList18 get:[controlList18 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord18 = 0;
                    } else if (ctrecord18 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList18 add:data];
                        [data release];
                        ctrecord18 = 127;
                    }
                }
            }
            
            if ([mevent controlNum] == 31) {
                int value = [mevent controlValue];
                if (value < 20) {
                    if (ctrecord19 == 127) {
                        ControlData *cdata = [controlList19 get:[controlList19 count]-1];
                        [cdata setEndtime:[mevent startTime]];
                        ctrecord19 = 0;
                    }
                }
                if (value > 110) {
                    if (ctrecord19 == 0) {
                        ControlData *data = [[ControlData alloc] initWithNumber:[mevent controlNum] andValue:value andStarttime:[mevent startTime] andEndtime:0];
                        [controlList19 add:data];
                        [data release];
                        ctrecord19 = 127;
                    }
                    
                }
            }

            /** add by sunlie end */
        }
        else if (eventflag >= EventProgramChange && 
                 eventflag < EventProgramChange + 16) {
            [mevent setEventFlag:EventProgramChange];
            [mevent setChannel:(u_char)(eventflag - EventProgramChange)];
            [mevent setInstrument:[file readByte]];
            
        }
        else if (eventflag >= EventChannelPressure && 
                 eventflag < EventChannelPressure + 16) {
            [mevent setEventFlag:EventChannelPressure];
            [mevent setChannel:(u_char)(eventflag - EventChannelPressure)];
            [mevent setChanPressure:[file readByte]];
        }
        else if (eventflag >= EventPitchBend && 
                 eventflag < EventPitchBend + 16) {
            [mevent setEventFlag:EventPitchBend];
            [mevent setChannel:(u_char)(eventflag - EventPitchBend)];
            [mevent setPitchBend:[file readShort]];
        }
        else if (eventflag == SysexEvent1) {
            [mevent setEventFlag:SysexEvent1];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];
        }
        else if (eventflag == SysexEvent2) {
            [mevent setEventFlag:SysexEvent2];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];
        }
        else if (eventflag == MetaEvent) {
            [mevent setEventFlag:MetaEvent];
            [mevent setMetaevent:[file readByte]];
            [mevent setMetalength:[file readVarlen]];
            [mevent setMetavalue:[file readBytes:[mevent metalength]] ];

            if ([mevent metaevent] == MetaEventTimeSignature) {
                if ([mevent metalength] < 2) {
                    MidiFileException *e = 
                    [MidiFileException init:@"Bad Meta Event Time Signature len" 
                      offset:[file offset]];
                    @throw e;
                }
                else if ([mevent metalength] >= 2 && [mevent metalength] < 4) {
                    [mevent setNumerator:[mevent metavalue][0] ];
                    u_char log2 = [mevent metavalue][1];
                    [mevent setDenominator:(int)pow(2, log2)];
                }
                else {
                    [mevent setNumerator:[mevent metavalue][0] ];
                    u_char log2 = [mevent metavalue][1];
                    [mevent setDenominator:(int)pow(2, log2)];
                }
            }
            else if ([mevent metaevent] == MetaEventTempo) {
                if ([mevent metalength] != 3) {
                    MidiFileException *e = 
                    [MidiFileException init:@"Bad Meta Event Tempo len" 
                      offset:[file offset]];
                    @throw e;
                }
                u_char *value = [mevent metavalue];
                [mevent setTempo:((value[0] << 16) | (value[1] << 8) | value[2])];
            }
            else if ([mevent metaevent] == MetaEventEndOfTrack) {
                [mevent release];
                break; 
            }
        }
        else {
            /* printf("Unknown eventflag %d offset %d\n", eventflag, [file offset]); */
            MidiFileException *e =
                [MidiFileException init:@"Unknown event" offset:([file offset] -4)];
            @throw e;
        }
        [mevent release];
    }
    
    /** add by sunlie start */
    if ([controlList8 count] > 0 && [[controlList8 get:[controlList8 count]-1] endtime] == 0) {
        [[controlList8 get:[controlList8 count]-1] setEndtime:preTime8];
        [[controlList8 get:[controlList8 count]-1] setCValue:ctrecord8];
    }
    /** add by sunlie end */

    return result;
}


/** Return true if this track contains multiple channels.
 * If a MidiFile contains only one track, and it has multiple channels,
 * then we treat each channel as a separate track.
 */
+(BOOL) hasMultipleChannels:(MidiTrack*) track {
    Array *notes = [track notes];
    int channel = [(MidiNote*)[notes get:0] channel];
    for (int i =0; i < [notes count]; i++) {
        MidiNote *note = [notes get:i];
        if ([note channel] != channel) {
            return true;
        }
    }
    return false;
}


/** Calculate the track length (in bytes) given a list of Midi events */
+(int)getTrackLength:(Array*)events {
    int len = 0;
    u_char buf[1024];
    for (int i = 0; i < [events count]; i++) {
        MidiEvent *mevent = [events get:i];
        len += varlenToBytes([mevent deltaTime], buf, 0);
        len += 1;  /* for eventflag */
        switch ([mevent eventFlag]) {
            case EventNoteOn: len += 2; break;
            case EventNoteOff: len += 2; break;
            case EventKeyPressure: len += 2; break;
            case EventControlChange: len += 2; break;
            case EventProgramChange: len += 1; break;
            case EventChannelPressure: len += 1; break;
            case EventPitchBend: len += 2; break;

            case SysexEvent1:
            case SysexEvent2:
                len += varlenToBytes([mevent metalength], buf, 0);
                len += [mevent metalength];
                break;
            case MetaEvent:
                len += 1;
                len += varlenToBytes([mevent metalength], buf, 0);
                len += [mevent metalength];
                break;
            default: break;
        }
    }
    return len;
}

/** Write the given list of Midi events into a valid Midi file. This
 *  method is used for sound playback, for creating new Midi files
 *  with the tempo, transpose, etc changed.
 *
 *  Return true on success, and false on error.
 */
+(BOOL)writeToFile:(NSString*)filename withEvents:(Array*)eventlists
           andMode:(int)trackmode andQuarter:(int)quarter andMidifile:(MidiFile *)midifile andMidiOptions:(MidiOptions *)options withPulsesPerMsec:(double)timeDifference withFileType:(int)type{//modify by yizhq
    u_char buf[4096];
    const char *cfilename;
    int file, error;

    cfilename = [filename cStringUsingEncoding:NSUTF8StringEncoding];
    file = open(cfilename, O_CREAT|O_TRUNC|O_WRONLY, 0644);
    if (file < 0) {
        return NO;
    }

    error = 0;
    /* Write the MThd, len = 6, track mode, number tracks, quarter note */
    dowrite(file, (u_char*)"MThd", 4, &error);
    intToBytes(6, buf, 0);
    dowrite(file, buf, 4, &error);
    buf[0] = (u_char)(trackmode >> 8);
    buf[1] = (u_char)(trackmode & 0xFF);
    dowrite(file, buf, 2, &error);
    buf[0] = 0;
    buf[1] = (u_char)[eventlists count] + 1;//modify by yizhq
    dowrite(file, buf, 2, &error);
    buf[0] = (u_char)(quarter >> 8);
    buf[1] = (u_char)(quarter & 0xFF);
    dowrite(file, buf, 2, &error);

        for (int tracknum = 0; tracknum < [eventlists count]; tracknum++) {
            Array *events = [eventlists get:tracknum];
            
            /* Write the MTrk header and track length */
            dowrite(file, (u_char*)"MTrk", 4, &error);
            int len = [MidiFile getTrackLength:events];
            intToBytes(len, buf, 0);
            dowrite(file, buf, 4, &error);
            
            for (int i = 0; i < [events count]; i++) {
                MidiEvent *mevent = [events get:i];
                int varlen = varlenToBytes([mevent deltaTime], buf, 0);
                dowrite(file, buf, varlen, &error);
                
                if ([mevent eventFlag] == SysexEvent1 ||
                    [mevent eventFlag] == SysexEvent2 ||
                    [mevent eventFlag] == MetaEvent) {
                    buf[0] = [mevent eventFlag];
                }
                else {
                    buf[0] = (u_char)([mevent eventFlag] + [mevent channel]);
                }
                dowrite(file, buf, 1, &error);
                
                if ([mevent eventFlag] == EventNoteOn) {
                    buf[0] = [mevent notenumber];
                    buf[1] = [mevent velocity];
                    dowrite(file, buf, 2, &error);
                }
                else if ([mevent eventFlag] == EventNoteOff) {
                    buf[0] = [mevent notenumber];
                    buf[1] = [mevent velocity];
                    dowrite(file, buf, 2, &error);
                }
                else if ([mevent eventFlag] == EventKeyPressure) {
                    buf[0] = [mevent notenumber];
                    buf[1] = [mevent keyPressure];
                    dowrite(file, buf, 2, &error);
                }
                else if ([mevent eventFlag] == EventControlChange) {
                    buf[0] = [mevent controlNum];
                    buf[1] = [mevent controlValue];
                    dowrite(file, buf, 2, &error);
                }
                else if ([mevent eventFlag] == EventProgramChange) {
                    buf[0] = [mevent instrument];
                    dowrite(file, buf, 1, &error);
                }
                else if ([mevent eventFlag] == EventChannelPressure) {
                    buf[0] = [mevent chanPressure];
                    dowrite(file, buf, 1, &error);
                }
                else if ([mevent eventFlag] == EventPitchBend) {
                    buf[0] = (u_char)([mevent pitchBend] >> 8);
                    buf[1] = (u_char)([mevent pitchBend] & 0xFF);
                    dowrite(file, buf, 2, &error);
                }
                else if ([mevent eventFlag] == SysexEvent1) {
                    int offset = varlenToBytes([mevent metalength], buf, 0);
                    memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                    dowrite(file, buf, offset + [mevent metalength], &error);
                }
                else if ([mevent eventFlag] == SysexEvent2) {
                    int offset = varlenToBytes([mevent metalength], buf, 0);
                    memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                    dowrite(file, buf, offset + [mevent metalength], &error);
                }
                else if ([mevent eventFlag] == MetaEvent &&
                         [mevent metaevent] == MetaEventTempo) {
                    buf[0] = [mevent metaevent];
                    buf[1] = 3;
                    buf[2] = (u_char)(([mevent tempo] >> 16) & 0xFF);
                    buf[3] = (u_char)(([mevent tempo] >> 8) & 0xFF);
                    buf[4] = (u_char)([mevent tempo] & 0xFF);
                    dowrite(file, buf, 5, &error);
                }
                else if ([mevent eventFlag] == MetaEvent) {
                    buf[0] = [mevent metaevent];
                    int offset = varlenToBytes([mevent metalength], buf, 1) + 1;
                    memcpy(&(buf[offset]), [mevent metavalue], [mevent metalength]);
                    dowrite(file, buf, offset + [mevent metalength], &error);
                }
            }
        }
    
    /** add by yizhq for tempo track start */
    int dataLen, bFlag, tmpQuarternote;
    dowrite(file, (u_char*)"MTrk", 4, &error);
    
    if ([midifile quarternote]/128 <= 0) {
        bFlag = 6;
    }else{
        bFlag = 7;
    }
    dataLen = (bFlag + 5) * ceil([midifile totalpulses]/[midifile quarternote]);
//    NSLog(@"dataLen is %i totalpulses is %i quarternote is %i", dataLen, [midifile totalpulses], [midifile quarternote]);
    intToBytes(dataLen, buf, 0);
    dowrite(file, buf, 4, &error);
    
    for(int sectionnum = 0; sectionnum < dataLen/bFlag + 5; sectionnum++)
    {
        buf[0] = 0x00;

        if(sectionnum == 0)
            buf[1] = 0x99;
        else
            buf[1] = 0x00;
        
        buf[2] = 0x60;
        //set tempo mute
        if ([midifile getTempoMuteState] == -1 ) {
            buf[3] = 0x00;
        }else{
            buf[3] = 0x7F;
        }
//        if (sectionnum == 0) {
//            buf[3] = 0x00;
//        }
        TimeSignature *sTime = [midifile time];
        
        if (sTime.denominator == 4) {
            tmpQuarternote = [midifile quarternote];
        }else if (sTime.denominator == 8){
            tmpQuarternote = [midifile quarternote]/2;
        }else if(sTime.denominator == 2){
            tmpQuarternote = [midifile quarternote]*2;
        }
        
        if (bFlag == 6) {
            int tmp = tmpQuarternote%128;
            if (sectionnum == 0) {
                tmp = tmpQuarternote + timeDifference;
            }else{
                tmp = tmpQuarternote;
            }
            buf[4] = tmp;
            buf[5] = 0x4B;
        }else{
            int tmp1;
            int tmp2;
            if (sectionnum == 0) {
                int tmp = ceil(tmpQuarternote + timeDifference);
                tmp1 = tmp/128;
                tmp2 = tmp%128;
            }else{
                tmp1 = tmpQuarternote/128;
                tmp2 = tmpQuarternote%128;
            }
            buf[4] = tmp1 + 128;
            buf[5] = tmp2;
            buf[6] = 0x4B;
        }
        
        dowrite(file, buf, bFlag, &error);
    }
    
	buf[0] = 0x00;
	buf[1] = 0x00;
	buf[2] = 0xFF;
	buf[3] = 0x2F;
	buf[4] = 0x00;
	dowrite(file, buf, 5, &error);
    /** add by yizhq for tempo track end */
    
    close(file);
    if (error)
        return NO;
    else
        return YES;
}

/** Clone the list of MidiEvents */
+(Array*)cloneMidiEvents:(Array*)origlist {
    Array *newlist = [Array new:[origlist count]];
    for (int tracknum = 0; tracknum < [origlist count]; tracknum++) {
        Array *origevents = [origlist get:tracknum];
        Array *newevents = [Array new:[origevents count]];
        [newlist add:newevents];
        for (int i = 0; i < [origevents count]; i++) {
            MidiEvent *mevent = [origevents get:i];
            MidiEvent *eventcopy = [mevent copy];
            [newevents add:eventcopy];
            [eventcopy release];
        }
        [newevents release];
    }
    return newlist;
}


/** Add a tempo event to the beginning of each track */
+(void) addTempoEvent:(Array*)eventlist withTempo:(int)tempo {
    for (int tracknum = 0; tracknum < [eventlist count]; tracknum++) {

        /* Create a new tempo event */
        MidiEvent *tempoEvent = [[MidiEvent alloc] init];
        [tempoEvent setDeltaTime:0];
        [tempoEvent setStartTime:0];
        [tempoEvent setHasEventflag:YES];
        [tempoEvent setEventFlag:MetaEvent];
        [tempoEvent setMetaevent:MetaEventTempo];
        [tempoEvent setMetalength:3];
        [tempoEvent setTempo:tempo];

        /* Insert the event at the beginning of the events array */
        Array *events = [eventlist get:tracknum];
        [events add:tempoEvent];
        for (int i = [events count]-2; i >= 0; i--) {
            MidiEvent *event = [events get:i];
            [events set:event index:i+1];
        }
        [events set:tempoEvent index:0];
        [tempoEvent release];
    }
}

/** Search the events for a ControlChange event with the same
 *  channel and control number.  If a matching event is found,
 *   update the control value.  Else, add a new ControlChange event.
 */
+(void)updateControlChange:(Array*)newevents withEvent:(MidiEvent*)changeEvent {
    for (int i = 0; i < [newevents count]; i++) {
        MidiEvent *mevent = [newevents get:i];
        if (([mevent eventFlag] == [changeEvent eventFlag]) &&
            ([mevent channel] == [changeEvent channel]) &&
            ([mevent controlNum] == [changeEvent controlNum])) {

             [mevent setControlValue: [changeEvent controlValue]];
             return;
        }
    }
    [newevents add:changeEvent];
}


/** Start the Midi music at the given pause time (in pulses).
 *  Remove any NoteOn/NoteOff events that occur before the pause time.
 *  For other events, change the delta-time to 0 if they occur
 *  before the pause time.  Return the modified Midi Events.
 */
+(Array*)startAtPauseTime:(int)pauseTime withEvents:(Array*)list {
    Array *newlist = [Array new:[list count]];
    for (int tracknum = 0; tracknum < [list count]; tracknum++) {
        Array *events = [list get:tracknum];
        Array *newevents = [Array new:[events count]];
        [newlist add:newevents];

        BOOL foundEventAfterPause = NO;
        for (int i = 0; i < [events count]; i++) {
            MidiEvent *mevent = [events get:i];

            if ([mevent startTime] < pauseTime) {
                if ([mevent eventFlag] == EventNoteOn ||
                    [mevent eventFlag] == EventNoteOff) {

                    /* Skip NoteOn/NoteOff event */
                }
                else if ([mevent eventFlag] == EventControlChange) {
                    [mevent setDeltaTime:0];
                    [MidiFile updateControlChange:newevents withEvent:mevent];
                }
                else {
                    [mevent setDeltaTime:0];
                    [newevents add:mevent];
                }
            }
            else if (!foundEventAfterPause) {
                [mevent setDeltaTime:([mevent startTime] - pauseTime)];
                
                [newevents add:mevent];
                foundEventAfterPause = YES;
            }
            else {
                [newevents add:mevent];
            }
        }
        [newevents release];
    }
    return newlist;
}


/** Write this Midi file to the given filename.
 * If options is not null, apply those options to the midi events
 * before performing the write.
 * Return true if the file was saved successfully, else false.
 */
/** modify by yizhq start */
//- (BOOL)changeSound:(MidiOptions *)options toFile:(NSString*)destfile {
//    Array* newevents = events;
//    if (options != NULL) {
//        newevents = [self applyOptionsToEvents: options];
//    }
//    BOOL ret = [MidiFile writeToFile:destfile withEvents:newevents
//                     andMode:trackmode andQuarter:quarternote];
//    if (newevents != events) {
//        [newevents release];
//    }
//    return ret;
//}

- (BOOL)changeSound:(MidiOptions *)options oldMidi:(MidiFile *)midifile toFile:(NSString*)destfile secValue:(double)timeDifference andSpeed:(BOOL)isSpeed{
    BOOL ret = NO;
    Array* newevents = events;
    if (options != NULL) {
        newevents = [self applyOptionsToEvents: options andSpeed:isSpeed];
    }


    ret = [MidiFile writeToFile:destfile withEvents:newevents
                                       andMode:trackmode andQuarter:quarternote andMidifile:midifile andMidiOptions:options withPulsesPerMsec:timeDifference withFileType:0];
    if (newevents != events) {
        [newevents release];
    }

    return ret;
}

- (BOOL)changeSoundForTempo:(MidiOptions *)options oldMidi:(MidiFile *)midifile toFile:(NSString*)destfile secValue:(double)timeDifference andSpeed:(BOOL)isSpeed{
    BOOL ret = NO;

    int leftMuteState,rightMuteState, tmpTempoMuteState;
    if ([tracks count] == 1) {
        rightMuteState = [options->mute get:0];
        [options->mute set:-1 index:0];
    }else{
        leftMuteState = [options->mute get:1];
        rightMuteState = [options->mute get:0];
        [options->mute set:-1 index:0];
        [options->mute set:-1 index:1];
    }

    tmpTempoMuteState = tempoMuteState;
    tempoMuteState = 0;
    
    Array* newevents = events;
    if (options != NULL) {
        newevents = [self applyOptionsToEvents: options andSpeed:isSpeed];
    }

    ret = [MidiFile writeToFile:destfile withEvents:newevents
                        andMode:trackmode andQuarter:quarternote andMidifile:midifile andMidiOptions:options withPulsesPerMsec:timeDifference withFileType:1];

    if (newevents != events) {
        [newevents release];
    }
    
    if ([tracks count] == 1) {
        [options->mute set:rightMuteState index:0];
    }else{
        [options->mute set:leftMuteState index:1];
        [options->mute set:rightMuteState index:0];
    }
 
    tempoMuteState = tmpTempoMuteState;
    return ret;
}
/** modify by yizhq end */


/** Apply the following sound options to the midi events.
 * - The tempo (the microseconds per pulse)
 * - The instruments per track
 * - The note number (transpose value)
 * - The tracks to include
 * Save the modified midi data to the given filename.
 * Return true if the file was saved successfully, else false.
 */
- (Array*)applyOptionsToEvents:(MidiOptions *)options andSpeed:(BOOL)isSpeed {
    if (trackPerChannel) {
        return [self applyOptionsPerChannel:options];
    }

    /* A midifile can contain tracks with notes and tracks without notes.
     * The options.tracks and options.instruments are for tracks with notes.
     * So the track numbers in 'options' may not match correctly if the
     * midi file has tracks without notes. Re-compute the instruments, and
     * tracks to keep.
     */
    int num_tracks = [events count];
    IntArray *instruments = [IntArray new:num_tracks];
    IntArray *keeptracks  = [IntArray new:num_tracks];

    for (int i = 0; i < num_tracks; i++) {
        [instruments add:0];
        [keeptracks add:YES];
    }
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int realtrack = [track number];
        [instruments set:[options->instruments get:tracknum] index:realtrack ];
        if ([options->tracks get:tracknum] == NO || [options->mute get:tracknum]) {
            [keeptracks set:NO index:realtrack];
        }
    }

    Array *newevents = [MidiFile cloneMidiEvents:events];
    if (isSpeed) {
        [MidiFile addTempoEvent:newevents withTempo:options->tempo];
    }

    /* Change the note number (transpose), instrument, and tempo */
    for (int tracknum = 0; tracknum < [newevents count]; tracknum++) {
        Array *eventlist = [newevents get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            int num = [mevent notenumber] + options->transpose;
            if (num < 0)
                num = 0;
            if (num > 127)
                num = 127;
            [mevent setNotenumber:(u_char)num];
            if (!options->useDefaultInstruments) {
                [mevent setInstrument:(u_char)[instruments get:tracknum] ];
            }
            if (isSpeed) {
                [mevent setTempo:options->tempo];
            }
        }
    }

    if (options->pauseTime != 0) {
        Array *oldevents = newevents;
        newevents = [MidiFile startAtPauseTime:options->pauseTime withEvents:oldevents]; 
        [oldevents release];
    }

    /* Change the tracks to include */
    int count = 0;
    for (int tracknum = 0; tracknum < [keeptracks count]; tracknum++) {
         if ([keeptracks get:tracknum]) {
             count++;
         }
    }

    Array *result = [Array new:count];
    for (int tracknum = 0; tracknum < [keeptracks count]; tracknum++) {
        if ([keeptracks get:tracknum]) {
            [result add:[newevents get:tracknum]];
        }
    }
    [newevents release];
    [keeptracks release];
    [instruments release];
    return result;
}


/** Apply the following sound options to the midi events:
 * - The tempo (the microseconds per pulse)
 * - The instruments per track
 * - The note number (transpose value)
 * - The tracks to include
 * Return the modified list of midi events.
 *
 * This Midi file only has one actual track, but we've split that
 * into multiple fake tracks, one per channel, and displayed that
 * to the end-user.  So changing the instrument, and tracks to
 * include, is implemented differently than the applyOptions() method:
 *
 * - We change the instrument based on the channel, not the track.
 * - We include/exclude channels, not tracks.
 * - We exclude a channel by setting the note volume/velocity to 0.
 */
- (Array*)applyOptionsPerChannel:(MidiOptions *)options {
    /* Determine which channels to include/exclude.
     * Also, determine the instrument for each channel.
     */
    IntArray *instruments = [IntArray new:16];
    IntArray *keepchannel  = [IntArray new:16];

    for (int i = 0; i < 16; i++) {
        [instruments add:0];
        [keepchannel add:YES];
    }
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *note = [[track notes] get:0];
        int channel = [note channel];
        [instruments set:[options->instruments get:tracknum] index:channel ];
        if ([options->tracks get:tracknum] == NO || [options->mute get:tracknum]) {
            [keepchannel set:NO index:channel];
        }
    }

    Array *newevents = [MidiFile cloneMidiEvents:events];
    [MidiFile addTempoEvent:newevents withTempo:options->tempo];

    /* Change the note number (transpose), instrument, and tempo */
    for (int tracknum = 0; tracknum < [newevents count]; tracknum++) {
        Array *eventlist = [newevents get:tracknum];
        for (int i = 0; i < [eventlist count]; i++) {
            MidiEvent *mevent = [eventlist get:i];
            int num = [mevent notenumber] + options->transpose;
            if (num < 0)
                num = 0;
            if (num > 127)
                num = 127;
            [mevent setNotenumber:(u_char)num];
            int channel = [mevent channel];
            if (![keepchannel get:channel]) {
                [mevent setVelocity:0];
            }
            if (!options->useDefaultInstruments) {
                u_char instr = [instruments get:channel];
                [mevent setInstrument:instr];
            }
            [mevent setTempo:options->tempo];
        }
    }
    if (options->pauseTime != 0) {
        Array *oldevents = newevents;
        newevents = [MidiFile startAtPauseTime:options->pauseTime withEvents:oldevents];
        [oldevents release];
    }
    [instruments release];
    [keepchannel release];
    return newevents;
}



/** Apply the given sheet music options to the MidiNotes.
 *  Return the midi tracks with the changes applied.
 */
- (Array*)changeMidiNotes:(MidiOptions*)options {
    Array *old;
    Array* newtracks = [Array new:10];

    for (int track = 0; track < [tracks count]; track++) {
        if ([options->tracks get:track]) {
            MidiTrack *t = [tracks get:track];
            MidiTrack *copy = [t copy];
            [newtracks add:copy];
            [copy release];
        }
    }

    /* To make the sheet music look nicer, we round the start times
     * so that notes close together appear as a single chord.  We
     * also extend the note durations, so that we have longer notes
     * and fewer rest symbols.
     */
    TimeSignature *time = [self time];
    if (options->time != nil) {
        time = options->time;
    }

    [MidiFile roundStartTimes:newtracks toInterval:options->combineInterval withTime:[self time]];
    [MidiFile roundDurations:newtracks withQuarter:[time quarter]];

    if (options->twoStaffs) {
        old = newtracks;
        newtracks = [MidiFile combineToTwoTracks:newtracks withMeasure:[time measure]];
        [old release];
    }
    if (options->shifttime != 0) {
        [MidiFile shiftTime:newtracks byAmount:options->shifttime];
    }

    if (options->transpose != 0) {
        [MidiFile transpose:newtracks byAmount:options->transpose];
    }

    return newtracks;
}


/** Shift the starttime of the notes by the given amount.
 * This is used by the Shift Notes menu to shift notes left/right.
 */
+(void)shiftTime:(Array*)tracks byAmount:(int) amount {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [note setStarttime:([note startTime] + amount)];
        }
    }
}

/* Shift the note keys up/down by the given amount */
+(void)transpose:(Array*) tracks byAmount:(int) amount {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [note setNumber:([note number] + amount)];
            if ([note number] < 0) {
                [note setNumber:0];
            }
        }
    }
}


/* Find the highest and lowest notes that overlap this interval (starttime to endtime).
 * This method is used by splitTrack to determine which staff (top or bottom) a note
 * should go to.
 *
 * For more accurate splitTrack() results, we limit the interval/duration of this note
 * (and other notes) to one measure. We care only about high/low notes that are
 * reasonably close to this note.
 */

+(void)findHighLowNotes:(Array*)notes withMeasure:(int)measurelen startIndex:(int)startindex
                        fromStart:(int)starttime toEnd:(int)endtime withHigh:(int*)high
                        andLow:(int*)low {

    int i = startindex;
    if (starttime + measurelen < endtime) {
        endtime = starttime + measurelen;
    }

    while (i < [notes count]) {
        MidiNote *note = [notes get:i];
        if ([note startTime] >= endtime) {
            break;
        }
        if ([note endTime] < starttime) {
            i++;
            continue;
        }
        if ([note startTime] + measurelen < starttime) {
            i++;
            continue;
        }
        if (*high < [note number]) {
            *high = [note number];
        }
        if (*low > [note number]) {
            *low = [note number];
        }
        i++;
    }
}

/* Find the highest and lowest notes that start at this exact start time */
+(void)findExactHighLowNotes:(Array*)notes startIndex:(int)startindex
                        withStart:(int)starttime withHigh:(int*)high
                        andLow:(int*)low {

    int i = startindex;

    while ([(MidiNote*)[notes get:i] startTime] < starttime) {
        i++;
    }

    while (i < [notes count]) {
        MidiNote *note = [notes get:i];
        if ([note startTime] != starttime) {
            break;
        }
        if (*high < [note number]) {
            *high = [note number];
        }
        if (*low > [note number]) {
            *low = [note number];
        }
        i++;
    }
}


/* Split the given MidiTrack into two tracks, top and bottom.
 * The highest notes will go into top, the lowest into bottom.
 * This function is used to split piano songs into left-hand (bottom)
 * and right-hand (top) tracks.
 */
+(Array*)splitTrack:(MidiTrack*) track withMeasure:(int)measurelen{
    Array *notes = [track notes];
    int notes_count = [notes count];
    
    MidiTrack *top = [[MidiTrack alloc] initWithTrack:1];
    MidiTrack *bottom = [[MidiTrack alloc] initWithTrack:2];
    [top setTotalpulses:[track totalpulses]];//add by yizhq
    [bottom setTotalpulses:[track totalpulses]];//add by yizhq
    Array* result = [Array new:2];
    [result add:top];
    [result add:bottom];

    if (notes_count == 0)
        return result;
    
    /** add by sunlie start */
    if (notes_count > 0) {
        //modify start by sunl 20150331
        if ([[track controlList] count ] > 0) {
            if([track number] == 1){
                [top setControlList:[track controlList]];
            }else{
                [bottom setControlList:[track controlList]];
            }
        }
        
        if ([[track controlList2] count ] > 0) {
            if([track number] == 1){
                [top setControlList2:[track controlList2]];
            }else{
                [bottom setControlList2:[track controlList2]];
            }
        }
        
        if ([[track controlList3] count ] > 0) {
            if([track number] == 1){
                [top setControlList3:[track controlList3]];
            }else{
                [bottom setControlList3:[track controlList3]];
            }
        }
        
        if ([[track controlList4] count ] > 0) {
            if([track number] == 1){
                [top setControlList4:[track controlList4]];
            }else{
                [bottom setControlList4:[track controlList4]];
            }
        }
        if ([[track controlList5] count ] > 0) {
            if([track number] == 1){
                [top setControlList5:[track controlList5]];
            }else{
                [bottom setControlList5:[track controlList5]];
            }
        }
        if ([[track controlList6] count ] > 0) {
            if([track number] == 1){
                [top setControlList6:[track controlList6]];
            }else{
                [bottom setControlList6:[track controlList6]];
            }
        }
        if ([[track controlList7] count ] > 0) {
            if([track number] == 1){
                [top setControlList7:[track controlList7]];
            }else{
                [bottom setControlList7:[track controlList7]];
            }
        }
        if ([[track controlList8] count ] > 0) {
            if([track number] == 1){
                [top setControlList8:[track controlList8]];
            }else{
                [bottom setControlList8:[track controlList8]];
            }
        }
        if ([[track controlList9] count ] > 0) {
            if([track number] == 1){
                [top setControlList9:[track controlList9]];
            }else{
                [bottom setControlList9:[track controlList9]];
            }
        }
        if ([[track controlList10] count ] > 0) {
            if([track number] == 1){
                [top setControlList10:[track controlList10]];
            }else{
                [bottom setControlList10:[track controlList10]];
            }
        }
        if ([[track controlList11] count ] > 0) {
            if([track number] == 1){
                [top setControlList11:[track controlList11]];
            }else{
                [bottom setControlList11:[track controlList11]];
            }
        }
        if ([[track controlList12] count ] > 0) {
            if([track number] == 1){
                [top setControlList12:[track controlList12]];
            }else{
                [bottom setControlList12:[track controlList12]];
            }
        }
        if ([[track controlList13] count ] > 0) {
            if([track number] == 1){
                [top setControlList13:[track controlList13]];
            }else{
                [bottom setControlList13:[track controlList13]];
            }
        }
        if ([[track controlList14] count ] > 0) {
            if([track number] == 1){
                [top setControlList14:[track controlList14]];
            }else{
                [bottom setControlList14:[track controlList14]];
            }
        }
        if ([[track controlList15] count ] > 0) {
            if([track number] == 1){
                [top setControlList15:[track controlList15]];
            }else{
                [bottom setControlList15:[track controlList15]];
            }
        }
        if ([[track controlList16] count ] > 0) {
            if([track number] == 1){
                [top setControlList16:[track controlList16]];
            }else{
                [bottom setControlList16:[track controlList16]];
            }
        }
        if ([[track controlList17] count ] > 0) {
            if([track number] == 1){
                [top setControlList17:[track controlList17]];
            }else{
                [bottom setControlList17:[track controlList17]];
            }
        }
        if ([[track controlList18] count ] > 0) {
            if([track number] == 1){
                [top setControlList18:[track controlList18]];
            }else{
                [bottom setControlList18:[track controlList18]];
            }
        }
        if ([[track controlList19] count ] > 0) {
            if([track number] == 1){
                [top setControlList19:[track controlList19]];
            }else{
                [bottom setControlList19:[track controlList19]];
            }
        }
        //modify end by sunl  20150331

    }
    /** add by sunlie end */

    int prevhigh  = 76; /* E5, top of treble staff */
    int prevlow   = 45; /* A3, bottom of bass staff */
    int startindex = 0;

    for (int i = 0; i < notes_count; i++) {
        MidiNote *note = [notes get:i];
        int number = [note number];

        int high, low, highExact, lowExact;
        high = low = highExact = lowExact = number;

        while ([(MidiNote*)[notes get:startindex] endTime] < [note startTime]) {
            startindex++;
        }

        /* I've tried several algorithms for splitting a track in two,
         * and the one below seems to work the best:
         * - If this note is more than an octave from the high/low notes
         *   (that start exactly at this start time), choose the closest one.
         * - If this note is more than an octave from the high/low notes
         *   (in this note's time duration), choose the closest one.
         * - If the high and low notes (that start exactly at this starttime)
         *   are more than an octave apart, choose the closest note.
         * - If the high and low notes (that overlap this starttime)
         *   are more than an octave apart, choose the closest note.
         * - Else, look at the previous high/low notes that were more than an
         *   octave apart.  Choose the closeset note.
         */
        [MidiFile findHighLowNotes:notes withMeasure:measurelen startIndex:startindex
                  fromStart:[note startTime] toEnd:[note endTime]
                  withHigh:&high andLow:&low];
        [MidiFile findExactHighLowNotes:notes startIndex:startindex withStart:[note startTime]
                  withHigh:&highExact andLow:&lowExact];

        if([track number] == 1){
            [top addNote:note];
        }else{
            [bottom addNote:note];
        }
        
//        if (highExact - number > 12 || number - lowExact > 12) {
//            if (highExact - number <= number - lowExact) {
//                [top addNote:note];
//            }
//            else {
//                [bottom addNote:note];
//            }
//        }
//        else if (high - number > 12 || number - low > 12) {
//            if (high - number <= number - low) {
//                [top addNote:note];
//            }
//            else {
//                [bottom addNote:note];
//            }
//        }
//        else if (highExact - lowExact > 12) {
//            if (highExact - number <= number - lowExact) {
//                [top addNote:note];
//            }
//            else {
//                [bottom addNote:note];
//            }
//        }
//        else if (high - low > 12) {
//            if (high - number <= number - low) {
//                [top addNote:note];
//            }
//            else {
//                [bottom addNote:note];
//            }
//        }
//        else {
//            if (prevhigh - number <= number - prevlow) {
//                [top addNote:note];
//            }
//            else {
//                [bottom addNote:note];
//            }
//        }

        /* The prevhigh/prevlow are set to the last high/low
         * that are more than an octave apart.
         */
        if (high - low > 12) {
            prevhigh = high;
            prevlow = low;
        }
    }

    [[top notes] sort:sortbytime];
    [[bottom notes] sort:sortbytime];

    [top release];
    [bottom release];
    return result;
}



/** Combine the notes in the given tracks into a single MidiTrack.
 *  The individual tracks are already sorted.  To merge them, we
 *  use a mergesort-like algorithm.
 */
+(MidiTrack*) combineToSingleTrack:(Array*)tracks {
    /* Add all notes into one track */
    MidiTrack *result = [[MidiTrack alloc] initWithTrack:1];

    if ([tracks count] == 0) {
        return result;
    }
    else if ([tracks count] == 1) {
        MidiTrack *track = [tracks get:0];
        [result setTotalpulses:[track totalpulses]];//add by yizhq
        [result setNumber:[track number]];
        for (int i = 0; i < [[track notes] count]; i++) {
            [result addNote:[[track notes] get:i] ];
        }
        /** add by sunlie start */
        if ([[result notes] count] > 0) {
            if ([[track controlList] count ] > 0) {
                [result setControlList:[track controlList]];
            }
            
            if ([[track controlList2] count ] > 0) {
                [result setControlList2:[track controlList2]];
            }
            
            if ([[track controlList3] count ] > 0) {
                [result setControlList3:[track controlList3]];
            }
            
            if ([[track controlList4] count ] > 0) {
                [result setControlList4:[track controlList4]];
            }
            if ([[track controlList5] count ] > 0) {
                [result setControlList5:[track controlList5]];
            }
            if ([[track controlList6] count ] > 0) {
                [result setControlList6:[track controlList6]];
            }
            if ([[track controlList7] count ] > 0) {
                [result setControlList7:[track controlList7]];
            }
            if ([[track controlList8] count ] > 0) {
                [result setControlList8:[track controlList8]];
            }
            if ([[track controlList9] count ] > 0) {
                [result setControlList9:[track controlList9]];
            }
            if ([[track controlList10] count ] > 0) {
                [result setControlList10:[track controlList10]];
            }
            if ([[track controlList11] count ] > 0) {
                [result setControlList11:[track controlList11]];
            }
            if ([[track controlList12] count ] > 0) {
                [result setControlList12:[track controlList12]];
            }
            if ([[track controlList13] count ] > 0) {
                [result setControlList13:[track controlList13]];
            }
            if ([[track controlList14] count ] > 0) {
                [result setControlList14:[track controlList14]];
            }
            if ([[track controlList15] count ] > 0) {
                [result setControlList15:[track controlList15]];
            }
            if ([[track controlList16] count ] > 0) {
                [result setControlList16:[track controlList16]];
            }
            if ([[track controlList17] count ] > 0) {
                [result setControlList17:[track controlList17]];
            }
            if ([[track controlList18] count ] > 0) {
                [result setControlList18:[track controlList18]];
            }
            if ([[track controlList19] count ] > 0) {
                [result setControlList19:[track controlList19]];
            }
        }
        /** add by sunlie end */
        return result;
    }

    int noteindex[64];
    int notecount[64];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        noteindex[tracknum] = 0;
        notecount[tracknum] = [[track notes] count];
    }

    MidiNote *prevnote = nil;
    while (1) {
        MidiNote *lowestnote = nil;
        int lowestTrack = -1;
        for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
            MidiTrack *track = [tracks get:tracknum];
            if (noteindex[tracknum] >= notecount[tracknum]) {
                continue;
            }
            MidiNote *note = [[track notes] get:noteindex[tracknum]];
            if (lowestnote == nil) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
            else if ([note startTime] < [lowestnote startTime]) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
            else if ([note startTime] == [lowestnote startTime] &&
                     [note number] < [lowestnote number]) {
                lowestnote = note;
                lowestTrack = tracknum;
            }
        }
        if (lowestnote == nil) {
            /* We've finished the merge */
            break;
        }
        noteindex[lowestTrack]++;
        if ((prevnote != nil) && ([prevnote startTime] == [lowestnote startTime]) &&
            ([prevnote number] == [lowestnote number]) ) {

            /* Don't add duplicate notes, with the same start time and number */
            if ([lowestnote duration] > [prevnote duration]) {
                [prevnote setDuration:[lowestnote duration]];
            }
        }
        else {
            [result addNote:lowestnote];
            prevnote = lowestnote;
        }
    }

    return result;
}


/** Combine the notes in all the tracks given into two MidiTracks,
 * and return them.
 * 
 * This function is intended for piano songs, when we want to display
 * a left-hand track and a right-hand track.  The lower notes go into 
 * the left-hand track, and the higher notes go into the right hand 
 * track.
 */
+(Array*) combineToTwoTracks:(Array*) tracks withMeasure:(int)measurelen {
    MidiTrack *single = [MidiFile combineToSingleTrack:tracks];
    Array* result = [MidiFile splitTrack:single withMeasure:measurelen];
    [single release];

    Array* lyrics = [Array new:20];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        if ([track lyrics] != nil) {
            [lyrics addArray:[track lyrics]];
        }
    }
    if ([lyrics count] > 0) {
        [lyrics sort:sortMidiEvent];
        MidiTrack *track = [result get:0];
        [track setLyrics:lyrics];
    }
    [lyrics release];

    return result;
}


/** Check that the MidiNote start times are in increasing order.
 * This is for debugging purposes.
 */
+(void)checkStartTimes:(Array*) tracks {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int prevtime = -1;
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            assert([note startTime] >= prevtime);
            prevtime = [note startTime];
        }
    }
}


/** In Midi Files, time is measured in pulses.  Notes that have
 * pulse times that are close together (like within 10 pulses)
 * will sound like they're the same chord.  We want to draw
 * these notes as a single chord, it makes the sheet music much
 * easier to read.  We don't want to draw notes that are close
 * together as two separate chords.
 *
 * The SymbolSpacing class only aligns notes that have exactly the same
 * start times.  Notes with slightly different start times will
 * appear in separate vertical columns.  This isn't what we want.
 * We want to align notes with approximately the same start times.
 * So, this function is used to assign the same starttime for notes
 * that are close together (timewise).
 */
/** the function modify by sunlie  */
+(void)roundStartTimes:(Array*)tracks toInterval:(int)millisec withTime:(TimeSignature*)time {
    
    /* Get all the starttimes in all tracks, in sorted order */
    int initsize = 1;
    if ([tracks count] > 0) {
        initsize = [[ (MidiTrack*)[tracks get:0] notes] count];
        initsize = initsize * [tracks count]/2;
    }
    
    IntArray*  starttimes = [IntArray new:initsize];
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            [starttimes add:[note startTime]];
        }
    }
    [starttimes sort];

    /* Notes within "millisec" milliseconds apart should be combined */
//    int interval = [time quarter] * millisec * 1000 / [time tempo];
    int interval = [time quarter]/20;

    /* If two starttimes are within interval millisec, make them the same */
    for (int i = 0; i < [starttimes count] - 1; i++) {
        if ([starttimes get:(i+1)] - [starttimes get:i] <= interval) {
            [starttimes set:[starttimes get:i] index:(i+1)];
        }
    }

    [MidiFile checkStartTimes:tracks];

    /* Adjust the note starttimes, so that it matches one of the starttimes values */
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        int i = 0;

        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            while (i < [starttimes count] &&
                   [note startTime] - interval > [starttimes get:i]) {
                i++;
            }

            if ([note startTime] > [starttimes get:i] &&
                [note startTime] - [starttimes get:i] <= interval) {

                [note setStarttime:[starttimes get:i]];
            }
        }
        [[track notes] sort:sortbytime];
    }
    [starttimes release];
}


/** We want note durations to span up to the next note in general.
 * The sheet music looks nicer that way.  In contrast, sheet music
 * with lots of 16th/32nd notes separated by small rests doesn't
 * look as nice.  Having nice looking sheet music is more important
 * than faithfully representing the Midi File data.
 *
 * Therefore, this function rounds the duration of MidiNotes up to
 * the next note where possible.
 */
+(void)roundDurations:(Array*)tracks withQuarter:(int) quarternote {
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        MidiNote *prevNote = nil;

        for (int i = 0; i < [[track notes] count] - 1; i++) {
            MidiNote *note1 = [[track notes] get:i];

            if (prevNote == nil) {
                prevNote = note1;
            }

            /* Get the next note that has a different start time */
            MidiNote *note2 = note1;
            for (int j = i+1; j < [[track notes] count]; j++) {
                note2 = [[track notes] get:j];
                if ([note1 startTime] < [note2 startTime]) {
                    break;
                }
            }
            int maxduration = [note2 startTime] - [note1 startTime];

            int dur = 0;
            if (quarternote <= maxduration)
                dur = quarternote;
            else if (quarternote/2 <= maxduration)
                dur = quarternote/2;
            else if (quarternote/3 <= maxduration)
                dur = quarternote/3;
            else if (quarternote/4 <= maxduration)
                dur = quarternote/4;
            /** add by sunlie start */
            else if (quarternote/6 <= maxduration)
                dur = quarternote/6;
            else if (quarternote/8 <= maxduration)
                dur = quarternote/8;
            /** add by sunlie end */

            if (dur < [note1 duration]) {
                dur = [note1 duration];
            }

            /* Special case: If the previous note's duration
             * matches this note's duration, we can make a notepair.
             * So don't expand the duration in that case.
             */
            if ([prevNote startTime] + [prevNote duration] == [note1 startTime] &&
                [prevNote duration] == [note1 duration]) {

                dur = [note1 duration];
            }
            /** modify by sunlie start */
            if (abs(maxduration-[note1 duration]) < quarternote/8) {     //modify by sunlie 20150509
                [note1 setDuration:dur];
            }
            /** modify by sunlie end */

            MidiNote *nextNote = [[track notes] get:i+1];
            if ([nextNote startTime] != [note1 startTime]) {
                prevNote = note1;
            }
        }
    }
}

/** Split the given track into multiple tracks, separating each
 * channel into a separate track.
 */
+(Array*) splitChannels:(MidiTrack*) origtrack withEvents:(Array*)events {

    /* Find the instrument used for each channel */
    IntArray* channelInstruments = [IntArray new:16];
    for (int i =0; i < 16; i++) {
        [channelInstruments add:0];
    }
    for (int i = 0; i < [events count]; i++) {
        MidiEvent *mevent = [events get:i];
        if ([mevent eventFlag] == EventProgramChange) {
            [channelInstruments set:[mevent instrument] index:[mevent channel]];
        }
    }
    [channelInstruments set:128 index:9]; /* Channel 9 = Percussion */

    Array *result = [Array new:2];
    for (int i = 0; i < [[origtrack notes] count]; i++) {
        MidiNote *note = [[origtrack notes] get:i];
        BOOL foundchannel = FALSE;
        for (int tracknum = 0; tracknum < [result count]; tracknum++) {
            MidiTrack *track = [result get:tracknum];
            if ([note channel] == [(MidiNote*)[[track notes] get:0] channel]) {
                foundchannel = TRUE;
                [track addNote:note];
            }
        }
        if (!foundchannel) {
            MidiTrack* track = [[MidiTrack alloc] initWithTrack:([result count] + 1)];
            [track addNote:note];
            int instrument = [channelInstruments get:[note channel]];
            [track setInstrument:instrument];
            [result add:track];
            [track release];
        }
    }
    return result;
}


/** Guess the measure length.  We assume that the measure
 * length must be between 0.5 seconds and 4 seconds.
 * Take all the note start times that fall between 0.5 and 
 * 4 seconds, and return the starttimes.
 */
- (IntArray*)guessMeasureLength {
    IntArray *result = [IntArray new:30];

    int pulses_per_second = (int) (1000000.0 / [timesig tempo] * [timesig quarter]);
    int minmeasure = pulses_per_second / 2; /* The minimum measure length in pulses */
    int maxmeasure = pulses_per_second * 4; /* The maximum measure length in pulses */

    // Get the start time of the first note in the midi file.
    int firstnote = [timesig measure] * 5;
    for (int tracknum = 0; tracknum < [tracks count]; tracknum++) {
        MidiTrack *track = [tracks get:tracknum];
        if (firstnote > [(MidiNote*)[[track notes] get:0] startTime] ) {
            firstnote = [(MidiNote*)[[track notes] get:0] startTime];
        }
    }

    // interval = 0.06 seconds, converted into pulses
    int interval = [timesig quarter] * 60000 / [timesig tempo];

    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        int prevtime = 0;

        for (int j = 0; j < [[track notes] count]; j++) {
            MidiNote *note = [[track notes] get:j];
            if ([note startTime] - prevtime <= interval)
                continue;

            prevtime = [note startTime];
            int time_from_firstnote = [note startTime] - firstnote;

            // Round the time down to a multiple of 4
            time_from_firstnote = time_from_firstnote / 4 * 4;
            if (time_from_firstnote < minmeasure)
                continue;
            if (time_from_firstnote > maxmeasure)
                break;

            if (![result contains:time_from_firstnote]) {
                [result add:time_from_firstnote];
            }
        }
    }
    [result sort];
    return result;
}

/* The Program Change event gives the instrument that should
 * be used for a particular channel.  The following table
 * maps each instrument number (0 thru 128) to an instrument
 * name.
 */
static NSArray* instrNames = NULL;
+(NSArray*)instrumentNames {
    if (instrNames == NULL) {
        instrNames = [NSArray arrayWithObjects:
            @"Acoustic Grand Piano",
            @"Bright Acoustic Piano",
            @"Electric Grand Piano",
            @"Honky-tonk Piano",
            @"Electric Piano 1",
            @"Electric Piano 2",
            @"Harpsichord",
            @"Clavi",
            @"Celesta",
            @"Glockenspiel",
            @"Music Box",
            @"Vibraphone",
            @"Marimba",
            @"Xylophone",
            @"Tubular Bells",
            @"Dulcimer",
            @"Drawbar Organ",
            @"Percussive Organ",
            @"Rock Organ",
            @"Church Organ",
            @"Reed Organ",
            @"Accordion",
            @"Harmonica",
            @"Tango Accordion",
            @"Acoustic Guitar (nylon)",
            @"Acoustic Guitar (steel)",
            @"Electric Guitar (jazz)",
            @"Electric Guitar (clean)",
            @"Electric Guitar (muted)",
            @"Overdriven Guitar",
            @"Distortion Guitar",
            @"Guitar harmonics",
            @"Acoustic Bass",
            @"Electric Bass (finger)",
            @"Electric Bass (pick)",
            @"Fretless Bass",
            @"Slap Bass 1",
            @"Slap Bass 2",
            @"Synth Bass 1",
            @"Synth Bass 2",
            @"Violin",
            @"Viola",
            @"Cello",
            @"Contrabass",
            @"Tremolo Strings",
            @"Pizzicato Strings",
            @"Orchestral Harp",
            @"Timpani",
            @"String Ensemble 1",
            @"String Ensemble 2",
            @"SynthStrings 1",
            @"SynthStrings 2",
            @"Choir Aahs",
            @"Voice Oohs",
            @"Synth Voice",
            @"Orchestra Hit",
            @"Trumpet",
            @"Trombone",
            @"Tuba",
            @"Muted Trumpet",
            @"French Horn",
            @"Brass Section",
            @"SynthBrass 1",
            @"SynthBrass 2",
            @"Soprano Sax",
            @"Alto Sax",
            @"Tenor Sax",
            @"Baritone Sax",
            @"Oboe",
            @"English Horn",
            @"Bassoon",
            @"Clarinet",
            @"Piccolo",
            @"Flute",
            @"Recorder",
            @"Pan Flute",
            @"Blown Bottle",
            @"Shakuhachi",
            @"Whistle",
            @"Ocarina",
            @"Lead 1 (square)",
            @"Lead 2 (sawtooth)",
            @"Lead 3 (calliope)",
            @"Lead 4 (chiff)",
            @"Lead 5 (charang)",
            @"Lead 6 (voice)",
            @"Lead 7 (fifths)",
            @"Lead 8 (bass + lead)",
            @"Pad 1 (new age)",
            @"Pad 2 (warm)",
            @"Pad 3 (polysynth)",
            @"Pad 4 (choir)",
            @"Pad 5 (bowed)",
            @"Pad 6 (metallic)",
            @"Pad 7 (halo)",
            @"Pad 8 (sweep)",
            @"FX 1 (rain)",
            @"FX 2 (soundtrack)",
            @"FX 3 (crystal)",
            @"FX 4 (atmosphere)",
            @"FX 5 (brightness)",
            @"FX 6 (goblins)",
            @"FX 7 (echoes)",
            @"FX 8 (sci-fi)",
            @"Sitar",
            @"Banjo",
            @"Shamisen",
            @"Koto",
            @"Kalimba",
            @"Bag pipe",
            @"Fiddle",
            @"Shanai",
            @"Tinkle Bell",
            @"Agogo",
            @"Steel Drums",
            @"Woodblock",
            @"Taiko Drum",
            @"Melodic Tom",
            @"Synth Drum",
            @"Reverse Cymbal",
            @"Guitar Fret Noise",
            @"Breath Noise",
            @"Seashore",
            @"Bird Tweet",
            @"Telephone Ring",
            @"Helicopter",
            @"Applause",
            @"Gunshot",
            @"Percussion",
            nil
        ];
    }
    instrNames = [instrNames retain];
    return instrNames;
}

/** Return the last start time */
-(int)endTime {
    int lastStart = 0;
    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        if ([[track notes] count] == 0) {
            continue;
        }
        int lastindex = [[track notes] count] - 1;
        int last = [ (MidiNote*)[[track notes] get:lastindex] startTime];
        if (last > lastStart) {
            lastStart = last;
        }
    }
    return lastStart;
}

/** Given a filename, like "Bach__Minuet_in_G", return
 *  the string "Bach: Minuet in G".
 */
+(NSString*)titleName:(NSString*)filename {
    NSString *title = filename;
    if ([title hasSuffix:@".mid"]) {
        title = [title substringToIndex:[title length] - 4];
    }
    NSArray *pieces = [title componentsSeparatedByString:@"__"];
    title = [pieces componentsJoinedByString:@": "];
    pieces = [title componentsSeparatedByString:@"_"];
    title = [pieces componentsJoinedByString:@" "];
    return [title retain];
}


/** Initialize the default MidiOptions */
-(void)initOptions:(MidiOptions *)options {
    memset(options, 0, sizeof(MidiOptions));

    int numtracks = [tracks count];
    options->tracks = [IntArray new:numtracks];
    options->mute = [IntArray new:numtracks];
    options->instruments = [IntArray new:numtracks];
    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        [options->tracks add:1];
        [options->mute add:0];
        [options->instruments add: [track instrument]];
        if ([track instrument] == 128) { /* Percussion */
            [options->tracks set:0 index:i];
        }
    }
    options->useDefaultInstruments = YES;
    options->scrollVert = YES;
    options->largeNoteSize = YES;//change section width & make symbol big 
    if ([options->tracks count] == 1) {
        options->twoStaffs = YES;
    }
    else {
        options->twoStaffs = NO;
    }
    options->showNoteLetters = 0;
    options->showMeasures = NO;
    options->shifttime = NO;
    options->transpose = NO;
    options->key = -1;
    options->time = timesig;
    options->colors = nil;
    options->shadeColor = [UIColor colorWithRed:210.0/255.0
                     green:205.0/255.0 blue:220.0/255.0 alpha:1.0];
    options->shade2Color = [UIColor colorWithRed:80.0/255.0
                     green:100.0/255.0 blue:250.0/255.0 alpha:1.0];
    options->combineInterval = 40;
    options->tempo = [timesig tempo];
    options->pauseTime = 0;
    options->playMeasuresInLoop = NO;
    options->playMeasuresInLoopStart = NO;
    options->playMeasuresInLoopEnd = [self endTime] / [timesig measure];
    
    /** add by yizhq start */
    options->staveModel = 0;
    options->startSecTime = 0;
    options->endSecTime = 0;
    options->normalColor = [UIColor blackColor];
    options->highLightColor = [UIColor blackColor];
    /** add by yizhq end */
}

/** Return true if this midi file has lyrics */
-(BOOL)hasLyrics {
    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        if ([track lyrics] != nil) {
            return YES;
        }
    }
    return NO;
}


- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                     @"Midi File tracks=%d quarter=%d %@\n",
                     [tracks count], quarternote, [timesig description]];
    for (int i = 0; i < [tracks count]; i++) {
        MidiTrack *track = [tracks get:i];
        s = [s stringByAppendingString:[track description]];
    }
    return s;
}


/** add by yizhq start */
-(void)rightHandMute:(MidiOptions*)options andState:(BOOL)state
{
    if (state == YES) {
        [options->mute set:-1 index:0];
    }else{
        [options->mute set:0 index:0];
    }
}

-(void)leftHandMute:(MidiOptions*)options andState:(BOOL)state
{
    if (state == YES) {
        [options->mute set:-1 index:1];
    }else{
        [options->mute set:0 index:1];
    }
}

-(BOOL)getRightHadnMuteState:(MidiOptions*)options
{
    if ( [options->mute count] <= 0 ) {
        return NO;
    }
    int state = [options->mute get:0];
    if ( state == -1) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)getLeftHadnMuteState:(MidiOptions*)options
{
    if ( [options->mute count] <= 1 ) {
        return NO;
    }
    int state = [options->mute get:1];
    if ( state == -1) {
        return YES;
    }else{
        return NO;
    }
}

/** add by yizhq end */

-(int)getMeasureCount
{
    int count = totalpulses/[timesig measure];
    return count;
}

-(int)getMidiFileTimes
{
    return (totalpulses/[[self time] quarter])*[[self time] tempo]/1000;
}


-(void)tempoMute:(MidiOptions*)options andState:(BOOL)state{
    if (state == YES) {
        
        tempoMuteState = -1;
    }else{
        tempoMuteState = 0;
    }
}

-(BOOL)getTempoMuteState:(MidiOptions*)options{
    if ( tempoMuteState == -1) {
        return YES;
    }else{
        return NO;
    }
}

-(int)getTempoMuteState{
    return tempoMuteState;
}


@end /* class MidiFile */

/* Command-line program to print out a parsed Midi file. Used for debugging. */
int main2(int argc, char **argv)
{
    if (argc == 1) {
        printf("Usage: MidiFile <filename>\n");
        return 0;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *filename = 
      [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
    MidiFile *f = [[MidiFile alloc] initWithFile:filename];
    NSString *output = [f description];
    const char *out = [output cStringUsingEncoding:NSUTF8StringEncoding];
    printf("%s\n", out);
    return 0;
}



