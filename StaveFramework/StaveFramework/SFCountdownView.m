//
//  SFCountdownView.h
//  Pod
//
//  Created by Thomas Winkler on 10/02/14.
//  Copyright (c) 2014 SimpliFlow. All rights reserved.
//

#import "SFCountdownView.h"

@interface SFCountdownView ()

@property (nonatomic) NSTimer* timer;
@property (assign,nonatomic) UILabel* countdownLabel;
@property (nonatomic) int currentCountdownValue;

@end

#define COUNTDOWN_LABEL_FONT_SCALE_FACTOR 0.3

@implementation SFCountdownView

-(void)dealloc
{
    if(self.countdownLabel)
    {
        [self.countdownLabel release];
        self.countdownLabel = nil;
    }
    [super dealloc];
}

- (id)initWithParentView:(UIView*)view
{
    if(self  = [super init])
    {
        parent = view;
    }
    return self;
}


- (void) updateAppearance
{
    // countdown label
    float fontSize = parent.bounds.size.width * COUNTDOWN_LABEL_FONT_SCALE_FACTOR;
    
    self.countdownLabel = [[UILabel alloc] init];
    [self.countdownLabel setFont:[UIFont fontWithName:self.fontName size:fontSize]];
    [self.countdownLabel setTextColor:self.countdownColor];
    self.countdownLabel.textAlignment = NSTextAlignmentCenter;
    
    self.countdownLabel.opaque = YES;
    self.countdownLabel.alpha = 0;
    [parent addSubview: self.countdownLabel];
    
    self.countdownLabel.frame =  CGRectMake(312, 300, 400, 200);
}


#pragma mark - start/stopping
- (void) start
{
    [self stop];
    self.currentCountdownValue = self.countdownFrom;
    self.countdownLabel.alpha = 1.0;
//    self.countdownLabel.text = [NSString stringWithFormat:@"%d", self.countdownFrom];
    [self animate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(animate)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void) start:(double)sectionTime withCnt:(int)countCnt{
    [self stop];
    self.currentCountdownValue = countCnt;
    self.countdownLabel.alpha = 1.0;
//    self.countdownLabel.text = [NSString stringWithFormat:@"%d", self.countdownFrom];
    [self animate];
    NSLog(@"section time is %f", sectionTime/countCnt);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(sectionTime/countCnt)
                                                  target:self
                                                selector:@selector(animate)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void) stop
{
    if (self.timer && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - animation stuff

- (void) animate
{
    [UIView animateWithDuration:0.9 animations:^{
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5, 2.5);
        self.countdownLabel.transform = transform;
        self.countdownLabel.backgroundColor=[UIColor clearColor];
        self.countdownLabel.alpha = 0;
        self.countdownLabel.text = self.finishText;
    } completion:^(BOOL finished) {
        if (finished) {
            
            [self stop];
            if (self.delegate) {
                [self.delegate countdownFinished:self];
                self.countdownLabel.text = nil;
            }
        }
    }];
}
- (void) animate2
{
    [UIView animateWithDuration:0.9 animations:^{
        
        CGAffineTransform transform = CGAffineTransformMakeScale(2.5, 2.5);
        self.countdownLabel.backgroundColor=[UIColor clearColor];
        self.countdownLabel.transform = transform;
        self.countdownLabel.alpha = 0;
        
    } completion:^(BOOL finished) {
        if (finished) {
            
            if (self.currentCountdownValue == 0) {
                [self stop];
                if (self.delegate) {
                    [self.delegate countdownFinished:self];
                    self.countdownLabel.text = nil;
                }
                
            } else {
                
                self.countdownLabel.transform = CGAffineTransformIdentity;
                self.countdownLabel.alpha = 1.0;
                
                self.currentCountdownValue--;
                if (self.currentCountdownValue == 0) {
                    self.countdownLabel.text = self.finishText;
                } else {
                    self.countdownLabel.text = [NSString stringWithFormat:@"%d", self.currentCountdownValue ];
                }
            }
        }
    }];
}


#pragma mark - custom getters
- (NSString*)finishText
{
    if (!_finishText) {
        _finishText = @"Go";
    }
    
    return _finishText;
}

- (int) countdownFrom
{
    if (_countdownFrom == 0) {
        _countdownFrom = kDefaultCountdownFrom;
    }
    
    return _countdownFrom;
}

- (UIColor*)countdownColor
{
    if (!_countdownColor) {
        _countdownColor = [UIColor blackColor];
    }
    
    return _countdownColor;
}

- (NSString *)fontName
{
    if (!_fontName) {
        _fontName = @"HelveticaNeue-Medium";
    }
    
    return _fontName;
}



@end
