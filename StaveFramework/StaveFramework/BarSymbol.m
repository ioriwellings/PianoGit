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
#import "BarSymbol.h"


/** @class BarSymbol 
 * The BarSymbol represents the vertical bars which delimit measures.
 * The starttime of the symbol is the beginning of the new
 * measure.
 */
@implementation BarSymbol

/** Create a BarSymbol. The starttime should be the beginning of a measure. */
- (id)initWithTime:(int)start {
    starttime = start;
    width = NoteWidth;
    return self;
}

/** Get the time (in pulses) this symbol occurs at.
 * This is used to determine the measure this symbol belongs to.
 */
- (int)startTime {
    return starttime;
}

/** Get the minimum width (in pixels) needed to draw this symbol */
- (int)minWidth {
    return 2 * LineSpace;
}

/** Get the width (in pixels) of this symbol. The width is set
 * in SheetMusic:alignSymbols to vertically align symbols.
 */
- (int)width {
    return width;
}

/** Set the width (in pixels) of this symbol. The width is set
 * in SheetMusic:alignSymbols to vertically align symbols.
 */
- (void)setWidth:(int)w {
    width = w;
    
    if (repeatFlag == 1 || repeatFlag == 2) {
        width += 5;
    }
}

/** Get the number of pixels this symbol extends above the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)aboveStaff {
    return 0;
}

/** Get the number of pixels this symbol extends below the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)belowStaff {
    return 0;
}

/** add by sunlie start */
-(int)repeatFlag {
    return repeatFlag;
}
-(void)setRepeatFlag:(int)r {
    repeatFlag = r;
}
/** add by sunlie end */
-(void)setMeasureWidth:(int)v {
    measureWidth = v;
}

-(int)getMeasureWidth {
    return measureWidth;
}

-(void)setTrackNum:(int)num
{
    tracknum = num;
}

-(void)setTotalTracks:(int)value
{
    totaltracks = value;
}

-(void)setStraffHeight:(int)height
{
    straffHeight = height;
}


/** Draw a vertical bar.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 */
-(void)draw:(CGContextRef)context atY:(int)ytop; {
//    int y = ytop;
//    int yend = y + LineSpace*4 + LineWidth*4;
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(NoteWidth/2, y)];
//    [path addLineToPoint:CGPointMake(NoteWidth/2, yend)];
//    [path setLineWidth:1];
//    [path stroke];
    

    int ystart, yend;
    if (tracknum == 0)
        ystart = ytop - LineWidth;
    else
        ystart = 0;
    
    if (tracknum == (totaltracks-1))
        yend = ytop + 4 * NoteHeight;
    else
        yend = straffHeight;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.5;//fix line width by yizhq
    [path moveToPoint:CGPointMake(NoteWidth/2, ystart)];
    [path addLineToPoint:CGPointMake(NoteWidth/2, yend)];
    [path stroke];
    
    
    [self drawRepeatStartAndEnd:context atY:ytop];
    [self drawRepeat3And4:context atY:ytop];
}




-(void)drawRepeatStartAndEnd:(CGContextRef)context atY:(int)ytop {
    
    if (!(repeatFlag == 1 || repeatFlag == 2)) return;
    
    int xpos = 0, xpos1 = 0;
    int ystart = ytop - LineWidth;
    int yend = ytop + 4 * NoteHeight;
    
    if (repeatFlag == 2) {
        xpos = 0;
        xpos1 = -NoteWidth;
    } else if (repeatFlag == 1) {
        xpos = NoteWidth;
        xpos1 = NoteWidth;
    }
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 1;
    [path moveToPoint:CGPointMake(xpos, ystart)];
    [path addLineToPoint:CGPointMake(xpos, yend)];
    [path stroke];
    
    int ypos1 = ytop +  LineSpace/2;
    CGContextTranslateCTM (context, xpos1 , ypos1);
    CGContextFillEllipseInRect(context, CGRectMake(LineSpace/2, LineSpace, NoteWidth/3, NoteWidth/3));
    CGContextTranslateCTM (context, -xpos1 , -ypos1);
    
    
    int ypos2 = ytop + 2.5 * LineSpace;
    CGContextTranslateCTM (context, xpos1 , ypos2);
    CGContextFillEllipseInRect(context, CGRectMake(LineSpace/2, LineSpace, NoteWidth/3, NoteWidth/3));
    CGContextTranslateCTM (context, -xpos1 , -ypos2);
    
}

-(void)drawRepeat3And4:(CGContextRef)context atY:(int)ytop {
    if (!(repeatFlag == 3 || repeatFlag == 4)) return;
    
    int ystart, xpos = NoteWidth/2;
    ystart = NoteHeight;
    CGPoint point = CGPointMake(NoteWidth, ystart+NoteHeight);

    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xpos, ystart)];
    [path addLineToPoint:CGPointMake(xpos, ystart + NoteHeight/2)];
    
    
    [path moveToPoint:CGPointMake(xpos + measureWidth, ystart)];
    [path addLineToPoint:CGPointMake(xpos + measureWidth, ystart + NoteHeight/2)];
    
    
    [path moveToPoint:CGPointMake(xpos, ystart)];
    [path addLineToPoint:CGPointMake(xpos + measureWidth, ystart)];
    
    [path stroke];
    
    
    char buffer[100];
    memset(buffer, 0x00, sizeof(buffer));
    sprintf(buffer, "%d", repeatFlag-2);
    CGContextSelectFont(context, "Georgia-Italic", 12.0, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetTextMatrix(context, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    CGContextShowTextAtPoint(context, point.x, point.y, buffer, strlen(buffer));
}

- (NSString*)description {
    NSString *s = [NSString stringWithFormat:
                    @"BarSymbol starttime=%d width=%d",
                      starttime, width];
    return s;
}

@end


