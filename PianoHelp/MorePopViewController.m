//
//  MorePopViewController.m
//  PianoHelp
//
//  Created by Jobs on 6/21/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "MorePopViewController.h"
#import "UserInfo.h"

@interface MorePopViewController ()

@end

@implementation MorePopViewController

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
    self.labUser.text = [NSString stringWithFormat:@" %@ ", [UserInfo sharedUserInfo].userName];
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

- (IBAction)btnQuit_onclick:(id)sender
{
    if([self.loginDelegate respondsToSelector:@selector(quit)])
    {
        [self.loginDelegate quit];
    }
}
- (IBAction)btnOfficeWeb_click:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://jiayinqiji.com"]];
}
@end
