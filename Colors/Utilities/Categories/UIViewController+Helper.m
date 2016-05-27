//
//  UIViewController+Helper.m
//  CallAtHome
//
//  Created by Pankaj Sharma on 10/06/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "UIViewController+Helper.h"
#ifndef LOCALIZE
#define LOCALIZE(str)  NSLocalizedString(str, nil)
#endif


@implementation UIViewController (Helper)
#pragma mark - Alerts
- (void)showSimpleAlertViewWithTitle:(NSString *)title message:(NSString *)msg
{
  [self showSimpleAlertViewWithTitle:title message:msg completion:nil];
}


- (void)showSimpleAlertViewWithTitle:(NSString *)title message:(NSString *)msg completion:(AlertActionHandler)dismissAction
{
  UIViewController *presenter = self;
  
  if (self.presentedViewController) {
    presenter = self.presentedViewController;
  }
  NSString *cancelButtonTitle = LOCALIZE(@"Dismiss");
  if ([UIAlertController class]) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
      if (dismissAction) {
        dismissAction(alert);
      }
    }];
    [alert addAction:dismiss];
    [presenter presentViewController:alert animated:YES completion:nil];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
  }
}



- (void)showLocationAlertWithTitle:(NSString *)title message:(NSString *)msg
{
  NSString *cancelButtonTitle = @"Dismiss";
  NSString *otherButtonTitle = @"Settings";
  if ([UIAlertController class]) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingsButton = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
      [self openSettingsApp];
    }];
    [alert addAction:settingsButton];

    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:dismiss];
    dispatch_async(dispatch_get_main_queue(), ^ {
      [self presentViewController:alert animated:YES completion:nil];
    });
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
  }
}



- (void)showDeleteAlertWithTitle:(NSString *)title message:(NSString *)message deleteAction:(AlertActionHandler)deleteAction
{
  if (title == nil) {
    title = LOCALIZE(@"Delete");
  }
  
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *delete = [UIAlertAction actionWithTitle:LOCALIZE(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    dispatch_async(dispatch_get_main_queue(), ^{
      deleteAction(alertVC);
    });
  }];
  
  [alertVC addAction:delete];
  
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:LOCALIZE(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
  [alertVC addAction:cancel];
  
  [self presentViewController:alertVC animated:true completion: nil];
}


- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)msg
                       positiveTitle:(nonnull NSString *)positiveTitle
                       negativeTitle:(nonnull NSString *) negativeTitle
                       actionHandler:(nullable AlertActionHandlerChoice)actionHandler
{
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *positiveButton = [UIAlertAction actionWithTitle:positiveTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    actionHandler(YES);
  }];
  [alert addAction:positiveButton];
  
  UIAlertAction *negativeButton = [UIAlertAction actionWithTitle:negativeTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    actionHandler(NO);
  }];
  [alert addAction:negativeButton];
  
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertForError:(NSError *)error
{
  NSString *message = nil;
#ifdef ERROR_KEY
  message = error.userInfo[ERROR_KEY];
#endif
  if (message == nil) {
    message = error.localizedDescription;
  }
  [self showSimpleAlertViewWithTitle:@"Something Went Wrong" message:message];
}


- (void)showAlertForNoInternetConnectivity
{
  [self showSimpleAlertViewWithTitle:@"No Internet Connectivity"
                             message:@"You do not have internet connectivity right now. Connect and try again!"];
}


+ (UIViewController *)topMostViewControllerThatCanPresentVC
{
  UIViewController *topVC = [UIViewController topViewControllerWithRootViewController:
                             [UIApplication sharedApplication].keyWindow.rootViewController];
  if ([topVC isKindOfClass:[UIAlertController class]]) {
    UIViewController *presentingVC = topVC.presentingViewController;
    [presentingVC dismissViewControllerAnimated:YES completion:nil];
    return presentingVC;
  }
  
  return topVC;
}


#pragma mark - Others
- (UIViewController *)topMostViewControllerThatCanPresentVC
{
  return [UIViewController topMostViewControllerThatCanPresentVC];
}


+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
  if ([rootViewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController* tabBarController = (UITabBarController*)rootViewController;
    return [UIViewController topViewControllerWithRootViewController:tabBarController.selectedViewController];
  } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController* navigationController = (UINavigationController*)rootViewController;
    return [UIViewController topViewControllerWithRootViewController:navigationController.visibleViewController];
  } else if (rootViewController.presentedViewController) {
    UIViewController* presentedViewController = rootViewController.presentedViewController;
    return [UIViewController topViewControllerWithRootViewController:presentedViewController];
  } else {
    return rootViewController;
  }
}


- (void)openSettingsApp
{
  BOOL canOpenSettings = ((&UIApplicationOpenSettingsURLString) != NULL);
  if (canOpenSettings) {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
  }
}



- (CGSize)screenSize
{
  static CGSize screenSize;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    screenSize = [UIScreen mainScreen].bounds.size;
  });
  return screenSize;
}


- (BOOL)isSomeVCPresented
{
  if (self.presentedViewController && ![self.presentedViewController isKindOfClass:[UIAlertController class]]) {
    return YES;
  }
  
  return NO;
}

- (UIAlertController *)currentlyShownAlertController
{
  UIViewController *topVC = [UIViewController topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
  if ([topVC isKindOfClass:[UIAlertController class]]) {
    return (UIAlertController *)topVC;
  }
  return nil;
}

#pragma mark - Parent/Child
- (void)addChildVC:(UIViewController *)childVC
{
  if (![self.childViewControllers containsObject:childVC]) {
    [self addChildViewController:childVC];
    [self.view addSubview:childVC.view];
    [childVC.view setFrame:self.view.frame];
    [childVC didMoveToParentViewController:self];
  }
  childVC.view.frame = self.view.bounds;
}

- (void)addChildVC:(UIViewController *)childVC withAnimation:(BOOL)animation
{
  if (![self.childViewControllers containsObject:childVC]) {
    [self addChildViewController:childVC];
    [self.view addSubview:childVC.view];
    [childVC.view setFrame:self.view.frame];
    [childVC didMoveToParentViewController:self];
  }
  childVC.view.frame = self.view.bounds;
  childVC.view.alpha = 0.0;
  if (animation) {
    [UIView animateWithDuration:0.3f animations:^{
      childVC.view.alpha = 1.0;
    }];
  }else {
       childVC.view.alpha = 1.0;
  }
  
}

- (void)removeFromParentVC
{
  if (self.parentViewController) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }
}

- (void)removeFromParentVCWithAnimation:(BOOL)animation
{
  if (self.parentViewController) {
    
    if (animation) {
      [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0;
      } completion:^(BOOL finished) {
        self.view.alpha = 1.0;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];

      }];
    }else {
      [self.view removeFromSuperview];
      [self removeFromParentViewController];
    }
  }
}
@end
