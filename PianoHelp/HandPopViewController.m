//
//  HandPopViewController.m
//  PianoHelp
//
//  Created by luo on 14-6-21.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "HandPopViewController.h"
#import "MelodyDetailViewController.h"

@interface HandPopViewController ()

@end

@implementation HandPopViewController

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
    MelodyDetailViewController *vc = self.parentVC;
    if(vc.iPlayMode == 1)
    {
        ((UIButton*)self.view.subviews[2]).hidden = YES;
        ((UIButton*)self.view.subviews[4]).hidden = YES;
    }
    
    if(vc.handMode == LeftHand)
    {
        self.imageLeft.highlighted = YES;
    }
    else if(vc.handMode == RightHand)
    {
        self.imageRight.highlighted = YES;
    }
    else
    {
        self.imageLeftAndRight.highlighted = YES;
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

- (IBAction)btnLeft:(UIButton *)sender
{
    [self.shd handModel:1];
    self.parentVC.handMode = LeftHand;
    [self.parentVC.popVC dismissPopoverAnimated:YES];
}

- (IBAction)btnRight:(UIButton *)sender
{
    [self.shd handModel:2];
    self.parentVC.handMode = RightHand;
    [self.parentVC.popVC dismissPopoverAnimated:YES];
}

- (IBAction)btnLeftRight_onclick:(id)sender
{
    [self.shd handModel:0];
    self.parentVC.handMode = TwoHand;
    [self.parentVC.popVC dismissPopoverAnimated:YES];
}
@end
