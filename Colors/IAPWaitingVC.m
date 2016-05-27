//
//  IAPWaitingVC.m
//  Colors
//
//  Created by Surjeet Singh on 05/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "IAPWaitingVC.h"
#import "UIViewController+Helper.h"

@interface IAPWaitingVC ()

@end
@implementation IAPWaitingVC

- (void)viewDidLoad {
    [super viewDidLoad];
  [self.activityIndicator startAnimating];
    // Do any additional setup after loading the view from its nib.
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}


- (void)loadView
{
  [super loadView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startActivityIndicator {
  
}

- (void)stopActivityIndicator {
  [self.activityIndicator stopAnimating];
}

-(void)displayMessage:(NSString *)msg andStartActivityIndicator:(BOOL)start{  
  
  UIViewController *topMost = [UIViewController topMostViewControllerThatCanPresentVC];
  
  
 // [topMost addChildVC:self];
  [topMost addChildVC:self withAnimation:YES];
  if (start) {
    [self.activityIndicator startAnimating];
  }
  self.msgLabel.text = msg;

//  [topMost presentViewController:self animated:YES completion:^{
//    if (start) {
//      [self.activityIndicator startAnimating];
//    }
//    self.msgLabel.text = msg;
//  }];
}

- (void)displayMessage:(NSString *)msg {
  
}
- (IBAction)cancelButtonTap:(UIButton *)sender {
  [self removeFromParentVC];
 // [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
