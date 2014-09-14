//
//  MessageBox.m
//  Rockwell
//
//  Created by Iori on 13-1-29.
//  Copyright (c) 2013年 Iori. All rights reserved.
//

#import "MessageBox.h"

@implementation MessageBox

+(void)showMsg:(NSString*)strMsg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Infomation", @"AlertView Common's Title, eg Hi, Hello")
                                                         message:strMsg
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

+(IoriLoadingView*)showLoadingViewWithText:(NSString*)strString parentViewSize:(CGSize)pSize
{
    IoriLoadingView *view = [self showLoadingViewWithBlockOnClick:NULL hasCancel:NO parentViewSize:pSize];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    lab.frame = CGRectMake((view.frame.size.width-lab.frame.size.width)/2,
                           (view.frame.size.height-lab.frame.size.height)/2,
                           lab.frame.size.width,
                           lab.frame.size.height);
    lab.text = [@"\n\n\n\n\n" stringByAppendingString:strString];
    lab.numberOfLines = 6;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.backgroundColor = [UIColor clearColor];
    [view addSubview:lab];
    return view;
}


+(IoriLoadingView*)showLoadingViewWithBlockOnClick:(void (^)(IoriLoadingView *loadingView))handle hasCancel:(BOOL)cancel parentViewSize:(CGSize)pSize
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithInteger:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:3.1415926];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 0.65f;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.autoreverses = NO; // Very convenient CA feature for an animation like this
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    IoriLoadingView *view = [[IoriLoadingView alloc] initWithFrame:CGRectMake(0, 0, pSize.width, pSize.height)];
    view.backgroundColor = [UIColor colorWithWhite:.1 alpha:.15];
//    if(!cancel)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_resh.png"]];
        UIImageView *subImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_resh2.png"]];
//        subImageView.frame = CGRectMake((imageView.frame.size.width - subImageView.frame.size.width)/2,
//                                        (imageView.frame.size.height-subImageView.frame.size.height)/2,
//                                        subImageView.frame.size.width,
//                                        subImageView.frame.size.height);
        
        imageView.frame = CGRectMake((view.frame.size.width - imageView.frame.size.width)/2,
                                        (view.frame.size.height-imageView.frame.size.height)/2,
                                        imageView.frame.size.width,
                                        imageView.frame.size.height);
        
        subImageView.frame = CGRectMake((view.frame.size.width - subImageView.frame.size.width)/2,
                                     (view.frame.size.height-subImageView.frame.size.height)/2,
                                     subImageView.frame.size.width,
                                     subImageView.frame.size.height);
        
        
        [view addSubview:imageView];
        [view addSubview:subImageView];
        [imageView.layer addAnimation:rotationAnimation forKey:@"rota"];
        
        
    }
    
    if(cancel)
    {
        UIButton *btnLoading = [UIButton buttonWithType:UIButtonTypeCustom];
//        UIImage *image = [UIImage imageNamed:@"image_resh.png"];
//        UIImage *subImage = [UIImage imageNamed:@"image_resh2.png"];
//        [btnLoading setImage:image forState:UIControlStateNormal];
//        [btnLoading setBackgroundImage:subImage forState:UIControlStateNormal];
//        [btnLoading.imageView.layer addAnimation:rotationAnimation forKey:@"rota"];
        btnLoading.frame = CGRectMake(0,
                                      0,
                                      pSize.width,
                                      pSize.height);
        [btnLoading addTarget:view  action:@selector(cancelLoading) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnLoading];
        view.cancelCompletionBlock = handle;
        
    }
    view.frame = CGRectMake((pSize.width - view.frame.size.width)/2.0,
                                   (pSize.height - view.frame.size.height)/2.0,
                                   view.frame.size.width,
                                   view.frame.size.height);
    
    return view;
}

@end
