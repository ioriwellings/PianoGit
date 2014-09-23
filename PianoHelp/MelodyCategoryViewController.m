//
//  MelodyCategoryViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyCategoryViewController.h"
#import "AppDelegate.h"
#import "MelodyCategory.h"
#import "MelodyCategoryCollectioViewCell.h"
#import "MelodyViewController.h"
#import "GridLayout.h"
#import "AppDelegate.h"
#import "MessageBox.h"



@interface MelodyCategoryViewController ()
{
    IoriLoadingView *loadingView;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) MelodyCategory *currentMelodyCategory;

@end

@implementation MelodyCategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.levelIndent == 0)
    {
        [IAPHelper shareIAPHelper].delegate = self;
    }

    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    if(self.levelIndent == 1)
    {
        [self.collectionView setCollectionViewLayout:[[GridLayout alloc] init]];
    }
//    NSArray *arrayResult = self.fetchedResultsController.fetchedObjects;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.labTitle.text = self.title;
//    if(self.levelIndent == 0)
//    {
//        [self.navigationController setNavigationBarHidden:YES animated:NO];
//    }
//    else if(self.levelIndent == 1)
//    {
//        [self.navigationController setNavigationBarHidden:YES animated:NO];
//    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    if([[segue identifier] isEqualToString:@"pushMelody"])
    {
        MelodyViewController *vc = [segue destinationViewController];
        vc.title = self.currentMelodyCategory.name;
        vc.melodySet = self.currentMelodyCategory.melody;
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
     NSArray *sections = [self.fetchedResultsController sections];
    return [sections count];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    NSArray *sections = [self.fetchedResultsController sections];
    if([sections count] == 0) return 0;
    id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    UICollectionViewCell *cell = nil;

    MelodyCategory *selectedItem = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if([selectedItem.name isEqualToString:@"小汤1"] || [selectedItem.name isEqualToString:@"小汤2"])
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier_h" forIndexPath:indexPath];
//        cell.frame = CGRectMake(cell.frame.origin.x,
//                                cell.frame.origin.y,
//                                210,
//                                240);
    }
    else
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    }
    
    [((MelodyCategoryCollectioViewCell*)cell) updateContent:selectedItem];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.levelIndent == 0)
    {
        MelodyCategory *selectedItem = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        if([selectedItem.buy intValue] == 2)
        {
            MelodyCategoryCollectioViewCell *cell = (MelodyCategoryCollectioViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
            [cell btnBuy_click:nil];
        }
        else
        {
            [self.parentViewController performSegueWithIdentifier:@"pushMelodyLevelSegue" sender:selectedItem];
        }
    }
    else if (self.levelIndent == 1)
    {
        self.currentMelodyCategory = (MelodyCategory *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"pushMelody" sender:nil];
    }
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
//{
//    return nil;
//}

#pragma mark - Fetched results controller

/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:30];
    
    // Create the sort descriptors array.
    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    //NSSortDescriptor *sortTitle = [NSSortDescriptor sortDescriptorWithKey:@"melody@name" ascending:YES];
    NSArray *sortDescriptors = @[authorDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    if(self.levelIndent == 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K = %@)", @"parentCategory", nil]; //%K is a var arg substitution for a key path.
        fetchRequest.predicate = predicate;
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parentCategory = %@)", self.parentCategory, nil];
        fetchRequest.predicate = predicate;
    }
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                 sectionNameKeyPath:nil
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (IBAction)btnBack_onclick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnRestoreBuy_click:(id)sender
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark -IAP ACTION-

-(void)willToPay:(NSString*)productID
{
    loadingView = [MessageBox showLoadingViewWithBlockOnClick:^(IoriLoadingView *loadingView) {
        ;
    } hasCancel:NO parentViewSize:self.view.frame.size];
    [self.view addSubview:loadingView];
}

-(void)canotToPay
{
    [loadingView removeFromSuperview];
    [MessageBox showMsg:@"iPad当前设置无法购买任何产品，请更改选项[通用－访问限制－应用程序内购买]"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General&path=Restrictions"]];
}
-(void)canotGetProductInfo:(NSError *)error
{
    [loadingView removeFromSuperview];
    if(error)
        [MessageBox showMsg:error.localizedDescription];
    else
        [MessageBox showMsg:@"无法连接App Store."];
}
-(void)getProductInfoSucceed:(NSArray *)products
{
    
}
-(void)completePurchase:(SKPaymentTransaction *)transaction
{
    [loadingView removeFromSuperview];
    [MessageBox showMsg:@"购买成功！"];
}
-(void)failedPurchase:(SKPaymentTransaction *)transaction
{
    [loadingView removeFromSuperview];
    [MessageBox showMsg:transaction.error.localizedDescription];
}
-(void)provideProduct:(NSString*)strID
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"buyURL == %@", strID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        MelodyCategory *cate = [objects firstObject];
        cate.buy = @1;
        NSError *error;
        if([moc save:&error])
        {
            [self.collectionView reloadData];
        }
    }
}
@end
