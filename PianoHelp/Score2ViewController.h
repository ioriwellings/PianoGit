//
//  Score2ViewController.h
//  PianoHelp
//
//  Created by Jobs on 10/14/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface Score2ViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *labConsuming;
@property (weak, nonatomic) IBOutlet UILabel *labNormalSpeed;
@property (weak, nonatomic) IBOutlet UILabel *labGain;
@property (weak, nonatomic) IBOutlet UILabel *labOwn;

- (IBAction)btnOK_click:(id)sender;
- (IBAction)btnClose_click:(id)sender;
@end
