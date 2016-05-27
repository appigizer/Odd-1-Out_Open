//
//  ColorsCollectionVC.m
//  Colors
//
//  Created by Surjeet Singh on 29/02/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@import GoogleMobileAds;
#import "ColorsCollectionVC.h"
#import "GameStatsView.h"
#import "IAPHelper.h"
@import AudioToolbox;
#import <AudioToolbox/AudioToolbox.h>
#import <KSToastView.h>
#define DEFAULT_ALPHA 1.0
#define DEFAULT_HEADER_HEIGHT 100.0
#define DEFAULT_FOOTER_HEIGHT 50.0
#define NO_OF_IMAGES 20
#define MAX_LIMIT_FOR_DIGIT_LEVEL 10


@interface ColorsCollectionVC () <GADInterstitialDelegate>
{
  int currentBlocksPerRowCount;
  int gameScore;
  int highestScore;
  int maximumNoOfCellInARow;
  float alphaValue;
  int currentTime;
  BOOL background;
  int currentLevel;
  int timeForHint;
  int noOfHint;
  float cellSpacing;
  float lineSpacing;
}

@property (nonatomic) BOOL removeAds;

///GameStat Object to Display HighScore , Hint , Time and Score
@property (strong, nonatomic) GameStatsView *header;

@property (strong, nonatomic) UICollectionReusableView *footer;

///Holds the current Color of Cell
@property(nonatomic, strong) UIColor *currentColor;

///Hold the index value of Different Cell
@property(nonatomic) int diffrentCell;

///Hold the indexPath of different Cell
@property(nonatomic, strong) NSIndexPath *differentCellIndexPath;

///Timer to increase the Progress of Progress Bar
@property(nonatomic, retain) NSTimer *timer;

///HOld the current level of game
@property(nonatomic, strong) NSString *level;

///Key to retrive the highScore of current Level
@property(nonatomic, strong) NSString *highScoreKey;

///User Default
@property(nonatomic, weak) NSUserDefaults *userDefault;

///String for Digit Level
@property(nonatomic, strong) NSString *differentString;

///Hold the size of current cell
@property(nonatomic) CGSize currentCellSize;

@property (strong, nonatomic) IBOutlet UIView *pauseScreenView;

@property (strong, nonatomic) UIVisualEffectView *dimView;

@property (strong, nonatomic) NSArray *emojis;

@property (strong, nonatomic) NSString *differentEmoji;

@property (strong, nonatomic) NSString *sameEmoji;

@property (copy, nonatomic) NSString *reuseIdentifier;

@property (strong, nonatomic) UIImage *sameImage;
@property (strong, nonatomic) UIImage *differentImage;

@property (strong, nonatomic) GADInterstitial *interstitialAd;

@property (strong, nonatomic) UIVisualEffectView *visualEffectView;

@property (nonatomic) SystemSoundID gameOverSoundID;

@property (nonatomic, strong) UILabel *timeBonusLabel;

@property (strong, nonatomic) IBOutlet UIImageView *gameNameImageView;

@end

@implementation ColorsCollectionVC

///Reuse Identifier for Collection view Cell
static NSString * const reuseIdentifier1 = @"ColorCell";
static NSString * const reuseIdentifier2 = @"ColorCellWithImage";
static NSString *const hintNotification = @"TimeForAHintNotification";
static NSString *const turnOffHintButtonAnimation = @"TurnOffHintButtonAnimation";

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.definesPresentationContext = YES;
  self.userDefault = [NSUserDefaults standardUserDefaults];
  self.level = [self.userDefault objectForKey:@"level"];
  
  if ([self.level isEqualToString:@"Color"] || [self.level isEqualToString:@"Digit"] || [self.level isEqualToString:@"Emojis"]) {
    self.reuseIdentifier = reuseIdentifier1;
  }else {
    self.reuseIdentifier = reuseIdentifier2;
  }
  
  self.highScoreKey = [NSString stringWithFormat:@"%@HighScore", self.level];
  [self retriveHighScoreAtLevel];
  self.interstitialAd = [self createInterstitial];
  
  if ([self.level isEqualToString:@"Emojis"]) {
    self.emojis = @[@"😂", @"😜" ,@"☹️", @"😀", @"😬", @"😆", @"😅", @"😇", @"😊", @"🙂", @"🙃", @"☺️", @"😋", @"😩", @"😳", @"😎", @"🤑", @"🤓", @"😍", @"😘", @"😖", @"🙄", @"😝", @"🤔", @"😤", @"😢", @"🤒", @"🤐", @"😴", @"😭"];
  }
  
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    maximumNoOfCellInARow = 9;
    cellSpacing = 5;
    lineSpacing = 5;
  }else {
    maximumNoOfCellInARow = 6;
    cellSpacing = 2;
    lineSpacing = 2;
  }
  
  ///Replace with your own in app purchase id
  _removeAds = [[IAPHelper sharedManager] isProductPurchased:@"put_your_own_iap_adremove_id_here"];
  
  [self initGameStuff];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeForAHint:) name:hintNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeForAHint:) name:turnOffHintButtonAnimation object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterInBackground) name:UIApplicationWillResignActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterInForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  
  //creating TimeBonusLabel
  self.timeBonusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
  [self.timeBonusLabel setTextColor:[UIColor redColor]];
  
  [self.header.timerProgressBar addSubview:self.timeBonusLabel];
  self.timeBonusLabel.center = self.header.timerProgressBar.center;
  //[self.timeBonusLabel setHidden:true];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  self.header.scoreLabel.text = [NSString stringWithFormat:@"Score : %d", gameScore];
  self.header.highestScoreLabel.text = [NSString stringWithFormat:@"Best : %d", highestScore];
  
  
  [self.header.hintButton setTitle:[NSString stringWithFormat:@"x %d",noOfHint] forState:UIControlStateNormal];
}




- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  self.currentCellSize = [self calculateCurrentCellSizeWithViewSize:size];
  [self.collectionViewLayout invalidateLayout];
  
  [coordinator animateAlongsideTransitionInView:self.collectionView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    
    self.dimView.frame = CGRectMake(0, 0, size.width, size.height);
    self.pauseScreenView.center = self.dimView.center;
  } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    
  }];
  
  
}


#pragma mark - Some One Time Init Stuff

- (UIView *)dimView
{
  if (!_dimView) {
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    
    _dimView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _dimView.frame = self.view.frame;
    //    _dimView.backgroundColor = [UIColor blackColor];
    //    _dimView.alpha = 0.6;
    _dimView.hidden = true;
    UITapGestureRecognizer *dismissPauseScreen = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnResumeButton:)];
    [_dimView addGestureRecognizer:dismissPauseScreen];
    [self.view addSubview:_dimView];
  }
  return _dimView;
}


- (void)retriveHighScoreAtLevel
{
  highestScore = (int)[self.userDefault integerForKey:self.highScoreKey];
  if (highestScore == 0) {
    [self.userDefault setInteger:0 forKey:self.highScoreKey];
  }
  highestScore = (int)[self.userDefault integerForKey:self.highScoreKey];
}


///This method will initialize all the imp component at the reset.
- (void)initGameStuff
{
  currentBlocksPerRowCount = 1;
  currentLevel = -1;
  gameScore = 0;
  alphaValue = 0.5;
  timeForHint = 0;
  noOfHint = 5;
  [self.header.hintButton setTitle:[NSString stringWithFormat:@"x %d",noOfHint] forState:UIControlStateNormal];
  self.header.scoreLabel.text = [NSString stringWithFormat:@"Score : %d", gameScore];
  [self initializeTimer];
  //  maxValue = ceilf((self.view.bounds.size.width + 5) / 49);
  [self setUp];
  
}

- (GADInterstitial *)createInterstitial {
  return nil;
  //  GADInterstitial *interstitial =
  //  [[GADInterstitial alloc] initWithAdUnitID:@"put_your_own_admob_unit_id_here"];
  //  interstitial.delegate = self;
  //  GADRequest *testAdRequest = [GADRequest request];
  //
  //#if DEBUG
  //  testAdRequest.testDevices = @[@"put_your_own_test_device_id_here"];
  //#endif
  //
  //  [interstitial loadRequest:testAdRequest];
  //  return interstitial;
}

- (void)initializeTimer {
  currentTime = 0;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
  [self.header.timerProgressBar setValue:currentTime animateWithDuration:0.0];
}





#pragma mark - Randomize Things
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
    
    // NSLog(@"%f ", bright);
    
  } while (bright > 0.6);
  return randomColor;
}

- (UIColor *)randomRGBColor {
  float red = (arc4random() % 255 )/256.0;
  float green = (arc4random() % 255 )/256.0;
  float blue = (arc4random() % 255 )/256.0;
  UIColor *color = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:1.0];
  return color;
}

- (int)selectDifferentCell
{
  
  if ([self.level isEqualToString:@"Digit"]) {
    self.differentString = [NSString stringWithFormat:@"%d", arc4random_uniform(MAX_LIMIT_FOR_DIGIT_LEVEL)];
  }else if ([self.level isEqualToString:@"Emojis"]){
    [self selectEmojis];
  }else if (![self.level isEqualToString:@"Color"]) {
    [self selectImages];
  }
  
  return (arc4random_uniform(currentBlocksPerRowCount*currentBlocksPerRowCount));
}


- (void)selectImages
{
  if ([self.level isEqualToString:@"Smiley"]) {
    
    int random1,random2;
    do {
      random1 = arc4random_uniform(NO_OF_IMAGES)+1;
      random2 = arc4random_uniform(NO_OF_IMAGES)+1;
    } while (random1 == random2);
    
    NSString *image0 = [NSString stringWithFormat:@"%@-%d-0", self.level, random1];
    NSString *image1 = [NSString stringWithFormat:@"%@-%d-1", self.level, random2];
    
    self.sameImage = [UIImage imageNamed:image0];
    self.differentImage = [UIImage imageNamed:image1];
  }else {
    int random1,random2;
    do {
      random1 = arc4random_uniform(NO_OF_IMAGES)+1;
      random2 = arc4random_uniform(NO_OF_IMAGES)+1;
    } while (random1 == random2);
    
    NSString *image0 = [NSString stringWithFormat:@"%@-%d", self.level, random1];
    NSString *image1 = [NSString stringWithFormat:@"%@-%d", self.level, random2];
    
    self.sameImage = [UIImage imageNamed:image0];
    self.differentImage = [UIImage imageNamed:image1];
    
  }
  
  
}

- (void)selectEmojis {
  self.differentEmoji = self.emojis[arc4random_uniform((u_int32_t)self.emojis.count)];
  do {
    self.sameEmoji = self.emojis[arc4random_uniform((u_int32_t)self.emojis.count)];
  } while ([self.differentEmoji isEqualToString:self.sameEmoji]);
}



#pragma mark - Method will be Called after Every Level

- (void)setUp
{
  int levelNumber = currentLevel + 1;
  if (currentBlocksPerRowCount < maximumNoOfCellInARow && levelNumber % 3 == 0) {
    currentBlocksPerRowCount++;
  }else {
    alphaValue = (alphaValue >= 0.9) ? alphaValue:alphaValue+0.05;
  }
  //  background = !background;
  //  if (background) {
  //    self.collectionView.backgroundColor = [UIColor blackColor];
  //  }else {
  //    self.collectionView.backgroundColor = [UIColor whiteColor];
  //  }
  //NSLog(@"Alpha Value %f", alphaValue);
  //self.currentColor = [self randomRGBColor];
  self.currentColor = [self randomColor];
  self.diffrentCell = [self selectDifferentCell];
  self.currentCellSize = [self calculateCurrentCellSizeWithViewSize:self.view.bounds.size];
  
}


- (void)updateGameScore
{
  if (gameScore > highestScore) {
    highestScore = gameScore;
    [self.userDefault setInteger:highestScore forKey:self.highScoreKey];
    
  }
  currentLevel++;
  timeForHint = 0;
  
  int div = 5;
  if (currentLevel < maximumNoOfCellInARow) {
    div = maximumNoOfCellInARow;
  }
  
  if (currentLevel % div==0 && currentLevel > 0) {
    
    if (currentTime<5) {
      currentTime = 0;
    }else {
      int timeGained = 3;//in seconds
      [KSToastView ks_setAppearanceBackgroundColor:[UIColor blackColor]];
      NSString *timeGainedStr = [NSString stringWithFormat:@"+ %is", timeGained];
      [KSToastView ks_showToast:timeGainedStr duration:1.0];
      currentTime = currentTime - timeGained;
    }
    [self updateTimer:self.timer];
  }
  
  self.header.scoreLabel.text = [NSString stringWithFormat:@"Score : %d", gameScore];
  self.header.highestScoreLabel.text = [NSString stringWithFormat:@"Best : %d", highestScore];
  
}


///Method to calculate Current cell size According to view.width and view.height
- (CGSize )calculateCurrentCellSizeWithViewSize:(CGSize )size
{
  CGSize currentViewSize = size;
  CGSize itemSize = CGSizeZero;
  int footerViewHeight = _removeAds ? 0 : DEFAULT_FOOTER_HEIGHT;
  currentViewSize.height = currentViewSize.height - lineSpacing*(currentBlocksPerRowCount-1) - footerViewHeight - DEFAULT_HEADER_HEIGHT;
  currentViewSize.width = currentViewSize.width - cellSpacing*(currentBlocksPerRowCount-1);
  
  //  if (currentViewSize.height > currentViewSize.width) {
  //    currentViewSize.height = currentViewSize.width;
  //  }else {
  //    currentViewSize.width = currentViewSize.height;
  //  }
  
  itemSize.height = floorf(currentViewSize.height / currentBlocksPerRowCount);
  itemSize.width = floorf(currentViewSize.width / currentBlocksPerRowCount);
  
  NSLog(@"Cell size = %f %f", itemSize.width, itemSize.height);
  return itemSize;
}



- (void)updateTimer:(NSTimer *)timer
{
  
  if (currentTime == 60) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:turnOffHintButtonAnimation object:self];
    [self displayGameOverWithTitle:@"Time Out ☹️"];
    
  }else {
    
    if(currentTime > 50){
      [self playSoundWithSoundName:@"tick" withExtension:@"aiff"];
    }
    
    currentTime++;
    
    if (currentLevel%5 == 0) {
      
    }
    [self.header.timerProgressBar setValue:currentTime animateWithDuration:1.0];
    
    timeForHint++;
    if (timeForHint == 5 && noOfHint > 0) {
      
      [[NSNotificationCenter defaultCenter] postNotificationName:hintNotification object:self];
    }
    
  }
  
}


///Method will Called When Hint Notification Fired
- (void)timeForAHint:(NSNotification *)notification
{
  
  if ([[notification name] isEqualToString:hintNotification]) {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionRepeat| UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
      self.header.hintButton.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:nil];
  }else if ([[notification name] isEqualToString:turnOffHintButtonAnimation]) {
    
    [self.header.hintButton.layer removeAllAnimations];
    self.header.hintButton.transform = CGAffineTransformIdentity;
    
    
  }
  
}




- (IBAction)tapOnHint:(UIButton *)sender {
  
  if (noOfHint == 0) {
    //show some paid ad here
  } else {
    noOfHint --;
    [self.header.hintButton setTitle:[NSString stringWithFormat:@"x %d",noOfHint] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:turnOffHintButtonAnimation object:self];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.differentCellIndexPath];
    cell.transform = CGAffineTransformMakeScale(0.2, 0.2);
    UIColor *color = cell.backgroundColor;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
      [self.header.hintButton setEnabled:false];
      cell.transform = CGAffineTransformIdentity;
      cell.backgroundColor = [UIColor yellowColor];
      
    } completion:^(BOOL finished) {
      
      cell.backgroundColor = color;
      [self.header.hintButton setEnabled:true];
      if (alphaValue >0.5) {
        alphaValue = 0.7;
      }
    }];
  }
}

- (IBAction)tapOnPauseButton:(UIButton *)sender {
  [self pauseGame];
  [[NSNotificationCenter defaultCenter] postNotificationName:turnOffHintButtonAnimation object:self];
  self.dimView.hidden = false;
  self.pauseScreenView.center = self.view.center;
  self.pauseScreenView.layer.cornerRadius = 10;
  [self.view addSubview:self.pauseScreenView];
  self.gameNameImageView.frame = CGRectMake(0, 0, 100, 50);
  
  [self.view addSubview:self.gameNameImageView];
  NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.gameNameImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
  centerX.active = true;
  
  NSLayoutConstraint *y = [NSLayoutConstraint constraintWithItem:self.gameNameImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20];
  y.active = YES;
  
}

#pragma mark - Pause Screen Related Stuff

- (IBAction)tapOnResumeButton:(UIButton *)sender {
  [self.pauseScreenView removeFromSuperview];
  [self.gameNameImageView removeFromSuperview];
  self.dimView.hidden = true;
  [self resumeGame];
}
- (IBAction)tapOnHomeButton:(UIButton *)sender {
  if(self.presentingViewController) {
    [self dismissViewControllerAnimated:YES completion:nil];
  }else {
    [self.navigationController popViewControllerAnimated:YES];
  }
  
}
- (IBAction)tapOnRestartButton:(UIButton *)sender {
  
  [self.pauseScreenView removeFromSuperview];
  [self.gameNameImageView removeFromSuperview];
  
  self.dimView.hidden = true;
  
  if ([self.interstitialAd isReady] && !_removeAds) {
    
    [self.interstitialAd presentFromRootViewController:self.navigationController];
  }else {
    [self initGameStuff];
    [self.collectionView reloadData];
  }
  
  
}




- (IBAction)tapOnTellAFriend:(UIButton *)sender
{
  NSString *msg = @"Check out this fun Puzzle Game. I'm sure you will like it. http://apple.co/1UPVCCf ";
  [self showShareOptionsWithMessgae:msg sender:sender completion:nil];
}

- (IBAction)tapOnBestScore:(UIButton *)sender {
  [self tapOnPauseButton:nil];
  
  NSString *message = [NSString stringWithFormat:@"Dare to beat my highscore of %d in `%@` level. Game on!! \n http://apple.co/1UPVCCf ",highestScore,self.level];
  
  [self showShareOptionsWithMessgae:message sender:sender completion:nil];
}

#pragma mark - Pause Related Functionality

- (void)pauseGame
{
  [self.timer invalidate];
  self.timer = nil;
}

- (void)resumeGame
{
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}


#pragma mark - Game Over Related Stuff

///Method to Display Alert Controller with A titile
- (void)displayGameOverWithTitle:(NSString *)title
{
  UIAlertController *gameOver = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"Your score  %d", gameScore] preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *restart = [UIAlertAction actionWithTitle:@"Restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self initGameStuff];
    [self.collectionView reloadData];
    AudioServicesDisposeSystemSoundID(self.gameOverSoundID);
  }];
  
  UIAlertAction *home = [UIAlertAction actionWithTitle:@"Home" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self tapOnHomeButton:nil];
  }];
  
  UIAlertAction *share = [UIAlertAction actionWithTitle:@"Share Score" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    
    NSString *message = [NSString stringWithFormat:@"I just Scored %d in this `%@` level. Dare to beat it!! \currentBlocksPerRowCount http://apple.co/1UPVCCf ",gameScore,self.level];
    
    [self showShareOptionsWithMessgae:message sender:gameOver completion:^{
      [self initGameStuff];
      [self.collectionView reloadData];
      [self tapOnPauseButton:nil];
    }];
  }];
  [gameOver addAction:restart];
  [gameOver addAction:home];
  [gameOver addAction:share];
  [self presentViewController:gameOver animated:YES completion:^{
    if (self.timer != (id)[NSNull null]) {
      [self.timer invalidate];
      self.timer = nil;
    }
  }];
}

#pragma mark - Share Action
- (void)showShareOptionsWithMessgae:(NSString *)message sender:(nullable id)sender completion:(void (^ __nullable)(void))completion
{
  UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
  
  if ([share respondsToSelector:@selector(popoverPresentationController)] ) {
    // iOS8
    share.popoverPresentationController.sourceView = self.view;
    if ([sender isKindOfClass:[UIAlertController class]]) {
      share.popoverPresentationController.sourceRect = CGRectMake(self.view.center.x, self.view.center.y, 20.0f, 20.0f);
      [share setCompletionWithItemsHandler:^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
        //show alert again
        UIAlertController *alertSender = (UIAlertController *)sender;
        [self presentViewController:alertSender animated:true completion:nil];
      }];
    } else {
      UIView *senderView = (UIView *)sender;
      share.popoverPresentationController.sourceRect = [senderView convertRect:senderView.bounds toView:self.view];
    }
  }
  
  [self presentViewController:share animated:YES completion:nil];
}

#pragma mark - Sound Related Function

- (void)playSoundwithSoundID:(int)ID {
  //
  ////  NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"tock" ofType:@"caf"];
  //  NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
  //  SystemSoundID soundID;
  //  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
  AudioServicesPlaySystemSound (1103);
  
}

- (void)playSoundWithSoundName:(NSString *)name withExtension:(NSString *)extension
{
  NSString *soundPath = [[NSBundle mainBundle] pathForResource:name  ofType:extension];
  SystemSoundID soundID;
  
  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
  if ([name isEqualToString:@"sadtrombo"]) {
    self.gameOverSoundID = soundID;
  }
  AudioServicesPlaySystemSound (soundID);
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
  return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  return (currentBlocksPerRowCount*currentBlocksPerRowCount);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.reuseIdentifier forIndexPath:indexPath];
  
  UILabel *label ;
  UIImageView *imageView;
  
  
  if ([self.level isEqualToString:@"Color"] || [self.level isEqualToString:@"Digit"] || [self.level isEqualToString:@"Emojis"]) {
    label = [cell.contentView viewWithTag:100];
    label.textColor = [UIColor whiteColor];
  } else {
    imageView = [cell.contentView viewWithTag:200];
  }
  
  cell.backgroundColor = self.currentColor;
  
  
  if ([self.level isEqualToString:@"Color"]) {
    label.text = @"";
    if (indexPath.row == self.diffrentCell) {
      cell.backgroundColor = [self.currentColor colorWithAlphaComponent:alphaValue];
      
    }
    
  } else if ([self.level isEqualToString:@"Digit"]) {
    
    if (indexPath.row == self.diffrentCell) {
      label.text = [NSString stringWithFormat:@" %@ ",self.differentString];
    }else {
      label.text = [NSString stringWithFormat:@"%@%@",self.differentString, self.differentString];
      
    }
    
  }else if ([self.level isEqualToString:@"Emojis"]){
    
    if (indexPath.row == self.diffrentCell) {
      label.text = [NSString stringWithFormat:@" %@ ",self.sameEmoji];
    }else {
      label.text = [NSString stringWithFormat:@" %@ ", self.differentEmoji];
      
    }
    
  }else if ([self.level isEqualToString:@"Smiley"] || [self.level isEqualToString:@"Human Reaction"] || [self.level isEqualToString:@"Profession"] ||[self.level isEqualToString:@"Shape"] ||[self.level isEqualToString:@"Greek Symbols"] || [self.level isEqualToString:@"Sports"]) {
    
    if (indexPath.row == self.diffrentCell) {
      [imageView setImage:self.differentImage];
    }else {
      [imageView setImage:self.sameImage];
    }
  }
  
  if (indexPath.row == self.diffrentCell) {
    self.differentCellIndexPath = indexPath;
  }
  
  return cell;
}


#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.currentCellSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
  return lineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
  return cellSpacing;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
  return CGSizeMake(collectionView.frame.size.width, _removeAds ? 0 : 50.0f);
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  // [[self.collectionView cellForItemAtIndexPath:indexPath] setHighlighted:YES];
  [self playSoundwithSoundID:1103];
  if (indexPath.row == self.diffrentCell) {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:turnOffHintButtonAnimation object:self];
    gameScore++;
    [self updateGameScore];
    [self setUp];
    //[self initializeTimer];
    [self.collectionView reloadData];
    
    
  }else {
    
    [self playSoundWithSoundName:@"sadtrombo" withExtension:@"wav"];
    [self displayGameOverWithTitle:@"Wrong Tile Pressed ☹️"];
  }
  
  
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
  if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
    GameStatsView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    self.header = header;
    return header;
  }else {
    UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
//    if (!_removeAds) {
//      GADBannerView *bannerAd = (GADBannerView *)[footer viewWithTag:101];
//      bannerAd.rootViewController = self.navigationController;
//#if DEBUG
//      GADRequest *testAdRequest = [GADRequest request];
//      testAdRequest.testDevices = @[@"put_your_own_device_id_here"];
//      [bannerAd loadRequest:testAdRequest];
//#else
//      bannerAd.autoloadEnabled = true;
//#endif
//    }else {
//      footer.backgroundColor = [UIColor blackColor];
//    }
//    
    self.footer = footer;
    return footer;
  }
  
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
  return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  if (cell.layer.borderWidth > 0) {
    return;
  }
  cell.layer.borderWidth = 5;
  //  if ([indexPath isEqual:self.differentCellIndexPath]) {
  //    cell.layer.borderColor = [[UIColor greenColor] CGColor];
  //    cell.layer.backgroundColor = [[UIColor greenColor] CGColor];
  //  }else {
  //    cell.layer.borderColor = [[UIColor redColor] CGColor];
  //    cell.layer.backgroundColor = [[UIColor redColor] CGColor];
  //  }
  
  [UIView animateWithDuration:0.3 animations:^{
    cell.transform = CGAffineTransformMakeScale(0.8, 0.8);
  }];
  
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
  UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
  cell.layer.borderWidth = 0;
  //  cell.layer.backgroundColor = [self.currentColor CGColor];
  [UIView animateWithDuration:0.1 animations:^{
    cell.transform = CGAffineTransformIdentity;
  }];
}

#pragma mark - <GADInterstitialDelegate>

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  
  self.interstitialAd = [self createInterstitial];
  
  [self initGameStuff];
  [self.collectionView reloadData];
}

- (void)applicationEnterInBackground
{
  NSLog(@"in back");
  [self pauseGame];
}

- (void)applicationEnterInForeground
{
  NSLog(@"in fore");
  [self resumeGame];
}

#pragma mark - Don't Cross
- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  
}


@end
