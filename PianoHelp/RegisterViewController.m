//
//  RegisterViewController.m
//  PianoHelp
//
//  Created by Jobs on 8/21/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "RegisterViewController.h"
#import "MessageBox.h"
#import "NSString+URLConnection.h"
#import "AppDelegate.h"
#import "Users.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

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

-(void)dealloc
{
    
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

- (IBAction)btnBack_click:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnRegister_click:(id)sender
{
    if(self.txtUserName.text == nil ||
       [self.txtUserName.text isEqualToString:@""])
    {
        [MessageBox showMsg:@"请添写昵称！"];
        return;
    }
    else if(self.txtPwd.text == nil ||
            [self.txtPwd.text isEqualToString:@""])
    {
        [MessageBox showMsg:@"未设置密码！"];
        return;
    }
    else if([self.txtPwd.text isEqualToString:self.txtPwd2.text] == NO)
    {
        [MessageBox showMsg:@"两次密码不一致，请重输入！"];
        return;
    }
    NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:@"register.ashx"];
    /*NSError *ER=nil;
     BOOL isConnectioned = [@"http://www.twitter.com" isReachableURLWithError:&ER];
     NSLog(@"%i", isConnectioned); ER = nil;
     isConnectioned = [@"http://ioriwellings.wordpress.com" isReachableURLWithError:&ER];
     NSLog(@"%i", isConnectioned); ER = nil;
     isConnectioned = [@"http://192.168.0.4:8087/MateService/TagData.ashx?strMinDate=2012-01-01&strMaxDate=2013-02-01" isReachableURLWithError:&ER];
     NSLog(@"%i", isConnectioned); ER = nil;
     isConnectioned = [@"http://www.twitter.com" isURLConnectionOK:ER];*/
    
    [strURL postToServer:strURL
               bodyPairs:@{
                           @"userName":self.txtUserName.text,
                           @"pwd":self.txtPwd.text,
                           @"email":self.txtMail.text
                           }
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error == nil && data)
         {
             NSError *errJSON = nil;
             id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errJSON];
             
             if(errJSON)
             {
                 [MessageBox showMsg: [NSString stringWithFormat:@"服务器错误：%@", errJSON]];
             }
             else
             {
                 if([[json objectForKey:@"success"] isEqualToString:@"NO"])
                 {
                     [MessageBox showMsg:[[json objectForKey:@"error" ] objectForKey:@"message"]];
                 }
                 else if([[json objectForKey:@"success"] isEqualToString:@"YES"])
                 {
                     NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
                     Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:moc];
                     user.userName = self.txtUserName.text;
                     user.pwd = self.txtPwd.text;
                     NSError *error;
                     if(![moc save:&error])
                     {
                         NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                         [MessageBox showMsg:@"error to save!"];
                         return;
                     }
                     [MessageBox showMsg:NSLocalizedString(@"Register Success", @"message used for inform login state.")];
                     [self dismissViewControllerAnimated:YES completion:NULL];
                 }
             }
         }
         else if([error code] == kCFURLErrorTimedOut)
         {
             [MessageBox showMsg:NSLocalizedString(@"The connection timed out.", @"message used for notice connection timed out.")];
             return ;
         }
         else
         {
             [MessageBox showMsg:NSLocalizedString(@"Login fail, Username or passowrd is invalid.", @"message used for notice login fail.")];
             return ;
         }
         
     }];
}
@end
