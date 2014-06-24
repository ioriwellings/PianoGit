//
//  SoundPopViewController.m
//  PianoHelp
//
//  Created by luo on 14-6-21.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "SoundPopViewController.h"

@interface SoundPopViewController ()

@end

@implementation SoundPopViewController

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
    
    
    [self.btnBeat setSelected:self.beatMute];
    [self.btnSparring setSelected:self.sparringMute];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnPeiLian:(UIButton *)sender
{
    if ([self.btnSparring isSelected]) {
        [self.shd SparringMute:0];
        [self.btnSparring setSelected:FALSE];
    } else {
        [self.shd SparringMute:1];
        [self.btnSparring setSelected:TRUE];
    }
    
}

- (IBAction)btnJiePai:(UIButton *)sender
{
    if ([self.btnBeat isSelected]) {
        [self.shd beatMute:0];
        [self.btnBeat setSelected:FALSE];
    } else {
        [self.shd beatMute:1];
        [self.btnBeat setSelected:TRUE];
    }
}
@end
