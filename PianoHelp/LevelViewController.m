//
//  LevelViewController.m
//  PianoHelp
//
//  Created by Jobs on 12/12/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "LevelViewController.h"
#import "UserInfo.h"

@interface LevelViewController ()

@end

@implementation LevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int iDays = [UserInfo sharedUserInfo].dbUser.totalLoginDays.integerValue;
    int iLevel = iDays / 3;
    if(iLevel<0) iLevel = 1;
    self.labLevel.text = [NSString stringWithFormat:@"%d", iLevel];
    self.labDays.text = [UserInfo sharedUserInfo].dbUser.totalLoginDays.stringValue;
    if(iDays<100)
    {
        int starCount = (iDays) / 1 ;
        for (int i=0; i<starCount; i++)
        {
            UIImage *image = [UIImage imageNamed:@"level_10.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(i*40,
                                         0,
                                         40,
                                         40);
            [self.starContainer addSubview:imageView];
            
        }
    }
    else if(iDays>= 100 && iDays<200)
    {
        int starCount = (iDays - 100 ) / 10 ;
        for (int i=1; i<=starCount; i++)
        {
            UIImage *image = [UIImage imageNamed:@"level_100.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(i*imageView.frame.size.width,
                                         0,
                                         imageView.frame.size.width,
                                         imageView.frame.size.height);
            [self.starContainer addSubview:imageView];
            
        }
    }
    else if(iDays>= 200 && iDays<300)
    {
        int starCount = (iDays - 200 ) / 10 ;
    }
    else if(iDays>= 300 && iDays<400)
    {
        int starCount = (iDays - 300 ) / 10 ;
    }
    else if(iDays>= 400 && iDays<500)
    {
        int starCount = (iDays - 400 ) / 10 ;
    }
    else if(iDays>= 500 && iDays<600)
    {
        int starCount = (iDays - 500 ) / 10 ;
    }
    else if(iDays>= 600 && iDays<700)
    {
        int starCount = (iDays - 600 ) / 10 ;
    }
    else
    {
        int starCount = (iDays - 700 ) / 10 ;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
