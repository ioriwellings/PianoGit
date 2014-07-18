/*
 * Copyright (c) 2007-2011 Madhav Vaidyanathan
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 2.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */
#import <Foundation/NSObject.h>
#import "Array.h"

/* add by sunlie start */
struct _ClefData {
    int starttime;       /** Start time of the symbol */
    int clef;            /** The clef, Clef_Treble or Clef_Bass */
    int endtime;
};
typedef struct _ClefData ClefData;
/* add by sunlie end */

@interface ClefMeasures : NSObject {
    ClefData* clefs;
    int clefsLen;
    int measure;
    Array* beatarray;
}

/** modify by sunlie */
-(id)initWithNotes:(Array*)notes andTime:(TimeSignature *)time andBeats:(Array*)beats andControl:(Array*)clist andTotal:(int)totalpulses andTracknum:(int) tracknum;
-(int)getClef:(int)starttime;
-(int)getClefsLen;
-(ClefData*)getClefData;
-(int)mainClef:(Array*)notes;
-(void)dealloc;

@end

