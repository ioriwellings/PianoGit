//
//  IoriLoadingView.m
//  StyleWeekly
//
//  Created by Iori on 13-6-28.
//  Copyright (c) 2013年 Iori. All rights reserved.
//

#import "IoriLoadingView.h"

@implementation IoriLoadingView
{
    __weak UIImageView *rotaImageView;
}

-(id)initWithImageView:(UIImageView*)imageView
{
    if(self = [super initWithFrame:imageView.frame])
    {
        rotaImageView = imageView;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)dealloc
{
#if DEBUG
    NSLog(@"debugLog: %@ dealloc.", [self class]);
#endif
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)cancelLoading
{
    [rotaImageView.layer removeAnimationForKey:@"rota"];
    if(self.cancelCompletionBlock)
    {
        self.cancelCompletionBlock(self);
    }
    [self removeFromSuperview];
}

@end
