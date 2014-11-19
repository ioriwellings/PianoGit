//
//  PracticeRecordCell.h
//  PianoHelp
//
//  Created by Jobs on 11/18/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface PracticeRecordCell : BaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labMode;
@property (weak, nonatomic) IBOutlet UILabel *labScore;

@end
