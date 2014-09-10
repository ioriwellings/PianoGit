//
//  BeatSignature.m
//  PainoSpirit
//
//  Created by yizhq on 14-4-7.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "BeatSignature.h"


@implementation BeatSignature


- (void) setNumerator:(int)numerator
{
    _numerator = numerator;
}
- (int) numerator
{
    return _numerator;
}

- (void) setDenominator:(int)denominator
{
    _denominator = denominator;
}
- (int) denominator
{
    return _denominator;
}
//- (void) setTempo:(int)t {
//    _tempo = t;
//}
//- (int) tempo {
//    return _tempo;
//}
- (void) setStarttime:(int)starttime
{
    _starttime = starttime;
}
- (int) starttime
{
    return _starttime;
}

- (id) initWithNumerator:(int)numerator andDenominator:(int)denominator andStarttime:(int)starttime
{

    if(numerator <= 0 || denominator <= 0 || starttime < 0 )
    {
        return nil;
    }
    
    if(numerator == 5)
    {
        numerator = 4;
    }

    _denominator = denominator;
    _numerator = numerator;
//    _tempo = tempo;
    _starttime = starttime;
    
    return self;
}
@end
