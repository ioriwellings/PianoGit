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
#import "NSString+URLConnection.h"

@interface LoginViewController ()
{
    IoriLoadingView* loadingView;
}
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeLoadingView)
                                                 name:@"zipOK"
                                               object:nil];
    
    if([((AppDelegate*)[UIApplication sharedApplication].delegate) isInited] == NO)
    {
        loadingView = [MessageBox showLoadingViewWithText:@"程序初始化中......" parentViewSize:CGSizeMake(1024, 768)];
        [self.view addSubview:loadingView];
    }
}

-(void)removeLoadingView
{
    [loadingView removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performAutoLogin];
    [self readUserConfiguration];
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

#pragma mark - login -

- (IBAction)view_touchDown:(id)sender
{
    [self.txtPassword resignFirstResponder];
    [self.txtUserName resignFirstResponder];
}

- (IBAction)btnLogin_onclick:(id)sender
{
    [self view_touchDown:nil];
    if([self AuthenticateUser:self.txtUserName.text password:self.txtPassword.text == nil ? @"" : self.txtPassword.text])
    {
        [self settingUserConfiguration];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
    else
    {
        if([HTTPSERVERSADDRESS isURLConnectionOK:nil])
        {
            NSDictionary *dictUser = [self getRemoteUserWithName:self.txtUserName.text password:self.txtPassword.text];
            if(dictUser)
            {
                NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
                Users *user = (Users*)[NSEntityDescription insertNewObjectForEntityForName:@"Users" inManagedObjectContext:moc];
                user.userName = [dictUser objectForKey:@"userName"];
                user.pwd = [dictUser objectForKey:@"pwd"];
                NSError *error;
                if(![moc save:&error])
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    [MessageBox showMsg:@"无法正确获取用户信息!"];
                    return;
                }
                if([self AuthenticateUser:user.userName password:user.pwd])
                {
                    [self settingUserConfiguration];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
                    [self dismissViewControllerAnimated:NO completion:NULL];
                }
                return;
            }
        }
        else
        {
            [MessageBox showMsg:@"没有网络，无法正确获取用户信息!"];
        }
        [MessageBox showMsg:@"用户名或密码不正确！"];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
    }
                     completion:^(BOOL finished)
    {
        
        //[self.view removeFromSuperview];
        
    }];
}

-(NSDictionary*)getRemoteUserWithName:(NSString*)strUserName password:(NSString*)pwd
{
    NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:[NSString stringWithFormat:@"getRemoteUser.ashx?userName=%@&pwd=%@", strUserName, pwd]];
    NSURL *url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
    NSURLResponse *respone;
    NSError *err;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&err];
    if(data == nil || [data length] == 0)
        return nil;
    else
    {
        NSError *errJSON = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errJSON];
        if(json && errJSON == nil)
        {
            return json;
        }
        NSLog(@"error:%@", errJSON);
        return nil;
    }
}

- (IBAction)chkRemember_click:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.isSelected];
}

- (IBAction)chkAutoLogin_click:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.isSelected];
}

- (IBAction)btnAnonymity_click:(id)sender
{
    if([self AuthenticateUser:@"guest" password:@""])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
    else
    {
        [MessageBox showMsg:@"系统异常，请联系厂家或重装应用程序！"];
    }
}

-(BOOL) AuthenticateUser:(NSString*)userName password:(NSString*)pwd //验证用户
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate ).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Users" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName == %@ AND pwd== %@ ",
                              [userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ],
                               [pwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                              ];
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

-(void)performAutoLogin
{
    if(!self.isSecondtRun)
    {
        NSString *strPath = [self getConfigurationPath];
        NSMutableDictionary *dictConf = [NSMutableDictionary dictionaryWithContentsOfFile:strPath];
        if(dictConf == nil)
        {
            return;
        }
        NSDictionary *autoLogin = [dictConf objectForKey:@"AutoLogin"];
        if(autoLogin)
        {
            if([self AuthenticateUser:(NSString *)[autoLogin objectForKey:@"userName"] password:(NSString *)[autoLogin objectForKey:@"pwd"]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
                [self dismissViewControllerAnimated:NO completion:NULL];
            }
            else
            {
                [MessageBox showMsg:@"用户名或密码不正确！"];
            }
        }
    }
}

-(void)readUserConfiguration
{
    NSString *strPath = [self getConfigurationPath];
    NSMutableDictionary *dictConf = [NSMutableDictionary dictionaryWithContentsOfFile:strPath];
    if(dictConf == nil)
    {
        return;
    }
    
    NSMutableDictionary *dictLast = [dictConf objectForKey:@"LastUser"];
    
    
    if(dictLast && (self.txtUserName.text == nil || [[self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]))
    {
        self.txtUserName.text = [dictLast objectForKey:@"userName"];
    }
    
    NSDictionary *autoLogin = [dictConf objectForKey:@"AutoLogin"];
    if(autoLogin)
    {
        if([[self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] isEqualToString:(NSString*)[autoLogin objectForKey:@"userName"]])
        {
            [self.chkAutoLogin setSelected:YES];
        }
    }
    NSMutableArray *rememberUser = [dictConf objectForKey:@"RememberUsers"];
    if(rememberUser)
    {
        for (NSDictionary *dictItem in rememberUser)
        {
            NSString *userName = [dictItem objectForKey:@"userName"];
            if([userName isEqualToString: [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])
            {
                [self.chkRemember setSelected:YES];
                self.txtPassword.text = (NSString*)[dictItem objectForKey:@"pwd"];
                break;
            }
        }
    }
}

-(void)settingUserConfiguration
{
    NSString *strPath = [self getConfigurationPath];
    NSMutableDictionary *dictConf = [NSMutableDictionary dictionaryWithContentsOfFile:strPath];
    if(dictConf == nil)
    {
        dictConf = [[NSMutableDictionary alloc] init];
    }

    if(self.chkAutoLogin.isSelected)
    {
        NSDictionary *autoLogin = [dictConf objectForKey:@"AutoLogin"];
        if(!autoLogin)
        {//记住当前用户，让它自动登录
            [dictConf setValue:[[NSMutableDictionary alloc] init] forKey:@"AutoLogin"];
            autoLogin = [dictConf objectForKey:@"AutoLogin"];
        }
        [autoLogin setValue:self.txtUserName.text forKey:@"userName"];
        [autoLogin setValue:self.txtPassword.text forKey:@"pwd"];
    }
    else
    {//删掉当前用户的自动登录配置
        [dictConf removeObjectForKey:@"AutoLogin"];
    }
    
    if(self.chkRemember.isSelected)
    {//记录该用户名与密码
        NSMutableArray *rememberUser = [dictConf objectForKey:@"RememberUsers"];
        if(!rememberUser)
        {
            [dictConf setValue:[[NSMutableArray alloc] init] forKey:@"RememberUsers"];
            rememberUser = [dictConf objectForKey:@"RememberUsers"];
        }
        BOOL isFound = NO;
        for (NSDictionary *dictItem in rememberUser)
        {//看看有没有这个用户
            NSString *userName = [dictItem objectForKey:@"userName"];
            if([userName isEqualToString: [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])
            {
                isFound = YES;
                break;
            }
        }
        if(!isFound)
        {//没找到用户，说明是新的
            NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
            [user setObject:self.txtUserName.text forKey:@"userName"];
            [user setObject:self.txtPassword.text forKey:@"pwd"];
            [rememberUser addObject:user];
        }
    }
    else
    {//取消记住该用户名与密码
        NSMutableArray *rememberUser = [dictConf objectForKey:@"RememberUsers"];
        if(rememberUser)
        {
            for (NSDictionary *dictItem in rememberUser)
            {
                NSString *userName = [dictItem objectForKey:@"userName"];
                if([userName isEqualToString: [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]])
                {
                    [rememberUser removeObject:dictItem];
                    break;
                }
            }
        }
    }
    
    NSMutableDictionary *dictLast = [dictConf objectForKey:@"LastUser"];
    if(dictLast == nil)
    {
        dictLast = [[NSMutableDictionary alloc] init];
        [dictConf setObject:dictLast forKey:@"LastUser"];
    }
    [dictLast setObject:self.txtUserName.text forKey:@"userName"];
    
    [dictConf writeToFile:strPath atomically:YES];
}

-(NSString*)getConfigurationPath
{
    //NSString *strPath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSString *strPath = [NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES ) objectAtIndex:0];
    strPath = [strPath stringByAppendingPathComponent:@"Configuration.plist"];
    return strPath;
}

#pragma mark - UITextFieldDelegate -

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self readUserConfiguration];
}

#pragma mark - UIKeyboard Notification  -

- (void)keyboardWillShow:(NSNotification *)notification
{
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
	
	CGRect frame = self.loginContainerView.frame;
	frame.origin.y = keyboardTop - frame.size.height;
	self.loginContainerView.frame = frame;
    [UIView commitAnimations];
    
	
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
	
	CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //CGFloat keyboardTop = keyboardRect.size.height;
	
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
	CGRect frame = self.loginContainerView.frame;
	frame.origin.y = 247;
	self.loginContainerView.frame = frame;
	[UIView commitAnimations];
}

@end
