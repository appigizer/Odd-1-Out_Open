//
//  UnlockLevelVC.m
//  Colors
//
//  Created by Surjeet Singh on 10/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "UnlockLevelVC.h"
#import "IAPHelper.h"
#include "UnlockLevelCell.h"
#import "UIViewController+Helper.h"

NSString * const LevelsUnlockedNotification = @"levels_unlocked";

@interface UnlockLevelVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *levelTableView;

@end

@implementation UnlockLevelVC

static NSString * const reuseIdentifier = @"UnlockLevelCell";

- (void)viewDidLoad {
    [super viewDidLoad];
  self.levelTableView.dataSource = self;
  self.levelTableView.delegate = self;
    // Do any additional setup after loading the view.
     // self.levelTableView.tableHeaderView = [self setUpHeader];
  
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}


//- (UIView *)setUpHeader {
//  
//  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
//  UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//  label.translatesAutoresizingMaskIntoConstraints = false;
//  label.text = @"Unlock these Awesome Levels";
// // label.textColor = [UIColor whiteColor];
//  label.textAlignment = NSTextAlignmentCenter;
//  [label setFont:[UIFont fontWithName:@"Marker Felt" size:33.0]];
//  [label sizeToFit];
//  
//  [header addSubview:label];
//  
//  NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
//  centerX.active = true;
//  
//  NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
//  centerY.active = true;
//  
//  return header;
//}

- (IBAction)tapOnBackButton:(UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapOnUnlockLevelButton:(id)sender {
  //Directly unlocking it here now; You can redirect it to purchase
  [self showAlertControllerWithTitle:@"Unlock All Levels?"
                             message:@"Add you own code here to unlock levels. Do you want to unlock the levels?"
                       positiveTitle:@"Yes"
                       negativeTitle:@"Cancel"
                       actionHandler:^(BOOL isPositiveAction) {
                         [[NSNotificationCenter defaultCenter] postNotificationName:LevelsUnlockedNotification object:nil];
                      }];
  //[[IAPHelper sharedManager] requestPurchaseOfProductWithProductID:self.levelProductID];
}



#pragma mark - <UITableViewDataSource>


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.levels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UnlockLevelCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//  UILabel *label = [cell.contentView viewWithTag:1];
//  UIImageView *imageview = [cell.contentView viewWithTag:11];
  [cell.bgImageView setImage:[UIImage imageNamed:self.levels[indexPath.section]]];
  cell.label.text = self.levels[indexPath.section];
  return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  UIView *view = [UIView new];
  view.backgroundColor = [UIColor clearColor];
  return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 20;
}
#pragma mark - <UITableViewDelegate>



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
