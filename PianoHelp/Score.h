//
//  Score.h
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Score : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * good;
@property (nonatomic, retain) NSString * melodyID;
@property (nonatomic, retain) NSNumber * miss;
@property (nonatomic, retain) NSString * pattern;
@property (nonatomic, retain) NSNumber * perfect;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * toneCount;
@property (nonatomic, retain) NSNumber * upload;

@end
