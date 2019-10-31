//
//  NSString+URLEncode.m
//  BITUNION
//
//  Created by 尹帅 on 2018/6/25.
//  Copyright © 2018年 michael. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

- (NSString *)URLDecodedString{
    NSString *string = [[[self stringByRemovingPercentEncoding]
                         stringByReplacingOccurrencesOfString: @"<br+/>" withString: @"<br>"] stringByReplacingOccurrencesOfString:@"+" withString:@" "] ;
    return string;
}

- (NSString *)URLEncodedString {
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:self] invertedSet];
   NSString *encodedUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return  encodedUrl;
}

@end
