//
//  SoundPopViewController.m
//  PianoHelp
//
//  Created by luo on 14-6-21.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "SoundPopViewController.h"
#import "MelodyDetailViewController.h"

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
    if(1)
    {
        [self.btnJiePaiYin setHighlighted:YES];
        [self.btnPeiLianYin setSelected:YES];
    }
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
    int value = 0;//add test by zyw
    [self.shd SparringMute:value];
    [self.parentVC.popVC dismissPopoverAnimated:YES];
}

- (IBAction)btnJiePai:(UIButton *)sender
{
    int value = 0;//add test by zyw
    [self.shd beatMute:value];
    [self.parentVC.popVC dismissPopoverAnimated:YES];
}
@end
