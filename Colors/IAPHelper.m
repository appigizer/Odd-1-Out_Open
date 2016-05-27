//
//  IAPHelper.m
//  Colors
//
//  Created by Surjeet Singh on 04/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "IAPHelper.h"
#import "UIViewController+Helper.h"

@implementation IAPHelper

+ (id)sharedManager
{
  static IAPHelper *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init
{
  if (self = [super init]) {
    
    ///Put your own in app purchase ids here
    self.productIDs = @[@"put_your_own_iap_buylevel_id_here", @"put_your_own_iap_adremove_id_here"];

    self.productInfo = @{@"Shape" : @"put_your_own_iap_buylevel_id_here",
                         @"RemoveAds": @"put_your_own_iap_adremove_id_here"
                         };
//
    self.waitingVC = [[IAPWaitingVC alloc] initWithNibName:@"IAPWaitingVC" bundle:nil];
    self.userDefault = [NSUserDefaults standardUserDefaults];
    
    self.isPurchaseAvilable = YES;
    
    [self initializepurchasedProduct];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
    NSSet *productIdentifiers = [NSSet setWithArray:self.productIDs];
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.productRequest.delegate = self;
    [self.productRequest start];
  }
  return self;
}


- (void)initializepurchasedProduct {
  
  self.purchasedProducts = [[NSMutableSet alloc] init];
  
  for (NSString *productID in self.productIDs) {
    if ([self.userDefault boolForKey:productID]) {
      [self.purchasedProducts addObject:productID];
    }
  }
}


- (void)requestPurchaseOfProductWithTitle:(NSString *)title {
  
  if (![SKPaymentQueue canMakePayments] ) {
    return;
  }
  NSString *productID = [self.productInfo objectForKey:title];
  
  SKProduct *product;
  
  if (productID != (id)[NSNull null]) {
    
    for (SKProduct *pro in self.productArray) {
      
      if ([pro.productIdentifier isEqualToString:productID]) {
        product = pro;
        break;
      }
    }
    
        [self purchaseProduct:product];
    
  } else {
    
    NSLog(@"Product Is not Avilable");
  
  }
}

- (void)requestPurchaseOfProductWithProductID:(NSString *)productID
{
  if (![SKPaymentQueue canMakePayments] || !(self.isPurchaseAvilable)) {
    return;
  }
  
  for (SKProduct *product in self.productArray) {
    
    if ([product.productIdentifier isEqualToString:productID]) {
      [self purchaseProduct:product];
      break;
    }
  }

  
  
}

- (void)requestPurchaseOfProductWithIndex:(NSUInteger)index
{
  if (![SKPaymentQueue canMakePayments] || !(self.isPurchaseAvilable)) {
    return;
  }
  [self purchaseProduct:self.productArray[index]];
}



- (void)purchaseProduct:(SKProduct *)product
{
  if (product == nil) {
    NSLog(@"Product is not At this time");
    return;
  }
  NSLog(@"Buying Product = %@", product.localizedTitle);
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
  
}

- (BOOL)isProductPurchased:(NSString *)productID {
  return [self.purchasedProducts containsObject:productID];
}


- (void)restorePurchases
{
  //Uncomment below code for actually restoring the purchases
  [[UIViewController topMostViewControllerThatCanPresentVC] showSimpleAlertViewWithTitle:@"Restore Purchases" message:@"This feature requires In-App-Purchases enabled. This open-source version doesn't have that included."];

//  [self.waitingVC displayMessage:@"Please Wait ...." andStartActivityIndicator:YES];
//  self.manualRestoration = YES;
//  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
  
}

#pragma mark <SKProductsRequestDelegate>
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
  if (response.products.count != 0) {
    
    self.productArray = response.products;//[NSArray arrayWithArray:response.products];
    
    for (SKProduct *product in self.productArray) {
      
      NSLog(@"Product = %@", product);
    }
  }else {
    
    NSLog(@"No Product is Avilable");
    
  }
  
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  if (error) {
    
    NSLog(@" error Code = %ld  error = %@",(long)error.code, error);
    self.isPurchaseAvilable = NO;
  }
}


#pragma mark <SKPaymentTransactionObserver>
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
  NSLog(@"Inside Queue Callback");
  NSMutableArray *restoredProduct = [[NSMutableArray alloc]init];
  
  for (SKPaymentTransaction *transaction in transactions) {
    
    NSLog(@"%@", transaction.payment.productIdentifier);
    
    switch (transaction.transactionState) {
      case SKPaymentTransactionStatePurchased:
        [self transactionCompleted:transaction];
        break;
        
      case SKPaymentTransactionStateFailed:
        [self transactionFailed:transaction];
        break;
        
      case SKPaymentTransactionStateRestored:
        [self transactionRestored:transaction];
        [restoredProduct addObject:transaction.payment.productIdentifier];
        NSLog(@"Product Restored");
        break;
        
      case SKPaymentTransactionStatePurchasing:
        [self.waitingVC displayMessage:@"Please Wait ...." andStartActivityIndicator:YES];
        [self transactionInProgress:transaction];
        break;
        
      default:
        break;
    }
    
  }
  if (restoredProduct.count !=0) {
    if ([self.IAPDelegate respondsToSelector:@selector(restoredProductWithProductID:)]) {
        [self.IAPDelegate restoredProductWithProductID:restoredProduct];
    }
  }
  
}


- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
  [self.waitingVC removeFromParentVCWithAnimation:YES];
  if ([self.IAPDelegate shouldDisplayAlertView]) {
    [[UIViewController topMostViewControllerThatCanPresentVC] showSimpleAlertViewWithTitle:nil message:@"Sorry! Some problem occurred while trying to restore your purchases. Please try again!"];
  }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
  [self.waitingVC removeFromParentVCWithAnimation:YES];
  if (self.manualRestoration) {
    [self setManualRestoration:false];
    if ([self.IAPDelegate shouldDisplayAlertView]) {
      [[UIViewController topMostViewControllerThatCanPresentVC] showSimpleAlertViewWithTitle:nil message:@"Your purchases have been successfully restore"];
    }
  }
}

-(void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
  [self.waitingVC removeFromParentVCWithAnimation:YES];
  
}


-(void)transactionInProgress:(SKPaymentTransaction *)transaction
{
  if ([self.IAPDelegate respondsToSelector:@selector(restoredProductWithProductID:)]) {
  [self.IAPDelegate paymentInitiatedForProductID:transaction.payment.productIdentifier];
  }
}

- (void)transactionCompleted:(SKPaymentTransaction *)transaction
{
  [self.purchasedProducts addObject:transaction.payment.productIdentifier];
  [self.userDefault setBool:YES forKey:transaction.payment.productIdentifier];
  ///delegate Method Call
  
  if ([self.IAPDelegate respondsToSelector:@selector(restoredProductWithProductID:)]) {
  
  [self.IAPDelegate productPurchasedWithProductID:transaction.payment.productIdentifier];
  }
  
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

}

- (void)transactionRestored:(SKPaymentTransaction *)transaction
{
  [self.purchasedProducts addObject:transaction.payment.productIdentifier];
  [self.userDefault setBool:YES forKey:transaction.payment.productIdentifier];
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

}

- (void)transactionFailed:(SKPaymentTransaction *)transaction
{
  NSLog(@"Payment Failed");
  
  if ([self.IAPDelegate respondsToSelector:@selector(restoredProductWithProductID:)]) {
  [self.IAPDelegate purchaseFailedForProductID:transaction.payment.productIdentifier withError:transaction.error];
  }
  
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)dealloc
{

}

@end
