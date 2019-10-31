//
//  BITLoginViewController.h
//  BITUNION
//
//  Created by 尹帅 on 2018/6/22.
//  Copyright © 2018年 michael. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BITUserInfo;

@interface BITLoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *passwdTxtField;

@end
