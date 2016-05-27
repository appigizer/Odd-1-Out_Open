//
//  LevelCell.m
//  Colors
//
//  Created by Surjeet Singh on 07/03/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "LevelCell.h"

@implementation LevelCell

- (void)awakeFromNib {
  self.selectedBackgroundView = [UIView new];
  self.backgroundColor = [UIColor clearColor];
//    self.contentView.backgroundColor = [UIColor clearColor];
  self.topView.layer.cornerRadius = self.topView.bounds.size.height/2;
  self.topView.layer.borderWidth = 2;
  
  self.topView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
  [super setHighlighted:highlighted animated:animated];
  if (highlighted) {
    self.label.textColor = [UIColor redColor];
  }else {
    self.label.textColor = [UIColor blackColor];
  }
}
@end
