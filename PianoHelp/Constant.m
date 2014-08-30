//
//  Constant.m
//  HttpRequest
//
//  Created by zhengyw on 14-8-26.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import "Constant.h"

@implementation Constant

@synthesize G_WEBSERVICE_ERROR;


- (id)init
{
    self = [super init];
    if (self) {
        //远程Web Service调用失败后返回值前缀，即返回的字符串中如果以该字符串开头，则说明调用失败
        G_WEBSERVICE_ERROR = [[NSString alloc] initWithFormat:@"ResponseError\n"];
    }
    
    return self;
}

+(Constant *)sharedConstant
{
    static Constant * sharedConstant;
    @synchronized(self)
    {
        if (!sharedConstant) {
            sharedConstant = [[Constant alloc] init];
        }
    }
    return sharedConstant;
}


@end
