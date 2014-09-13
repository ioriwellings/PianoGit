//
//  QinFangViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "QinFangViewController.h"
#import "AppDelegate.h"
#import "MelodyFavorite.h"
#import "Melody.h"
#import "FavoriteTableViewCell.h"
#import "MelodyDetailViewController.h"
#import "UserInfo.h"

@interface QinFangViewController ()
@property (nonatomic, weak) UIButton *btnModel;
@property (nonatomic, weak) UIButton *btnScope;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController0;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController1;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController2;
//@property (nonatomic, strong) NSMutableArray *melodyArray;
@end

@implementation QinFangViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadingData:)
                                                 name:kLoginSuccessNotification object:nil];
    
    
}

-(void)resetFetchedResultController
{
    self.fetchedResultsController0 = nil;
    self.fetchedResultsController1 = nil;
    self.fetchedResultsController2 = nil;
    [self btnScope_click:self.btnAll]; //切换默认的tab，下次进来会强制跳到任务里，避免数据被缓存
}

-(void)loadingData:(NSNotification *)notification
{
    switch(self.type )
    {
        case 1://love
            [self btnScope_click:self.btnLove];
            self.btnScope = self.btnLove;
            break;
        case 2://task
            [self btnScope_click:self.btnTask];
            self.btnScope = self.btnTask;
            break;
        case 3://all
            [self btnScope_click:self.btnAll];
            self.btnScope = self.btnAll;
            break;
        default:
            [self btnScope_click:self.btnTask];
            self.btnScope = self.btnTask;
            break;
    }
    
    [self.btnScope setSelected:YES];
    self.btnModel = self.btnPlayModel;
    [self.btnPlayModel setSelected:YES];
    
    [self setNumberoOfEveryGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNumberoOfEveryGroup)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //if(!IS_RUNNING_IOS7)
    {
        for (UIView *subView in self.toolBar.subviews)
        {
            if([subView isKindOfClass:[UIImageView class]])
            {
                [subView removeFromSuperview];
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"melodyDetailSegue"])
    {
        MelodyDetailViewController *vc = segue.destinationViewController;
        vc.iPlayMode = self.btnModel.tag;
        //add test by zyw
        NSString *filename = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) filePathForName:((MelodyButton*)sender).fileName];
        vc.fileName = filename;
        vc.saveName = ((MelodyButton*)sender).fileName;
    }
}


#pragma mark - UITableView data source and delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.btnScope.tag == 0 )
        return 40;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    headView.backgroundColor = [UIColor colorWithWhite:0.01 alpha:0.02];
    UILabel *view = [[UILabel alloc] init];
    view.backgroundColor = [UIColor darkGrayColor];
    view.textColor = [UIColor whiteColor];
    view.textAlignment = NSTextAlignmentCenter;
    view.shadowColor = [UIColor grayColor];
    view.shadowOffset = CGSizeMake(1, 2);
    //view.backgroundColor = [UIColor lightGrayColor];
//    view.alpha = 0.9;

    NSString *strSectionTitle = [[[self.fetchedResultsController0 sections] objectAtIndex:section] name];
    if([strSectionTitle isEqualToString:@"1"])
        view.text = @"喜爱";
    if([strSectionTitle isEqualToString:@"2"])
        view.text = @"任务";
    if([strSectionTitle isEqualToString:@"3"])
    {
        view.text = @"任务与喜爱";
        view.frame = CGRectMake(tableView.frame.size.width-100, 0, 100, 30);
    }
    else
    {
        view.frame = CGRectMake(tableView.frame.size.width-40, 0, 40, 30);
    }
    [headView addSubview:view];
    return headView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.btnScope.tag == 0)
    {
        NSUInteger iCount = [[self.fetchedResultsController0 sections] count];
        return iCount;
    }
    if(self.btnScope.tag == 1)
    {
        NSUInteger iCount = [[self.fetchedResultsController1 sections] count];
        return iCount;
    }
    if(self.btnScope.tag == 2)
    {
        NSUInteger iCount = [[self.fetchedResultsController2 sections] count];
        return iCount;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    if(self.btnScope.tag == 0)
    {
        NSArray *sections = [self.fetchedResultsController0 sections];
        if([sections count]>0)
            sectionInfo = [sections objectAtIndex:section];
        else
        {
            return 0;
        }
    }
    else if(self.btnScope.tag == 1)
    {
        NSArray *sections = [self.fetchedResultsController1 sections];
        if([sections count]>0)
            sectionInfo = [sections objectAtIndex:section];
        else
        {
            return 0;
        }
    }
    else if(self.btnScope.tag == 2)
    {
        NSArray *sections = [self.fetchedResultsController2 sections];
        if([sections count]>0)
            sectionInfo = [sections objectAtIndex:section];
        else
        {
            return 0;
        }
    }
    NSUInteger iResult = [sectionInfo numberOfObjects];
    return iResult;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
    static NSString *CellIdentifier = @"FavoriteTableCell";
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MelodyFavorite *melodyFavo = nil;
    if(self.btnScope.tag == 0)
    {
        melodyFavo = [self.fetchedResultsController0 objectAtIndexPath:indexPath];
    }
    else if(self.btnScope.tag == 1)
    {
        melodyFavo = [self.fetchedResultsController1 objectAtIndexPath:indexPath];
    }
    else if(self.btnScope.tag == 2)
    {
        melodyFavo = [self.fetchedResultsController2 objectAtIndexPath:indexPath];
    }
    ((FavoriteTableViewCell*)cell).tableView = tableView;
    ((FavoriteTableViewCell*)cell).indexPath = indexPath;
    [((FavoriteTableViewCell*)cell) updateContent:melodyFavo];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    FavoriteTableViewCell *cell = (FavoriteTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"melodyDetailSegue" sender:cell.btnPlay];
    [cell setSelectedOnSelf];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        // Delete the managed object.
        MelodyFavorite *mo = nil;
        NSManagedObjectContext *context = nil;
        if(self.btnScope.tag == 0)
        {
            mo = [self.fetchedResultsController0 objectAtIndexPath:indexPath];
            context = [self.fetchedResultsController0 managedObjectContext];
            [context deleteObject:mo];
        }
        else if(self.btnScope.tag == 1)
        {
            mo = [self.fetchedResultsController1 objectAtIndexPath:indexPath];
            context = [self.fetchedResultsController1 managedObjectContext];
            if([mo.sort integerValue] == 3)
            {
                mo.sort = @1;
            }
            else
            {
                [context deleteObject:mo];
            }
        }
        else if(self.btnScope.tag == 2)
        {
            mo = [self.fetchedResultsController2 objectAtIndexPath:indexPath];
            context = [self.fetchedResultsController2 managedObjectContext];
            if([mo.sort integerValue] == 3)
            {
                mo.sort = @2;
            }
            else
            {
                [context deleteObject:mo];
            }
        }

        NSError *error;
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    [self setNumberoOfEveryGroup];
}

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController0 //ALL
{
    
    if (_fetchedResultsController0 != nil) {
        return _fetchedResultsController0;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ ", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"melody.name" ascending:YES selector:@selector(localizedCompare:)];
    NSArray *sortArray = @[sort, sort1];
    [fetchRequest setSortDescriptors:sortArray];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController0 = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:@"sort"
                                 cacheName:nil];
    _fetchedResultsController0.delegate = self;
    
    return _fetchedResultsController0;
}

- (NSFetchedResultsController *)fetchedResultsController1 //TASK
{
    
    if (_fetchedResultsController1 != nil) {
        return _fetchedResultsController1;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ ", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"melody.name" ascending:YES selector:@selector(localizedCompare:)];
    NSArray *sortArray = @[sort, sort1];
    [fetchRequest setSortDescriptors:sortArray];
    
    if(self.btnScope.tag != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ AND (sort = 2 or sort = 3) ", [UserInfo sharedUserInfo].userName];
        [fetchRequest setPredicate:predicate];
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController1 = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                  sectionNameKeyPath:nil
                                  cacheName:nil];
    _fetchedResultsController1.delegate = self;
    
    return _fetchedResultsController1;
}

- (NSFetchedResultsController *)fetchedResultsController2 //LIKE
{
    
    if (_fetchedResultsController2 != nil) {
        return _fetchedResultsController2;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ ", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"melody.name" ascending:YES selector:@selector(localizedCompare:)];
    NSArray *sortArray = @[sort, sort1];
    [fetchRequest setSortDescriptors:sortArray];
    
    if(self.btnScope.tag != 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ AND (sort = 1 or sort = 3)" , [UserInfo sharedUserInfo].userName];
        [fetchRequest setPredicate:predicate];
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController2 = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                  sectionNameKeyPath:nil
                                  cacheName:nil];
    _fetchedResultsController2.delegate = self;
    
    return _fetchedResultsController2;
}

/*
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            [self.tableView cellForRowAtIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - ACTION

- (IBAction)btnModel_click:(id)sender
{
    if(self.btnModel != sender)
    {
        if(self.btnModel)
            [self.btnModel setSelected:NO];
        self.btnModel = sender;
        [self.btnModel setSelected:YES];
    }
    else
    {
        return;
    }
    
    if([self.btnModel tag] == 1)
    {
        
    }
    else if([self.btnModel tag] ==2)
    {
        
    }
    else
    {
        
    }
}

- (IBAction)btnScope_click:(id)sender
{
    if(self.btnScope != sender)
    {
        if(self.btnScope)
            [self.btnScope setSelected:NO];
        self.btnScope = sender;
        [self.btnScope setSelected:YES];
    }
    else
    {
        return;
    }
    
    if([UserInfo sharedUserInfo].userName == nil) return;
    
    
    if(self.btnScope.tag == 0)//all
    {
        NSError *error;
        if (![[self fetchedResultsController0] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.fetchedResultsController0.delegate = self;
        self.fetchedResultsController1.delegate = nil;
        self.fetchedResultsController2.delegate = nil;
        [self.tableView reloadData];
    }
    else if(self.btnScope.tag == 1) //task
    {
        NSError *error;
        if (![[self fetchedResultsController1] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.fetchedResultsController0.delegate = nil;
        self.fetchedResultsController1.delegate = self;
        self.fetchedResultsController2.delegate = nil;
        [self.tableView reloadData];
    }
    else if(self.btnScope.tag == 2) // favr
    {
        NSError *error;
        if (![[self fetchedResultsController2] performFetch:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.fetchedResultsController0.delegate = nil;
        self.fetchedResultsController1.delegate = nil;
        self.fetchedResultsController2.delegate = self;
        [self.tableView reloadData];
    }
}

-(void)scrollTableViewToMelody:(Melody*)melody type:(NSInteger)iSort
{
    int i=0;
    if(iSort == 3) //all
    {
        NSArray *array = self.fetchedResultsController0.fetchedObjects;
        NSInteger sectionCount = [[self.fetchedResultsController0 sections] count];
        NSInteger section = sectionCount-1;
        for (MelodyFavorite *obj in array)
        {
            if([obj.sort intValue] !=  iSort)
            {
                continue;
            }
            if(obj.melody == melody)
            {
                //[self.tableView scrollRectToVisible:CGRectMake(0, i*134, self.tableView.frame.size.width, 134) animated:NO];
                NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:section];
                [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                [self.tableView selectRowAtIndexPath:indexP animated:NO scrollPosition:UITableViewScrollPositionNone];
                FavoriteTableViewCell *cell = (FavoriteTableViewCell*)[self.tableView cellForRowAtIndexPath:indexP];
                [cell setSelectedOnSelf];
                break;
            }
            i++;
        }
    }
    
    if(iSort == 2) //task
    for (MelodyFavorite *obj in self.fetchedResultsController1.fetchedObjects)
    {
        if(obj.melody == melody)
        {
            NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self.tableView selectRowAtIndexPath:indexP animated:NO scrollPosition:UITableViewScrollPositionNone];
            FavoriteTableViewCell *cell = (FavoriteTableViewCell*)[self.tableView cellForRowAtIndexPath:indexP];
            [cell setSelectedOnSelf];
            break;
        }
        i++;
    }
    
    if(iSort == 1) //favr
    for (MelodyFavorite *obj in self.fetchedResultsController2.fetchedObjects)
    {
        if(obj.melody == melody)
        {
            NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            [self.tableView selectRowAtIndexPath:indexP animated:NO scrollPosition:UITableViewScrollPositionNone];
            FavoriteTableViewCell *cell = (FavoriteTableViewCell*)[self.tableView cellForRowAtIndexPath:indexP];
            [cell setSelectedOnSelf];
            break;
        }
        i++;
    }
}

-(void)setNumberoOfEveryGroup
{
    [self setNumberOfAllKind];
    [self setNumberOfTaskKind];
    [self setNumberOfFavoKind];
    self.labNumberLike.layer.cornerRadius = 6;
    self.labNumberLike.layer.masksToBounds = YES;
    self.labNumberLike.layer.backgroundColor = [UIColor redColor].CGColor;
    self.labNumberTask.layer.cornerRadius = 6;
    self.labNumberTask.layer.masksToBounds = YES;
    self.labNumberTask.layer.backgroundColor = [UIColor redColor].CGColor;
    self.labNumberAll.layer.masksToBounds = YES;
    self.labNumberAll.layer.cornerRadius = 6;
    self.labNumberAll.layer.backgroundColor = [UIColor redColor].CGColor;
}

-(void)setNumberOfAllKind
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ ", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sort"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
                                                              arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    NSError *error = nil;
    NSArray *objects = [((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects == nil)
    {
        // Handle the error.
    }
    else
    {
        if ([objects count] > 0)
        {
            NSNumber *oNum = [[objects objectAtIndex:0] valueForKey:@"count"];
            if([oNum intValue] > 0)
            {
                self.labNumberAll.text = [oNum stringValue];
                self.labNumberAll.hidden = NO;
            }
            else
            {
                self.labNumberAll.text = [NSString string];
                self.labNumberAll.hidden = YES;
            }
        }
        else
        {
            self.labNumberAll.text = [NSString string];
            self.labNumberAll.hidden = YES;
        }
    }
}

-(void)setNumberOfTaskKind
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sort = 2 or sort = 3) and user.userName == %@", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sort"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
                                                              arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    NSError *error = nil;
    NSArray *objects = [((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects == nil)
    {
        // Handle the error.
    }
    else
    {
        if ([objects count] > 0)
        {
            NSNumber *oNum = [[objects objectAtIndex:0] valueForKey:@"count"];
            if([oNum intValue] > 0)
            {
                self.labNumberTask.text = [oNum stringValue];
                self.labNumberTask.hidden = NO;
            }
            else
            {
                self.labNumberTask.text = [NSString string];
                self.labNumberTask.hidden = YES;
            }
        }
        else
        {
            self.labNumberTask.text = [NSString string];
            self.labNumberTask.hidden = YES;
        }
    }
}

-(void)setNumberOfFavoKind
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(sort = 1 or sort = 3) and user.userName == %@", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"sort"];
    NSExpression *countExpression = [NSExpression expressionForFunction:@"count:"
                                                              arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"count"];
    [expressionDescription setExpression:countExpression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    
    NSError *error = nil;
    NSArray *objects = [((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (objects == nil)
    {
        // Handle the error.
    }
    else
    {
        if ([objects count] > 0)
        {
            NSNumber *oNum = [[objects objectAtIndex:0] valueForKey:@"count"];
            if([oNum intValue] > 0)
            {
                self.labNumberLike.text = [oNum stringValue];
                self.labNumberLike.hidden = NO;
            }
            else
            {
                self.labNumberLike.text = [NSString string];
                self.labNumberLike.hidden = YES;
            }
        }
        else
        {
            self.labNumberLike.text = [NSString string];
            self.labNumberLike.hidden = YES;
        }
    }
}

@end
