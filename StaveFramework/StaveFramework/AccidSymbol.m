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

/** @class AccidSymbol
 * An accidental (accid) symbol represents a sharp, flat, or natural
 * accidental that is displayed at a specific position (note and clef).
 */

#import "AccidSymbol.h"

@implementation AccidSymbol

/**
 * Create a new AccidSymbol with the given accidental, that is
 * displayed at the given note in the given clef.
 */
- (id)initWithAccid:(int)a andNote:(WhiteNote*)note andClef:(int)c {
    accid = a;
    whitenote = [note retain];
    clef = c;
    width = [self minWidth];
    return self;
}

/** Return the white note this accidental is displayed at */
- (WhiteNote*)note {
    return whitenote;
}

/** Get the time (in pulses) this symbol occurs at.
 * Not used.  Instead, the StartTime of the ChordSymbol containing this
 * AccidSymbol is used.
 */
- (int)startTime {
    return -1;
}

/** Get the minimum width (in pixels) needed to draw this symbol */
- (int)minWidth {
    return 3 * NoteHeight/2;
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
}

-(void)setAccid:(int) a {
    accid = a;
}

/** Get the number of pixels this symbol extends above the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)aboveStaff {
    int dist = [[WhiteNote top:clef] dist:whitenote] * 
               NoteHeight/2;
    if (accid == AccidSharp || accid == AccidNatural)
        dist -= NoteHeight;
    else if (accid == AccidFlat)
        dist -= 3*NoteHeight/2;

    if (dist < 0)
        return -dist;
    else
        return 0;
}

/** Get the number of pixels this symbol extends below the staff. Used
 *  to determine the minimum height needed for the staff (Staff:findBounds).
 */
- (int)belowStaff {
    int dist = [[WhiteNote bottom:clef] dist:whitenote] * 
               NoteHeight/2 + NoteHeight;
    if (accid == AccidSharp || accid == AccidNatural) 
        dist += NoteHeight;

    if (dist > 0)
        return dist;
    else 
        return 0;
}

/** Draw the symbol.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 */
- (void) draw:(CGContextRef) context atY:(int)ytop {
    /* Align the symbol to the right */
//    NSAffineTransform *trans = [NSAffineTransform transform];
//    [trans translateXBy:(width - [self minWidth]) yBy:0.0];
//    [trans concat];
    
    CGContextTranslateCTM (context, (width - [self minWidth]), 0);

    /* Store the y-pixel value of the top of the whitenote in ynote. */
    int ynote = ytop + [[WhiteNote top:clef] dist:whitenote] * 
                NoteHeight/2;

    if (accid == AccidSharp)
        [self drawSharp:context atY:ynote];
    else if (accid == AccidFlat)
        [self drawFlat:context atY:ynote];
    else if (accid == AccidNatural)
        [self drawNatural:context atY:ynote];
    else if (accid == DoubleSharp)//chongsheng
        [self DrawDoubleSharp:context atY:ynote];
    else if (accid == DoubleFlat)//chongjiang
        [self DrawDoubleFlat:context atY:ynote];

    CGContextTranslateCTM (context, -(width - [self minWidth]), 0);
}

/** Draw a sharp symbol.
 * @param ynote The pixel location of the top of the accidental's note.
 */
- (void) drawSharp:(CGContextRef) context atY:(int)ynote {
    UIBezierPath *path = [UIBezierPath bezierPath];

    /* Draw the two vertical lines */
    int ystart = ynote - NoteHeight;
    int yend = ynote + 2*NoteHeight;
    int x = NoteHeight/2;
    [path setLineWidth:1];
    [path moveToPoint:CGPointMake(x, ystart + 2)];
    [path addLineToPoint:CGPointMake(x, yend)];
    [path moveToPoint:CGPointMake(x + NoteHeight/2, ystart)];
    [path addLineToPoint:CGPointMake(x + NoteHeight/2, yend-2)];
    [path stroke];

    /* Draw the slightly upwards horizontal lines */
    int xstart = NoteHeight/2 - NoteHeight/4;
    int xend = NoteHeight + NoteHeight/4;
    ystart = ynote + LineWidth;
    yend = ystart - LineWidth - LineSpace/4;
   
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xstart, ystart)];
    [path addLineToPoint:CGPointMake(xend, yend)];
    ystart += LineSpace;
    yend += LineSpace;
    [path moveToPoint:CGPointMake(xstart, ystart)];
    [path addLineToPoint:CGPointMake(xend, yend)];
    [path setLineWidth:LineSpace/2];
    [path stroke];
}

/** Draw a sharp symbol.
 * @param ynote The pixel location of the top of the accidental's note.
 */
- (void)drawFlat:(CGContextRef) context atY:(int)ynote {
    int x = LineSpace/4;
    UIBezierPath* path = [UIBezierPath bezierPath];

    /* Draw the vertical line */
    [path moveToPoint:CGPointMake(x, ynote - NoteHeight - NoteHeight/2)];
    [path addLineToPoint:CGPointMake(x, ynote + NoteHeight)];

    /* Draw 3 bezier curves.
     * All 3 curves start and stop at the same points.
     * Each subsequent curve bulges more and more towards 
     * the topright corner, making the curve look thicker
     * towards the top-right.
     */

    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
          controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
          controlPoint2:CGPointMake(x + LineSpace, ynote + LineSpace/3)
    ];

    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
          controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
          controlPoint2:CGPointMake(x + LineSpace + LineSpace/4,
                                     ynote + LineSpace/3 - LineSpace/4)
    ];


    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
          controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
          controlPoint2:CGPointMake(x + LineSpace + LineSpace/2,
                                     ynote + LineSpace/3 - LineSpace/2)
    ];

    [path setLineWidth:1];
    [path stroke];
}

//add by yizhq start
/**
 * Draw DoubleSharp symbol
 *
 */
-(void)DrawDoubleSharp:(CGContextRef)ctx atY:(int)ynote{

    int x,y,rectwidth,spacing;
    x = - NoteHeight/2;
    y = ynote - NoteHeight;
    rectwidth = 5;
    spacing = 10;
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 1);
    
    CGContextSetLineWidth(ctx, 2);
    CGContextMoveToPoint(ctx, x+2, y+2);
    CGContextAddLineToPoint(ctx, x+spacing+rectwidth-2, y+spacing+rectwidth-2);
    CGContextStrokePath(ctx);
    
    CGContextMoveToPoint(ctx, x+2, y+spacing+rectwidth-2);
    CGContextAddLineToPoint(ctx, x+spacing+rectwidth-2, y+2);
    CGContextStrokePath(ctx);
    
	CGContextSetLineWidth(ctx, 0.5);
	
	CGRect rcts[4];
	rcts[0] = CGRectMake(x, y, 5, 5);
	rcts[1] = CGRectMake(x, y+spacing, 5, 5);
	rcts[2] = CGRectMake(x+spacing, y, 5, 5);
	rcts[3] = CGRectMake(x+spacing, y+spacing, 5, 5);
	CGContextAddRects(ctx, rcts, 4);
    CGContextDrawPath(ctx, kCGPathFill);
	CGContextStrokePath(ctx);
}

/**
 * Draw DoubleFlat symbol
 *
 */
-(void)DrawDoubleFlat:(CGContextRef)context atY:(int)ynote{
    int x = LineSpace/4;
    int x1 = -LineSpace;
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(x, ynote - NoteHeight - NoteHeight/2)];
    [path addLineToPoint:CGPointMake(x, ynote + NoteHeight)];
    
    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x + LineSpace, ynote + LineSpace/3)
     ];
    
    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x + LineSpace + LineSpace/4,
                                      ynote + LineSpace/3 - LineSpace/4)
     ];
    
    
    [path moveToPoint:CGPointMake(x, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x + LineSpace + LineSpace/2,
                                      ynote + LineSpace/3 - LineSpace/2)
     ];
    
    [path moveToPoint:CGPointMake(x1, ynote - NoteHeight - NoteHeight/2)];
    [path addLineToPoint:CGPointMake(x1, ynote + NoteHeight)];
    
    /* Draw 3 bezier curves.
     * All 3 curves start and stop at the same points.
     * Each subsequent curve bulges more and more towards
     * the topright corner, making the curve look thicker
     * towards the top-right.
     */
    
    [path moveToPoint:CGPointMake(x1, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x1, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x1 + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x1 + LineSpace, ynote + LineSpace/3)
     ];
    
    [path moveToPoint:CGPointMake(x1, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x1, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x1 + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x1 + LineSpace + LineSpace/4,
                                      ynote + LineSpace/3 - LineSpace/4)
     ];
    
    
    [path moveToPoint:CGPointMake(x1, ynote + LineSpace/4)];
    [path addCurveToPoint:CGPointMake(x1, ynote + LineSpace + LineWidth + 1)
            controlPoint1:CGPointMake(x1 + LineSpace/2, ynote - LineSpace/2)
            controlPoint2:CGPointMake(x1 + LineSpace + LineSpace/2,
                                      ynote + LineSpace/3 - LineSpace/2)
     ];
    
    [path setLineWidth:1];
    [path stroke];
}
//add by yizhq end
/** Draw a natural symbol.
 * @param ynote The pixel location of the top of the accidental's note.
 */
- (void)drawNatural:(CGContextRef) context atY:(int)ynote {
    UIBezierPath* path = [UIBezierPath bezierPath];

    /* Draw the two vertical lines */
    int ystart = ynote - LineSpace - LineWidth;
    int yend = ynote + LineSpace + LineWidth;
    int x = LineSpace/2;

    [path moveToPoint:CGPointMake(x, ystart)];
    [path addLineToPoint:CGPointMake(x, yend)];
    x += LineSpace - LineSpace/4;
    ystart = ynote - LineSpace/4;
    yend = ynote + 2*LineSpace + LineWidth - LineSpace/4;
    [path moveToPoint:CGPointMake(x, ystart)];
    [path addLineToPoint:CGPointMake(x, yend)];
    [path setLineWidth:1];
    [path stroke];

    /* Draw the slightly upwards horizontal lines */
    path = [UIBezierPath bezierPath];
    int xstart = LineSpace/2;
    int xend = xstart + LineSpace - LineSpace/4;
    ystart = ynote + LineWidth;
    yend = ystart - LineWidth - LineSpace/4;
    [path moveToPoint:CGPointMake(xstart, ystart)];
    [path addLineToPoint:CGPointMake(xend, yend)];
    ystart += LineSpace;
    yend += LineSpace;
    [path moveToPoint:CGPointMake(xstart, ystart)];
    [path addLineToPoint:CGPointMake(xend, yend)];

    [path setLineWidth:LineSpace/2];
    [path stroke];
}

- (NSString*)description {
    NSString* names[] = { @"None", @"Sharp", @"Flat", @"Natural" };
    NSString* clefs[] = { @"Treble", @"Bass" };
    NSString *s = [NSString stringWithFormat: 
                     @"AccidSymbol accid=%@ whitenote=%@ clef=%@ width=%d",
                     names[accid], [whitenote description], clefs[clef], width];
    return s;
}

- (void)dealloc {
    [whitenote release];
    [super dealloc];
}

@end


