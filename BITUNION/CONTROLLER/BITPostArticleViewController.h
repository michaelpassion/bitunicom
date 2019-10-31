//
//  BITPostArticleViewController.h
//  BITUNION
//
//  Created by 尹帅 on 2019/6/3.
//  Copyright © 2019 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "TZImagePickerController.h"
#import "BITAttachImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BITPostArticleViewController : UIViewController <TZImagePickerControllerDelegate, BITAttachImageViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishBarItem;
@property (weak, nonatomic) IBOutlet UITextField *titile;
@property (weak, nonatomic) IBOutlet UITextView *articleTextView;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) UIStackView *attachStack;

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
- (IBAction)cancelEdit:(id)sender;
- (IBAction)addPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;

@end

NS_ASSUME_NONNULL_END
