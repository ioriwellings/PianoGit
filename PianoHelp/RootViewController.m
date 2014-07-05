//
//  RootViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-12.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "RootViewController.h"
#import "MelodyCategoryViewController.h"
#import "MelodyCategory.h"
#import "LoginViewController.h"
#import "QinFangViewController.h"
#import "Melody.h"
#import "WuXianPuViewController.h"

@interface RootViewController ()
{
    LoginViewController *loginVC;
    UIPopoverController *popVC;
    QinFangViewController *qinFangVC;
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.type = 0;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ditu.png"]];
    imageView.frame = CGRectMake(0, 0, 1024, 768);
    [self.view addSubview:imageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jumpToMelodyForBackFromDetailView:)
                                                 name:kBackToQinfangNotification object:nil];
    
    self.lastClickButton = self.btnQinFang;
    [self.lastClickButton setSelected:YES];
    self.title = @"首页";
    UIImage *image = [UIImage imageNamed:@"daohangtiao.png"];
    self.topToolbar.backgroundColor = [UIColor colorWithPatternImage:image];
    
    
    loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self addChildViewController:loginVC];
    if (self.type == 0) {
        [self.view addSubview:loginVC.view];
        //if(!IS_RUNNING_IOS7)
        {
            for (UIView *subView in self.topToolbar.subviews)
            {
                if([subView isKindOfClass:[UIImageView class]])
                {
                    [subView removeFromSuperview];
                }
            }
        }
    } else {
        [self buttonToolbar_click:self.btnQinFang];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    if(!IS_RUNNING_IOS7)
    {
        self.navigationController.navigationBar.tintColor = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LoginViewControllerDelegate

-(void)quit
{
    [popVC dismissPopoverAnimated:NO];
    loginVC.view.alpha=0;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view addSubview:loginVC.view];
        loginVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"pushMelodyLevelSegue"])
    {
        MelodyCategoryViewController *vc = [segue destinationViewController];
        vc.levelIndent = 1;
        vc.title = ((MelodyCategory*)sender).name;
        vc.parentCategory = sender;
    }
    else if ([[segue identifier] isEqualToString:@"morePopSegue"])
    {
        MorePopViewController *vc = [segue destinationViewController];
        vc.loginDelegate = self;
        popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    else if ([[segue identifier] isEqualToString:@"EmbedQinFangSegue"])
    {
        QinFangViewController *vc = [segue destinationViewController];
        vc.type = self.type;
        qinFangVC = vc;
    }
}


- (IBAction)buttonToolbar_click:(id)sender
{
    if(sender == self.btnShop) return;
    if(self.lastClickButton)
    {
        [self.lastClickButton setSelected:NO];
    }
    self.lastClickButton = sender;
    [self.lastClickButton setSelected:YES];
    if(sender == self.btnMelody)
    {
        self.melodyContainerView.hidden = NO;
        self.qinFangContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = YES;
    }
    else if(sender ==  self.btnQinFang)
    {
        self.qinFangContainerView.hidden = NO;
        self.melodyContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = YES;
    }
    else if(sender == self.btnShop)
    {
//        self.melodyContainerView.hidden = YES;
//        self.qinFangContainerView.hidden = YES;
//        self.shopContainerView.hidden = NO;
//        self.showContainerView.hidden = YES;
    }
    else if(sender == self.btnShow)
    {
        self.melodyContainerView.hidden = YES;
        self.qinFangContainerView.hidden = YES;
        self.shopContainerView.hidden = YES;
        self.showContainerView.hidden = NO;
    }
}

-(void)jumpToMelodyForBackFromDetailView:(NSNotification *)notification
{
    WuXianPuViewController *vc = notification.object;
    Melody *melody = [notification.userInfo objectForKey:@"melody"];
    [self buttonToolbar_click:self.btnQinFang];
    if(vc.type == 1)//favr
    {
        [qinFangVC btnScope_click:qinFangVC.btnLove];
    }
    else if(vc.type == 2)//task
    {
        [qinFangVC btnScope_click:qinFangVC.btnTask];
    }
    else if(vc.type == 3)//all
    {
        [qinFangVC btnScope_click:qinFangVC.btnAll];
    }
    [qinFangVC scrollTableViewToMelody:melody type:vc.type];
}

@end
