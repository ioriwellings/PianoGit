//
//  PracticeRecord.h
//  PianoHelp
//
//  Created by Jobs on 11/16/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PracticeRecord : NSManagedObject

@property (nonatomic, retain) NSString * melodyName;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSString * mode;

@end
