//
//  ScroeViewController.h
//  PianoHelp
//
//  Created by Jobs on 6/25/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

@interface ScroeViewController : BaseViewController
{
    
}

@property NSInteger iGood;
@property NSInteger iWrong;
@property NSInteger iRight;

@property (weak, nonatomic) IBOutlet UILabel *labScroe;
@property (weak, nonatomic) IBOutlet UILabel *labRight;
@property (weak, nonatomic) IBOutlet UILabel *labWrong;
@property (weak, nonatomic) IBOutlet UILabel *labPerfect;
@property (weak, nonatomic) IBOutlet UILabel *labGain;
@property (weak, nonatomic) IBOutlet UILabel *labOwn;

- (IBAction)btnClose_onclick:(id)sender;
- (IBAction)btnCorrect_onclick:(id)sender;
- (IBAction)btnShare_onclick:(id)sender;
- (IBAction)btnSaveRecord_onclick:(id)sender;
- (IBAction)btnReview_click:(id)sender;

@end
