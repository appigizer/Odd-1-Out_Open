//
//  NSObject+BlockOperations.h
//  CallAtHome
//
//  Created by Pankaj Sharma on 06/06/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define InvokeThisMethodOnMainThread(param) \
if (![NSThread isMainThread]) { \
[self performSelectorOnMainThread:_cmd withObject:param waitUntilDone:NO];   \
return; \
}

#define InvokeThisMethodOnMainThreadWithNoParam() \
if (![NSThread isMainThread]) { \
[self performSelector:_cmd];   \
return; \
}


typedef void (^BlockOperation)(void);

@interface NSObject (BlockOperations)
- (void)performBlock:(BlockOperation)blockOp afterDelay:(NSTimeInterval)delay;
- (void)performBlockOnMainThread:(BlockOperation)blockOp;
- (void)executeBlockOnMainQueue:(BlockOperation)blockOp;
+ (void)performBlock:(BlockOperation)blockOp afterDelay:(NSTimeInterval)delay;
@end


@interface NSObject (NetworkActivity)
+ (void)showNetworkActityIndicator;
+ (void)hideNetworkActityIndicator;
@end
