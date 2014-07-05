//
//  WuXianPuViewController.m
//  PianoHelp
//
//  Created by zhengyw on 14-6-25.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "WuXianPuViewController.h"
#import "RootViewController.h"

@interface WuXianPuViewController ()

@end

@implementation WuXianPuViewController

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
    
    switch(self.type ) {
        case 0:
            self.btnPuKu.hidden = YES;
            break;
        case 1:
        case 2:
        case 3:
            self.btnPuKu.hidden = NO;
            break;
    }
    
    if (self.fileName == nil) return;
    
    midifile = [[MidiFile alloc] initWithFile:self.fileName];
    [midifile initOptions:&options];
    
    [self loadSheetMusic];
}


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
    
    float height = sheetmusic.frame.size.height;
    CGRect frame = CGRectMake(0, 75, 1024, 768-75);
    scrollView= [[UIScrollView alloc] initWithFrame: frame];
    scrollView.contentSize= CGSizeMake(1024, height+280);
    scrollView.backgroundColor = [UIColor whiteColor];
    
    
    [scrollView addSubview:sheetmusic];
    sheetmusic.scrollView = scrollView;
    sheetmsic1 = [[SheetMusicPlay alloc] initWithStaffs:[sheetmusic  getStaffs]
                                          andTrackCount: [sheetmusic getTrackCounts] andOptions:&options];
    
    sheetmsic1.frame = frame;
    [sheetmsic1 setZoom:zoom];
    sheetmsic1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:sheetmsic1];
    [self.view addSubview:scrollView];
    
    
    player = [[MidiPlayer alloc] init];
    player.delegate = self;
    player.sheetPlay = sheetmsic1;
    float value = 60000000/[[midifile time] tempo];
    [player changeSpeed:value];
    [player setMidiFile:midifile withOptions:&options andSheet:sheetmusic];
    
    [piano setShade:[UIColor blueColor] andShade2:[UIColor redColor]];
    [piano setMidiFile:midifile withOptions:&options];
    [player setPiano:piano];
    
    scrollView.hidden = NO;
    sheetmsic1.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPuKuClick:(UIButton *)sender
{
    [player stop];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kBackToQinfangNotification object:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnPlayClick:(UIButton *)sender {
    
    if([((UIButton*)sender) isSelected])
    {
        [((UIButton*)sender) setSelected:false];
        [player playPause];
        scrollView.hidden = NO;
        sheetmsic1.hidden = YES;
    }
    else
    {
        [((UIButton*)sender) setSelected:true];
        [player listen];
        
        scrollView.hidden = YES;
        sheetmsic1.hidden = NO;
    }
    
}

- (IBAction)btnBackClick:(UIButton *)sender {
    
    [player stop];
    [self.navigationController popViewControllerAnimated:YES];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"pushRootViewSegue"])
    {
        [player stop];
        RootViewController *vc = segue.destinationViewController;
        vc.type = self.type;
    }
}

#pragma mark MidiPlayerDelegate
-(void)endSongs
{
    scrollView.hidden = NO;
    sheetmsic1.hidden = YES;
}

@end
