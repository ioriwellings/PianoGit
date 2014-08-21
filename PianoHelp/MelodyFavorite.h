//
//  MelodyFavorite.h
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Melody, Score, Users;

@interface MelodyFavorite : NSManagedObject

@property (nonatomic, retain) NSString * melodyID;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Melody *melody;
@property (nonatomic, retain) Users *user;
@property (nonatomic, retain) Score *score;

@end
