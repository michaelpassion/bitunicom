//
//  BITNetManager.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/24.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITNetManager.h"
#import "BITUserInfo.h"

static NSString * const CBITUnionAPIBaseURLString = @"http://out.bitunion.org/open_api/";

@implementation BITNetManager

+ (instancetype) sharedClient {
    static BITNetManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BITNetManager alloc] initWithBaseURL:[NSURL URLWithString:CBITUnionAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
    _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sharedClient;
}

+ (void)relogin {
    BITUserInfo* user = [BITUserInfo sharedBITUser];
    NSDictionary *dict = @{@"username": user.username,
                           @"password": user.password
                           };
    

    [[BITNetManager sharedClient] POST:@"bu_logging.php" parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"success ");
        NSData *responseData = [NSData dataWithData:responseObject];
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        user.session = response[@"session"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed");
        NSLog(@"error %@",error);
    }];
}



@end
