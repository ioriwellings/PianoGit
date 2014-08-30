//
//  Constant.h
//  HttpRequest
//
//  Created by zhengyw on 14-8-26.
//  Copyright (c) 2014年 zhengyw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject

//远程Web Service调用失败后返回值前缀，即返回的字符串中如果以该字符串开头，则说明调用失败
@property (readonly) NSString * G_WEBSERVICE_ERROR;

+ (Constant *)sharedConstant;

@end
