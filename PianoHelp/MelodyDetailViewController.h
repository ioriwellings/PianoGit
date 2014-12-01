//
//  MelodyDetailViewController.h
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "BaseViewController.h"
#import "MelodyViewController.h"
#import "StaveFramework/MidiFile.h"
#import "StaveFramework/MidiPlayer.h"
#import "StaveFramework/Piano.h"
#import "StaveFramework/SheetMusic.h"
#import "StaveFramework/SheetMusicPlay.h"
#import "StaveFramework/SFCountdownView.h"

typedef enum : NSUInteger
{
    TwoHand,
    LeftHand,
    RightHand
} HandMode;

@interface MelodyDetailViewController : BaseViewController <SFCountdownViewDelegate, MidiPlayerDelegate, UIGestureRecognizerDelegate, SheetMusicsDelegate>
{
    MidiFile *midifile;         /** The midifile that was read */
    SheetMusic *sheetmusic;     /** The sheet music to display */
    UIScrollView *scrollView;   /** For scrolling through the sheet music */
    MidiPlayer *player;         /** The top panel for playing the music */
    Piano *piano;               /** The piano at the top, for highlighting notes */
    float zoom;                 /** The zoom level */
    MidiOptions options;        /** The options selected in the menus */
    
    SheetMusicPlay *sheetmsic1;
    
    int option;
    BOOL splitState;
    int splitStart;
    int splitEnd;
    BOOL isEnd;
    NSTimer *timer;
}

@property (nonatomic) NSInteger iPlayMode;
@property (weak, nonatomic) IBOutlet UIButton *btnAccompany;
@property (weak, nonatomic) IBOutlet UIButton *btnHandCtl;
@property (weak, nonatomic) IBOutlet UIButton *btnSplitSection;
@property (weak, nonatomic) IBOutlet UIButton *btnTryListen;
@property (weak, nonatomic) IBOutlet UIButton *btnHint;
@property (weak, nonatomic) IBOutlet UIButton *btnXiaoJieTiaoZhuan;
@property (weak, nonatomic) IBOutlet UIButton *btnSuDu;
@property (weak, nonatomic) IBOutlet UIButton *btnRePlay;
@property (strong, nonatomic) UIPopoverController *popVC;
@property (weak, nonatomic) IBOutlet UISlider *sliderXiaoJie;
@property (weak, nonatomic) IBOutlet UISlider *sliderSpeed;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *saveName;
@property (weak, nonatomic) id<FixSearchDisplayDelegate> fixSearchDisplayDelegate;

@property (weak, nonatomic) IBOutlet UIView *menuBar;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property BOOL isPresentScroeVC;
@property (weak, nonatomic) IBOutlet UILabel *labDebug;
@property (weak, nonatomic) IBOutlet UIButton *btnRedirect;
@property (nonatomic, readonly ,getter = getOption) MidiOptions *__options;
@property (nonatomic, readonly ,getter = getMIDIFile) MidiFile * __midiFile;
@property (nonatomic) HandMode handMode;
@property (strong, nonatomic) MelodyFavorite *favo;

- (IBAction)btnBack_click:(id)sender;
- (IBAction)btnSection_click:(id)sender;
- (IBAction)btnHand_click:(id)sender;
- (IBAction)btnPeiLianYin_click:(id)sender;
- (IBAction)btnHint_click:(id)sender;
- (IBAction)btnTryListen_click:(id)sender;
- (IBAction)btnRePlay_click:(id)sender;
- (IBAction)btnPlay_click:(id)sender;
- (IBAction)btnSudu_click:(id)sender;
- (IBAction)btnDeviceRedirect_click:(id)sender;

- (IBAction)xiaoJieSlider_valueChanged:(id)sender;
- (IBAction)suduSlider_valueChanged:(id)sender;


- (IBAction)handleTap:(UITapGestureRecognizer *)sender;

@end
