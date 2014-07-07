/*
 * Copyright (c) 2009-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#import "MusicSymbol.h"

@interface BarSymbol : NSObject <MusicSymbol> {
    int starttime;
    int width;
    
    int straffHeight;           /** The height of the staff in pixels */
    int tracknum;               /** The track this staff represents */
    int totaltracks;            /** The total number of tracks */
    /** add by sunlie start */
    int repeatFlag;             /** 1: repeat start  2: repeat end  3: 1 house   4:2 house  */
    /** add by sunlie end */
    int measureWidth;
}

-(id)initWithTime:(int) starttime;
-(int)startTime;
-(int)minWidth;
-(int)width;
-(void)setWidth:(int)w;
-(int)aboveStaff;
-(int)belowStaff;
/** add by sunlie start */
-(int)repeatFlag;
-(void)setRepeatFlag:(int)r;
/** add by sunlie end */
-(void)setMeasureWidth:(int)v;
-(int) getMeasureWidth;

-(void)setTrackNum:(int)num;
-(void)setTotalTracks:(int)value;
-(void)setStraffHeight:(int)height;


-(void)draw:(CGContextRef)context atY:(int)ytop;
-(NSString*)description;

@end

