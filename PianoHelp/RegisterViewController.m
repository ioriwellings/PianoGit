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
#import "DatePickerViewController.h"

@interface RegisterViewController ()
{
    NSString *sessionID;
}
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

    NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:@"Default.aspx"];
    [strURL getURLData:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        sessionID = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:[NSString stringWithFormat:@"(S(%@))/VerifyCode.aspx", sessionID]];
        [strURL getURLData:^(NSURLResponse *response, NSData *data, NSError *error) {
            self.labLoading.hidden = YES;
            self.imageVerifyCode.image = [UIImage imageWithData:data];
        }];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([[segue identifier] isEqualToString:@"DatePickerSegue"])
     {
         DatePickerViewController *vc = ((UIStoryboardPopoverSegue*)segue).destinationViewController;
         vc.parentVC = self;
     }
 }
 

- (IBAction)btnBack_click:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnRegister_click:(id)sender
{
    if(self.txtUserName.text == nil ||
       [[self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        [MessageBox showMsg:@"请添写昵称！"];
        return;
    }
    else if(self.txtPwd.text == nil ||
            [[self.txtPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        [MessageBox showMsg:@"未设置密码！"];
        return;
    }
    else if([[self.txtPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]
             isEqualToString:[self.txtPwd2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] == NO)
    {
        [MessageBox showMsg:@"两次密码不一致，请重输入！"];
        return;
    }
    else if ([[self.txtValidCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""])
    {
        [MessageBox showMsg:@"验证码不能为空"];
        return;
    }
    NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:[NSString stringWithFormat:@"(S(%@))/register.ashx", sessionID]];
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
                           @"userName": [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                           @"pwd": [self.txtPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                           @"email": [self.txtMail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                           @"address": [self.txtAddr.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                           @"birthday": [self.txtBirthday.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                           @"sex": (self.btnMale.isSelected) ? @"1" : @"0",
                           @"verifyCode": [self.txtValidCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                           }
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error == nil && data)
         {
             NSError *errJSON = nil;
             id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errJSON];
             
             if(errJSON)
             {
                 [MessageBox showMsg: [NSString stringWithFormat:@"服务器错误：%@", [errJSON.userInfo objectForKey:@"NSDebugDescription"]]];
             }
             else
             {
                 if([[[json objectForKey:@"success"] stringValue] isEqualToString:@"0"])
                 {
                     [MessageBox showMsg:[[json objectForKey:@"error" ] objectForKey:@"message"]];
                 }
                 else if([[[json objectForKey:@"success"] stringValue] isEqualToString:@"1"])
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
             [MessageBox showMsg:NSLocalizedString(@"Register fail, Unknow error.", @"message used for notice register fail.")];
             return ;
         }
         
     }];
}

- (IBAction)btnMale_click:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    BOOL bSel = btn.isSelected;
    if(bSel)return;
    [btn setSelected:!bSel];
    [self.btnFeMale setSelected:bSel];
}

- (IBAction)btnFeMale_click:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    BOOL bSel = btn.isSelected;
    if(bSel)return;
    [btn setSelected:!bSel];
    [self.btnMale setSelected:bSel];
}

- (IBAction)view_touchDown:(id)sender
{
    [self.txtUserName becomeFirstResponder ];
    [self.txtUserName resignFirstResponder];
}

#pragma mark - UITextFieldDelegate Protocol -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark - Upate date -
-(void) updateDateFromDatePicker:(id)date
{
    NSDate *_date = (NSDate*)date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setAMSymbol:@"AM"];
	[formatter setPMSymbol:@"PM"];
	[formatter setDateFormat:@"yyyy年MM月dd日"];
	self.txtBirthday.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:_date]];;
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
	
	CGRect frame = self.scrollview.frame;
	frame.size.height = frame.size.height - keyboardRect.size.height;
	//self.scrollview.frame = frame;
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
    
	CGRect frame = self.scrollview.frame;
	frame.size.height = frame.size.height + keyboardRect.size.height;
	//self.scrollview.frame = frame;
	[UIView commitAnimations];
}

@end
