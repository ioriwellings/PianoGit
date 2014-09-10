//
//  ShowViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "ShowViewController.h"

@interface ShowViewController ()

@end

@implementation ShowViewController

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
    self.webView.delegate = self;
	self.webView.backgroundColor = [UIColor clearColor];
//	self.webView.opaque = NO;
//	self.webView.scalesPageToFit = YES;
	for (id subview in self.webView.subviews)
	{
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
		{
            ((UIScrollView *)subview).bounces = NO;
			break;
		}
	}
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.115:9000/work.aspx"]];
    [self.webView loadRequest:request];
//    [self.webView loadRequest:[NSURLRequest requestWithURL: [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@",
//                                                                                  [[NSBundle mainBundle] pathForResource:@"IEEE 754" ofType:@"html"]
//                                                                                ]]]];
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
#pragma mark - UIWebview delegate -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (IBAction)btnBack_click:(id)sender
{
    [self.webView goBack];
}
@end
