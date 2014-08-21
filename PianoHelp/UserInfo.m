//
//  UserInfo.m
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "UserInfo.h"

static UserInfo *_userInfo;

@implementation UserInfo
+ (UserInfo*)sharedUserInfo
{
    @synchronized(self)
    {
        if (_userInfo == nil)
			_userInfo = [[self alloc] init];
    }
    return _userInfo;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (_userInfo == nil)
        {
            _userInfo = [super allocWithZone:zone];
            return _userInfo;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

//- (id)retain
//{
//    return self;
//}
//
//- (unsigned)retainCount
//{
//    return UINT_MAX;  // denotes an object that cannot be released
//}
//
//- (void)release
//{
//    //do nothing
//}
//
//- (id)autorelease
//{
//    return self;
//}

@end
