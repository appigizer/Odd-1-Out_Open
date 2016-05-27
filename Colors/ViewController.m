//
//  ViewController.m
//  Colors
//
//  Created by Surjeet Singh on 29/02/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "ViewController.h"
#import "IAPHelper.h"
#import "LevelCell.h"
#import "UnlockLevelVC.h"
#import "Reachability.h"
#import <KSToastView.h>
#import "UIViewController+Helper.h"


@interface ViewController () <IAPHelperDelegate>
{
  int noOfFreeStage;
}

@property (weak, nonatomic) IBOutlet UITableView *levelTableView;
@property (weak, nonatomic) IBOutlet UIButton *removeAdsButton;

@property (copy, nonatomic) NSArray<NSString *> *productIDs;

@property (strong, nonatomic) NSArray *levels;

@property (nonatomic) BOOL canPerformSegue;

@property (nonatomic, strong) NSMutableArray<UIView *> *views;

@property (nonatomic, strong) UIView *footer;

@property (nonatomic, strong) Reachability *internetReachability;

@property (nonatomic) BOOL isGamePlayOn; //Whether playing game

@end

@implementation ViewController

static NSString * const reuseIdentifier = @"levelCell";

- (void)viewDidLoad {
  [super viewDidLoad];
  [IAPHelper sharedManager].IAPDelegate = self;
  
  
  
  noOfFreeStage = 7;
  
  self.levels = @[@"Color", @"Digit", @"Emojis",@"Sports", @"Shape",  @"Profession", @"Smiley" ,@"Greek Symbols", @"Human Reaction" ];
  self.productIDs = @[@"put_your_own_iap_buylevel_id_here", @"put_your_own_iap_adremove_id_here"];
  self.levelTableView.dataSource = self;
  self.levelTableView.delegate = self;

  if ([[IAPHelper sharedManager] isProductPurchased:self.productIDs[1]]) {
    [self.removeAdsButton setHidden:YES];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
  self.internetReachability = [Reachability reachabilityForInternetConnection];
  [self.internetReachability startNotifier];
  
  ///This notification code is only for testing/open source code purpose; And must be removed when using In App Purchase
  [[NSNotificationCenter defaultCenter] addObserverForName:LevelsUnlockedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.productIDs[0]];
    //also add to IAP
    [[IAPHelper sharedManager].purchasedProducts addObject:self.productIDs[0]];
    //reload collection view
    [self.levelTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
  }];
  
}



- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  _isGamePlayOn = false;
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
  //  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  //  CGFloat width = size.width;
  //  CGFloat height = floorf(size.height / 10);
  //
  //
  //
  //  [coordinator animateAlongsideTransitionInView:self.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
  //    CGFloat y = self.view.bounds.origin.y;
  //    for (UIView *view in self.views) {
  //      view.frame = CGRectMake(view.frame.origin.x, y, width, height);
  //       y = y+height;
  //    }
  //  } completion:nil];
//}

- (void)reachabilityChanged:(NSNotification *)notification
{
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

///Method for Selecting Random Color
- (UIColor *)randomColor
{
  float bright;
  UIColor *randomColor;
  do {
    float hur = (arc4random() % 255 / 256.0); //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    randomColor = [[UIColor alloc] initWithHue:hur saturation:saturation brightness:brightness alpha:1.0];
    CGFloat red, green, blue;
    [randomColor getRed:&red green:&green blue:&blue alpha:nil];
    bright = ((red  * (CGFloat)299.0) + (green * (CGFloat)587.0) + (blue * (CGFloat)114.0)) / (CGFloat)1000.0;
    
  } while (bright > 0.6);
  return randomColor;
}

- (UIView *)setUpFooter
{
  UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
  UIButton *unlockLevels = [UIButton buttonWithType:UIButtonTypeCustom];
  [unlockLevels setTranslatesAutoresizingMaskIntoConstraints:false];
  [unlockLevels setTitle:@"Unlock More Levels" forState:UIControlStateNormal];
  
  [unlockLevels.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:33.0]];
  [unlockLevels setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [unlockLevels sizeToFit];
  [unlockLevels addTarget:self action:@selector(tapOnUnlockLevels:) forControlEvents:UIControlEventTouchUpInside];
  [unlockLevels setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
  [footer addSubview:unlockLevels];
  
  NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:unlockLevels attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:footer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
  centerX.active = true;
  
  NSLayoutConstraint *topSpaceToFooter = [NSLayoutConstraint constraintWithItem:unlockLevels attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footer attribute:NSLayoutAttributeTop multiplier:1 constant:30];
  topSpaceToFooter.active = true;
  
  
  //Restore Buttons
  UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [restoreButton setTranslatesAutoresizingMaskIntoConstraints:false];
  [restoreButton setTitle:@"Restore Purchases" forState:UIControlStateNormal];
  
  [restoreButton.titleLabel setFont:[UIFont fontWithName:@"Marker Felt" size:33.0]];
  [restoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [restoreButton sizeToFit];
  [restoreButton addTarget:[IAPHelper sharedManager] action:@selector(restorePurchases) forControlEvents:UIControlEventTouchUpInside];
  [restoreButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
  
  [footer addSubview:restoreButton];
  
  
  NSLayoutConstraint *restoreButtonCenterX = [NSLayoutConstraint constraintWithItem:restoreButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:footer attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
  restoreButtonCenterX.active = true;
  
  NSLayoutConstraint *bottomSpaceToFooter = [NSLayoutConstraint constraintWithItem:restoreButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footer attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
  bottomSpaceToFooter.active = true;
  
  
  return footer;
}

- (void)tapOnUnlockLevels:(UITapGestureRecognizer *)gestureRecognizer
{
  if (self.internetReachability.currentReachabilityStatus == NotReachable) {
    [self displayNoInternetAlert];
  }else {
    UnlockLevelVC *unlockLevel = [self.storyboard instantiateViewControllerWithIdentifier:@"UnlockLevelVC"];
    unlockLevel.levels = @[@"Sports", @"Shape",  @"Profession", @"Smiley" ,@"Greek Symbols", @"Human Reaction"];
    unlockLevel.levelProductID = self.productIDs[0];
    // [self showViewController:unlockLevel sender:self];
    [self presentViewController:unlockLevel animated:YES completion:nil];
    
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)displayNoInternetAlert
{
  UIAlertController *gameOver = [UIAlertController alertControllerWithTitle:@"Connectivity Problem" message:@"No Internet Connection" preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
  }];
  
  [gameOver addAction:ok];
  [self presentViewController:gameOver animated:YES completion:^{
  }];
}

- (IBAction)tapOnRemoveAds:(UIButton *)sender {
  if (self.internetReachability.currentReachabilityStatus == NotReachable) {
    [self displayNoInternetAlert];
  } else {
    //Uncomment to actually use In App Purchase
//    [[IAPHelper sharedManager]requestPurchaseOfProductWithProductID:self.productIDs[1]];

    ///This notification code is only for testing/open source code purpose; And must be removed when using In App Purchase
    [self showAlertControllerWithTitle:@"Remove Ads?"
                               message:@"Add you own code here to remove ads. Right now there are no ads. Do you want to marks ads removed?"
                         positiveTitle:@"Yes"
                         negativeTitle:@"Cancel"
                         actionHandler:^(BOOL isPositiveAction) {
                           [[NSUserDefaults standardUserDefaults] setBool:isPositiveAction forKey:self.productIDs[1]];
                           [self.removeAdsButton setHidden:YES];
                           //also add to IAP
                           [[IAPHelper sharedManager].purchasedProducts addObject:self.productIDs[1]];
                         }];
  }
  
}
- (IBAction)tapOnRateUs:(UIButton *)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1090333342"]];
  ///Replace with your own app store id
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if ([[IAPHelper sharedManager] isProductPurchased:self.productIDs[1]]) {
    [self.removeAdsButton setHidden:YES];
  }
  
  if ([[IAPHelper sharedManager] isProductPurchased:self.productIDs[0]]) {
    return self.levels.count;
  }
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  LevelCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  cell.label.text = self.levels[indexPath.section];
  cell.bgImageView.image = [UIImage imageNamed:self.levels[indexPath.section]];
  cell.label.textColor = [UIColor blackColor];
  
  return cell;
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section > 2) {
    
    NSLog(@"section %@",self.productIDs[0]);
    
    if (![[IAPHelper sharedManager] isProductPurchased:self.productIDs[0]]) {
      [[IAPHelper sharedManager] requestPurchaseOfProductWithProductID:self.productIDs[0]];
    }else {
      self.canPerformSegue = YES;
    }
  }else {
    self.canPerformSegue = YES;
  }
  
  self.canPerformSegue = YES;
  
  NSLog(@"Selected Level = %@", self.levels[indexPath.section]);
  //  [self tapOnUnlockLevels:nil];
  if (self.canPerformSegue) {
    self.canPerformSegue = NO;
    LevelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self setUpBeforeGameStart:cell];
    [self performSegueWithIdentifier:@"startGameSegue" sender:self];
  }
}

- (void)setUpBeforeGameStart:(LevelCell *)cell
{
  NSString *selectedLevel  = [cell.label text];
  NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
  [userdefault setObject:selectedLevel forKey:@"level"];
  _isGamePlayOn = true;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
  
  if ([[IAPHelper sharedManager]isProductPurchased:self.productIDs[0]]) {
    return nil;
  }else {
    if (section == 2) {
      return [self setUpFooter];
    }
    
  }
  return nil;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  
  if (section == 2) {
    if (![[IAPHelper sharedManager]isProductPurchased:self.productIDs[0]]) {
      return 150;
    }
  }
  return 18;
}




#pragma mark <IAPHelperDelegate>

- (BOOL)shouldDisplayAlertView
{
  return !_isGamePlayOn;
}

- (void)productPurchasedWithProductID:(NSString *)productID
{
  [self.levelTableView reloadData];
}

- (void)restoredProductWithProductID:(NSArray<NSString *> *)productIDs
{
  //  [KSToastView ks_setAppearanceBackgroundColor:[UIColor blackColor]];
  //  [KSToastView ks_showToast:@" Please Wait..." duration:2.0];
  [self.levelTableView reloadData];
}

- (void)purchaseFailedForProductID:(NSString *)productID withError:(NSError *)error {
  
}

- (void)paymentInitiatedForProductID:(NSString *)productID
{
  
}

@end
