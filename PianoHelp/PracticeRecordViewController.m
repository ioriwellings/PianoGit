//
//  PracticeRecordViewController.m
//  PianoHelp
//
//  Created by Jobs on 11/18/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "PracticeRecordViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "PracticeRecord.h"
#import "PracticeRecordCell.h"

@interface PracticeRecordViewController ()
{
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation PracticeRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView data source and delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    headView.backgroundColor = [UIColor colorWithWhite:0.01 alpha:0.02];
    static NSString *CellIdentifier = @"TableViewCell";
    PracticeRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.labDate.text = @"日期/时间";
    cell.labName.text = @"练习曲目";
    cell.labMode.text = @"练习模式";
    cell.labScore.text = @"得分";
    [headView addSubview:cell];
    return headView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger iCount = [[UserInfo sharedUserInfo].dbUser.record count];
    return iCount;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell from self's table view.
    static NSString *CellIdentifier = @"TableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSOrderedSet *_dataSource = [[UserInfo sharedUserInfo].dbUser.record reversedOrderedSet];
    [((PracticeRecordCell*)cell) updateContent:((PracticeRecord*)[_dataSource objectAtIndex:indexPath.row])];
    return cell;
}

#pragma mark - Fetched results controller
/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PracticeRecord" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ ", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortArray = @[sort];
    [fetchRequest setSortDescriptors:sortArray];
    
    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                  initWithFetchRequest:fetchRequest
                                  managedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext
                                  sectionNameKeyPath:nil
                                  cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
