//
//  ShowViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-15.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ShowViewController : BaseViewController <UIWebViewDelegate>
{
    
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)btnBack_click:(id)sender;
@end
