//
//  KeySymbol.m
//  StaveFramework
//
//  Created by 李洪胜 on 14-8-2.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import "KeySymbol.h"
#import "AccidSymbol.h"

@implementation KeySymbol
- (id)initWithKey:(KeySignature *)k andClef:(int)c andWidh:(int)w{
    key = k;
    clef = c;
    keys = [[key getSymbols:clef] retain];
    width = w;
    return self;
}

- (int)startTime {
    return -1;
}

- (int)minWidth {
    return 3 * NoteHeight/2;
}

- (int)width {
    return width;
}

- (void)setWidth:(int)w {
    width = w;
}

-(int)clef {
    return  clef;
}
-(void)setClef:(int) c {
    clef = c;
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

/** Draw the symbol.
 * @param ytop The ylocation (in pixels) where the top of the staff starts.
 */
- (void) draw:(CGContextRef) context atY:(int)ytop {
    int xpos = 0;
    int i;
    
    for (i = 0; i < [keys count]; i++) {
        AccidSymbol *a = [keys get:i];
        CGContextTranslateCTM (context, xpos, 0.0);
        [a draw:context atY:ytop];
        CGContextTranslateCTM (context, -xpos, 0.0);
        
        xpos += [a width];
    }
    if ([key preKey] != 0) {
        KeySignature *tmp;
        Array *tmpKeys;
        if ([key preKey] > 0 ) {
            tmp = [[KeySignature alloc] initWithSharps:[key preKey] andFlats:0 andPreKey: 0];
        } else {
            tmp = [[KeySignature alloc] initWithSharps:0 andFlats:-[key preKey] andPreKey: 0];
        }
        tmpKeys = [[tmp getSymbols:clef] retain];
        for (i = 0; i < [tmpKeys count]; i++) {
            AccidSymbol *a = [tmpKeys get:i];
            [a setAccid:AccidNatural];
            CGContextTranslateCTM (context, xpos, 0.0);
            [a draw:context atY:ytop];
            CGContextTranslateCTM (context, -xpos, 0.0);
            
            xpos += [a width];
        }
    }
}

- (void)dealloc {
    [key release];
    [keys release];
    [super dealloc];
}

@end
