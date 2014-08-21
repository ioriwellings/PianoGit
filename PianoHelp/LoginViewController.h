//
//  LoginViewController.h
//  PianoHelp
//
//  Created by Jobs on 6/17/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UISwitch *chkRemember;
@property (weak, nonatomic) IBOutlet UISwitch *chkAutoLogin;

- (IBAction)btnLogin_onclick:(id)sender;
@end
