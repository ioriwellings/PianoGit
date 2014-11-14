//
//  PianoDataJudged.m
//  PainoSpirit
//
//  Created by 李洪胜 on 14-4-10.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//
#include <sys/time.h>
#import "PianoDataJudged.h"
#include <sys/time.h>
#import "PianoDataJudged.h"

@implementation PianoDataJudged

-(id) init {
    int i;
    pianoData = [Array new:100];
    notes = [Array new:100];
    prevChordList = [Array new:100];
    curChordList = [Array new:100];
    judgedResult = [IntArray new:4];
    (void)gettimeofday(&beginTime, NULL);
    
    for (i=0; i<4; i++) {
        [judgedResult add:0];
    }
    
    type = 0;
    return self;
}

-(id)initWithOptions:(MidiOptions*)options
{
    int i;
    pianoData = [Array new:100];
    notes = [Array new:100];
    prevChordList = [Array new:100];
    curChordList = [Array new:100];
    judgedResult = [IntArray new:4];
    (void)gettimeofday(&beginTime, NULL);
    
    for (i=0; i<4; i++)
    {
        [judgedResult add:0];
    }
    
    type = 0;
    int trackCount = [options->tracks count];
    NSLog(@"=====numtracks:%d", trackCount);
    if (trackCount != 1)
    {
        int rState = [options->mute get:0];
        
        int lState = [options->mute get:1];
        
        //右手是第1音轨，左手是第2音轨
        //右手模式，右手静音；左手模式，左手静音
        if (rState == -1 && lState == 0)
        { //右手模式
            type = 1;
        }
        else if (rState == 0 && lState == -1)
        { //左手模式
            type = 2;
        }
    }
    
    return self;
}

-(void)setPianoData:(NSMutableArray*)data {
    int i;
    for (i = 0; i < [data count]; i++) {
        int c = [[data objectAtIndex:i] intValue];
        NSLog(@"======== setPianoData is [%d]=======", c);
        [pianoData add:[data objectAtIndex:i]];
    }
    [self parseData];
    [pianoData clear];
}

-(IntArray*)judgedResult {
    return judgedResult;
}

-(void)setJudgedResult:(IntArray*)j {
    judgedResult = j;
}

-(struct timeval)beginTime {
    return beginTime;
}

-(void)setBeginTime:(struct timeval)b {
    beginTime = b;
}

-(TimeSignature*)timesig {
    return timesig;
}

-(void)setTimesig:(TimeSignature*)t {
    timesig = t;
}

-(double)pulsesPerMsec {
    return pulsesPerMsec;
}

-(void)setPulsesPerMsec:(double)p {
    pulsesPerMsec = p;
}
-(void)setSheetMusic:(SheetMusic *)s {
    sheet = s;
}
-(void)setIsSpeed:(BOOL)flag {
    isSpeed = flag;
}

- (double)getCurrentTime: (long)mesc {
    Array *tempoarray = [sheet tempoarray];
    int i = 0;
    double tmpPulsesPerMsec = 0.0;
    long tmpMesc = 0;
    double tmpCurrentTime = 0;
    long tmp;
    
    int tmpFlag = 0;
    for (i=1; i<[tempoarray count]; i++) {
        tmpPulsesPerMsec = [[[sheet midifile] time] quarter]*(1000.0 / [[tempoarray get:i-1] tempo]);
        tmp = ([[tempoarray get:i] starttime]-[[tempoarray get:i-1] starttime])/tmpPulsesPerMsec;

        if (tmpMesc+tmp>=mesc) {
            tmpFlag--;
            break;
        }
        tmpMesc+=tmp;
    }
    i--;
    tmpPulsesPerMsec = [[[sheet midifile] time] quarter]*(1000.0 / [[tempoarray get:i] tempo]);
    tmpCurrentTime = [[tempoarray get:i] starttime];
    tmp = mesc - tmpMesc;
    tmpCurrentTime+=tmp*tmpPulsesPerMsec;
    
    return tmpCurrentTime;
}


-(void)parseData {
    int i = 0;
    long msec;
    double starttime;
    
    NSLog(@"========= pianoData is [%d]===========", [pianoData count]);
    while ((i+2) < [pianoData count]) {
        NSLog(@"======= while piano i[%d] i+1 [%d], i+2 [%d]",
              [[pianoData get:i] intValue], [[pianoData get:i+1] intValue],
              [[pianoData get:i+2] intValue]);
        
        
        if ([[pianoData get:i] intValue] == 0x90) {
            if ([[pianoData get:i+2] integerValue] > 0) {
                struct timeval now;
                (void)gettimeofday(&now, NULL);
                msec = (now.tv_sec - beginTime.tv_sec)*1000 +
                (now.tv_usec - beginTime.tv_usec)/1000;
                if ([[sheet tempoarray] count] == 1 || isSpeed) {
                    starttime = msec * pulsesPerMsec;
                } else {
                    starttime = [self getCurrentTime:msec];
                }

                MidiNote *note = [[MidiNote alloc]init];
                [note setStarttime:starttime];
                [note setNumber:[[pianoData get:i+1] intValue]];
                [notes add:note];
                NSLog(@"======= parseData note number[%d]=========", [note number]);
            }
        }
        i += 3;
    }
}

-(void)FindChords:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs {
    int upFlag = 0;
    Staff *staff;
    int i;
    int j;
    int k;
    int start = 0, step = 2;
    
    switch(type) {
        case 0:
            start = 0;
            step = 1;
            break;
        case 1://右手模式
            start = 0;
            step = 2;
            break;
        case 2:
            start = 1;
            step = 2;
            break;
        default:
            start = 0;
            step = 1;
            break;
    }
    

    
    for (i=start; i<[staffs count]; i+=step) {
        staff = [staffs get:i];
        if (([staff endTime] <= curPulseTime) || ([staff startTime] > curPulseTime)) {
            continue;
        } else {
            Array* symbols = [staff symbols];
            for (j = 0; j < [symbols count]; j++) {

                NSObject <MusicSymbol> *symbol = [symbols get:j];
                if ([symbol isKindOfClass:[ChordSymbol class]]) {
                    ChordSymbol *chord = (ChordSymbol *)symbol;
                    if ([chord startTime] > curPulseTime) {
                        break;
                    } else if ([chord startTime] >= prevPulseTime) {//fix bug > 2 >= for judge first chordsymbol
                        if (upFlag == 0) {
                            upFlag = 1;
                            if ([curChordList count] > 0) {
                                for (k = 0; k < [curChordList count]; k++) {
                                    [prevChordList add:[curChordList get:k]];
                                }
                                [curChordList clear];
                            }
                            [curChordList add:chord];
                        } else {
                            [curChordList add:chord];
                        }
                    } else if ([curChordList count] > 0 && curPulseTime - [[curChordList get:0] startTime] > [[[sheet midifile] time] quarter]) {//fix bug > 2 >= for judge first chordsymbol
                        if (upFlag == 0) {
                            upFlag = 1;
                            for (k = 0; k < [curChordList count]; k++) {
                                [prevChordList add:[curChordList get:k]];
                            }
                            [curChordList clear];
                        }
                    }
                }
            }
        }
    }
}


-(void)FindTheLastChords:(Array*)staffs {
    Staff *staff;
    int i, j;
    int start = 0, step = 2;
    switch(type) {
        case 0:
            start = 0;
            step = 1;
            break;
        case 1://右手模式
            start = 0;
            step = 2;
            break;
        case 2:
            start = 1;
            step = 2;
            break;
        default:
            start = 0;
            step = 1;
            break;
    }
    
    for (i=start; i<[staffs count]; i+=step) {
        staff = [staffs get:i];
        Array* symbols = [staff symbols];
        for (j = [symbols count]-1; j >= 0; j--) {
            NSObject <MusicSymbol> *symbol = [symbols get:j];
            if ([symbol isKindOfClass:[ChordSymbol class]]) {
                ChordSymbol *chord = (ChordSymbol *)symbol;
                NSLog(@"-------zzzzzz %d", [chord judgedResult]);
                if ([chord judgedResult] == 0) {
                    [prevChordList add:chord];
                    break;
                }
            }
        }
    }
}

-(void)judgedPianoPlay:(int)curPulseTime andPrevPulseTime:(int)prevPulseTime andStaffs:(Array*)staffs andMidifile:(MidiFile *)midifile {
    
    if (staffs == nil) {
        return;
    }
    
    int j;
    
    if (prevPulseTime != -10) {
        [self FindChords:curPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs];
    } else {
        [self FindTheLastChords:staffs];
    }
    
    if ([prevChordList count] >= 0) {
        for (j = [prevChordList count] - 1; j >= 0; j--) {
            ChordSymbol *chord = [prevChordList get:j];
            int start = [chord startTime];
            int end = [chord endTime];
            NoteData *noteData = [chord notedata];
            int count = 0;
            int rightCount = 0;
            int i,k;
            int result = 0;
            NoteData nd;
            
            for (i = 0; i < [chord notedata_len]; i++) {
                nd = noteData[i];
                if (nd.previous == 1) {
                    continue;
                } else
                {
                    count++;
                }
            }
            
            if (count == 0) {
                [chord setJudgedResult:-2];
                [prevChordList remove:chord];
                continue;
            }
            
            for (i = 0; i < [chord notedata_len]; i++) {
                nd = noteData[i];
                if (nd.previous == 1) {
                    continue;
                }
                
                if (nd.addflag == 1) {
                    rightCount++;
                    continue;
                }
                
                if([chord eightFlag] > 0) {
                    nd.number = nd.number+12;
                } else if ([chord eightFlag] < 0) {
                    nd.number = nd.number-12;
                }
                
                for (k = 0; k < [notes count]; k++) {
                    NSLog(@"================== note number[%d]", [[notes get:k] number] );
                    if (abs([[notes get:k] startTime]-start) <= [timesig quarter]/3) {
                        if (nd.number == [[notes get:k] number]) {
                            if (result == 0) {
                                result = 2;
                            }
                            rightCount++;
                            [notes remove:[notes get:k]];
                            break;
                        }
                    } else if (abs([[notes get:k] startTime]-start) <= 2*[timesig quarter]/3) {
                        if (nd.number == [[notes get:k] number]) {
                            if (result > 1 || result == 0) {
                                result = 1;
                            }
                            rightCount++;
                            [notes remove:[notes get:k]];
                            break;
                        }
                    } else if ([[notes get:k] startTime]-start > 2*[timesig quarter]/3) {
                        break;
                    }
                }
            }
            
            if ([chord judgedResult] == 0) {
                NSLog(@"====== result[%d] rightCount [%d]=====", result, rightCount);
                
                if (result == -1 || rightCount < count) {
                    [chord setJudgedResult:-1];
                    [prevChordList remove:chord];
                    [judgedResult set:[judgedResult get:0]+1 index:0];
                    [judgedResult set:[judgedResult get:1]+1 index:1];
                    
                } else if (result == 0 && curPulseTime-start > (end-start)) {
                    [chord setJudgedResult:-1];
                    

                    [prevChordList remove:chord];
                    [judgedResult set:[judgedResult get:0]+1 index:0];
                    [judgedResult set:[judgedResult get:1]+1 index:1];
                } else if (result > 0) {
                    [chord setJudgedResult:result];
                    [prevChordList remove:chord];
                    if (result == 1) {
                        [judgedResult set:[judgedResult get:0]+1 index:0];
                        [judgedResult set:[judgedResult get:2]+1 index:2];
                    } else {
                        [judgedResult set:[judgedResult get:0]+1 index:0];
                        [judgedResult set:[judgedResult get:3]+1 index:3];
                    }
                }
            }
        }
    }
    
    return;
}

-(void)RoundStartTimes:(Array*)midiNotes {
    int j;
    MidiNote *note;
    IntArray*  starttimes = [IntArray new:100];
    int interval = 20;
    note = [midiNotes get:0];
    int tmptime = [note startTime];
    
    for (j = 0; j < [midiNotes count] - 1; j++) {
        note = [midiNotes get:j];
        if ([[midiNotes get:j+1] startTime]-tmptime <= interval/2) {
            tmptime = [[midiNotes get:j+1] startTime];
            [[midiNotes get:j+1] setStartTime:[[midiNotes get:j] startTime]];
        } else if ([[midiNotes get:j+1] startTime]-tmptime <= interval && [note duration] > 120) {
            tmptime = [[midiNotes get:j+1] startTime];
            [[midiNotes get:j+1] setStartTime:[[midiNotes get:j] startTime]];
        } else {
            tmptime = [[midiNotes get:j+1] startTime];
        }
    }
    
    [midiNotes sort:sortbytime];
    
    for (j = 0; j < [midiNotes count]; j++) {
        [starttimes add:[[midiNotes get:j] startTime]];
    }
    
    [starttimes sort];
    
    for (j = 0; j < [starttimes count] - 1; j++) {
        if ([starttimes get:j+1] - [starttimes get:j] <= interval/2) {
            [starttimes set:[starttimes get:j] index:j+1];
        }
    }
    
    j=0;
    
    for (j = 0; j < [midiNotes count]; j++) {
        note = [midiNotes get:j];
        while ([note startTime]-interval > [starttimes get:j]) {
            j++;
        }
        
        if ([note startTime] > [starttimes get:j] &&
            [note startTime] - [starttimes get:j] <= interval) {
            [note setStarttime:[starttimes get:j]];
        }
    }
    
    [midiNotes sort:sortbytime];
}

-(void)DataClear {
    [curChordList clear];
    [prevChordList clear];
    [pianoData clear];
    [notes clear];
    for(int i = 0; i<4; i++) {
        [judgedResult set:0 index:i];
    }
}

- (void)dealloc
{
    [pianoData release];
    [notes release];
    [prevChordList release];
    [curChordList release];
    [judgedResult release];
    [super dealloc];
}


@end
