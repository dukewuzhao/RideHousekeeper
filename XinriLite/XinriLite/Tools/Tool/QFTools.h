//
//  QFTools.h
//  QFBasicProject
//
//  Created by 霍标 on 14-5-23.
//  Copyright (c) 2014年 Huo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface QFTools : NSObject

+ (AFHTTPSessionManager *)sharedManager;//避免内存泄漏
/** 色值*/
+ (UIColor *) colorWithHexString: (NSString *)color;

/** md5加密*/
+ (NSString *)md5:(NSString *)str;

/** json字符串替换*/
+ (NSString *)jsonStringReplace:(NSString *)str;

/** post字符串转化*/
+ (NSString *)postStringReplace:(NSString *)str;

//+ (NSLayoutConstraint *)heightWithItemView:(UIView *)view andToItemVIew:(UIView *)toView andLayoutAttribute:(NSLayoutAttribute)layoutAttribute;
/** 根据网络图片设置控件宽高 */
+ (CGSize)downloadImageSizeWithURL:(id)imageURL;

/** 判断字符串含不含中文*/
+(BOOL)IsChinese:(NSString *)str;

/** 注册判断字符串含不含英文数字*/
+(BOOL)IsEnglishAndNum:(NSString *)str;

/** 字符串转为时间格式 */
+ (NSDate *)dateFromString:(NSString *)dateString;

/** 时间转为字符串时分秒 */
+ (NSString *)stringFromDateHMS:(NSDate *)date;

/** 去掉品牌名称中-后面的内容*/
+ (NSString *)subTheBrandTitle:(NSString *)title;

/** 替换字符串中的 , 为 空格*/
+ (NSString *)replaceTheCharator:(NSString *)tagStr;

/** 转码 */
+ (NSString *)encodeToPercentEscapeString: (NSString *) input;

/** 解码 */
+ (NSString *)decodeFromPercentEscapeString: (NSString *) input;

/** 检测是否是邮箱 */
+ (BOOL)isValidateEmail:(NSString *)email;

/** 检测是否是手机号码 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/** 检测是否是身份证号码 */
+ (BOOL)verifyIDCardNumber:(NSString *)value;

/** 照片转base64 */
+(NSString *) image2String:(UIImage *)image;

/** 判断是否是数字 */
+ (BOOL)isPureInt:(NSString *)string;

/** URI 转码（特殊字符）*/
+ (NSString *)URItranscodingWithString:(NSString *)str;

/** 判断是否是空格 */
+ (BOOL)isEmpty:(NSString *)str;

/** 判断是否是空 或者 NULL */
+ (BOOL) isBlankString:(NSString *)string;

/** 从沙盒取照片 */
+(UIImage *)getphoto;

/** 从内存中取数据 */
+(NSString *)getdata:(NSString *)string;

/** 从内存中取用户信息数据 */
+(NSString *)getuserInfo:(NSString *)string;

+(NSString *)toHexString:(long)value;

//获取但前时间
+(NSString *)replyDataAndTime;

//16进制转二进制
+(NSString *)getBinaryByhex:(NSString *)hex;

+(float)roundFloat:(float)price;
//修改navigationbar下方横线的颜色
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIViewController*)currentViewController;

+(NSString *)replaceStringWithAsterisk:(NSString *)originalStr startLocation:(NSInteger)startLocation lenght:(NSInteger)lenght;
//图片压缩
+ (NSData *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxSizeWithKB:(CGFloat) maxSize;

+ (NSString *)completionStr:(NSString *)str needLength:(NSInteger)length;

@end
