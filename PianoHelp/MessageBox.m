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

@end
