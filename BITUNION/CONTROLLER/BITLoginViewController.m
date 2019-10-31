//
//  BITLoginViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/22.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITLoginViewController.h"
#import "BITUserInfo.h"
#import "BITNetManager.h"
#import "NSDictionary+BITJSONString.h"
#import "NSString+URLEncode.h"
#import "BITForumListTableViewController.h"

@interface BITLoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) BITNetManager *bitNetManager;
@property (nonatomic, strong) NSMutableArray *BITForumGroup;
@end

@implementation BITLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.loginBtn.enabled = false;
    _BITForumGroup = [[NSMutableArray alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logIn:(UIButton *)sender {
    
    NSDictionary *dict = @{@"action":@"login",
                           @"username":_usernameTxtField.text,
                           @"password":_passwdTxtField.text};
    
    [[BITNetManager sharedClient] POST:@"bu_logging.php" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"success ");
        NSData *responseData = [NSData dataWithData:responseObject];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        BITUserInfo *sharedUser = [BITUserInfo sharedBITUser];
        sharedUser.username = response[@"username"];
        sharedUser.password = self.passwdTxtField.text;
        sharedUser.session = response[@"session"];
        
        [self performSegueWithIdentifier:@"login2formlist" sender:nil];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
        NSLog(@"error %@",error);
    }];
    
    
}
-(void)getFourmList {
    BITUserInfo *_sharedUser = [BITUserInfo sharedBITUser];
    
    NSDictionary *parameter = @{@"action":@"forum",
                                @"username":_sharedUser.username,
                                @"session":_sharedUser.session
                                };
    
    [[BITNetManager sharedClient] POST:@"bu_forum.php" parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // session未过期，且请求论坛列表成功，
        if ([response[@"result"] isEqualToString:@"success"]) {
            NSDictionary* dict =[NSDictionary dictionaryWithDictionary: response[@"forumslist"]];
            NSArray * keys = [dict allKeys];
            for (NSString *key in keys) {
                if (![key isEqualToString:@""]) {
                    NSString *groupName = [dict[key][@"main"][@"name"] stringByRemovingPercentEncoding];
                    [self.BITForumGroup addObject:groupName];
                }
            }


        } else {
            [BITNetManager relogin];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}

- (IBAction)checkUsernameAndPassword:(UITextField *)sender {
    if (self.usernameTxtField.text.length < 1 ||
        self.passwdTxtField.text.length < 1) {
        self.loginBtn.enabled = NO;
    } else {
        self.loginBtn.enabled = YES;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
