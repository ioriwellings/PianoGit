//
//  FavoriteTableViewCell.m
//  PianoHelp
//
//  Created by Jobs on 14-5-30.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "FavoriteTableViewCell.h"
#import "MelodyFavorite.h"
#import "Melody.h"
#import "Score.h"

@implementation FavoriteTableViewCell

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.contentView.layer.cornerRadius = 16;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateContent:(id)obj
{
    MelodyFavorite *favo = (MelodyFavorite*)obj;
    self.labTitle.text = favo.melody.name;
    self.labAuthor.text = favo.melody.author;
    self.btnPlay.fileName = favo.melody.filePath;
    if(favo.melody.score)
        self.labScore.text = [favo.melody.score.score stringValue];
    if(favo.melody.score.rank)
    {
        [self.btnRank setTitle:[favo.melody.score.rank stringValue] forState:UIControlStateNormal];
        self.btnRank.hidden = NO;
    }
    else
        self.btnRank.hidden = YES;
}

- (IBAction)btnPlay_click:(id)sender
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        //cell.selected = NO;
        ((FavoriteTableViewCell*)cell).imageSelected.hidden = YES;
    }
    self.selected = YES;
    self.imageSelected.hidden = NO;
}
@end
