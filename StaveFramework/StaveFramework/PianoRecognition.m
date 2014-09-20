//
//  PianoRecognition.m
//  PainoSpirit
//
//  Created by zyw on 14-5-26.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//
#include <sys/time.h>
#import "PianoRecognition.h"

@implementation PianoRecognition

@synthesize endDelegate;
@synthesize sheetShadeDelegate;


/**
 *  使用midi连线方式进行评判，使用次函数进行初期化
 */
-(id)initWithStaff:(Array*)staffs WithtMidiFile:(MidiFile*)file andOptions:(MidiOptions*)options
{
    pianoData = [Array new:100];
    notes = [Array new:100];
    (void)gettimeofday(&beginTime, NULL);
    
    //取得1/4音符tick数
    quarter = [[file time] quarter];
    currIndex = 0;
    
    numtracks = [options->tracks count];
    if (numtracks == 1) {//单音轨
        leftAndRight = 1;//right mode
    } else {
        int rState = [options->mute get:0];
        int lState = [options->mute get:1];
        
        //右手是第1音轨，左手是第2音轨
        //右手模式，右手静音；左手模式，左手静音
        if (rState == -1 && lState == 0) { //右手模式
            leftAndRight = 1;
        } else if (rState == 0 && lState == -1) { //左手模式
            leftAndRight = 2;
        } else {//右手模式
            leftAndRight = 1;
        }
    }
    
    [self getChordSymbolDatas:staffs];
    return self;
}


/**
 *  使用midi连线或蓝牙方式进行评判，使用次函数进行初期化
 */
-(id)initWithtMidiFile:(MidiFile*)file andOptions:(MidiOptions*)options
{
    pianoData = [Array new:100];
    notes = [Array new:100];
    (void)gettimeofday(&beginTime, NULL);
    
    
    staffIndex = 0;
    chordIndex = 0;
    quarter = [[file time] quarter];
    
    numtracks = options->numtracks;
    if (numtracks == 1) {//右手模式
        leftAndRight = 1;//right mode
    } else {
        int rState = [options->mute get:0];
        int lState = [options->mute get:1];
        
        //右手是第1音轨，左手是第2音轨
        //右手模式，右手静音；左手模式，左手静音
        if (rState == -1 && lState == 0) { //左手模式
            leftAndRight = 2;
        } else if (rState == 0 && lState == -1) { //右手模式
            leftAndRight = 1;
            staffIndex = 1;
        } else {//右手模式
            leftAndRight = 1;
        }
    }
    
    return self;
}

/**
 *  从staffs中取得待评判数据
 */
-(void)getChordSymbolDatas:(Array*)staffs
{
    int step = 0;int start = 0;
    if (numtracks == 2) {//双音轨
        step = 2;
        switch(leftAndRight) {
            case 1://右手模式
                start = 0;
                break;//左手模式
            case 2:
                start = 1;
                break;
            default://默认右手模式
                start = 0;
                break;
        }
    } else {//单音轨
        step = 1;
        start = 0;
    }
    
    if (symbolDatas == nil) {
        symbolDatas =[[NSMutableArray alloc] init];
    } else {
        [symbolDatas removeAllObjects];
    }
    
    for (int i=start; i<[staffs count]; i+=step) {
        Staff *staff = [staffs get:i];
        Array* symbols = [staff symbols];
        
        for (int j = 0; j < [symbols count]; j++) {
            NSObject <MusicSymbol> *symbol = [symbols get:j];
            if ([symbol isKindOfClass:[ChordSymbol class]]) {
                ChordSymbol *chord = (ChordSymbol *)symbol;
                
                RecognitionData *data = [[RecognitionData alloc] initWithStaffIndex:i andChordIndex:j andChordSymbol:chord];
                [symbolDatas addObject: data];
            }
        }
    }
}

-(NSMutableArray*)getChordSymbolDatas
{
    return symbolDatas;
}

-(int)getCurrIndex
{
    return currIndex;
}

-(void)setCurrIndex:(int)index
{
    currIndex = index;
}

-(void)setPianoData:(NSMutableArray*)data {
    for (int i = 0; i < [data count]; i++) {
        [pianoData add:[data objectAtIndex:i]];
    }
    
    
    if ([notes count] >= 30) {
        NSLog(@"到30个还没弹对，就重新开始了");
        [notes clear];
    }
    
    [self parseData];
    [pianoData clear];
}

-(void)setBeginTime:(struct timeval)b {
    beginTime = b;
}

-(void)setPulsesPerMsec:(double)p {
    pulsesPerMsec = p;
}

-(int)getNotesCount {

    for (int i = 0; i < [notes count]; i++) {
        NSLog(@"==========the notes number[%d]|", [[notes get:i] number]);
    }
    
    return [notes count];
}

-(void)parseData {
    long msec;
    double starttime;
    int count = [pianoData count]/3;
    
    for(int i = 0; i < count; i++) {
        //    while ((i+2) < [pianoData count]) {
        
        if ([[pianoData get:i*3] intValue] == 0x90) {
            struct timeval now;
            (void)gettimeofday(&now, NULL);
            msec = (now.tv_sec - beginTime.tv_sec)*1000 +
            (now.tv_usec - beginTime.tv_usec)/1000;
            starttime = msec * pulsesPerMsec;
            MidiNote *note = [[MidiNote alloc]init];
            [note setStarttime:starttime];
            [note setNumber:[[pianoData get:i*3+1] intValue]];
            [notes add:note];
        }
    }
    NSLog(@"oooooo [%d] mmmmmmmmmmmmmmmm [%d]", count, [notes count]);
}

/**
 *  是否是和旋
 */
-(BOOL) isChord:(int)len
{
    for(int i = 0; i < len-1; i++) {
        int end = [[notes get:i] startTime];
        int start = [[notes get:i+1] startTime];
        
        NSLog(@"start is [%d], end is [%d] quarter[%d]", start, end, quarter);
        if ((start-end) > quarter) {
            return FALSE;
        }
    }
    return TRUE;
}


/**
 *  评判音符
 */
-(BOOL) judgeResult:(ChordSymbol*)chord withCount:(int)count
{
    NoteData nd;
    NoteData *noteData = [chord notedata];
    int number = 0;
    int flag = [chord eightFlag];
    
    if ([notes count] <= 0) return FALSE;
    NSLog(@"===judgeResult count = [%d]", count);
    if (count == 1) {  //单音符
        nd = noteData[0];
        number = nd.number;
        
        if (nd.previous == 1) {
            [notes remove:[notes get:0]];
            return TRUE;
        }
        
        if(flag > 0) {
            number += 12;
        } else if (flag < 0) {
            number -= 12;
        }
        
        NSLog(@"===nd number[%d]  notenum0[%d]", number, [[notes get:0] number]);
        if ([self judgeNote:number]) {
            [notes clear];
            return TRUE;
        } else {
            return FALSE;
        }
    } else if (count >1) { //和旋
        
        NSLog(@"is hexuang! 1");
        if ([chord notedata_len] > [notes count]) {
            return FALSE;
        }
        
        //        NSLog(@"is hexuang! 2");
        //        if (![self isChord:[chord notedata_len]]) {
        //           return FALSE;
        //        }
        
        NSLog(@"is hexuang! 3");
        for (int i = 0; i < [chord notedata_len]; i++) {
            nd = noteData[i];
            number = nd.number;
            
            if(flag > 0) {
                number += 12;
            } else if (flag < 0) {
                number -= 12;
            }
            
            if (nd.previous == 1) {
                continue;
            }
            if (![self judgeNote:number]) {
                return FALSE;
            }
        }
        
        [notes clear];
        return TRUE;
    }
    
    return FALSE;
}

-(BOOL)judgeNote:(int)number {
    for (int i = 0; i < [notes count]; i++) {
        if (number == [[notes get:i] number]) {
            //            [notes remove:[notes get:i]];
            return TRUE;
        }
    }
    return FALSE;
}



-(int) getChordSymbolCount:(ChordSymbol*)chord {
    
    if ([chord notedata_len] <= 0) return -1;
    
    NoteData *noteData = [chord notedata];
    BOOL isSingle = TRUE;
    int number = noteData[0].number;
    
    for (int i = 1; i < [chord notedata_len]; i++) {
        NoteData nd = noteData[i];
        if (number != nd.number) {
            isSingle = FALSE;
            break;
        }
    }
    
    if (!isSingle) {
        return [chord notedata_len];
    } else {
        return 1;
    }
}

/**
 *  取得待评判音符的数量
 */
-(int)getCurChordSymolNoteCount
{
    if (currIndex < 0 || currIndex >= [symbolDatas count]) return -1;
    RecognitionData *data = [symbolDatas objectAtIndex:currIndex];
    ChordSymbol *chord = [data getChordSymbol];
    
    NoteData *noteData = [chord notedata];
    for (int i = 0; i < [chord notedata_len]; i++) {
        NoteData nd = noteData[i];
        NSLog(@"==========the current symbol number is[%d]|", nd.number);
    }
    return [self getChordSymbolCount:chord];
}


/**
 *  取得待评判音符
 */
-(ChordSymbol*)getCurChordSymol
{
    if (currIndex < 0 || currIndex >= [symbolDatas count]) return nil;
    RecognitionData *data = [symbolDatas objectAtIndex:currIndex];
    ChordSymbol *chord = [data getChordSymbol];
    return chord;
}

/**
 *  midi连线评判
 */
-(void)recognitionPlayByLine
{
    NSLog(@"=== recognitionPlayByLine index[%d] note data[%d]", currIndex , [notes count]);
    if (currIndex < 0 || currIndex >= [symbolDatas count]) return;
    
    RecognitionData *data = [symbolDatas objectAtIndex:currIndex];
    ChordSymbol *chord = [data getChordSymbol];
    if ([self judgeResult:chord withCount:[chord notedata_len]]) {
        if (sheetShadeDelegate != nil) {
            [chord setJudgedResult:1];
            [sheetShadeDelegate sheetShade:[data getStaffIndex] andChordIndex:[data getChordIndex] andChordSymbol:chord];
            currIndex++;
        }
        [notes clear];
    }
    
    
    //评判完成
    if (currIndex == [symbolDatas count] && endDelegate != nil) {
        [endDelegate endSongsResult:0 andRight:(int)[symbolDatas count] andWrong:0];
    }
}

/**
 *  蓝牙和midi连线评判
 */
-(BOOL)recognitionPlay:(Array*)staffs
{
    if (staffs == nil) {
        return FALSE;
    }
    
    Staff *staff = [staffs get:staffIndex];
    Array* symbols = [staff symbols];
    int start = chordIndex;
    for (int i = start; i < [symbols count]; i++) {
        
        NSObject <MusicSymbol> *symbol = [symbols get:i];
        if ([symbol isKindOfClass:[ChordSymbol class]]) {
            
            ChordSymbol *chord = (ChordSymbol *)symbol;
            if ([self judgeResult:chord withCount:[chord notedata_len]]) {
                if (sheetShadeDelegate != nil) {
                    [chord setJudgedResult:1];
                    [sheetShadeDelegate sheetShade:staffIndex andChordIndex:i andChordSymbol:chord];
                    chordIndex = i;
                    
                    
                    return TRUE;
                }
            } else {
                [notes clear];
                return FALSE;
            }
        }
        
        if (i == [symbols count] && [notes count] > 0) {//
            chordIndex = 0;
            if (numtracks == 2) {
                staffIndex += 2;
            } else {
                staffIndex ++;
            }
            
            [self recognitionPlay:staffs];
        }
    }
    return FALSE;
}


- (void)dealloc
{
    [pianoData release];
    [notes release];
    
    if (symbolDatas != nil)
    {
        [symbolDatas release];
    }
    
    [super dealloc];
}


@end
