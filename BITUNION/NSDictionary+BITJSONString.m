//
//  NSDictionary+BITJSONString.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/25.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "NSDictionary+BITJSONString.h"

@implementation NSDictionary (BITJSONString)
-(NSString *)dictionaryToJsonString
{
    NSError *error = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
