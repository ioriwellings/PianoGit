//
//  MelodyDetailViewController.m
//  PianoHelp
//
//  Created by Jobs on 14-5-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyDetailViewController.h"
#import "SectionPopViewController.h"
#import "HandPopViewController.h"
#import "SoundPopViewController.h"
#import "ScroeViewController.h"

@interface MelodyDetailViewController ()
{
    BOOL isHitAnimating;
}
@property (nonatomic,weak) UIButton *btnCurrent;
@property (strong, nonatomic) SFCountdownView *sfCountdownView;
@end

@implementation MelodyDetailViewController

-(MidiOptions*)getOption
{
    return &options;
}

-(MidiFile*)getMIDIFile
{
    return midifile;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        splitState = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.fileName == nil) return;
    
    midifile = [[MidiFile alloc] initWithFile:self.fileName];
    [midifile initOptions:&options];
    
    //set measure count
    self.sliderXiaoJie.maximumValue = [midifile getMeasureCount];
    self.sliderSpeed.value = 60000000/[[midifile time] tempo];
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)self.sliderSpeed.value] forState:UIControlStateNormal];
    
    [self loadSheetMusic];
    
    isEnd = FALSE;
    
//    ScroeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScroeViewController"];
//    vc.modalPresentationStyle = UIModalPresentationFullScreen;
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    [self presentViewController:vc animated:YES completion:NULL];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if(IS_RUNNING_IOS7)
    {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"popoverSectionSegue"])
    {
        SectionPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    
    if([segue.identifier isEqualToString:@"popoverHandSegue"])
    {
        HandPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
    
    if([segue.identifier isEqualToString:@"popoverSoundSegue"])
    {
        SoundPopViewController *vc = [segue destinationViewController];
        vc.parentVC = self;
        vc.shd = self;
        
        vc.beatMute = [midifile getTempoMuteState:&options];
        if ( [midifile getLeftHadnMuteState:&options] &&
            [midifile getRightHadnMuteState:&options]) {
            vc.sparringMute = YES;
        } else {
            vc.sparringMute = NO;
        }
        self.popVC = ((UIStoryboardPopoverSegue*)segue).popoverController;
    }
}

#pragma mark - IBAction

- (IBAction)btnBack_click:(id)sender
{
    [player stop];
    [player disConnectMIDI];
    if([self.fixSearchDisplayDelegate respondsToSelector:@selector(fixSearchBarPosition)])
    {
        //[self.fixSearchDisplayDelegate fixSearchBarPosition];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setCurrentButtonState:(id)sender
{
//    [self.btnCurrent setSelected:NO];
//    UIButton *btn = (UIButton*)sender;
//    [btn setSelected:YES];
//    self.btnCurrent = btn;
}

- (IBAction)btnSection_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnHand_click:(id)sender
{
    [self setCurrentButtonState:sender];
}

- (IBAction)btnPeiLianYin_click:(id)sender
{
    [self setCurrentButtonState:sender];}

- (IBAction)btnHint_click:(id)sender
{
//    [self setCurrentButtonState:sender];
//    if(isHitAnimating) return;
//    isHitAnimating = YES;
//    int iPianoHeight = piano.frame.size.height;
//    int iCurrentX = 75;
//    int iHasHintX = iCurrentX + iPianoHeight;
//    if(piano.hidden)
//    {
//        piano.hidden = NO;
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            scrollView.frame = CGRectMake(0,
//                                          iHasHintX,
//                                          1024,
//                                          scrollView.frame.size.height-iPianoHeight);
//            sheetmsic1.frame = CGRectMake(0,
//                                          iHasHintX,
//                                          sheetmsic1.frame.size.width,
//                                          sheetmsic1.frame.size.height);
//        } completion:^(BOOL finished) {
//            isHitAnimating = NO;
//        }];
//    }
//    else
//    {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            scrollView.frame = CGRectMake(0,
//                                          iCurrentX,
//                                          1024,
//                                          scrollView.frame.size.height+iPianoHeight);
//            sheetmsic1.frame = CGRectMake(0,
//                                          iCurrentX,
//                                          sheetmsic1.frame.size.width,
//                                          sheetmsic1.frame.size.height);
//            piano.hidden = YES;
//        } completion:^(BOOL finished) {
//            
//            isHitAnimating = NO;
//        }];
//    }
    
    [player PianoTips:YES];
    if (timer != nil) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(noteOffCallBack:) userInfo:nil repeats:NO];
    
}

- (void)noteOffCallBack:(NSTimer*)arg {
    [player PianoTips:NO];
}


- (IBAction)btnTryListen_click:(id)sender
{
    option = 1;//试听
    [self.btnPlay setSelected:true];
    
    [player listen];
    
    scrollView.hidden = YES;
    sheetmsic1.hidden = NO;
}

- (IBAction)btnRePlay_click:(id)sender
{
    if (splitState == true) {
        [self clearSplitMeasure];
    }
    [player stop];
    option = 2;//重播
    [((UIButton*)sender) setSelected:true];
    
    [self.btnXiaoJieTiaoZhuan setTitle:@"1" forState:UIControlStateNormal];
    [self.sliderXiaoJie setValue:1];
    
    [sheetmusic clearStaffs];
    [sheetmusic setNeedsDisplay];
    [sheetmsic1 setNeedsDisplay];
    
    [self.sfCountdownView start];
}

- (IBAction)btnPlay_click:(id)sender
{
    if([((UIButton*)sender) isSelected])
    {
        option = 3;//暂停
        [((UIButton*)sender) setSelected:false];
        [player playPause];
        scrollView.hidden = NO;
        sheetmsic1.hidden = YES;
        
        [sheetmusic setNeedsDisplay];
    }
    else
    {
        if (isEnd) {
            isEnd = FALSE;
            [player clearJudgedData];
            [sheetmusic clearStaffs];
            [sheetmusic setNeedsDisplay];
            [sheetmsic1 setNeedsDisplay];
        }
        
        option = 4;//播放
        [((UIButton*)sender) setSelected:true];
        [self.sfCountdownView start];
        [self hiddenMenuAndToolBar];
    }
}

- (IBAction)btnSudu_click:(id)sender
{
    self.sliderSpeed.value = 60000000/[[midifile time] tempo];
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)self.sliderSpeed.value] forState:UIControlStateNormal];
}

- (IBAction)xiaoJieSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnXiaoJieTiaoZhuan setTitle:[NSString stringWithFormat:@"%d", (int)slider.value] forState:UIControlStateNormal];
    
    [player jumpMeasure:(int)slider.value-1];
}

- (IBAction)suduSlider_valueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)slider.value] forState:UIControlStateNormal];
    
    [player changeSpeed:slider.value];
}

#pragma mark - private method
- (void) loadSheetMusic
{
    CGRect screensize = [[UIScreen mainScreen] applicationFrame];
    if (screensize.size.width >= 1200) {
        zoom = 1.5f;
    }
    else {
        zoom = 1.27f;
    }
    
    options.shadeColor = [UIColor grayColor];
    options.shade2Color = [UIColor greenColor];
    
    sheetmusic = [[SheetMusic alloc] initWithFile:midifile andOptions:&options];
    [sheetmusic setZoom:zoom];
    
    /* init player */
    piano = [[Piano alloc] init];
    piano.frame = CGRectMake(0, 75, 1024, 120);
    [self.view addSubview:piano];
    
    float height = sheetmusic.frame.size.height;
    CGRect frame;
    if (piano.hidden == YES) {
        frame = CGRectMake(0, 75, 1024, 768-75-piano.frame.size.height);
    }else{
        frame = CGRectMake(0, 75+piano.frame.size.height, 1024, 768-75-75-piano.frame.size.height);
    }
    //modify by yizhq end
    scrollView= [[UIScrollView alloc] initWithFrame: frame];
    scrollView.contentSize= CGSizeMake(1024, height+280);
    scrollView.backgroundColor = [UIColor whiteColor];
    
    
    [scrollView addSubview:sheetmusic];
    sheetmusic.scrollView = scrollView;
    sheetmsic1 = [[SheetMusicPlay alloc] initWithStaffs:[sheetmusic  getStaffs]
                                          andTrackCount: [sheetmusic getTrackCounts] andOptions:&options];
    
    sheetmsic1.frame = frame;
    [sheetmsic1 setZoom:zoom];
    sheetmsic1.backgroundColor = [UIColor clearColor];
    scrollView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:sheetmsic1];
//    [self.view addSubview:scrollView];
    [self.view insertSubview:sheetmsic1 atIndex:0];
    [self.view insertSubview:scrollView atIndex:0];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    //[sheetmusic addGestureRecognizer:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [sheetmsic1 addGestureRecognizer:tapGesture];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [scrollView addGestureRecognizer:tapGesture];
    

    player = [[MidiPlayer alloc] init];
    player.delegate = self;
    player.sheetPlay = sheetmsic1;
    [player changeSpeed:self.sliderSpeed.value];
    [player setMidiFile:midifile withOptions:&options andSheet:sheetmusic];
    
    [piano setShade:[UIColor blueColor] andShade2:[UIColor redColor]];
    [piano setMidiFile:midifile withOptions:&options];
    [player setPiano:piano];
    player.midiData = self.labDebug;
    
    scrollView.hidden = NO;
    sheetmsic1.hidden = YES;
    [self btnHint_click:nil];
    
    self.sfCountdownView = [[SFCountdownView alloc] initWithParentView:self.view];
    self.sfCountdownView.delegate = self;
    self.sfCountdownView.countdownColor = [UIColor blackColor];
    self.sfCountdownView.countdownFrom = 3;
    [self.sfCountdownView updateAppearance];
}

-(void)hiddenMenuAndToolBar
{
    if(self.menuBar.hidden)
    {
        self.menuBar.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, 0, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          scrollView.frame.origin.y+75 ,
                                          scrollView.frame.size.width,
                                          scrollView.frame.size.height-75*2 );
            sheetmsic1.frame = CGRectMake(0,
                                          sheetmsic1.frame.origin.y+75,
                                          sheetmsic1.frame.size.width,
                                          sheetmsic1.frame.size.height);
            piano.frame = CGRectMake(0,
                                     piano.frame.origin.y + 75,
                                     piano.frame.size.width,
                                     piano.frame.size.height);
        } completion:^(BOOL finished) {
            ;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, -75, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693+75, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          scrollView.frame.origin.y-75,
                                          scrollView.frame.size.width,
                                          scrollView.frame.size.height+75*2);
            sheetmsic1.frame = CGRectMake(0,
                                          sheetmsic1.frame.origin.y-75,
                                          sheetmsic1.frame.size.width,
                                          sheetmsic1.frame.size.height);
            piano.frame = CGRectMake(0,
                                     piano.frame.origin.y - 75,
                                     piano.frame.size.width,
                                     piano.frame.size.height);
        } completion:^(BOOL finished) {
            self.menuBar.hidden = YES;
        }];
    }
}


#pragma mark -
#pragma mark MidiPlayerDelegate
-(void)endSongs
{
    isEnd = TRUE;
    [[self btnPlay] setSelected:false];
    scrollView.hidden = NO;
    sheetmsic1.hidden = YES;
    
    NSLog(@"the song is end");
    [self hiddenMenuAndToolBar];
}


-(void)endSongsResult:(int)good andRight:(int)right andWrong:(int)wrong
{

    isEnd = TRUE;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [player stop];
        [self hiddenMenuAndToolBar];
        scrollView.hidden = NO;
        sheetmsic1.hidden = YES;
        
        [sheetmusic setNeedsDisplay];
        //    NSLog(@"the result good[%i] right[%i] wrong[%i]", good, right, wrong);
        int ff = (right + good)/((right + good + wrong)*1.0) * 100;
        
        ScroeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScroeViewController"];
        vc.iGood = good;
        vc.iRight = right;
        vc.iWrong = wrong;
        vc.iScore = ff;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:vc animated:YES completion:NULL];
    });
}

#pragma mark -
#pragma mark SFCountdownViewDelegate
- (void) countdownFinished:(SFCountdownView *)view
{
    switch (option ) {
        case 1://试听
            [player listen];
            break;
        case 2://重播
            [player replayByType];
            break;
        case 3://暂停
            break;
        case 4://播放
            if (splitState == true) {
                [player jumpMeasure:splitStart - 1];
            }
            [player playByType:self.iPlayMode];
            break;
    }
    
    if (self.iPlayMode == 2 || self.iPlayMode == 3) {
        
        scrollView.hidden = YES;
        sheetmsic1.hidden = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        // handling code
        [self hiddenMenuAndToolBar];
    }
}



#pragma mark - Delegate
//拆分小节
- (void) splitMeasure:(int) from andTo:(int)to
{
    
    if ([player PlayerState] == playing || [player PlayerState] == paused) {
        [player stop];
        [self.btnPlay setSelected:false];
    }
    [player setJSModel:from withEndSectionNum:to withTimeNumerator:[[midifile time] numerator] withTimeQuarter:[[midifile time]quarter] withMeasure:[[midifile time]measure]];
    [sheetmusic setJSModel:from withEndSectionNum:to withTimeNumerator:[[midifile time] numerator] withTimeQuarter:[[midifile time]quarter] withMeasure:[[midifile time]measure]];

    [sheetmusic clearStaffs];
    [player playJumpSection:from];
    [sheetmusic setNeedsDisplay];
    [sheetmsic1 setNeedsDisplay];

    splitState = true;
    splitStart = from;

}

//左右手模式
- (void) handModel:(int)value
{
    switch (value)
    {
        case 0://左右手模式
            [midifile leftHandMute:&options andState:NO];
            [midifile rightHandMute:&options andState:NO];
            break;
        case 1://左手模式
            if ([midifile getLeftHadnMuteState:&options] == YES)
            {
                [midifile leftHandMute:&options andState:NO];
            }
            else
            {
                [midifile leftHandMute:&options andState:YES];
            }
            break;
        case 2://右手模式
            if ([midifile getRightHadnMuteState:&options] == YES)
            {
                [midifile rightHandMute:&options andState:NO];
            }
            else
            {
                [midifile rightHandMute:&options andState:YES];
            }
            break;
        default:
            break;
    }
    
    [self.popVC dismissPopoverAnimated:YES];
    [player setMidiFile:midifile withOptions:&options andSheet:sheetmusic];
    [self btnPlay_click:self.btnPlay];
}


//陪练音开启关闭
- (void) SparringMute:(int)value
{
    if (value == 1) {//开启
        [midifile leftHandMute:&options andState:YES];
        [midifile rightHandMute:&options andState:YES];
    } else {//关闭
        [midifile leftHandMute:&options andState:NO];
        [midifile rightHandMute:&options andState:NO];
    }
    
    [self.popVC dismissPopoverAnimated:YES];
}

//节拍器开启关闭
- (void) beatMute:(int)value
{
    if (value == 1) {//开启
        [midifile tempoMute:&options andState:YES];
    } else {//关闭
        [midifile tempoMute:&options andState:NO];
    }
    [self.popVC dismissPopoverAnimated:YES];
}

//清除拆分曲谱
-(void)clearSplitMeasure{
    if ([player PlayerState] == playing || [player PlayerState] == paused) {
        [player stop];
    }
    [player clearJSModel];
    [sheetmusic clearJSModel];
    
    [sheetmsic1 setNeedsDisplay];
    [sheetmusic setNeedsDisplay];
    [player clearJumpSection];
    splitState = false;
    splitStart = 0;
}


-(void)dealloc
{
    self.sfCountdownView.delegate = nil;
    if (timer != nil) {
        [timer invalidate];
    }
}


@end
