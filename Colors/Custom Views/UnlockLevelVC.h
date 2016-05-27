//
//  UnlockLevelVC.h
//  Colors
//
//  Created by Surjeet Singh on 10/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnlockLevelVC : UIViewController

///Only for OpenSource purpose
FOUNDATION_EXPORT NSString * const LevelsUnlockedNotification;

@property (nonatomic, strong) NSArray *levels;
@property (strong, nonatomic) NSString *levelProductID;


@end
