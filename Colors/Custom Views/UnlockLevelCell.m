//
//  UnlockLevelCell.m
//  Colors
//
//  Created by Surjeet Singh on 01/04/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "UnlockLevelCell.h"

@implementation UnlockLevelCell

- (void)awakeFromNib {
  [super awakeFromNib];
  self.selectedBackgroundView = [UIView new];
  self.backgroundColor = [UIColor clearColor];
    // Initialization code
  self.layer.cornerRadius = self.contentView.frame.size.height / 2;
  self.layer.borderWidth = 2;
  self.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
