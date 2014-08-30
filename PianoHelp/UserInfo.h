//
//  UserInfo.h
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Users.h"

@interface UserInfo : NSObject
{
    
}
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) Users *dbUser;

+ (UserInfo*)sharedUserInfo;

-(void)logout;
@end
