//
//  IAPHelper.h
//  Colors
//
//  Created by Surjeet Singh on 04/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

@import StoreKit;

#import "IAPWaitingVC.h"
#import <Foundation/Foundation.h>

@protocol IAPHelperDelegate <NSObject>

@optional
///Default is YES.If you Don't Want to use Native Waiting View Return NO.
- (BOOL)shouldUseNativeWaitingView;

///Whether to display alert view (Return NO if gameplay is on)
- (BOOL)shouldDisplayAlertView;

///This Method Will return an array of product that has been restored.
- (void)restoredProductWithProductID:(NSArray<NSString *> *)productIDs;

///Mehotd will be Called when payment for product with product ID is initiated.
- (void)paymentInitiatedForProductID:(NSString *)productID;

///Purchase Done For Product ID.
- (void)productPurchasedWithProductID:(NSString *)productID;

///Purchase failed for product ID with error. 
- (void)purchaseFailedForProductID:(NSString *)productID withError:(NSError *)error;



@end

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) NSArray <NSString *> *productIDs;

@property (strong, nonatomic) NSArray<SKProduct *> *productArray;

@property (strong, nonatomic) SKProductsRequest *productRequest;

@property (strong, nonatomic) NSDictionary *productInfo;

@property (nonatomic) BOOL isPurchaseAvilable;

@property (nonatomic, strong) NSUserDefaults *userDefault;

@property (nonatomic, strong) NSMutableSet *purchasedProducts;

@property (nonatomic, strong) IAPWaitingVC *waitingVC;

@property (nonatomic) id<IAPHelperDelegate> IAPDelegate;

@property (nonatomic) BOOL manualRestoration;

+ (instancetype) sharedManager;

- (void)requestPurchaseOfProductWithTitle:(NSString *)title ;

- (void)requestPurchaseOfProductWithProductID:(NSString *)productID;

- (void)requestPurchaseOfProductWithIndex:(NSUInteger)index;

- (BOOL)isProductPurchased:(NSString *)productID;

- (void)restorePurchases;

@end
