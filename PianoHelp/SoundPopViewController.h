//
//  SoundPopViewController.h
//  PianoHelp
//
//  Created by luo on 14-6-21.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaveFramework/PianoCommon.h"
@class MelodyDetailViewController;

@interface SoundPopViewController : UIViewController

@property (weak, nonatomic) MelodyDetailViewController *parentVC;
@property (nonatomic, assign) id <SheetMusicsDelegate> shd;
@property (nonatomic) BOOL beatMute;
@property (nonatomic) BOOL sparringMute;
@property (weak, nonatomic) IBOutlet UIButton *btnBeat;

@property (weak, nonatomic) IBOutlet UIButton *btnSparring;

- (IBAction)btnPeiLian:(UIButton *)sender;
- (IBAction)btnJiePai:(UIButton *)sender;

@end
