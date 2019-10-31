//
//  BITUserInfo.h
//  BITUNION
//
//  Created by 尹帅 on 2018/6/22.
//  Copyright © 2018年 michael. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITUserInfo : NSObject

@property(nonatomic, strong) NSString * username;
@property(nonatomic, strong) NSString * password;
@property(nonatomic, strong) NSString * photo;
@property(nonatomic, strong) NSString * session;


+ (instancetype)sharedBITUser;

@end
