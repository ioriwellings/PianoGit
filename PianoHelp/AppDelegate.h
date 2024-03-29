//
//  AppDelegate.h
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSZipArchive.h"
#import "WXApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SSZipArchiveDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)initCategoryAndMelody;
-(NSString*)filePathForName:(NSString*)fileName;
-(void)loadDemoMidiToSQL;
-(BOOL)isInited;
-(void)checkForUpdate;
-(void)addPracticeRecordWithName:(NSString*)strName score:(NSNumber*)iScore mode:(NSString*)str;
-(void)addLoginDay;
@end
