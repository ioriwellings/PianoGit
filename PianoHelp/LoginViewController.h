//
//  LoginViewController.h
//  PianoHelp
//
//  Created by Jobs on 6/17/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *loginContainerView;
@property (weak, nonatomic) IBOutlet UIButton *chkRemember;
@property (weak, nonatomic) IBOutlet UIButton *chkAutoLogin;
@property (nonatomic) BOOL isSecondtRun;

- (IBAction)view_touchDown:(id)sender;
- (IBAction)btnLogin_onclick:(id)sender;
- (IBAction)chkRemember_click:(id)sender;
- (IBAction)chkAutoLogin_click:(id)sender;
- (IBAction)btnAnonymity_click:(id)sender;

@end
