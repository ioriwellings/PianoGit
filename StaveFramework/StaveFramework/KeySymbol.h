//
//  KeySymbol.h
//  StaveFramework
//
//  Created by 李洪胜 on 14-8-2.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import "MusicSymbol.h"
#import "KeySignature.h"

@interface KeySymbol : NSObject <MusicSymbol> {
    KeySignature *key;
    Array* keys;  
    int clef;              /** Which clef the symbols is in */
    int width;             /** Width of symbol */
}

-(id)initWithKey:(KeySignature *)key andClef:(int) clef andWidh:(int) width;
-(int)clef;
-(void)setClef:(int) c;
-(int)width;
-(void)setWidth:(int) w;
-(void) draw:(CGContextRef) context atY:(int) ytop;
-(void)dealloc;

@end
