//
//  RecognitionData.h
//  PainoSpirit
//
//  Created by zyw on 14-5-28.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecognitionData : NSObject {
    int staffIndex;
    int chordIndex;
    
    NSMutableArray* chords;
}

-(id) initWithStaffIndex:(int)index1 andChordIndex:(int)index2 andChordSymbols:(NSMutableArray*)data;

-(int)getStaffIndex;
-(int)getChordIndex;
-(NSMutableArray*)chordSymbols;

@end