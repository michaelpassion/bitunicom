//
//  BITUserInfo.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/22.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "BITUserInfo.h"
#import "BITNetManager.h"

@implementation BITUserInfo

+ (instancetype)sharedBITUser {
    static BITUserInfo *_sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUser = [[BITUserInfo alloc] init];
    });
    return _sharedUser;
}


@end
