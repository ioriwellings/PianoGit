//
//  QinFangViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Melody.h"

@interface QinFangViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *btnTask;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayModel;
@property (weak, nonatomic) IBOutlet UIButton *btnAll;
@property (weak, nonatomic) IBOutlet UIButton *btnLove;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int type;

- (IBAction)btnModel_click:(id)sender;
- (IBAction)btnScope_click:(id)sender;

-(void)scrollTableViewToMelody:(Melody*)melody type:(NSInteger)iSort;

@end
