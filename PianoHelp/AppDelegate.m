//
//  AppDelegate.m
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "AppDelegate.h"
#import "MelodyFavorite.h"
#import "MelodyCategory.h"
#import "Melody.h"
#import "Score.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
//    [self initCategoryAndMelody];
    self.window.backgroundColor = [UIColor lightGrayColor];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PianoHelp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PianoHelp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)initCategoryAndMelody
{
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    //cate.categoryID = @"01";
    cate.name = @"示范曲谱";
    NSError *error;
    
    //    cate.name = @"教材曲谱";
    
    //    cate.name = @"会员曲谱";
    
    //    cate.name = @"影视金曲";
    
    MelodyCategory *cateYingHuang = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    //cate.categoryID = @"02";
    cateYingHuang.parentCategory = cate;
    cateYingHuang.name = @"英皇考级";
    
    
    Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.melodyID = @"聂耳义勇军进行曲";
    melody.category = cateYingHuang;
    melody.author = @"聂耳";
    melody.name = @"义勇军进行曲";
    
    Melody *melody1 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody1.melodyID = @"聂耳黄河大合唱";
    melody1.category = cateYingHuang;
    melody1.author = @"聂耳";
    melody1.name = @"黄河大合唱";
    
    Melody *melody2 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody2.melodyID = @"贝多芬第一交响曲";
    melody2.category = cateYingHuang;
    melody2.author = @"贝多芬";
    melody2.name = @"贝多芬第一交响曲";
    
    Melody *melody3 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody3.melodyID = @"贝多芬第二交响曲";
    melody3.category = cateYingHuang;
    melody3.author = @"贝多芬";
    melody3.name = @"贝多芬第二交响曲";
    
    Melody *melody4 = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody4.melodyID = @"贝多芬第三交响曲";
    melody4.category = cateYingHuang;
    melody4.author = @"贝多芬";
    melody4.name = @"贝多芬第三交响曲";
    
    MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:self.managedObjectContext];
    favo.melody = melody1;
    favo.sort = @1;
    
    Score *score = (Score*)[NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:self.managedObjectContext];
    score.melody = melody1;
    score.rank = @1;
    score.score = @99;
    
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
