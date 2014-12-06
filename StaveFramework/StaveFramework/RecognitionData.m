//
//  RecognitionData.m
//  PainoSpirit
//
//  Created by zyw on 14-5-28.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "RecognitionlData.h"

@implementation RecognitionData

-(id)initWithStaffIndex:(int)index1 andChordIndex:(int)index2 andChordSymbols:(NSMutableArray *)data
{
    staffIndex = index1;
    chordIndex = index2;
    chords = [data retain];
    return self;
}


-(int)getStaffIndex
{
    return staffIndex;
}

-(int)getChordIndex
{
    return chordIndex;
}

-(NSMutableArray*)chordSymbols
{
    return chords;
}

- (void)dealloc
{
    [chords release];
    [super dealloc];
}

@end