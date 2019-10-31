//
//  BITAttachImageView.h
//  BITUNION
//
//  Created by 尹帅 on 2019/6/5.
//  Copyright © 2019 michael. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BITAttachImageViewDelegate;

@interface BITAttachImageView : UIView
@property(retain, nonatomic) UIImage *image;
@property(weak, nonatomic) BITAttachImageViewDelegate *delegate;


@end



NS_ASSUME_NONNULL_END
@protocol BITAttachImageViewDelegate

- (void)deleteButtonPressedAt:(BITAttachImageView *_Nullable) attachView;
- (void)imageTappedAt:(BITAttachImageView *_Nonnull) attachView;
@end







