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
#import "UserInfo.h"
#import <ImageIO/ImageIO.h>

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
    if(self.iScore < 60)
    {
        self.labScroe.text = @"加油";
    }
    else
        self.labScroe.text = [NSString stringWithFormat:@"%ld", (long)self.iScore];
    self.labRight.text = [NSString stringWithFormat:@"%ld", (long)self.iRight];
    self.labWrong.text = [NSString stringWithFormat:@"%ld", (long)self.iWrong];
    self.labPerfect.text = [NSString stringWithFormat:@"%ld", (long)self.iGood];
    self.labGain.text = [[@(self.iRight+self.iGood) stringValue] stringByAppendingString:@"枚"];
    
    self.labName.text = [[self.fileName lastPathComponent] stringByDeletingPathExtension];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:[NSString stringWithFormat:@"getUserCoins.ashx?userName=%@",[UserInfo sharedUserInfo].userName ]];
        NSURL *url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
        NSURLResponse *respone;
        NSError *err;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&respone error:&err];
        if(data == nil || [data length] == 0)
        {
            
        }
        else
        {
            NSError *errJSON = nil;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errJSON];
            if(json && errJSON == nil)
            {
                self.labOwn.text = [[[json valueForKey:@"Coins"] stringValue] stringByAppendingString:@"枚"];
            }
        }

    });
    
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
    IoriLoadingView *loading =[MessageBox showLoadingViewWithBlockOnClick:NULL hasCancel:NO parentViewSize:CGSizeMake(1024, 768)];
    [self.view addSubview:loading];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[UserInfo sharedUserInfo].userName isEqualToString:@"guest"] == NO)
        {
            NSString *coins = nil;
            if (self.iRight <= 0) {
                coins = @"0";
            } else {
                coins = [NSString stringWithFormat:@"%ld", (long)self.iRight + self.iGood];
            }
            
            //创建WebService的调用参数
            NSMutableArray* wsParas = [[NSMutableArray alloc] initWithObjects:
                                       @"userName",     [UserInfo sharedUserInfo].userName,
                                       @"coins",        coins, nil];
            
            //调用WebService，获取响应
            NSString* theResponse = [WebService getSOAP11WebServiceResponse:@"http://www.pcbft.com/"
                                                             webServiceFile:@"UpdateLandingDaysWebService.asmx"
                                                               xmlNameSpace:@"http://tempuri.org/"
                                                             webServiceName:@"updateCoins"
                                                               wsParameters:wsParas];
            
            //检查响应中是否包含错误
            NSString* errMsg = [WebService checkResponseError:theResponse];
            NSLog(@"the error message is %@", errMsg);
            NSLog(@"the result is %@", theResponse);
            //[MessageBox showMsg:@"金币上传成功"];
        }
        
    });
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnCorrect_onclick:(id)sender
{
}

- (IBAction)btnShare_onclick:(id)sender
{
    
    UIGraphicsBeginImageContext(CGSizeMake(1024, 768));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = CGRectMake(237, 94, 580, 526);
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(theImage.CGImage, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"我在钢琴伴侣的得分";
    //[message setThumbImage:theImage];
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImagePNGRepresentation(sendImage);
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = 1;
    [WXApi sendReq:req];
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
        
        NSString *coins = nil;
        if (self.iRight <= 0) {
            coins = @"0";
        } else {
            coins = [NSString stringWithFormat:@"%ld", (long)self.iRight + self.iGood];
        }
        
        //创建WebService的调用参数
        NSMutableArray* wsParas = [[NSMutableArray alloc] initWithObjects:
                                   @"midiFileName", saveName, @"fileData", string,
                                   @"userName",     [UserInfo sharedUserInfo].userName,
                                   @"scroe",        self.labScroe.text,
                                   @"coins",        coins, nil];
        
        
        
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

#pragma mark - weixin api -

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    }
}

-(UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 120.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else
    {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    
    return thumbnail;
}

CGImageRef MyCreateThumbnailImageFromData (NSData * data, int imageSize)
{
    CGImageRef        myThumbnailImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[3];
    CFTypeRef         myValues[3];
    CFNumberRef       thumbnailSize;
    
    // Create an image source from NSData; no options.
    myImageSource = CGImageSourceCreateWithData((CFDataRef)data,
                                                NULL);
    // Make sure the image source exists before continuing.
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    
    // Package the integer as a  CFNumber object. Using CFTypes allows you
    // to more easily create the options dictionary later.
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &imageSize);
    
    // Set up the thumbnail options.
    myKeys[0] = kCGImageSourceCreateThumbnailWithTransform;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    myKeys[2] = kCGImageSourceThumbnailMaxPixelSize;
    myValues[2] = (CFTypeRef)thumbnailSize;
    
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    
    // Create the thumbnail image using the specified options.
    myThumbnailImage = CGImageSourceCreateThumbnailAtIndex(myImageSource,
                                                           0,
                                                           myOptions);
    // Release the options dictionary and the image source
    // when you no longer need them.
    CFRelease(thumbnailSize);
    CFRelease(myOptions);
    CFRelease(myImageSource);
    
    // Make sure the thumbnail image exists before continuing.
    if (myThumbnailImage == NULL){
        fprintf(stderr, "Thumbnail image not created from image source.");
        return NULL;
    }
    
    return myThumbnailImage;
}


@end
