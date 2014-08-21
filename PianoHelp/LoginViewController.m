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
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil userInfo:nil ];
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
    else
    {
        [MessageBox showMsg:@"用户名或密码不正确！"];
    }
    [UIView animateWithDuration:0.3 animations:^{
        
    }
                     completion:^(BOOL finished)
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
