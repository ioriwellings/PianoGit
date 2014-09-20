//
//  ScroeViewController.m
//  PianoHelp
//
//  Created by Jobs on 6/25/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "ScroeViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "WebService.h"
#import "GTMBase64.h"
#import "UserInfo.h"
#import "MessageBox.h"
#import "IoriLoadingView.h"

@interface ScroeViewController ()

@end

@implementation ScroeViewController

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
    self.labScroe.text = [NSString stringWithFormat:@"%ld", (long)self.iScore];
    self.labRight.text = [NSString stringWithFormat:@"%ld", (long)self.iRight];
    self.labWrong.text = [NSString stringWithFormat:@"%ld", (long)self.iWrong];
    self.labPerfect.text = [NSString stringWithFormat:@"%ld", (long)self.iGood];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
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

- (IBAction)btnClose_onclick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnCorrect_onclick:(id)sender
{
}

- (IBAction)btnShare_onclick:(id)sender
{
    
}

- (IBAction)btnSaveRecord_onclick:(id)sender
{
    if ([[UserInfo sharedUserInfo].userName isEqualToString:@"guest"])
    {
        [MessageBox showMsg:@"匿名用户不能上传录音"];
        return;
    }
    
    IoriLoadingView *loading =[MessageBox showLoadingViewWithBlockOnClick:NULL hasCancel:NO parentViewSize:CGSizeMake(1024, 768)];
    [self.view addSubview:loading];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *temp = NSTemporaryDirectory();
        NSString *filename = [NSString stringWithFormat:@"%@__RecordTmp.m4a", temp];
        NSData *data = [NSData dataWithContentsOfFile: filename];
        data = [GTMBase64 encodeData:data];
        
        
        NSString *string = [[NSString alloc]
                            initWithData:data
                            encoding:NSUTF8StringEncoding];
        
        
        NSString *saveName = [[self.fileName lastPathComponent] stringByReplacingOccurrencesOfString:@"mid" withString:@"mp3"];
        
        //创建WebService的调用参数
        NSMutableArray* wsParas = [[NSMutableArray alloc] initWithObjects:
                                   @"midiFileName", saveName, @"fileData", string,
                                   @"userName",     [UserInfo sharedUserInfo].userName,
                                   @"scroe",     self.labScroe.text, nil];
        
        
        
        //调用WebService，获取响应
        NSString* theResponse = [WebService getSOAP11WebServiceResponse:@"http://www.pcbft.com/"
                                                         webServiceFile:@"UpLoadFileWebService.asmx"
                                                           xmlNameSpace:@"http://tempuri.org/"
                                                         webServiceName:@"UpLoadFile"
                                                           wsParameters:wsParas];
        
        //检查响应中是否包含错误
        NSString* errMsg = [WebService checkResponseError:theResponse];
        NSLog(@"the error message is %@", errMsg);
        NSLog(@"the result is %@", theResponse);
        [MessageBox showMsg:@"上传成功"];
        [self dismissViewControllerAnimated:YES completion:NULL];
    });
    
    
}

- (IBAction)btnReview_click:(id)sender
{
}
@end
