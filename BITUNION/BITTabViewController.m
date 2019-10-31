//
//  BITTabViewController.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/30.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITTabViewController.h"
#import "BITHeaders.h"

@interface BITTabViewController ()

@end

@implementation BITTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Network stuff

- (void) getFourmGroup{
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
                }
            }
            
            [self performSegueWithIdentifier:@"login2formlist" sender:nil];
            
        } else {
            // session 已过期，自动重新登录，重新请求
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
    }];
}
@end
