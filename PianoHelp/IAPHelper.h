//
//  IAPHelper.h
//  Moko
//
//  Created by Iori Yang on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAPActionDelegate <NSObject>
@optional
-(void)canotToPay;
-(void)canotGetProductInfo:(NSError *)error;
-(void)getProductInfoSucceed:(NSArray *)products;
-(void)completePurchase:(SKPaymentTransaction *)transaction;
-(void)failedPurchase:(SKPaymentTransaction *)transaction;
-(void)provideProduct:(NSString*)strID;
@end

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKRequest *skRequest;
    NSMutableDictionary *productsList;
    NSSet * productIdentifiers;
    NSMutableSet * purchasedProducts;
}
@property (assign) NSObject<IAPActionDelegate> *delegate;
@property (readonly) NSMutableDictionary *productsList;

+(IAPHelper*)shareIAPHelper;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
-(void) createSKRequest;
-(void) buyProduct:(NSString *)strProductID;
-(void) buyProductWithID:(NSString*)strID;

@end
