//
//  RegisterViewController.h
//  PianoHelp
//
//  Created by Jobs on 8/21/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController
{
    
}

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd2;
@property (weak, nonatomic) IBOutlet UITextField *txtMail;

- (IBAction)btnBack_click:(id)sender;
- (IBAction)btnRegister_click:(id)sender;

@end
