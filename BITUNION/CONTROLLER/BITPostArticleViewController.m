//
//  BITPostArticleViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2019/6/3.
//  Copyright © 2019 michael. All rights reserved.
//

#import "BITPostArticleViewController.h"
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#import "BITAttachImageView.h"
#import "Masonry.h"



@interface BITPostArticleViewController () <BITAttachImageViewDelegate>

@property(nonatomic, assign) NSUInteger maxAttachNumber;
@property(nonatomic, strong) NSArray<UIImage*> *attachedImages;
@property(nonatomic, strong) NSArray<PHAsset*> *attachedAssets;
@property(nonatomic, strong) UIScrollView *attachScrollView;
@property(nonatomic, assign) MASConstraint *contentViewOffset;
@property(nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation BITPostArticleViewController

- (void)setAttachedImages:(NSArray<UIImage *> *)attachedImages {
    if (attachedImages.count > 0) {
        _attachScrollView.hidden = FALSE;
    } else if (_attachedImages.count > 0 && attachedImages.count == 0) {
        _attachScrollView.hidden = TRUE;
    }
    [self updateContentLayout];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:TRUE];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _maxAttachNumber = 5;
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.showsVerticalScrollIndicator = FALSE;
    _scrollView.showsHorizontalScrollIndicator = FALSE;
    
    _attachStack = [[UIStackView alloc] init];
    _attachStack.axis = UILayoutConstraintAxisHorizontal;
    _attachStack.spacing = 5;
    
    _attachScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 200, 200)];
    _attachScrollView.showsVerticalScrollIndicator = false;
    _attachScrollView.showsHorizontalScrollIndicator = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboadWillShowwith:) name:UIKeyboardWillChangeFrameNotification  object:nil];
    
    [_attachScrollView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_attachScrollView];
    [_attachScrollView addSubview:_attachStack];
    
//    [_contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self->_hintLabel);
//        make.trailing.equalTo(self->_titleLabel);
//        self.contentViewOffset = make.bottom.equalTo(@10);
//        make.top.equalTo(self->_titleLabel.mas_bottom).offset(5);
//    }];
    
    [self updateUI];
    
    
}

- (void)keyboadWillShowwith:(NSNotification *) notifacation {
    NSDictionary *info = notifacation.userInfo;
    CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    _keyboardHeight = MAX(self.view.bounds.size.height - keyboardFrame.origin.y, 0);
    
}

- (void)updateContentLayout {
//    if (_attachedImages.count > 0) {
//        [_contentViewOffset setOffset: -_keyboardHeight - 5 -100];
//    } else {
//        [_contentViewOffset setOffset: -_keyboardHeight - 5];
//    }
    [self.view layoutIfNeeded];
}

- (void)updateUI{
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelEdit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPhoto:(id)sender {
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithMaxImagesCount:_maxAttachNumber delegate:self];
    imagePicker.modalPresentationStyle = UIModalPresentationFormSheet;
//    imagePicker.selectedAssets = _photoArray;
    imagePicker.allowTakeVideo = NO;
    imagePicker.allowPickingOriginalPhoto = NO;
    imagePicker.photoWidth = 1024;
    [self presentViewController:imagePicker animated:YES completion:nil];

}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [_articleTextView becomeFirstResponder];
    if ([photos count] > 0 && [assets count] > 0) {
        while (_attachStack.subviews.count) {
            [_attachStack.subviews.lastObject removeFromSuperview];
        }
        for (UIImage *photo in photos) {
            BITAttachImageView *view = [[BITAttachImageView alloc] initWithFrame:CGRectMake(0, 100, 800, 200)];
            view.image = photo;
            view.delegate = self;
            [_attachStack addArrangedSubview:view];
        }
        _attachedImages = photos;
        _attachedAssets = assets;
    }
    
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
//    [_articleTextView becomeFirstResponder];
}

- (void)deleteButtonPressedAt:(BITAttachImageView *)attachView {
    
}

- (void)imageTappedAt:(BITAttachImageView *)attachView {
    UIImage *image = attachView.image;
    NSInteger idx = [self.attachedImages indexOfObject:image];
    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initWithSelectedAssets:[NSMutableArray arrayWithArray:_attachedAssets] selectedPhotos:[NSMutableArray arrayWithArray:_attachedImages] index:idx];
    imagePicker.didFinishPickingPhotosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [self->_articleTextView becomeFirstResponder];
    };
    imagePicker.imagePickerControllerDidCancelHandle = ^{
        [self->_articleTextView becomeFirstResponder];
    };
    [self presentViewController:imagePicker animated:YES completion:nil];
}


@end
