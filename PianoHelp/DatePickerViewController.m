//
//  DatePickerViewController.m
//  PianoHelp
//
//  Created by Jobs on 8/25/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "DatePickerViewController.h"
#import "RegisterViewController.h"

@interface DatePickerViewController ()

@end

@implementation DatePickerViewController

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

- (IBAction)datePicker_changed:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)sender;
    [self.parentVC updateDateFromDatePicker:picker.date];
}
@end
