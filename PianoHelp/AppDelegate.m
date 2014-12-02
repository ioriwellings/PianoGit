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
#import "UserInfo.h"
#import "Users.h"
#import "IAPHelper.h"
#import "MessageBox.h"
#import "NSString+URLConnection.h"
#import "StaveFramework/MidiKeyboard.h"
#import "PracticeRecord.h"
@implementation AppDelegate
{
    BOOL bInited;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(void)addPracticeRecordWithName:(NSString*)strName score:(NSNumber *)iScore mode:(NSString *)str
{
    strName = [[strName stringByDeletingPathExtension] lastPathComponent];
    PracticeRecord *_record = (PracticeRecord*)[NSEntityDescription insertNewObjectForEntityForName:@"PracticeRecord" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    _record.melodyName = strName;
    _record.createDate = [NSDate date];
    _record.mode = str;
    _record.score = iScore;
    [[UserInfo sharedUserInfo].dbUser addRecordObject:_record];
    [self saveContext];
}

-(BOOL)isInited
{
    return bInited;
}

-(Users*)getCurrentUsers
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Users" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName == %@", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        return [objects firstObject];
    }
    return nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.backgroundColor = [UIColor lightGrayColor];
//    [self.window makeKeyAndVisible];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[IAPHelper shareIAPHelper]];
    
    [UserInfo sharedUserInfo].userName = @"guest";
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    NSInteger iLoop = 0;
    while (iLoop > 0)
    {
        [self initCategoryAndMelody];
        iLoop--;
    }
//    [self loadDemoMidiToSQL];
//    [self loadTempMIDE];//for test
    [self initDataBaseWithPList:nil];
    [MidiKeyboard sharedMidiKeyboard];
    [UserInfo sharedUserInfo].dbUser = [self getCurrentUsers];
//    [self addPracticeRecordWithName:[NSDate date].description score:0 mode:nil];
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
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[IAPHelper shareIAPHelper]];
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
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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

-(NSString*)filePathForName:(NSString*)fileName
{
    NSString *strResult = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    if(strResult == nil)
    {
        NSString *strCachePath = [self getCacheDirectoryURL];
        strResult = [[strCachePath stringByAppendingPathComponent:@"temp"] stringByAppendingPathComponent:fileName];
    }
    return strResult;
}

-(void)initCategoryAndMelody
{
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"示范曲谱";

    MelodyCategory *cateYingHuang = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
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
    score.rank = @1;
    score.score = @99;
    favo.score = score;
    
    for (int i=1; i<10; i++)
    {
        MelodyCategory *cateYingHuang = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
        cateYingHuang.parentCategory = cate;
        cateYingHuang.name = [NSString stringWithFormat:@"英皇考级%d", i];
    }
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

-(void)loadDemoMidiToSQL
{
    NSString *strDocumentPath = [self getCacheDirectoryURL];
    NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:@"initialedData.file"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:strImageDir])
    {
        [[NSFileManager defaultManager] createFileAtPath:strImageDir contents:nil attributes:nil];
    }
    else return;
    [self loadTempMIDE];
//    NSManagedObjectContext *moc = self.managedObjectContext;
//    Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:moc];
//    user.userName = [UserInfo sharedUserInfo].userName;
//    user.pwd = [NSString string];
    
//大类
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"考级";
    cate.cover = @"jiaocaiqupu.png";
    cate.buy = @2;
    cate.buyURL = @"com.jiaYinQiJi.product.a";
//子类
    MelodyCategory *cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"中国音协第六级－第八级";
    cate_sub.parentCategory = cate;
    
    Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拉可夫";
    melody.name = @"波尔卡";
    melody.melodyID = melody.name;
    melody.filePath = @"01.波尔卡.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"6";
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"于苏贤";
    melody.name = @"儿童舞";
    melody.melodyID = melody.name;
    melody.filePath = @"08.儿童舞.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"7";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"皮埃松卡";
    melody.name = @"塔兰泰拉舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"09.塔兰泰拉舞曲.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"7";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"巴赫";
    melody.name = @"布列舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"14.布列舞曲.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"6";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
//子类
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"中国音协第一级－第五级";
    cate_sub.parentCategory = cate;
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"瞿希贤";
    melody.name = @"听妈妈讲那过去的故事";
    melody.melodyID = melody.name;
    melody.filePath = @"04.听妈妈讲那过去的故事.mid";
    melody.style = @"复调性乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"5";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"卡尔汉斯";
    melody.name = @"森林波尔卡";
    melody.melodyID = melody.name;
    melody.filePath = @"05.森林波尔卡.mid";
    melody.style = @"乐曲";
    melody.memo = @"中国音乐家协会 2007";
    melody.level = @"4";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
//大类
    cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"教程";
    cate.cover = @"kaojiqupu.png";
//子类
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"约翰汤普森现代钢琴教程，第二册";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"淘气包";
    melody.melodyID = melody.name;
    melody.filePath = @"03.淘气包.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"带我回弗吉尼故乡";
    melody.melodyID = melody.name;
    melody.filePath = @"07.带我回弗吉尼故乡.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"诙谐曲";
    melody.melodyID = melody.name;
    melody.filePath = @"10.诙谐曲.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"星光圆舞曲";
    melody.melodyID = melody.name;
    melody.filePath = @"11.星光圆舞曲.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"约翰汤普森";
    melody.name = @"卡门";
    melody.melodyID = melody.name;
    melody.filePath = @"16.卡门.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"车尔尼849";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"849-3首";
    melody.melodyID = melody.name;
    melody.filePath = @"02.849-03.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"车尔尼599";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"599-54课";
    melody.melodyID = melody.name;
    melody.filePath = @"13.599-054.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"车尔尼";
    melody.name = @"599-58课";
    melody.melodyID = melody.name;
    melody.filePath = @"15.599-058.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"拜厄钢琴基本教程";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拜厄";
    melody.name = @"拜尔-100课";
    melody.melodyID = melody.name;
    melody.filePath = @"06.拜尔-100.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // ====
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"拜厄幼儿钢琴教程";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"拜厄";
    melody.name = @"幼儿拜尔-104课";
    melody.melodyID = melody.name;
    melody.filePath = @"12.幼儿拜尔-104课.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }


    //====
    
    cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"流行歌曲";
    cate.cover = @"shifanqupu.png";
    cate.buy = @1;
    cate.buyURL = @"com.jiaYinQiJi.product.b";
    
    cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"经典系列";
    cate_sub.parentCategory = cate;
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"秋日私语";
    melody.melodyID = melody.name;
    melody.filePath = @"17.秋日私语.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"水边的阿第丽娜";
    melody.melodyID = melody.name;
    melody.filePath = @"18.水边的阿第丽娜.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"理查德克莱德曼";
    melody.name = @"献给爱丽丝";
    melody.melodyID = melody.name;
    melody.filePath = @"19.献给爱丽丝.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
    melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate_sub;
    melody.author = @"识谱模式C大调";
    melody.name = @"识谱模式C大调";
    melody.melodyID = melody.name;
    melody.filePath = @"识谱模式C大调.mid";
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

-(void)loadTempMIDE
{
    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mid" inDirectory:@"temp"];
    
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = @"测试";
    cate.cover = @"jiaocaiqupu.png";
    
    MelodyCategory *cate_sub = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate_sub.name = @"临时的";
    cate_sub.parentCategory = cate;
    
    for (NSString *path in array)
    {

        Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
        melody.category = cate_sub;
        melody.author = @"拉可夫";
        melody.name = [path lastPathComponent];
        melody.melodyID = melody.name;
        melody.filePath = [NSString stringWithFormat:@"temp/%@", melody.name];
    }
    
    NSError *error;
    if(![self.managedObjectContext save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
}

#pragma mark -Update melody from webserver-

-(NSString*)getCacheDirectoryURL
{
    return [NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
}

-(void)checkForUpdate
{
    NSString *strUpdateFile = [[self getCacheDirectoryURL] stringByAppendingPathComponent:@"update.config"];
    NSString *strURL;
    if(![[NSFileManager defaultManager] fileExistsAtPath:strUpdateFile])
    {
        strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:@"checkForUpdate.ashx"];
    }
    else
    {
        NSString *strValue = [NSString stringWithContentsOfFile:strUpdateFile encoding:NSASCIIStringEncoding error:nil];
        strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:[NSString stringWithFormat:@"checkForUpdate.ashx?update=%@", strValue]];
    }
    
    [strURL getURLData:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        NSHTTPURLResponse* __response = (NSHTTPURLResponse*)response;
        if(error == NULL && data.length >0 && [__response statusCode] != 404 && [__response statusCode] != 503)
        {
            NSString *strUpdateDirPath = [[self getCacheDirectoryURL] stringByAppendingPathComponent:@"updateZip"];
            NSString *strFilePath = [[self getCacheDirectoryURL] stringByAppendingPathComponent:@"update.zip"];
            [data writeToFile:strFilePath atomically:YES];
            [SSZipArchive unzipFileAtPath:strFilePath
                            toDestination:strUpdateDirPath
                                 delegate:self];
            NSString *plistPath = [strUpdateDirPath stringByAppendingPathComponent:@"update.plist"];
            NSString *zipPath = [strUpdateDirPath stringByAppendingPathComponent:@"temp"];
            
            [self updatingWithPlist:plistPath zip:zipPath];
            [self saveContext];
            
            [[NSFileManager defaultManager] removeItemAtPath:strFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:strUpdateDirPath error:nil];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd hh:mm"];
            NSString *strContent = [formatter stringFromDate:[NSDate date]];
            [strContent writeToFile:strUpdateFile atomically:YES encoding:NSASCIIStringEncoding error:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateOK" object:nil userInfo:nil];
    }];
}

-(void)updatingWithPlist:(NSString*)plistPath zip:(NSString*)zipPath
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSInteger iCount =0;
    for (id ele in dict)
    {
//        NSLog(@"-- %i,subCate:%@", iCount, ele);
        MelodyCategory *subCate = [self getCategoryWithName:ele isSubCategory:YES];
        MelodyCategory *cate = nil;
        NSInteger jCount =0;
        for (id items in dict[ele])
        {
            if(!cate)
            {
                cate = [self getCategoryWithName:[dict[ele][items] objectForKey:@"类别"] isSubCategory:NO];
                if(subCate.parentCategory == nil)
                {
                    subCate.parentCategory = cate;
                }
            }
            Melody* melody = [self getMelodyWithCategory:subCate
                                                  author:[dict[ele][items] objectForKey:@"作者"]
                                                   level:[dict[ele][items] objectForKey:@"级别"]
                                                   style:[dict[ele][items] objectForKey:@"出版社"]
                                             association:[dict[ele][items] objectForKey:@"作品集"]
                                                filePath:[dict[ele][items] objectForKey:@"曲谱名称"]];
//            NSLog(@"    -- %i, Cate:%@, 曲谱名称:%@, memody:%@",
//                  jCount,
//                  [dict[ele][items] objectForKey:@"类别"],
//                  [dict[ele][items] objectForKey:@"曲谱名称"],
//                  melody);
            jCount++;
        }
        iCount ++;
    }
    [NSFileManager defaultManager].delegate = self;
    [[NSFileManager defaultManager] copyItemAtPath:zipPath toPath:[[self getCacheDirectoryURL] stringByAppendingPathComponent:@"temp"] error:nil];
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error movingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath;
{
    BOOL isDir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:&isDir] && isDir == NO)
    {
        NSFileWrapper *wrap = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:dstPath] options:NSFileWrapperReadingImmediate error:nil];
        [wrap setFilename:[[dstPath lastPathComponent] stringByAppendingPathComponent:@"123"]];
    }
    return YES;
}


- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    BOOL isDir;
    //NSString *dstPath = [[[self getCacheDirectoryURL] stringByAppendingPathComponent:@"temp"] stringByAppendingPathComponent:[zipPath lastPathComponent]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:&isDir] && isDir == NO)
    {
        [[NSFileManager defaultManager] removeItemAtPath:dstPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:nil];
    }
    return YES;
}

#pragma mark - init plist methods-

-(void)initDataBaseWithPList:(NSString*)strPath
{
    NSString *strDocumentPath = [self getCacheDirectoryURL];
    NSString *strImageDir = [strDocumentPath stringByAppendingPathComponent:@"initialedPLIST.file"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:strImageDir])
    {
        [[NSFileManager defaultManager] createFileAtPath:strImageDir contents:nil attributes:nil];
    }
    else
    {
        bInited = YES;
        return;
    }
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:moc];
    user.userName = [UserInfo sharedUserInfo].userName;
    user.pwd = [NSString string];
    
//    __block NSString *strPath = path;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
//    {
        if(![[NSFileManager defaultManager] fileExistsAtPath:strPath])
        {
            strPath = [[NSBundle mainBundle] pathForResource:@"dataSource" ofType:@"plist"];
        }
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:strPath];
        NSInteger iCount =0;
        for (id ele in dict)
        {
//            NSLog(@"-- %i,subCate:%@", iCount, ele);
            MelodyCategory *subCate = [self getCategoryWithName:ele isSubCategory:YES];
            MelodyCategory *cate = nil;
            NSInteger jCount =0;
            for (id items in dict[ele])
            {
                if(!cate)
                {
                    cate = [self getCategoryWithName:[dict[ele][items] objectForKey:@"类别"] isSubCategory:NO];
                    if(subCate.parentCategory == nil)
                    {
                        subCate.parentCategory = cate;
                    }
                    if([cate.name isEqualToString:@"试练曲集"])
                    {
                        
                    }
                }
                Melody* melody = [self getMelodyWithCategory:subCate
                                                      author:[dict[ele][items] objectForKey:@"作者"]
                                                       level:[dict[ele][items] objectForKey:@"级别"]
                                                       style:[dict[ele][items] objectForKey:@"出版社"]
                                                 association:[dict[ele][items] objectForKey:@"作品集"]
                                                    filePath:[dict[ele][items] objectForKey:@"曲谱名称"]];
//                NSLog(@"    -- %i, Cate:%@, 曲谱名称:%@, memody:%@",
//                      jCount,
//                      [dict[ele][items] objectForKey:@"类别"],
//                      [dict[ele][items] objectForKey:@"曲谱名称"],
//                      melody);
                jCount++;
            }
            iCount ++;
        }
        
        NSError *error;
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *strCachePath = [self getCacheDirectoryURL];
        [SSZipArchive unzipFileAtPath:[self filePathForName:@"temp.zip"]
                        toDestination:strCachePath
                             delegate:self];
    });
}


-(MelodyCategory*)getCategoryWithName:(NSString*)strName isSubCategory:(BOOL)bSub
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    if(bSub)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ and parentCategory != nil", strName];
        [fetchRequest setPredicate:predicate];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ and parentCategory == nil", strName];
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        return (MelodyCategory*)[objects firstObject];
    }
    
    MelodyCategory *cate = (MelodyCategory*)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
    cate.name = strName;
    if([strName isEqualToString:@"考级"])
    {
        cate.cover = @"kaojiqupu.png";
        cate.buy = @2;
        cate.buyURL = @"com.jiaYinQiJi.product.b";
    }
    else if([strName isEqualToString:@"教程"])
    {
        cate.cover = @"jiaocaiqupu.png";
        cate.buy = @0;
        cate.buyURL = @"com.jiaYinQiJi.product.a";
    }
    
    return cate;
}

-(Melody*)getMelodyWithCategory:(MelodyCategory*)cate author:(NSString*)strAuthor level:(NSString*)strLevel style:(NSString*)strStyle association:(NSString*)strAssoc filePath:(NSString*)strPath
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Melody" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND category=%@ AND author=%@",
                              [strPath lastPathComponent],
                              cate,
                              strAuthor];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        return (Melody*)[objects firstObject];
    }
    
    Melody *melody = (Melody*)[NSEntityDescription insertNewObjectForEntityForName:@"Melody" inManagedObjectContext:self.managedObjectContext];
    melody.category = cate;
    melody.author = strAuthor;
    melody.name = [strPath lastPathComponent];
    melody.style = strStyle;
    melody.memo = strAssoc;
    melody.level = strLevel;
    melody.melodyID = melody.name;
    melody.filePath = [melody.name stringByAppendingPathExtension:@"mid"];
    return melody;
}


#pragma mark - zip delegate -

- (void)zipArchiveProgressEvent:(NSInteger)loaded total:(NSInteger)total
{
    //NSLog(@"zipArchiveProgress:%li/%li", (long)loaded, (long)total);
}

- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath
{
    bInited = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"zipOK" object:nil userInfo:nil ];
}

@end
