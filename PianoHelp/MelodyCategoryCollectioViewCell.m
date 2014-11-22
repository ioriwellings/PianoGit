//
//  MelodyCategoryCollectioViewCell.m
//  PianoHelp
//
//  Created by Jobs on 14-5-22.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyCategoryCollectioViewCell.h"
#import "MelodyCategory.h"
#import "AppDelegate.h"

@implementation MelodyCategoryCollectioViewCell
{
    SKRequest *skRequest;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)btnBuy_click:(id)sender
{
    [[IAPHelper shareIAPHelper] buyProductWithID:self.productID];
}

-(void) updateContent:(id)obj
{
    MelodyCategory *category = (MelodyCategory*)obj;
    self.productID = category.buyURL;
    NSString *strPath = [[((AppDelegate*)[UIApplication sharedApplication].delegate) filePathForName:category.name] stringByAppendingPathExtension:@"png"];
    if(category.cover)
    {
        self.imageViewBG.image = [UIImage imageNamed:category.cover];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:strPath])
    {
        self.imageViewBG.image = [UIImage imageWithContentsOfFile:strPath];
    }
    else
    {
        if (category.parentCategory == NULL)
        {
            self.imageViewBG.image = [UIImage imageNamed:@"shifanqupu.png"];
        }
        else
        {
            self.imageViewBG.image = [UIImage imageNamed:@"shuji.png"];
        }
    }
    //else
    {
        if(category.name)
            self.labTitle.text = category.name;
    }
//    category.buy = @1;
    if([category.buy intValue] == 2)
    {
        self.imageViewBuy.image = [UIImage imageNamed:@"weigoumai.png"];
        self.imageViewBuy.hidden = NO;
        self.btnBuy.hidden = NO;
        [self.btnBuy setTitle:@"点击购买" forState:UIControlStateNormal];
        self.btnBuy.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_4);
        skRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
        skRequest.delegate = self;
        [skRequest start];
    }
    else if([category.buy intValue] == 1)
        
    {
        self.imageViewBuy.image = [UIImage imageNamed:@"yigoumai.png"];
        self.imageViewBuy.hidden = NO;
        self.btnBuy.hidden = YES;
        //[self.btnBuy setTitle:@"打开" forState:UIControlStateDisabled];
    }
    else
    {
        self.imageViewBuy.hidden = YES;
        self.btnBuy.hidden = YES;
    }
}

-(void)setPriceWithProduct:(SKProduct*)p
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:p.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:p.price];
    [self.btnBuy setTitle:formattedPrice forState:UIControlStateNormal];
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    for (SKProduct *product in myProducts)
    {
        [self setPriceWithProduct:product];
        break;
    }
}

@end
