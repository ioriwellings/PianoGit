//
//  PracticeRecordViewController.h
//  PianoHelp
//
//  Created by Jobs on 11/18/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PracticeRecordViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITabBarDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
