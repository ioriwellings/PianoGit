//
//  LoginViewController.m
//  PianoHelp
//
//  Created by Jobs on 6/17/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "MessageBox.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

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

- (IBAction)btnLogin_onclick:(id)sender
{
    if([self AuthenticateUser:self.txtUserName.text password:self.txtPassword.text == nil ? @"" : self.txtPassword.text])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
    else
    {
        [MessageBox showMsg:@"用户名或密码不正确！"];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
    } completion:^(BOOL finished)
    {
        
        //[self.view removeFromSuperview];
        
    }];
}

-(BOOL) AuthenticateUser:(NSString*)userName password:(NSString*)pwd //验证用户
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate ).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Users" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName == %@ AND pwd== %@ ", userName, pwd];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        [UserInfo sharedUserInfo].userName = userName;
        [UserInfo sharedUserInfo].dbUser = [objects firstObject];
        return YES;
    }
    return NO;
}
@end
