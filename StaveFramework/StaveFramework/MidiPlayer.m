/*
 * Copyright (c) 2011-2012 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#include <sys/time.h>
#include <unistd.h>
#import "MidiPlayer.h"
#import "Array.h"

/* A note about changing the volume:
 * MidiSheetMusic does not support volume control in Mac OS X 10.4
 * and earlier, because the NSSound setVolume method does not exist
 * in those earlier versions. In the code below, we check if the NSSound
 * class supports the setVolume method, using respondsToSelector.
 */

#if MAC_OS_X_VERSION_MAX_ALLOWED < MAC_OS_X_VERSION_10_5
@interface NSSound(NSVolume)

- (void)setVolume:(float)x;

@end
#endif


/** @class MidiPlayer
 *
 * The MidiPlayer is the panel at the top used to play the sound
 * of the midi file.  It consists of:
 *
 * - The Rewind button
 * - The Play/Pause button
 * - The Stop button
 * - The Fast Forward button
 * - The Playback speed bar
 * - The Volume bar
 *
 * The sound of the midi file depends on
 * - The MidiOptions (taken from the menus)
 *   Which tracks are selected
 *   How much to transpose the keys by
 *   What instruments to use per track
 * - The tempo (from the Speed bar)
 * - The volume
 *
 * The MidiFile.changeSound() method is used to create a new midi file
 * with these options.  The NSSound class is used for
 * playing, pausing, and stopping the sound.
 *
 * For shading the notes during playback, the method
 * Staff.shadeNotes() is used.  It takes the current 'pulse time',
 * and determines which notes to shade.
 */
@implementation MidiPlayer


@synthesize peripheral, midiData;
@synthesize sensor;
@synthesize sheetPlay;
@synthesize delegate;
@synthesize isSpeed;

-(void) changeVolume:(double)value
{
    return;
}

/** Resize an image */
+ (UIImage*) resizeImage:(UIImage*)origImage toSize:(CGSize)newsize {
    
    return nil;
}


/** Load the play/pause/stop button images */
+ (void)loadImages {
}

/** Create a new MidiPlayer, displaying the play/stop buttons, the
 *  speed bar, and volume bar.  The midifile and sheetmusic are initially null.
 */
- (id)init {
    
    self = [super init];
    midifile = nil;
    sheet = nil;
    memset(&options, 0, sizeof(MidiOptions));
    playstate = stopped;
    gettimeofday(&startTime, NULL);
    startPulseTime = 0;
    currentPulseTime = 0;
    prevPulseTime = -10;
    timer = nil;
    pianoData = nil;
    sensor = nil;
    recognition = nil;
    midiHandler = [MidiKeyboard sharedMidiKeyboard];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:kNAMIDIDatas object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midiStatus:) name:kNAMIDINotification object:nil];
    
    /* add by yizhq start */
    sound = [[GDSoundEngine alloc] init];
    /* add by yizhq end */
    isLine = FALSE;
    self.isSpeed = FALSE;
    
    return self;
}

- (void)setPiano:(Piano*)p {
    piano = [p retain];
}

- (void) disConnectMIDI {
    isLine = FALSE;
}

- (BOOL) getDeviceStatus {
    return [midiHandler isConnect];
}

/** The MidiFile and/or SheetMusic has changed. Stop any playback sound,
 *  and store the current midifile and sheet music.
 */
- (void)setMidiFile:(MidiFile*)file withOptions:(MidiOptions*)opt andSheet:(SheetMusic*)s {
    
    /* If we're paused, and using the same midi file, redraw the
     * highlighted notes.
     */
    isLine = [midiHandler isConnect];

    isLine = TRUE;
    if(sensor != nil || isLine) {
        sensor.delegate = self;
        pianoData = [[PianoDataJudged alloc] initWithOptions:opt];
        arrPacket =[[NSMutableArray alloc] init];
        
        recorder = [[PianoRecorder alloc]init];
    }
    
    if ((midifile == file && midifile != nil && playstate == paused)) {
        if (sheet != nil) {
            [sheet release];
        }
        sheet = [s retain];
        memcpy(&options, opt, sizeof(MidiOptions));
        
        //        [sheet shadeNotes:(int)currentPulseTime withPrev:-10 gradualScroll:NO];
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:-10 andKeyboard:nil];
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self selector:@selector(reshade:) userInfo:nil repeats:NO];
    }
    else {
        [self stop];
        if (sheet != nil) {
            [sheet release];
        }
        sheet = [s retain];
        memcpy(&options, opt, sizeof(MidiOptions));
        if (midifile != nil) {
            [midifile release];
        }
        midifile = [file retain];
    }
}

/** If we're paused, reshade the sheet music and piano. */
- (void)reshade:(NSTimer*)arg {
    if (playstate == paused) {
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:-10 andKeyboard:nil];
        //        [sheet shadeNotes:(int)currentPulseTime withPrev:-10 gradualScroll:NO];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    }
    [arg invalidate];
}


/** Delete the temporary midi sound file */
- (void)deleteSoundFile {
    if (tempSoundFile == nil) {
        return;
    }
    [self stop];
    const char *cfile = [tempSoundFile cStringUsingEncoding:NSUTF8StringEncoding];
    unlink(cfile);
    [tempSoundFile release];
    tempSoundFile = nil;
}


/** Return the number of tracks selected in the MidiOptions.
 *  If the number of tracks is 0, there is no sound to play.
 */
- (int)numberTracks {
    int count = 0;
    for (int i = 0; i < [options.tracks count]; i++) {
        if ([options.tracks get:i] && ![options.mute get:i]) {
            count += 1;
        }
    }
    return count;
}


/** Create a new midi sound data with all the MidiOptions incorporated.
 *  Store the new midi sound into the file tempSoundFile.
 */
- (void)createMidiFile {
    [tempSoundFile release];
    tempSoundFile = nil;
    /** modify by yizhq for change speed from 20 ~ 280 start */
    //    double inverse_tempo = 1.0 / [[midifile time] tempo];
    //    double inverse_tempo_scaled = inverse_tempo * doubleValue / 100.0;
    //    options.tempo = (int)(1.0 / inverse_tempo_scaled);
    options.tempo = (int)(60000 / doubleValue * 1000);
    //    NSLog(@"tempo is %i", options.tempo);
    /** modify by yizhq for change speed from 20 ~ 280 end */
    //    pulsesPerMsec = [[midifile time] quarter] * (1000.0 / options.tempo);
    
    if (isSpeed == true) {
        pulsesPerMsec = [[midifile time] quarter] * (1000.0 / options.tempo);
    }else{
        pulsesPerMsec = [self getPulsesPerMsec:currentPulseTime];
    }
    
    int tmpQuarternote = 0;
    if ([[midifile time]denominator] == 4) {
        tmpQuarternote = [[midifile time]numerator];
    }else if ([[midifile time]denominator] == 8){
        tmpQuarternote = [[midifile time]numerator]/2;
    }else if([[midifile time]denominator] == 2){
        tmpQuarternote = [[midifile time]numerator];
    }
    sectionTime = pulsesPerMsec * tmpQuarternote;
    
    NSString *tempPath = NSTemporaryDirectory();
    tempSoundFile = [NSString stringWithFormat:@"%@/temp.mid", tempPath];
    
    tempSoundFile = [tempSoundFile retain];
    if ([midifile changeSound:&options oldMidi:midifile toFile:tempSoundFile secValue:timeDifference andSpeed:isSpeed] == NO) {//modify by yizhq
        /* Failed to write to tempSoundFile */
        [tempSoundFile release]; tempSoundFile = nil;
    }
}

//add by yizhq start for prepare tempo
- (void)createTempoMidiFile {
    [tempoFile release];
    tempoFile = nil;
    options.tempo = (int)(60000 / doubleValue * 1000);
    //    pulsesPerMsec = [[midifile time] quarter] * (1000.0 / options.tempo);
    if (isSpeed == true) {
        pulsesPerMsec = [[midifile time] quarter] * (1000.0 / options.tempo);
    }else{
        pulsesPerMsec = [self getPulsesPerMsec:currentPulseTime];
    }
    
    if ([[midifile time]denominator] == 4) {
        sectionTime = pulsesPerMsec * ([[midifile time] numerator] + 1);
    }else if ([[midifile time]denominator] == 8){
        sectionTime = pulsesPerMsec * ([[midifile time] numerator] + 1);
    }else if([[midifile time]denominator] == 2){
        sectionTime = pulsesPerMsec * ([[midifile time] numerator] + 1);
    }
    
    NSString *tempPath = NSTemporaryDirectory();
    tempoFile = [NSString stringWithFormat:@"%@/tempofile.mid", tempPath];
    
    tempoFile = [tempoFile retain];
    if ([midifile changeSoundForTempo:&options oldMidi:midifile toFile:tempoFile secValue:timeDifference andSpeed:isSpeed] == NO) {//modify by yizhq
        /* Failed to write to tempSoundFile */
        [tempoFile release]; tempoFile = nil;
    }
}

- (void)deleteTempoFile {
    if (tempoFile == nil) {
        return;
    }
    const char *cfile = [tempoFile cStringUsingEncoding:NSUTF8StringEncoding];
    unlink(cfile);
    [tempoFile release];
    tempoFile = nil;
}

- (double) getSectionTime{
    double tempoTime = 0;
    double tmpPulsesPerMsec = 0;
    
    if (isSpeed == true) {
        tmpPulsesPerMsec = [[midifile time] quarter] * (1000.0 / ( (int)(60000 / doubleValue * 1000)));
    }else{
        tmpPulsesPerMsec = [self getPulsesPerMsec:currentPulseTime];
    }
    
    if ([[midifile time] denominator] == 4) {
        tempoTime = [midifile quarternote]/tmpPulsesPerMsec;
    }else if ([[midifile time] denominator] == 8){
        tempoTime = [midifile quarternote]/2/tmpPulsesPerMsec;
    }else if ([[midifile time] denominator] == 2){
        tempoTime = [midifile quarternote]*2/tmpPulsesPerMsec;
    }
    
    NSLog(@"prepare time is %f", tempoTime*[[midifile time] numerator]);
    return tempoTime*[[midifile time] numerator];
}

- (int)getCountDownCnt{
    int tmpQuarternote = 0;
    if ([[midifile time]denominator] == 4) {
        tmpQuarternote = ceil([[midifile time]numerator]);
    }else if ([[midifile time]denominator] == 8){
        tmpQuarternote = ceil([[midifile time]numerator]);
    }else if([[midifile time]denominator] == 2){
        tmpQuarternote = ceil([[midifile time]numerator]);
    }
    return [[midifile time]numerator];
}

- (void)playPrepareTempo:(double)time{
    prepareFlag = 1;
    soundTempo = [[GDSoundEngine alloc] init];
    [self createTempoMidiFile];
    [soundTempo loadMIDIFile:tempoFile];
    [soundTempo playPressed];
}

- (void)stopPrepareTempo{
    prepareFlag = 0;
    if (soundTempo != nil) {
        [soundTempo stopPressed];
        [soundTempo cleanup];
        [soundTempo release];
        soundTempo = nil;
        [self deleteTempoFile];
    }
}

-(void)resetShadeLine{
    [sheetPlay shadeNotes:0 withPrev:(int)currentPulseTime andKeyboard:nil];
}
//add by yizhq end

-(void) listen {
    judgeFlag = FALSE;
    [self playPause];
}

-(void) replayByType {
    
    [self doStop];
    [sheet clearStaffs];
    [self clearJudgedData];
    
    if (playModel != PlayModel1) {
        [sheetPlay setCurrentPulseTime:currentPulseTime];
    }
    
    switch(playModel) {
        case PlayModel1:
            [self playModel1];
            break;
        case PlayModel2:
            [self playPause];
            break;
        case PlayModel3:
            [self playPause];
            break;
        default:
            [self playPause];
            break;
    }
}
-(void)playByType:(int)type
{
    judgeFlag = true;
    playModel = type;
    
    switch(playModel) {
        case PlayModel1:
            [self playModel1];
            break;
        case PlayModel2:
            if (recorder != nil) {
                [recorder startRecord];
            }
            [self playPause];
            break;
        case PlayModel3:
            [self playPause];
            break;
        default:
            break;
    }
}

-(void)setIsLine:(BOOL)status
{
    isLine = status;
    
    if (isLine) {
        sensor.delegate = self;
        
        if (pianoData == nil) {
            pianoData = [[PianoDataJudged alloc] initWithOptions:&options];
        }
        
        if (arrPacket == nil) {
            arrPacket =[[NSMutableArray alloc] init];
        }
        
        
        if (recorder == nil) {
            recorder = [[PianoRecorder alloc]init];
        }
        
    }
}

/**
 *  识谱模式演奏
 */
- (void)playModel1 {
    if (midifile == nil || sheet == nil) {
        return;
    }
    else if (playstate == initStop || playstate == initPause) {
        return;
    }
    else if (playstate == playing) {
        playstate = initPause;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
        
        options.pauseTime = 0;
        startPulseTime = options.shifttime;
        currentPulseTime = options.shifttime;
        prevPulseTime = options.shifttime - [[midifile time] quarter];
        if (isLine) {
            if (recognition != nil) {
                [recognition release];
            }
            staffs = [sheet getStaffs];
            
            recognition = [[PianoRecognition alloc] initWithStaff:staffs WithtMidiFile:midifile andOptions:&options];
            recognition.endDelegate = self.delegate;
            recognition.sheetShadeDelegate = self;
        }
        
        [self createMidiFile];
        playstate = playing;
        (void)gettimeofday(&startTime, NULL);
        
        if (arrPacket != nil) {
            [arrPacket removeAllObjects];
        }
        
        if (recognition != nil) {
            [recognition setCurrIndex:0];
            [recognition setBeginTime:startTime];
            [recognition setPulsesPerMsec:pulsesPerMsec];
        }
        
        CGPoint initPos;
        initPos.x = 0; initPos.y = 0;
        [sheet scrollToShadedNotes:initPos gradualScroll:YES];
        return;
    }
}


- (void) sheetShade:(int) staffIndex andChordIndex:(int)chordIndex andChordSymbol:(ChordSymbol*)chord
{
    NSLog(@"====sheetShade === staff index = [%d] chord Index = [%d]", staffIndex, chordIndex);
    
    
    
    int currentPulseTimes = [chord startTime];
    int prevPulseTimes = [chord startTime];
    
    NSLog(@"====chord === currentPulseTimes = [%d] prevPulseTimes = [%d]",
          currentPulseTimes, prevPulseTimes);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[sheet shadeNotesByModel1:staffIndex andChordIndex:chordIndex andChord:chord];
        [sheetPlay shadeNotes:currentPulseTimes withPrev:prevPulseTimes andKeyboard:nil];
    });
    
    
}

/** add by yizhq start */
-(void)setJSModel:(int)startSectionNum withEndSectionNum:(int)endSectionNum withTimeNumerator:(int)numerrator withTimeQuarter:(int)quarter withMeasure:(int)measure{
    TimeSignature *t;
    Array *beatarray = [midifile beatarray];
    BeatSignature* beat = [beatarray get:0];
    int i;
    int measurecount = 0;
    int tmpTime = 0;
    int preTime = 0;
    //    int startTime = (startSectionNum - 1) * measure;
    //    int endTime = endSectionNum * measure;
    
    t = [[TimeSignature alloc] initWithNumerator:[beat numerator] andDenominator:[beat denominator] andQuarter:[[midifile time] quarter] andTempo:[[midifile time] tempo]];
    if ([beatarray count] > 1) {
        for (i = 1; i<[beatarray count]; i++) {
            int tmp =([[beatarray get:i] starttime]-preTime)/[t measure];
            measurecount += tmp;
            if (measurecount > startSectionNum-1) {
                measurecount -= tmp;
                tmpTime = preTime+(startSectionNum-1-measurecount)*[t measure];
                break;
            } else {
                preTime += tmp*[t measure];
                beat = [beatarray get:i];
                [t setNumerator:[beat numerator]];
                [t setDenominator:[beat denominator]];
                //                [t setTempo:[beat tempo]];
                [t setMeasure];
            }
        }
        
        if (i == [beatarray count]) {
            tmpTime = [beat starttime]+(startSectionNum-1-measurecount)*[t measure];
        }
    } else {
        tmpTime = [[midifile time] measure]*(startSectionNum-1);
    }
    
    options.staveModel = 1;
    options.startSecTime = tmpTime;
    beat = [beatarray get:0];
    [t setNumerator:[beat numerator]];
    [t setDenominator:[beat denominator]];
    //    [t setTempo:[beat tempo]];
    [t setMeasure];
    
    if ([beatarray count] > 1 && [[beatarray get:1] starttime]/[t measure] < endSectionNum) {
        for (i = 1; i<[beatarray count]; i++) {
            int tmp =([[beatarray get:i] starttime]-preTime)/[t measure];
            measurecount += tmp;
            if (measurecount > endSectionNum) {
                measurecount -= tmp;
                tmpTime = preTime+(endSectionNum-measurecount)*[t measure];
                break;
            } else {
                preTime += tmp*[t measure];
                beat = [beatarray get:i];
                [t setNumerator:[beat numerator]];
                [t setDenominator:[beat denominator]];
                //                [t setTempo:[beat tempo]];
                [t setMeasure];
            }
        }
        
        if (i == [beatarray count]) {
            tmpTime = preTime+(endSectionNum-measurecount)*[t measure];
        }
    } else {
        tmpTime = [[midifile time] measure]*(endSectionNum);
    }
    options.endSecTime = tmpTime;
}

-(void)clearJSModel{
    options.staveModel = 0;
    options.startSecTime = 0;
    options.endSecTime = 0;
}

-(int)PlayerState{
    return playstate;
}

-(void)playJumpSection:(int)startSectionNumber{
    if (options.staveModel == 1) {
        if (startSectionNumber < 0) {
            return;
        }
        int startSec = startSectionNumber;
        [self jumpMeasure:startSec - 1];
    }
}

-(void)clearJumpSection
{
    playstate = paused;
    currentPulseTime = 0;
    
    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime andKeyboard:nil];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];
    
    prevPulseTime = currentPulseTime;
    [sheetPlay setCurrentPulseTime:currentPulseTime];
}

- (double)getPulsesPerMsec:(double)currentTime {
    Array *tempoarray = [sheet tempoarray];
    int i = 0;
    double tmpPulsesPerMsec = 0.0;
    int tempo = 0;
    
    for (i=1; i<[tempoarray count]; i++) {
        if (currentTime < [[tempoarray get:i] starttime]) {
            break;
        }
    }
    i--;
    tempo = [[tempoarray get:i] tempo];
    tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0 / tempo);
    
    return tmpPulsesPerMsec;
}

- (double)getCurrentTime:(double)beginTime andMesc:(long)mesc {
    Array *tempoarray = [sheet tempoarray];
    int i = 0;
    double tmpPulsesPerMsec = 0.0;
    long tmpMesc = 0;
    double tmpCurrentTime = beginTime;
    long tmp;
    long beginMesc = 0;
    
    for (i=1; i<[tempoarray count]; i++) {
        tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0 / [[tempoarray get:i-1] tempo]);
        if ([[tempoarray get:i] starttime] >= beginTime) {
            break;
        }
        beginMesc += ([[tempoarray get:i] starttime]-[[tempoarray get:i-1] starttime])/tmpPulsesPerMsec;
    }
    i--;
    beginMesc += (beginTime-[[tempoarray get:i] starttime])/tmpPulsesPerMsec;
    i++;
    
    int tmpFlag = 0;
    for (; i<[tempoarray count]; i++) {
        tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0 / [[tempoarray get:i-1] tempo]);
        if (tmpFlag == 0) {
            tmp = ([[tempoarray get:i] starttime]-beginTime)/tmpPulsesPerMsec;
            tmpFlag = 1;
        } else {
            tmp = ([[tempoarray get:i] starttime]-[[tempoarray get:i-1] starttime])/tmpPulsesPerMsec;
            tmpFlag++;
        }
        
        if (tmpMesc+tmp>=mesc) {
            tmpFlag--;
            break;
        }
        tmpMesc+=tmp;
    }
    i--;
    tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0 / [[tempoarray get:i] tempo]);
    if (tmpFlag <= 0) {
        tmpCurrentTime = beginTime;
    } else {
        tmpCurrentTime = [[tempoarray get:i] starttime];
    }
    
    tmp = mesc - tmpMesc;
    tmpCurrentTime+=tmp*tmpPulsesPerMsec;
    
    return tmpCurrentTime;
}

-(SheetMusic*)sheetMusic {
    return sheet;
}
/** add by yizhq end */
/** The callback for the play/pause button (a single button).
 *  If we're stopped or pause, then play the midi file.
 *  If we're currently playing, then initiate a pause.
 *  (The actual pause is done when the timer is invoked).
 */
- (void)playPause {
    //    if (midifile == nil || sheet == nil || [self numberTracks] == 0) {modify by yizhq
    if (midifile == nil || sheet == nil) {
        return;
    }
    else if (playstate == initStop || playstate == initPause) {
        return;
    }
    else if (playstate == playing) {
        playstate = initPause;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
        /* The startPulseTime is the pulse time of the midi file when
         * we first start playing the music.  It's used during shading.
         */
        if (options.playMeasuresInLoop) {
            /* If we're playing measures in a loop, make sure the
             * currentPulseTime is somewhere inside the loop measures.
             */
            double nearEndTime = currentPulseTime + pulsesPerMsec*50;
            //            int measure = (int)(nearEndTime / [[midifile time] measure]);
            int measure = [sheet getMeasureNum:nearEndTime withTime:[midifile time]];
            if ((measure < options.playMeasuresInLoopStart) ||
                (measure > options.playMeasuresInLoopEnd)) {
                
                currentPulseTime = options.playMeasuresInLoopStart *
                [[midifile time] measure];
            }
            startPulseTime = currentPulseTime;
            options.pauseTime = (int)(currentPulseTime - options.shifttime);
        }
        else if (playstate == paused) {
            startPulseTime = currentPulseTime;
            options.pauseTime = (int)(currentPulseTime - options.shifttime);
        }
        else {
            options.pauseTime = 0;
            startPulseTime = options.shifttime;
            currentPulseTime = options.shifttime;
            prevPulseTime = options.shifttime - [[midifile time] quarter];
        }
        
        staffs = [sheet getStaffs];
        
        [self createMidiFile];
        /* add by yizhq start */
        //        [sound loadMIDIFile:[midifile filename]];
        //        [sound loadMIDIFile:tempPrepareTempoFile];
        //        [sound playPressed];
        [sound loadMIDIFile:tempSoundFile];
        [sound playPressed];
        playstate = playing;
        /* add by yizhq end */
        
        (void)gettimeofday(&startTime, NULL);
        
        
        if (timer != nil) {
            [timer invalidate];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
        //        [playButton setImage:pauseImage];
        //        [playButton setToolTip:@"Pause"];
        if (pianoData != nil) {
            
            struct timeval time;
            time.tv_sec = startTime.tv_sec;
            time.tv_usec = startTime.tv_usec;
            
            //get shift time
            double shift = 0;
            if ([[sheet tempoarray] count] == 1 || isSpeed) {
                shift = currentPulseTime/pulsesPerMsec*1000;
            } else {
                Array *tempoarray = [sheet tempoarray];
                double tmpPulsesPerMsec = 0.0;
                long tmpMesc = 0;
                int k;
                
                for (k=1; k<[tempoarray count]; k++) {
                    tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0/[[tempoarray get:k-1] tempo]);
                    if ([[tempoarray get:k] starttime] >= currentPulseTime) {
                        break;
                    }
                    tmpMesc += ([[tempoarray get:k] starttime]-[[tempoarray get:k-1] starttime])/tmpPulsesPerMsec;
                }
                k--;
                tmpMesc += (currentPulseTime-[[tempoarray get:k] starttime])/tmpPulsesPerMsec;
                shift = tmpMesc*1000;
            }
            time.tv_usec -= shift;
            
            [pianoData setBeginTime:time];
            [pianoData setPulsesPerMsec:pulsesPerMsec];
            [pianoData setIsSpeed:isSpeed];
            [pianoData setSheetMusic:[self sheetMusic]];
            
            [pianoData judgedPianoPlay:currentPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs andMidifile:midifile];
        }
        
        
        
        //        Array *tempoarray = [sheet tempoarray];
        //        int i = 0;
        //        double tmpPulsesPerMsec = 0.0;
        //        long tmpMesc = 0;
        //        double tmpCurrentTime = beginTime;
        //        long tmp;
        //        long beginMesc = 0;
        //
        //        for (i=1; i<[tempoarray count]; i++) {
        //            tmpPulsesPerMsec = [[midifile time] quarter]*(1000.0 / [[tempoarray get:i-1] tempo]);
        //            if ([[tempoarray get:i] starttime] >= beginTime) {
        //                break;
        //            }
        //            beginMesc += ([[tempoarray get:i] starttime]-[[tempoarray get:i-1] starttime])/tmpPulsesPerMsec;
        //        }
        //        i--;
        //        beginMesc += (beginTime-[[tempoarray get:i] starttime])/tmpPulsesPerMsec;
        
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime andKeyboard:midiHandler];
        //        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        return;
    }
}


/** The callback for the Stop button.
 *  If paused, clear the sound settings and state.
 *  Else, initiate a stop (the actual stop is done in the timer).
 */
- (void)stop {
    if (midifile == nil || sheet == nil || playstate == stopped) {
        return;
    }
    if (playstate == initPause || playstate == initStop || playstate == playing) {
        /* Wait for the timer to finish */
        
        
        playstate = initStop;
        [sheetPlay ClearShadeDataForDevice:midiHandler];
        usleep(300 * 1000);
        [self doStop];
    }
    else if (playstate == paused) {
        [self doStop];
    }
}

/** Perform the actual stop, by stopping the sound,
 *  removing any shading, and clearing the state.
 */
- (void)doStop {
    playstate = stopped;
    //    [sound stop];
    //    [sound release]; sound = nil;
    /* add by yizhq start */
    [sound stopPressed];
    //    [sound release];sound = nil;
    /* add by yizhq end */
    [self deleteSoundFile];
    
    /* Remove all shading by redrawing the music */
    sheet.hidden = NO;
    //    piano.hidden = NO; by IORI.
    
    if (recorder != nil) {
        [recorder stopRecord];
    }
    
    startPulseTime = 0;
    currentPulseTime = 0;
    prevPulseTime = 0;
    //    [playButton setImage:playImage];
    //    [playButton setToolTip:@"Play"];
    return;
}


-(void)Pause {
    playstate = paused;
    [sound stopPressed];
    [self deleteSoundFile];
    return;
}

/** Rewind the midi music back one measure.
 *  The music must be in the paused state.
 *  When we resume in playPause, we start at the currentPulseTime.
 *  So to rewind, just decrease the currentPulseTime,
 *  and re-shade the sheet music.
 */
- (void)rewind {
    if (midifile == nil || sheet == nil || playstate != paused) {
        return;
    }
    
    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime andKeyboard:nil];
    //    [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];
    
    prevPulseTime = currentPulseTime;
    currentPulseTime -= [[midifile time] measure];
    if (currentPulseTime < options.shifttime) {
        currentPulseTime = options.shifttime;
    }
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    //    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:NO];
    [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime andKeyboard:nil];
}

- (BOOL) jumpMeasure:(int)number
{
    TimeSignature *t;
    BeatSignature* beat = [[midifile beatarray] get:0];
    Array *beatarray = [midifile beatarray];
    int i;
    int measurecount = 0;
    int tmpTime = 0;
    int preTime = 0;
    if (number < 0) return FALSE;
    
    if (midifile == nil || sheet == nil) {
        return FALSE;
    }
    if (playstate != paused && playstate != stopped) {
        return FALSE;
    }
    playstate = paused;
    
    
    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime andKeyboard:nil];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];
    
    prevPulseTime = currentPulseTime;
    
    t = [[TimeSignature alloc] initWithNumerator:[beat numerator] andDenominator:[beat denominator] andQuarter:[[midifile time] quarter] andTempo:[[midifile time] tempo]];
    if ([beatarray count] > 1) {
        for (i = 1; i<[beatarray count]; i++) {
            int tmp =([[beatarray get:i] starttime]-preTime)/[t measure];
            measurecount += tmp;
            if (measurecount > number) {
                measurecount -= tmp;
                tmpTime = preTime+(number-measurecount)*[t measure];
                break;
            } else {
                preTime += tmp*[t measure];
                beat = [beatarray get:i];
                [t setNumerator:[beat numerator]];
                [t setDenominator:[beat denominator]];
                //                [t setTempo:[beat tempo]];
                [t setMeasure];
            }
        }
        
        if (i == [beatarray count]) {
            tmpTime = [beat starttime]+(number-measurecount)*[t measure];
        }
    } else {
        tmpTime = [[midifile time] measure]*number;
    }
    
    currentPulseTime = tmpTime;
    //    currentPulseTime = [[midifile time] measure]*number;
    //NSLog(@"currentpulseTime is %f", currentPulseTime);
    
    if (currentPulseTime > [midifile totalpulses]) {
        currentPulseTime -= [[midifile time] measure];
    }
    
    [sheetPlay setCurrentPulseTime:currentPulseTime];
    
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    //[sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
    
    
    return TRUE;
}


/** Fast forward the midi music by one measure.
 *  The music must be in the paused/stopped state.
 *  When we resume in playPause, we start at the currentPulseTime.
 *  So to fast forward, just increase the currentPulseTime,
 *  and re-shade the sheet music.
 */
- (void)fastForward {
    if (midifile == nil || sheet == nil) {
        return;
    }
    if (playstate != paused && playstate != stopped) {
        return;
    }
    playstate = paused;
    
    /* Remove any highlighted notes */
    [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime andKeyboard:nil];
    //    [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
    [piano shadeNotes:-10 withPrev:(int)currentPulseTime];
    
    prevPulseTime = currentPulseTime;
    currentPulseTime += [[midifile time] measure];
    if (currentPulseTime > [midifile totalpulses]) {
        currentPulseTime -= [[midifile time] measure];
    }
    [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
    //    [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:NO];
    [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime andKeyboard:nil];
}


- (void)ClearTimerCallback:(NSTimer*)arg{
    if (isLine) {
        [midiHandler sendClearData:0];
    }
}
/** The callback for the timer. If the midi is still playing,
 *  update the currentPulseTime and shade the sheet music.
 *  If a stop or pause has been initiated (by someone clicking
 *  the stop or pause button), then stop the timer.
 */
- (void)timerCallback:(NSTimer*)arg {
    if (midifile == nil || sheet == nil) {
        [timer invalidate]; timer = nil;
        playstate = stopped;
        return;
    }
    else if (playstate == stopped || playstate == paused) {
        /* This case should never happen */
        [timer invalidate]; timer = nil;
        return;
    }
    else if (playstate == initStop) {
        [timer invalidate]; timer = nil;
        return;
    }
    else if (playstate == playing) {
        struct timeval now;
        gettimeofday(&now, NULL);
        long msec = (now.tv_sec - startTime.tv_sec)*1000 +
        (now.tv_usec - startTime.tv_usec)/1000;
        prevPulseTime = currentPulseTime;
        
        if ([[sheet tempoarray] count] == 1 || isSpeed == true) {
            currentPulseTime = startPulseTime + msec * pulsesPerMsec;
        } else {
            currentPulseTime = [self getCurrentTime:startPulseTime andMesc:msec];
        }
        
        /* If we're playing in a loop, stop and restart */
        if (options.playMeasuresInLoop) {
            int measure = (int)(currentPulseTime / [[midifile time] measure]);
            if (measure > options.playMeasuresInLoopEnd) {
                [self restartPlayMeasuresInLoop];
                return;
            }
        }
        
        /* Stop if we've reached the end of the song */
        /** modify by yizhq start */
        int totalTime = 0;
        if (options.staveModel == 1) {
            totalTime = options.endSecTime;
        }else{
            totalTime = [midifile totalpulses];
            //            totalTime = [[staffs get:staffs.count - 1] endTime];
        }
        //        if (currentPulseTime > [midifile totalpulses]) {
        if (currentPulseTime > totalTime) {
            /** modify by yizhq end */
            [timer invalidate]; timer = nil;
            
            if (pianoData != nil && playModel == PlayModel2) {
                [pianoData judgedPianoPlay:prevPulseTime andPrevPulseTime:-10 andStaffs:staffs andMidifile:midifile];
            }
            
            [sheetPlay shadeNotes:-10 withPrev:(int)currentPulseTime andKeyboard:midiHandler];
            //            [sheet shadeNotes:-10 withPrev:(int)currentPulseTime gradualScroll:NO];
            
            [self doStop];
            
            if (delegate != nil) {
                [delegate endSongs];
            }
            
            if (pianoData != nil && judgeFlag) {
                
                IntArray *result = [pianoData judgedResult];
                
                if (delegate != nil) {
                    [delegate endSongsResult:[result get:3] andRight:[result get:2]
                                    andWrong:[result get:1]];
                }
            }
//            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(ClearTimerCallback:) userInfo:nil repeats:NO];
            [self ClearTimerCallback:nil];
            return;
        }
        
        if (pianoData != nil && judgeFlag) {
            [pianoData judgedPianoPlay:currentPulseTime andPrevPulseTime:prevPulseTime andStaffs:staffs andMidifile:midifile];
        }
        
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime
                  andKeyboard:midiHandler];
        //        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        return;
    }
    else if (playstate == initPause) {
        [timer invalidate]; timer = nil;
        struct timeval now;
        gettimeofday(&now, NULL);
        long msec = (now.tv_sec - startTime.tv_sec)*1000 +
        (now.tv_usec - startTime.tv_usec)/1000;
        
        //        [sound stop];
        //        [sound release]; sound = nil;
        /* add by yizhq start */
        [sound stopPressed];
        //        [sound release];sound = nil;
        /* add by yizhq end */
        prevPulseTime = currentPulseTime;
        
        if ([[sheet tempoarray] count] == 1 || isSpeed == true) {
            currentPulseTime = startPulseTime + msec * pulsesPerMsec;
        } else {
            currentPulseTime = [self getCurrentTime:startPulseTime andMesc:msec];
        }
        //modify currentPulseTime for tempo start
        //        int intactTempoCnt = currentPulseTime/(pulsesPerMsec*1000);
        int intactTempoCnt = currentPulseTime/[midifile quarternote];
        currentPulseTime = (intactTempoCnt + 1)*[midifile quarternote];
        //        timeDifference = currentPulseTime - (startPulseTime + msec * pulsesPerMsec);
        //        int intactTempoCnt = currentPulseTime/[midifile quarternote];
        //modify currentPulseTime for tempo end
        //        NSLog(@"timer prevPulseTime is %f currentPulseTime is %f", prevPulseTime, currentPulseTime);
        [sheetPlay shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime
                  andKeyboard:midiHandler];
        //        [sheet shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime gradualScroll:YES];
        [piano shadeNotes:(int)currentPulseTime withPrev:(int)prevPulseTime];
        prevPulseTime = currentPulseTime - [[midifile time] measure];
        //        [playButton setImage:playImage];
        //        [playButton setToolTip:@"Play"];
        playstate = paused;
        return;
    }
}

/** The "Play Measures in a Loop" feature is enabled, and we've reached
 *  the last measure. Stop the sound, and then start playing again.
 */
-(void)restartPlayMeasuresInLoop {
    [timer invalidate]; timer = nil;
    [self doStop];
    [NSTimer scheduledTimerWithTimeInterval:0.4
                                     target:self selector:@selector(replay:) userInfo:nil repeats:NO];
}

-(void)replay:(NSTimer*)arg {
    [self playPause];
}

/** Callback for volume bar.  Adjust the volume if the midi sound
 *  is currently playing.
 */
- (void)changeSpeed:(double)value {
    doubleValue = value;
}

/** This view uses flipped coordinates, where upper-left corner is (0,0) */
- (BOOL)isFlipped {
    return YES;
}


//bluetooth recv data
-(void) serialGATTCharValueUpdated:(NSString *)UUID value:(NSData *)data
{
    Byte *buffers = (Byte *)[data bytes];
    for(int i = 0; i < data.length; i++)
    {
        NSNumber *num = [[NSNumber alloc] initWithInt:buffers[i]];
        //        NSLog(@"MidiPlayer rece num is %x", [num intValue]);
        [arrPacket addObject: num];
    }
    
    len += data.length;
    if (len %3 == 0) {
        if (playstate == playing) {
            [pianoData setTimesig:[midifile time]];
            [pianoData setPianoData:arrPacket];
            
        }
        [arrPacket removeAllObjects];
        len = 0;
    }
}

-(void) setConnect
{
    NSLog(@"disconnect");
}

-(void)setDisconnect
{
    NSLog(@"disconnect");
}



-(void)byModel1{
    //    [recognition setTimesig:[midifile time]];
    
    [recognition setPianoData:arrPacket];
    int count = [recognition getCurChordSymolNoteCount];
    int c = [recognition getNotesCount];
    NSLog(@"====current chord symbol note count [%d] rece data count[%d] aaaa %d", count, c, [recognition getCurrIndex]);
    if (c >= count) {
        [recognition recognitionPlayByLine];
    }
    
}

-(void)byModel2 {
    [pianoData setTimesig:[midifile time]];
    [pianoData setPianoData:arrPacket];
    [arrPacket removeAllObjects];
    
}
//MidiKeyboard recevice data
- (void)receiveData:(NSNotification*)notification
{
    int notePlayed = [[notification.userInfo objectForKey:kNAMIDI_NoteKey] intValue];
    int velocity = [[notification.userInfo objectForKey:kNAMIDI_VelocityKey] intValue];
    NSLog(@"=====MidiKeyboard Recevice data NoteNumber[%d], Velocity[%d]", notePlayed, velocity);
    
    if (velocity == 0) return;
    
    [arrPacket removeAllObjects];
    NSNumber *num1 = [[NSNumber alloc] initWithInt:0x90];
    [arrPacket addObject: num1];
    
    NSNumber *num2 = [[NSNumber alloc] initWithInt:notePlayed];
    [arrPacket addObject: num2];
    
    NSNumber *num3 = [[NSNumber alloc] initWithInt:velocity];
    [arrPacket addObject: num3];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *data1 = [NSString stringWithFormat:@"键号:%d", notePlayed];
        
        if (self.midiData != nil) {
            [self.midiData setText:data1];
        }
        
        
        if (playstate == playing) {
            switch(playModel) {
//                case PlayModel1:
//                    [self byModel1];
//                    break;
//                case PlayModel2:
//                    [self byModel2];
//                    break;
//                case PlayModel3:
//                    [self byModel2];
//                    break;
            }
        }
    });
    
    if (playstate == playing) {
        switch(playModel) {
            case PlayModel1:
                [self byModel1];
                break;
            case PlayModel2:
                [self byModel2];
                break;
            case PlayModel3:
                [self byModel2];
                break;
        }
    }
    
}

- (void) clearJudgedData {
    if (pianoData != nil) {
        [pianoData DataClear];
    }
    
    [sheetPlay setCurrentPulseTime:0];
}

- (void)midiStatus:(NSNotification*)notification
{
    int messageID = [[notification.userInfo objectForKey:@"kNAMIDI_MessageID"] intValue];
    NSLog(@"MidiKeyboard Notify, MessageID=%d", messageID);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.midiData == nil) return;
        
        if (messageID == kMIDIMsgObjectAdded) {
            self.midiData.textColor = [UIColor whiteColor];
            [self.midiData setText:@"设备已连接"];
            [self setIsLine:TRUE];
        } else if (messageID == kMIDIMsgObjectRemoved) {
            self.midiData.textColor = [UIColor redColor];
            [self.midiData setText:@"设备未连接"];
            [self setIsLine:FALSE];
        }
    });
}

-(void)PianoTips:(BOOL)isOn {
    
    if (playModel != PlayModel1 ) {
        NSLog(@"current model is not PlayModel1!");
        return;
    }
    
    if (!isLine) {
        NSLog(@"Midi Line is disconnect!");
        return;
    }
    
    if (recognition == nil ) {
        NSLog(@"recognition is nil!");
        return;
    }
    
    
    
    NSMutableArray* mary = [recognition getCurChordSymol];
    if (mary == nil) {
        NSLog(@"current ChordSymbols is nil!");
        return;
    }
    
    
    for(int i = 0; i < [mary count]; i++) {
        
        ChordSymbol* c = [mary objectAtIndex:i];

        int velocity = 0;
        if (isOn) {
            velocity = 100;
        }
        
        int flag = [c eightFlag];
        NoteData *noteData = [c notedata];
        for (int i = 0; i < [c notedata_len]; i++) {
            NoteData nd = noteData[i];
            int number = nd.number;
            
            if (nd.previous == 1) {
                NSLog(@"midi note is previous.");
                continue;
            }
            
            if(flag > 0) {
                number += 12;
            } else if (flag < 0) {
                number -= 12;
            }
            number +=1;
            NSLog(@"==========the tips symbol number is[%d]|", number);
            
            usleep(1000);
            [midiHandler sendData:number andVelocity:velocity];
        }
    }
}


- (void)dealloc {
    [self deleteSoundFile];
    //    [playButton release];
    //    [stopButton release];
    //    [rewindButton release];
    //    [fastFwdButton release];
    //    [speedBar release];
    //    [volumeBar release];
    [midifile release];
    [sheet release]; 
    [piano release];
    [sound release];
    [pianoData release];
    [arrPacket release];

    if (recognition != nil)
    {
        [recognition release];
    }
    if (recorder != nil)
    {
        [recorder release];
    }
    
    [tempSoundFile release];
    if (timer != nil) {
        [timer invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end


