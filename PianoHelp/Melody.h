//
//  Melody.h
//  PianoHelp
//
//  Created by Jobs on 8/13/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MelodyCategory, MelodyFavorite;

@interface Melody : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * buy;
@property (nonatomic, retain) NSString * buyURL;
@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * deviceID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * melodyID;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * scrawlPath;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) MelodyCategory *category;
@property (nonatomic, retain) NSSet *favorite;
@end

@interface Melody (CoreDataGeneratedAccessors)

- (void)addFavoriteObject:(MelodyFavorite *)value;
- (void)removeFavoriteObject:(MelodyFavorite *)value;
- (void)addFavorite:(NSSet *)values;
- (void)removeFavorite:(NSSet *)values;

@end
