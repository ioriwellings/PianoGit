//
//  ScroeViewController.h
//  PianoHelp
//
//  Created by Jobs on 6/25/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "WXApi.h"

@interface ScroeViewController : BaseViewController <WXApiDelegate>
{
    
}

@property NSInteger iGood;
@property NSInteger iWrong;
@property NSInteger iRight;
@property NSInteger iScore;

@property (weak, nonatomic) IBOutlet UILabel *labScroe;
@property (weak, nonatomic) IBOutlet UILabel *labRight;
@property (weak, nonatomic) IBOutlet UILabel *labWrong;
@property (weak, nonatomic) IBOutlet UILabel *labPerfect;
@property (weak, nonatomic) IBOutlet UILabel *labGain;
@property (weak, nonatomic) IBOutlet UILabel *labOwn;
@property (strong, nonatomic) NSString *fileName;

- (IBAction)btnClose_onclick:(id)sender;
- (IBAction)btnCorrect_onclick:(id)sender;
- (IBAction)btnShare_onclick:(id)sender;
- (IBAction)btnSaveRecord_onclick:(id)sender;
- (IBAction)btnReview_click:(id)sender;

@end
