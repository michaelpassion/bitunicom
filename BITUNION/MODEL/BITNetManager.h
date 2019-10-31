//
//  BITNetManager.h
//  BITUNION
//
//  Created by 尹帅 on 2018/6/24.
//  Copyright © 2018年 michael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetWorking.h"

@interface BITNetManager : AFHTTPSessionManager

+ (instancetype)sharedClient;
+ (void)relogin;
@end
