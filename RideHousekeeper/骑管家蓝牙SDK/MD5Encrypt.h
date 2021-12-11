//
//  MD5Encrypt.h
//  myTest
//
//  Created by Apple on 2019/9/10.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MD5Encrypt : NSObject
+(NSString *)MD5ForLower32Bate:(NSString *)str;
// 32位大写
+(NSString *)MD5ForUpper32Bate:(NSString *)str;
// 16为大写
+(NSString *)MD5ForUpper16Bate:(NSString *)str;
// 16位小写
+(NSString *)MD5ForLower16Bate:(NSString *)str;
// 32位大写
+(NSString *)md5EncodeFromData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
