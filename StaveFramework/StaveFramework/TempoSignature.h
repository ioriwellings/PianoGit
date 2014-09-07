//
//  TempoSignature.h
//  StaveFramework
//
//  Created by 李洪胜 on 14-9-1.
//  Copyright (c) 2014年 yizhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TempoSignature : NSObject{
    int _tempo;
    int _starttime;      /** starttime of the beat signature */
}

- (void) setTempo:(int)t;
- (int) tempo;

- (void) setStarttime:(int)starttime;
- (int) starttime;

- (id) initWithNumerator:(int)tempo andStarttime:(int)starttime;


@end
