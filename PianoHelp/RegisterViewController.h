//
//  RegisterViewController.h
//  PianoHelp
//
//  Created by Jobs on 8/21/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface RegisterViewController : BaseViewController <UITextFieldDelegate, UIScrollViewDelegate>
{
    
}

-(void) updateDateFromDatePicker:(id)date;

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd2;
@property (weak, nonatomic) IBOutlet UITextField *txtMail;
@property (weak, nonatomic) IBOutlet UITextField *txtBirthday;
@property (weak, nonatomic) IBOutlet UITextField *txtAddr;
@property (weak, nonatomic) IBOutlet UITextField *txtValidCode;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UIButton *btnFeMale;
@property (weak, nonatomic) IBOutlet UIImageView *imageVerifyCode;
@property (weak, nonatomic) IBOutlet UILabel *labLoading;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

- (IBAction)btnBack_click:(id)sender;
- (IBAction)btnRegister_click:(id)sender;
- (IBAction)btnMale_click:(id)sender;
- (IBAction)btnFeMale_click:(id)sender;
- (IBAction)view_touchDown:(id)sender;

@end
