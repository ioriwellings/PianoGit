//
//  MessageBox.h
//  Rockwell
//
//  Created by Iori on 13-1-29.
//  Copyright (c) 2013年 Iori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IoriLoadingView.h"

@interface MessageBox : NSObject
{
    
}

+(void)showMsg:(NSString*)strMsg;
+(IoriLoadingView*)showLoadingViewWithBlockOnClick:(void (^)(IoriLoadingView *loadingView))handle hasCancel:(BOOL)cancel parentViewSize:(CGSize)pSize;
@end
