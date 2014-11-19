//
//  Users.h
//  PianoHelp
//
//  Created by Jobs on 11/16/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MelodyFavorite, PracticeRecord;

@interface Users : NSManagedObject

@property (nonatomic, retain) NSString * pwd;
@property (nonatomic, retain) NSNumber * remmberPWD;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *favorite;
@property (nonatomic, retain) NSOrderedSet *record;
@end

@interface Users (CoreDataGeneratedAccessors)

- (void)addFavoriteObject:(MelodyFavorite *)value;
- (void)removeFavoriteObject:(MelodyFavorite *)value;
- (void)addFavorite:(NSSet *)values;
- (void)removeFavorite:(NSSet *)values;

- (void)insertObject:(PracticeRecord *)value inRecordAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRecordAtIndex:(NSUInteger)idx;
- (void)insertRecord:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRecordAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRecordAtIndex:(NSUInteger)idx withObject:(PracticeRecord *)value;
- (void)replaceRecordAtIndexes:(NSIndexSet *)indexes withRecord:(NSArray *)values;
- (void)addRecordObject:(PracticeRecord *)value;
- (void)removeRecordObject:(PracticeRecord *)value;
- (void)addRecord:(NSOrderedSet *)values;
- (void)removeRecord:(NSOrderedSet *)values;
@end
