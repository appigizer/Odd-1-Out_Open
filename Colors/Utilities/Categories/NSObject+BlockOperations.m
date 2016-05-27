//
//  NSObject+BlockOperations.m
//  CallAtHome
//
//  Created by Pankaj Sharma on 06/06/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "NSObject+BlockOperations.h"
@import UIKit;

@implementation NSObject (BlockOperations)
/**
 * Performs block of code on the current thread after specified delay
 */
- (void)performBlock:(BlockOperation)blockOp afterDelay:(NSTimeInterval)delay
{
  [self performSelector:@selector(selectorWithBlock:) withObject:blockOp afterDelay:delay];
}

- (void)selectorWithBlock:(BlockOperation)blockOp
{
  blockOp();
}

- (void)performBlockOnMainThread:(BlockOperation)blockOp
{
  [self performSelector:@selector(selectorWithBlock:)
               onThread:[NSThread mainThread]
             withObject:blockOp
          waitUntilDone:NO];
}


- (void)executeBlockOnMainQueue:(BlockOperation)blockOp
{
  dispatch_async(dispatch_get_main_queue(), blockOp);
}

+ (void)performBlock:(BlockOperation)blockOp afterDelay:(NSTimeInterval)delay
{
   [self performSelector:@selector(selectorWithBlock:) withObject:blockOp afterDelay:delay];
}

+ (void)selectorWithBlock:(BlockOperation)blockOp
{
  blockOp();
}
@end


@implementation NSObject (NetworkActivity)
+ (void)showNetworkActityIndicator
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


+ (void)hideNetworkActityIndicator
{
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


@end
