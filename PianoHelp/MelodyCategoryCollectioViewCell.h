//
//  MelodyCategoryCollectioViewCell.h
//  PianoHelp
//
//  Created by Jobs on 14-5-22.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPHelper.h"

@interface MelodyCategoryCollectioViewCell : UICollectionViewCell <SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewBG;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBuy;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBuy;
@property (strong, nonatomic) NSString *productID;

- (IBAction)btnBuy_click:(id)sender;
-(void) updateContent:(id)obj;

@end
