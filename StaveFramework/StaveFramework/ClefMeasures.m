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
#import "Array.h"
#import "MidiFile.h"
#import "WhiteNote.h"
#import "ClefMeasures.h"
#import "ClefSymbol.h"
#import "ControlData.h"
#import "BeatSignature.h"

/** @class ClefMeasures
 * The ClefMeasures class is used to report what Clef (Treble or Bass) a
 * given measure uses.
 */
@implementation ClefMeasures
 
/** Given the notes in a track, calculate the appropriate Clef to use
 * for each measure.  Store the result in the clefs list.
 * @param notes  The midi notes
 * @param measurelen The length of a measure, in pulses
 */
/** modify by sunlie */
- (id)initWithNotes:(Array*)notes andTime:(TimeSignature *)time andBeats:(Array*)beats andControl:(Array*)clist andTotal:(int)t andTracknum:(int) num {
    /** add by sunlie start */
    int size = [beats count];
    int i = 0;
    int m = 0;
    int starttime = 0;
    
    beatarray = beats;
    if (size > 0) {
        [time setNumerator:[[beats get:0] numerator]];
        [time setDenominator:[[beats get:0] denominator]];
        [time setMeasure];
        m = [time measure];
        i = 1;
    }
    
    if (size > 1) {
        BeatSignature *beat = [beats get:i];
        starttime = beat.starttime;
//        starttime = [(BeatSignature*)[beats get:i] startTime];
    } else {
        starttime = 0;
    }
    /** add by sunlie end */
    
//    measure = measurelen;
    measure = m;         /** modify by sunlie */

    int mainclef;
    
    if (num == 0) {
        mainclef = Clef_Treble;
    } else if (num == 1) {
        mainclef = Clef_Bass;
    } else {
        mainclef = [self mainClef:notes];
    }
    
//    int clef = mainclef;
    
//    clefs = [IntArray new:([notes count] / 10) + 1];
    clefs = (ClefData*) calloc([clist count]*2+1, sizeof(ClefData));       /** modify by sunlie */
    
    /** add by sunlie start */
    int k = 0;
    ClefData *clefdata;
    if ([clist count] > 0 && [[clist get:0] starttime] == 0) {
        clefsLen = [clist count]*2;
        if ([clist count] > 0) {
            for (k = 0; k<[clist count]; k++) {
                ControlData *cdata = [clist get:k];
                if(k > 0) {
                    clefdata = &(clefs[2*k-1]);
                    clefdata->endtime = [cdata starttime];
                }
                clefdata = &(clefs[2*k]);
                if (mainclef == Clef_Treble) {
                    clefdata->clef = Clef_Bass;
                } else if(mainclef == Clef_Bass) {
                    clefdata->clef = Clef_Treble;
                }
                clefdata->starttime = [cdata starttime];
                clefdata->endtime = [cdata endtime];
                clefdata = &(clefs[2*k+1]);
                clefdata->clef = mainclef;
                clefdata->starttime = [cdata endtime];
            }
        }
    }
    else if ([clist count] > 0) {
        clefsLen = [clist count]*2+1;
        clefdata = &(clefs[0]);
        clefdata->clef = mainclef;
        clefdata->starttime = 0;
        
        if ([clist count] > 0) {
            for (k = 0; k<[clist count]; k++) {
                ControlData *cdata = [clist get:k];
                clefdata = &(clefs[2*k]);
                clefdata->endtime = [cdata starttime];
                clefdata = &(clefs[2*k+1]);
                if (mainclef == Clef_Treble) {
                    clefdata->clef = Clef_Bass;
                } else if(mainclef == Clef_Bass) {
                    clefdata->clef = Clef_Treble;
                }
                clefdata->starttime = [cdata starttime];
                clefdata->endtime = [cdata endtime];
                clefdata = &(clefs[2*(k+1)]);
                clefdata->clef = mainclef;
                clefdata->starttime = [cdata endtime];
            }
        }
    }
    else {
        clefsLen = 1;
        clefdata = &(clefs[0]);
        clefdata->clef = mainclef;
        clefdata->starttime = 0;
    }
    


//    if ([clist count] <= 0) {
//        for (j = 0; j < mcount; j++) {
//            [clefs add:clef];
//        }
//    } else {
//        ControlData *cdata = [clist get:k];
//
//        for (j = 0; j < mcount; j++) {
//            if (([cdata endtime] + [time quarter])/m <= j) {
//                k++;
//                if (k < [clist count]) {
//                    cdata = [clist get:k];
//                }
//            }
//            if (([cdata starttime] + [time quarter])/m <= j && ([cdata endtime] + [time quarter])/m > j) {
//                if (mainclef == Clef_Treble) {
//                    clef = Clef_Bass;
//                } else if(mainclef == Clef_Bass) {
//                    clef = Clef_Treble;
//                }
//            } else {
//                clef = mainclef;
//            }
//            [clefs add:clef];
//        }
//    }
    /** add by sunlie end */

    /** delete by sunlie start */
//
//    while (pos < [notes count]) {
//        /* Sum all the notes in the current measure */
//        int sumnotes = 0;
//        int notecount = 0;
//        while (pos < [notes count] && [(MidiNote*)[notes get:pos] startTime] < nextmeasure) {
//            sumnotes += [(MidiNote*)[notes get:pos] number];
//            notecount++;
//            pos++;
//        }
//        if (notecount == 0)
//            notecount = 1;
//
//        /* Calculate the "average" note in the measure */
//        int avgnote = sumnotes / notecount;
//        if (avgnote == 0) {
//            /* This measure doesn't contain any notes.
//             * Keep the previous clef.
//             */
//        }
//        else if (avgnote >= [[WhiteNote bottomTreble] number]) {
//            clef = Clef_Treble;
//        }
//        else if (avgnote <= [[WhiteNote topBass] number]) {
//            clef = Clef_Bass;
//        }
//        else {
//            /* The average note is between G3 and F4. We can use either
//             * the treble or bass clef.  Use the "main" clef, the clef
//             * that appears most for this track.
//             */
//            clef = mainclef;
//        }
//
//        [clefs add:clef];
//        nextmeasure += measurelen;
//    }
//    [clefs add:clef];
    /** delete by sunlie end */
    return self;
}

- (void)dealloc {
    free(clefs);
//    [clefs release];
    [super dealloc];
}

-(int)getClefsLen {
    return clefsLen;
}

-(ClefData*)getClefData {
    return clefs;
}

/** Given a time (in pulses), return the clef used for that measure. */
- (int)getClef:(int)starttime {
    /* If the time exceeds the last measure, return the last measure */
//    if (starttime / measure >= [clefs count]) {
//        return [clefs get:([clefs count]-1) ];
//    }
//    else {
//        return [clefs get:(starttime / measure) ];
//    }
    int i = 0;
    for (i = 0; i < clefsLen; i++) {
        if (starttime >= clefs[i].starttime && (starttime < clefs[i].endtime || clefs[i].endtime==0)) {
            return clefs[i].clef;
        }
    }
    return clefs[clefsLen-1].clef;
}

/** Calculate the best clef to use for the given notes.  If the
 * average note is below Middle C, use a bass clef.  Else, use a treble
 * clef.
 */
- (int)mainClef:(Array*)notes {
    int middleC = [[WhiteNote middleC] number];
    int total = 0;
    for (int i = 0; i < [notes count]; i++) {
        total += [(MidiNote*)[notes get:i] number];
    }
    if ([notes count] == 0) {
        return Clef_Treble;
    }
    else if (total/[notes count] >= middleC) {
        return Clef_Treble;
    }
    else {
        return Clef_Bass;
    }
}

@end


