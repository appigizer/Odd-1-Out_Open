//
//  GameStatsView.h
//  Colors
//
//  Created by Surjeet Singh on 29/02/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBCircularProgressBarView.h>

@interface GameStatsView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *hintButton;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *timerProgressBar;

@end
