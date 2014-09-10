//
//  TempoSignature.m
//  StaveFramework
//
//  Created by 李洪胜 on 14-9-1.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import "TempoSignature.h"

@implementation TempoSignature

- (void) setTempo:(int)t {
    _tempo = t;
}
- (int) tempo {
    return _tempo;
}
- (void) setStarttime:(int)starttime
{
    _starttime = starttime;
}
- (int) starttime
{
    return _starttime;
}

- (id) initWithNumerator:(int)tempo andStarttime:(int)starttime
{
    
    if(tempo <= 0 || starttime < 0 )
    {
        return nil;
    }
    
    _tempo = tempo;
    _starttime = starttime;
    
    return self;
}

@end
