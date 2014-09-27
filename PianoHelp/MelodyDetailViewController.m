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
#import "Melody.h"
#import "MelodyFavorite.h"
#import "Score.h"
#import "AppDelegate.h"
#import "UserInfo.h"

@interface MelodyDetailViewController ()
{
    BOOL isHitAnimating;
    BOOL isHiddenMenubar;
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
    
    if (self.iPlayMode == 1) {//识谱模式
        [self.btnHint setEnabled:true];
        [self.sliderSpeed setEnabled:false];
        [self.btnAccompany setEnabled:false];
        [self.sliderXiaoJie setEnabled:false];
        [self.btnXiaoJieTiaoZhuan setEnabled:false];
        [self.btnSplitSection setEnabled:false];
        [self.btnRePlay setEnabled:false];
    }else if(self.iPlayMode == 2){//跟弹模式
        [self.btnHint setEnabled:false];
        [self.sliderSpeed setEnabled:true];
        [self.btnAccompany setEnabled:true];
        [self.sliderXiaoJie setEnabled:true];
        [self.btnXiaoJieTiaoZhuan setEnabled:true];
        [self.btnSplitSection setEnabled:true];
        [self.btnRePlay setEnabled:true];
    }
    
    //    ScroeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScroeViewController"];
    //    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    //    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //    [self presentViewController:vc animated:YES completion:NULL];
    //[self endSongsResult:10 andRight:10 andWrong:10];
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
    [player stopPrepareTempo];
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
    
    if (option == 1) return;
    
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
    [self.btnHint setSelected:false];
    
    [player listen];
    [self btnStateCtlInPlay:1];
    scrollView.hidden = YES;
    sheetmsic1.hidden = NO;
}

- (IBAction)btnRePlay_click:(id)sender
{
//    if (splitState == true) {
//        [self clearSplitMeasure];
//    }
    [player stop];
    [player resetShadeLine];
    option = 2;//重播
    [((UIButton*)sender) setSelected:true];
    
    [self.btnXiaoJieTiaoZhuan setTitle:@"1" forState:UIControlStateNormal];
    [self.sliderXiaoJie setValue:1];
//        [sheetPlay shadeNotes:0 withPrev:0];
    [sheetmusic clearStaffs];
    [sheetmusic setNeedsDisplay];
    [sheetmsic1 setNeedsDisplay];
    
    //    [self.sfCountdownView start];
    if (self.iPlayMode != 1) {
        [player playPrepareTempo:[player getSectionTime]];
        [self.sfCountdownView start:[midifile getMidiFileTimes] withCnt:[midifile getMeasureCount]];

    } else {
        [player playByType:1];
    }
    [_btnPlay setSelected:true];
}

- (IBAction)btnPlay_click:(id)sender
{
    if([((UIButton*)sender) isSelected])
    {
        option = 3;//暂停
        [((UIButton*)sender) setSelected:false];
        [self btnStateCtlInPlay:3];
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
        //        [self.sfCountdownView start];

        if (self.iPlayMode != 1) {
            [player playPrepareTempo:[player getCountDownCnt]];
            [self.sfCountdownView start:[midifile getMidiFileTimes] withCnt:[midifile getMeasureCount]];
        } else {
            [player playByType:1];
        }
        [self.btnTryListen setEnabled:false];
        [self btnStateCtlInPlay:1];
        [self hiddenMenuAndToolBar];
    }
}

- (IBAction)btnSudu_click:(id)sender
{
    self.sliderSpeed.value = 60000000/[[midifile time] tempo];
    [self.btnSuDu setTitle:[NSString stringWithFormat:@"%d", (int)self.sliderSpeed.value] forState:UIControlStateNormal];
    player.isSpeed = FALSE;
    [player changeSpeed:self.sliderSpeed.value];
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
    
    player.isSpeed = TRUE;
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
    piano.hidden = YES;
    
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
    
    self.sfCountdownView = [[SFCountdownView alloc] initWithParentView:self.view];
    self.sfCountdownView.delegate = self;
    self.sfCountdownView.countdownColor = [UIColor blackColor];
    [self.sfCountdownView updateAppearance];
    
}

-(void)hiddenMenuAndToolBar
{
    if(isHiddenMenubar) return;
    if(self.menuBar.hidden)
    {
        self.menuBar.hidden = NO;
        isHiddenMenubar = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, 0, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          0+75 ,
                                          scrollView.frame.size.width,
                                          618);
            sheetmsic1.frame = CGRectMake(0,
                                          sheetmsic1.frame.origin.y+75,
                                          sheetmsic1.frame.size.width,
                                          sheetmsic1.frame.size.height);
            piano.frame = CGRectMake(0,
                                     piano.frame.origin.y + 75,
                                     piano.frame.size.width,
                                     piano.frame.size.height);
        } completion:^(BOOL finished) {
            isHiddenMenubar = NO;
        }];
    }
    else
    {
        isHiddenMenubar = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.menuBar.frame = CGRectMake(0, -75, 1024, 75);
            self.toolBar.frame = CGRectMake(0, 693+75, 1024, 75);
            scrollView.frame = CGRectMake(0,
                                          0,
                                          scrollView.frame.size.width,
                                          768);
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
            isHiddenMenubar = NO;
        }];
    }
}


#pragma mark -
#pragma mark MidiPlayerDelegate
-(void)endSongs
{
    isEnd = TRUE;
    [self.btnPlay setSelected:false];
    [self.btnTryListen setEnabled:true];
    [self btnStateCtlInPlay:2];
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
        vc.fileName = self.saveName;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:vc animated:YES completion:NULL];
        
        Score *score = self.favo.score; //[self getCurrentScore];
        if(score == nil)
        {
            score = (Score*)[NSEntityDescription insertNewObjectForEntityForName:@"Score" inManagedObjectContext:((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext];
            score.rank = [NSNumber numberWithInt:[self.favo.melody.level intValue]];
//        score.good = [NSNumber numberWithInt:good];
            score.miss = [NSNumber numberWithInt:wrong];
            score.perfect = [NSNumber numberWithInt:right];
            score.score = [NSNumber numberWithInt:ff];
            self.favo.score = score;
        }
        else
        {
            if([score.score intValue] < ff)
            {
                score.score = [NSNumber numberWithInt:ff];
            }
        }
        [((AppDelegate*)[UIApplication sharedApplication].delegate) saveContext];
    });
}

-(Score*)getCurrentScore
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@", [UserInfo sharedUserInfo].userName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        return ((MelodyFavorite*)[objects firstObject]).score;
    }
    return nil;
}

#pragma mark -
#pragma mark SFCountdownViewDelegate
- (void) countdownFinished:(SFCountdownView *)view
{
    [player stopPrepareTempo];
    switch (option ) {
        case 1://试听
            [player listen];
            break;
        case 2://重播
            if (splitState == true) {
                [self splitMeasure:splitStart andTo:splitEnd];
                [player jumpMeasure:splitStart - 1];
                [player playByType:self.iPlayMode];
            }else{
                [player replayByType];
            }
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
    splitEnd = to;
    
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
            [midifile leftHandMute:&options andState:YES];
            [midifile rightHandMute:&options andState:NO];
            break;
        case 2://右手模式
            [midifile leftHandMute:&options andState:NO];
            [midifile rightHandMute:&options andState:YES];
            
            break;
        default:
            break;
    }
    
    [self.popVC dismissPopoverAnimated:YES];
    [player setMidiFile:midifile withOptions:&options andSheet:sheetmusic];
//    [self btnPlay_click:self.btnPlay];
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

-(void)btnStateCtlInPlay:(int)state{

    if (state == 1) {//playing

        [self.btnXiaoJieTiaoZhuan setEnabled:false];
        [self.btnSuDu setEnabled:false];
        [self.sliderXiaoJie setEnabled:false];
        [self.sliderSpeed setEnabled:false];
        [self.btnAccompany setEnabled:false];
        [self.btnHandCtl setEnabled:false];
        [self.btnSplitSection setEnabled:false];
        
        if (_iPlayMode == 2) {
            [self.btnHint setEnabled:false];
            [self.btnRePlay setEnabled:true];
            if (option == 1) {//试听
                [self.btnRePlay setEnabled:false];
                [self.btnPlay setEnabled:false];
                [self.btnTryListen setEnabled:true];
            }else{
                [self.btnRePlay setEnabled:true];
                [self.btnTryListen setEnabled:false];
                [self.btnPlay setEnabled:true];
            }
        }else if (_iPlayMode == 1){
            [self.btnHint setEnabled:true];

            if (option == 1) {//试听
                [self.btnRePlay setEnabled:false];
                [self.btnPlay setEnabled:false];
                [self.btnTryListen setEnabled:true];
            }else{
                [self.btnRePlay setEnabled:true];
                [self.btnTryListen setEnabled:false];
                [self.btnPlay setEnabled:true];
            }
        }
    }else if(state == 2){//end playing
        [self.btnTryListen setEnabled:true];
        if (_iPlayMode == 2) {
            [self.btnHint setEnabled:false];
            [self.sliderXiaoJie setEnabled:true];
            [self.sliderSpeed setEnabled:false];
            [self.btnRePlay setEnabled:true];
            [self.btnSplitSection setEnabled:true];
            [self.btnXiaoJieTiaoZhuan setEnabled:true];
            [self.btnSuDu setEnabled:true];
            [self.btnAccompany setEnabled:true];
        }else if (_iPlayMode == 1){
            [self.btnHint setEnabled:true];
            [self.sliderXiaoJie setEnabled:false];
            [self.sliderSpeed setEnabled:false];
            [self.btnRePlay setEnabled:false];
            [self.btnSplitSection setEnabled:false];
            [self.btnXiaoJieTiaoZhuan setEnabled:false];
            [self.btnSuDu setEnabled:false];
            [self.btnAccompany setEnabled:false];
        }
        [self.btnPlay setEnabled:true];
        [self.btnHandCtl setEnabled:true];

    }else if (state == 3){//pause
        [self.btnXiaoJieTiaoZhuan setEnabled:true];
        [self.btnSuDu setEnabled:true];

        if (_iPlayMode == 2) {
            [self.btnHint setEnabled:false];
            [self.btnHandCtl setEnabled:true];
            [self.sliderXiaoJie setEnabled:true];
            [self.sliderSpeed setEnabled:true];
            [self.btnRePlay setEnabled:true];
        }else if (_iPlayMode == 1){
            [self.sliderSpeed setEnabled:false];
            [self.btnHint setEnabled:true];
            [self.btnHandCtl setEnabled:true];
            [self.sliderXiaoJie setEnabled:false];
            [self.btnRePlay setEnabled:true];
        }
    }
    
}


@end
