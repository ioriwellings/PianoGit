//
//  IoriLoadingView.h
//  StyleWeekly
//
//  Created by Iori on 13-6-28.
//  Copyright (c) 2013年 Iori. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IoriLoadingView : UIView

@property (nonatomic, strong) void (^cancelCompletionBlock)(IoriLoadingView* view);

-(id)initWithImageView:(UIImageView*)imageView;
-(void)cancelLoading;

@end
