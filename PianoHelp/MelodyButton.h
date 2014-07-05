//
//  MelodyButton.h
//  PianoHelp
//
//  Created by Jobs on 14-6-13.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Melody.h"

@interface MelodyButton : UIButton
@property(nonatomic, strong) NSString* fileName;
@property(nonatomic) int type;
@property(nonatomic, weak) Melody *melody;
@end
