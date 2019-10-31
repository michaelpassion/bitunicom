//
//  BITTopicTableViewCell.m
//  BITUNION
//
//  Created by 尹帅 on 2018/11/20.
//  Copyright © 2018 michael. All rights reserved.
//

#import "BITTopicTableViewCell.h"

@implementation BITTopicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _messageLabel.displaysAsynchronously = YES;
    _messageLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    _messageLabel.numberOfLines = 0;
    _messageLabel.preferredMaxLayoutWidth = CGRectGetWidth(_messageLabel.frame);

    _messageLabel.userInteractionEnabled = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
