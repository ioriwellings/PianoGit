//
//  Users.h
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MelodyFavorite;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * pwd;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *favorite;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addFavoriteObject:(MelodyFavorite *)value;
- (void)removeFavoriteObject:(MelodyFavorite *)value;
- (void)addFavorite:(NSSet *)values;
- (void)removeFavorite:(NSSet *)values;

@end
