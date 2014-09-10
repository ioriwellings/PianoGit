//
//  IAPHelper.m
//  Moko
//
//  Created by Iori Yang on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IAPHelper.h"
#import "NSString+URLConnection.h"

@implementation IAPHelper
{
    
}

@synthesize productsList;
@synthesize delegate;



+(IAPHelper*)shareIAPHelper
{
    static IAPHelper *_iapHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _iapHelper = [[self alloc] init];
    });
    return _iapHelper;
}

- (id)init
{
    
    NSSet *set = [[NSSet alloc] initWithObjects:@"com.jiaYinQiJi.product.a", @"com.jiaYinQiJi.product.b", nil];
    
    if ((self = [self initWithProductIdentifiers:set]))
    {
        
    }
    return self;
    
}

- (id)initWithProductIdentifiers:(NSSet *)Identifiers 
{
    if ((self = [super init])) 
    {
        productIdentifiers = Identifiers;
        // Check for previously purchased products
        purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in productIdentifiers) 
        {
            id productPurchased = [[NSUserDefaults standardUserDefaults] objectForKey:productIdentifier];
            if (productPurchased) 
            {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }        
    }
    return self;
}

-(void) createSKRequest
{
//    productsList = [NSMutableDictionary dictionaryWithCapacity:20];
//    skRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
//    skRequest.delegate = self;
//    [skRequest start];
}

-(void) buyProduct:(NSString *)strProductID
{
    if([SKPaymentQueue canMakePayments])
    {
        SKProduct *selectedProduct = [productsList objectForKey:strProductID];;
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        @try {
               [[SKPaymentQueue defaultQueue] addPayment:payment]; 
        }
        @catch (NSException *exception) 
        {
#if DEBUG            
            NSLog(@"%@", exception);
#endif
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                             message:@"网络错误，请稍后再试！"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        @finally
        {
            
        }
        
    }
    else
    {
        //can not to pay;
        if([self.delegate respondsToSelector:@selector(canotToPay)])
        {
            [self.delegate canotToPay];
        }
    }
}

-(void) buyProductWithID:(NSString*)strID
{
    productsList = [NSMutableDictionary dictionaryWithCapacity:20];
    skRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:strID]];
    skRequest.delegate = self;
    [skRequest start];
}

#pragma mark privatesTransaction methods

- (void)provideContent:(NSString *)productIdentifier transaction:(SKPaymentTransaction*)trans
{
//    NSString *strURL = [HTTPSERVERSADDRESS stringByAppendingPathComponent:@"/verfyiap.ashx"];
    
//    NSError *Err;
//    NSData *requestData = [NSJSONSerialization dataWithJSONObject:@{@"receipt-data":[trans.transactionReceipt base64Encoding]}
//                                                          options:0
//                                                            error:&Err];
//    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
//    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
//    [storeRequest setHTTPMethod:@"POST"];
//    [storeRequest setHTTPBody:requestData];
//    
//    // Make a connection to the iTunes Store on a background queue.
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
//    {
//                               if (connectionError) {
//                                   /* ... Handle error ... */
//                               } else {
//                                   NSError *error;
//                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                                   if (!jsonResponse) { /* ... Handle error ...*/ }
//                                   /* ... Send a response back to the device ... */
//                               }
//                           }];
    
//    [strURL postToServerWithParams:@{@"receiptData":[trans.transactionReceipt base64Encoding] } completionHandle:^(NSData *data, NSError *error)
//    {
//        if(!error && data)
//        {
//            NSError *err;
//            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
////            NSLog(@"json:%@", json);
//            if([[json objectForKey:@"status"] intValue] == 0)
//            {
//                
//            }
//        }
//    }];
    
    if([self.delegate respondsToSelector:@selector(provideProduct:)])
    {
        [self.delegate provideProduct:productIdentifier];
    }
}

-(void)recordTransaction:(SKPaymentTransaction*)transaction
{
    NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
    [obj setObject:transaction.payment.productIdentifier forKey:kProductIdentifier];
    [obj setObject:transaction.transactionDate forKey:transaction.payment.productIdentifier];
    
    NSArray *purchasedProductsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kPurchasedProductsKey];
    if(purchasedProducts == nil || [purchasedProductsArray count] == 0)
    {
        NSArray *array = [NSArray arrayWithObject:obj];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPurchasedProductsKey];
    }
    else 
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:purchasedProductsArray];
        [array addObject:obj];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:kPurchasedProductsKey];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:transaction.payment.productIdentifier]; //productPurchased
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [purchasedProducts addObject:transaction.payment.productIdentifier];
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    // and verifying store receipts
#if DEBUG   
    NSLog(@"Receipt:%@",transaction.transactionReceipt);
    NSLog(@"completeTransaction productIdentifier:%@",transaction.payment.productIdentifier);
#endif    
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier transaction:transaction];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if([self.delegate respondsToSelector:@selector(completePurchase:)])
    {
        [self.delegate completePurchase:transaction];
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier transaction:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
        NSLog(@"failedTransaction Error:%@", transaction.error);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    if([self.delegate respondsToSelector:@selector(failedPurchase:)])
    {
        [self.delegate failedPurchase:transaction];
    }
}

#pragma mark SKProductsRequestDelegate

-(void) requestDidFinish:(SKRequest *)request
{
    
}

-(void) request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(canotGetProductInfo:)])
    {
        [self.delegate canotGetProductInfo:error];
    }
}

-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    for (SKProduct *product in myProducts)
    {
#if DEBUG        
        NSLog(@"%@ %@ %@ %@", product.localizedTitle, product.price, product.productIdentifier, product.localizedDescription);
#endif
        //populate your ui from the products list;
        [productsList setObject:product forKey:product.productIdentifier];
        [self buyProduct:product.productIdentifier];
    }
    if([self.delegate respondsToSelector:@selector(getProductInfoSucceed:)])
    {
        [self.delegate getProductInfoSucceed:myProducts];
    }
}


#pragma mark SKPaymentTransactionObserver

-(void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (0 < [queue.transactions count])
    {

        
    }
}

@end
