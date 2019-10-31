//
//  BITTopicTableViewCell.h
//  BITUNION
//
//  Created by 尹帅 on 2018/11/20.
//  Copyright © 2018 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYText/YYText.h"

NS_ASSUME_NONNULL_BEGIN

@interface BITTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *floorLevel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (weak, nonatomic) IBOutlet YYLabel *messageLabel;

@end

NS_ASSUME_NONNULL_END
