//
//  BITAttachImageView.m
//  BITUNION
//
//  Created by 尹帅 on 2019/6/5.
//  Copyright © 2019 michael. All rights reserved.
//

#import "BITAttachImageView.h"
#import "Masonry.h"

@interface BITAttachImageView()
@property(nonatomic, assign) CGFloat imageSize;
@property(nonatomic, assign) CGFloat buttonSize;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIButton *deleteButton;

@end

@implementation BITAttachImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup {
    self.layer.cornerRadius = 4;
    self.clipsToBounds = true;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:tapGesture];
    [self.deleteButton setImage:[UIImage imageNamed:@"xxx"] forState:normal];
    self.deleteButton.backgroundColor = UIColor.whiteColor;
    self.deleteButton.tintColor = UIColor.redColor;
    self.deleteButton.layer.cornerRadius = _buttonSize/2;
    self.deleteButton.clipsToBounds = YES;
    [self.deleteButton addTarget:self action:@selector(pressDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_imageView];
    [self addSubview:_deleteButton];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.superview);
        make.width.height.mas_equalTo(self.imageView);
    }];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.deleteButton.superview);
        make.width.height.mas_equalTo(self.buttonSize);
    }];
    [self setBackgroundColor:[UIColor redColor]];
}

- (void)imageTapped:(UIImageView* )sender {
//    [_delegate imageTappedAt:sender];
}
- (void)pressDelete:(UIButton *)sender {
//    [self. deleteButtonPressedAt:sender];
}
@end
