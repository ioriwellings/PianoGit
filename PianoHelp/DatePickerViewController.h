//
//  DatePickerViewController.h
//  PianoHelp
//
//  Created by Jobs on 8/25/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RegisterViewController;

@interface DatePickerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) RegisterViewController* parentVC;

- (IBAction)datePicker_changed:(id)sender;

@end
