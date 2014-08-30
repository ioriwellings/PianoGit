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
    
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"0000"
                                                         ofType:@"mid"];
    
    
    NSData *data = [NSData dataWithContentsOfFile: filename];
    data = [GTMBase64 encodeData:data];
    
    
    NSString *string = [[NSString alloc]
                        initWithData:data
                        encoding:NSUTF8StringEncoding];
    
    
    
    
    //创建WebService的调用参数
    NSMutableArray* wsParas = [[NSMutableArray alloc] initWithObjects:
                               @"midiFileName", @"0000.mid", @"fileData", string,
                               @"userName",     @"zyw", @"type", @"教材",
                               @"scroe",     @"100", nil];
    
    
    
    //调用WebService，获取响应
    NSString* theResponse = [WebService getSOAP11WebServiceResponse:@"http://192.168.1.102:9000/"
                                                     webServiceFile:@"webservice1.asmx"
                                                       xmlNameSpace:@"http://tempuri.org/"
                                                     webServiceName:@"UpLoadFile"
                                                       wsParameters:wsParas];
    
    //检查响应中是否包含错误
    NSString* errMsg = [WebService checkResponseError:theResponse];
    NSLog(@"the error message is %@", errMsg);
    NSLog(@"the result is %@", theResponse);
    
}

- (IBAction)btnSaveRecord_onclick:(id)sender
{
}

- (IBAction)btnReview_click:(id)sender
{
}
@end
