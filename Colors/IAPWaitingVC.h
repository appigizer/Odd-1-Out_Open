//
//  IAPWaitingVC.h
//  Colors
//
//  Created by Surjeet Singh on 05/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPWaitingVC : UIViewController

@property (strong, nonatomic) UIImage *image;

///By default Image in ImageView is nil.
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

///By default white Activiry indiactor
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

///By Default Enabled
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

///You need to set That.
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

- (void)displayMessage:(NSString *)msg;

- (void)displayMessage:(NSString *)msg andStartActivityIndicator:(BOOL)start;
@end
