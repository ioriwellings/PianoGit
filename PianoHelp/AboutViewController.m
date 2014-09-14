//
//  AboutViewController.m
//  PianoHelp
//
//  Created by Jobs on 9/14/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    
	self.webView.backgroundColor = [UIColor clearColor];
    //	self.webView.opaque = NO;
    self.webView.scalesPageToFit = YES;
//	for (id subview in self.webView.subviews)
//	{
//        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
//		{
//            ((UIScrollView *)subview).bounces = NO;
//			break;
//		}
//	}
    [self.webView loadRequest:[NSURLRequest requestWithURL: [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",
                                                                                  [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"]
                                                                                ]]]];
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

@end
