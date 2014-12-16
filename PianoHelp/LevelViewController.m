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
    int iLevel = ceil(iDays / 3.0);
    if(iLevel<0) iLevel = 1.0;
    self.labLevel.text = [NSString stringWithFormat:@"%d", iLevel];
    self.labDays.text = [UserInfo sharedUserInfo].dbUser.totalLoginDays.stringValue;
    if(iDays<100)
    {
        int starCount = ceil(iDays / 10.0) ;
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
        UIImage *star = [UIImage imageNamed:@"level_100.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 100 ) / 10.0);
        for (int i=1; i<=starCount; i++)
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
    else if(iDays>= 200 && iDays<300)
    {
        UIImage *star = [UIImage imageNamed:@"level_200.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 200 ) / 10.0);
        for (int i=1; i<=starCount; i++)
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
    else if(iDays>= 300 && iDays<400)
    {
        UIImage *star = [UIImage imageNamed:@"level_300.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 300 ) / 10.0);
        for (int i=1; i<=starCount; i++)
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
    else if(iDays>= 400 && iDays<500)
    {
        UIImage *star = [UIImage imageNamed:@"level_400.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 400 ) / 10.0);
        for (int i=1; i<=starCount; i++)
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
    else if(iDays>= 500 && iDays<600)
    {
        UIImage *star = [UIImage imageNamed:@"level_500.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 500 ) / 10.0);
        for (int i=1; i<=starCount; i++)
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
    else if(iDays>= 600 && iDays<700)
    {
        UIImage *star = [UIImage imageNamed:@"level_500.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 600 ) / 10.0);
        for (int i=1; i<=starCount; i++)
        {
            UIImage *image = [UIImage imageNamed:@"level_100.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(i*40,
                                         0,
                                         40,
                                         40);
            [self.starContainer addSubview:imageView];
        }
    }
    else
    {
        UIImage *star = [UIImage imageNamed:@"level_500.png"];
        UIImageView *view = [[UIImageView alloc] initWithImage:star];
        view.frame = CGRectMake(0, 0, 40, 40);
        [self.starContainer addSubview:view];
        
        int starCount = ceil((iDays - 600 ) / 100.0);
        for (int i=1; i<=starCount; i++)
        {
            UIImage *image = [UIImage imageNamed:@"level_500.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(i*40,
                                         0,
                                         40,
                                         40);
            [self.starContainer addSubview:imageView];
        }
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
