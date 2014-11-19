//
//  PracticeRecordCell.m
//  PianoHelp
//
//  Created by Jobs on 11/18/14.
//  Copyright (c) 2014 FlintInfo. All rights reserved.
//

#import "PracticeRecordCell.h"
#import "PracticeRecord.h"

@implementation PracticeRecordCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)updateContent:(id)obj
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"AM"];
    [formatter setPMSymbol:@"PM"];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    PracticeRecord *_record = (PracticeRecord*)obj;
    self.labDate.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:_record.createDate]];;
    self.labName.text = _record.melodyName;
    self.labMode.text = _record.mode;
    self.labScore.text = [_record.score stringValue];
}

@end
