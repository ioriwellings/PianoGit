//
//  FavoriteTableViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-30.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "MelodyButton.h"

@class QinFangViewController;

@interface FavoriteTableViewCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageSelected;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labAuthor;
@property (weak, nonatomic) IBOutlet UILabel *labScore;
@property (weak, nonatomic) IBOutlet UIButton *btnRank;
@property (weak, nonatomic) IBOutlet MelodyButton *btnPlay;
@property (weak, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) MelodyFavorite *favo;
- (IBAction)btnPlay_click:(id)sender;
-(void)setSelectedOnSelf;
@end
