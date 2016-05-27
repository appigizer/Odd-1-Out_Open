//
//  UIViewController+Helper.h
//  CallAtHome
//
//  Created by Pankaj Sharma on 10/06/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+BlockOperations.h"

typedef void (^AlertActionHandler)( UIAlertController * _Nonnull alertController);
typedef void (^AlertActionHandlerVoid)(void);
typedef void (^AlertActionHandlerChoice)(BOOL isPositiveAction);
@interface UIViewController (Helper)
- (void)showSimpleAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)msg;
- (void)showSimpleAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)msg completion:(nullable AlertActionHandler)dismissAction;
- (void)showAlertForNoInternetConnectivity;
- (void)showAlertForError:(nullable NSError *)error;
- (void)showDeleteAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message deleteAction:(nullable AlertActionHandler)deleteAction;
- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)msg
                       positiveTitle:(nonnull NSString *)positiveTitle
                       negativeTitle:(nonnull NSString *) negativeTitle
                       actionHandler:(nullable AlertActionHandlerChoice)actionHandler;


- (nonnull UIViewController *)topMostViewControllerThatCanPresentVC;
+ (nonnull UIViewController *)topMostViewControllerThatCanPresentVC;
- (CGSize)screenSize;
- (void)openSettingsApp;
@property (nonatomic, readonly) BOOL isSomeVCPresented; /**< By this & no counting for UIAlertController */

- (nullable UIAlertController *)currentlyShownAlertController;
#pragma mark - Location
- (void)showLocationAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)msg;


#pragma mark - Parent/Child
- (void)addChildVC:(nonnull UIViewController *)childVC;
- (void)addChildVC:(nonnull UIViewController *)childVC withAnimation:(BOOL)animation;
- (void)removeFromParentVC;
- (void)removeFromParentVCWithAnimation:(BOOL)animationl;
@end
