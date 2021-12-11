//
//  QFTools.m
//  QFBasicProject
//
//  Created by 霍标 on 14-5-23.
//  Copyright (c) 2014年 Huo. All rights reserved.
//

#import "QFTools.h"
#import <CommonCrypto/CommonDigest.h>
@interface QFTools ()

@end

static AFHTTPSessionManager *manager;

@implementation QFTools

+ (UIViewController *)viewController:(UIView *)inputView {
    for (UIView *view = inputView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (AFHTTPSessionManager *)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化请求管理类
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSString *userAgent = userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", UserAgentHead, [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
        [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        // 设置15秒超时 - 取消请求
        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        manager.requestSerializer.timeoutInterval = 15.0f;
        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        // 编码
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        //缓存策略
        manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        // 支持内容格式
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                             @"text/plain",
                                                             @"text/JavaScript",
                                                             @"text/html",
                                                             @"application/x-gzip",
                                                             @"text/json", nil];
    });
    return manager;
}

+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}

+ (NSString *)jsonStringReplace:(NSString *)str
{
    NSString *reString;
    reString = [str stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    reString = [reString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    reString = [reString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    reString = [reString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    return reString;
}

+ (NSString *)postStringReplace:(NSString *)str
{
    NSString *reString;
    reString = [str stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    reString = [reString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    reString = [reString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    reString = [reString stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    return reString;
    
}

+ (CGSize)downloadImageSizeWithURL:(id)imageURL
{
    
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:imageURL];
    }
    if(URL == nil)
        return CGSizeZero;
    
    NSString* absoluteString = URL.absoluteString;
    
#ifdef dispatch_main_sync_safe
    if([[SDImageCache sharedImageCache] diskImageExistsWithKey:absoluteString])
    {
        UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:absoluteString];
        if(!image)
        {
            NSData* data = [[SDImageCache sharedImageCache] performSelector:@selector(diskImageDataBySearchingAllPathsForKey:) withObject:URL.absoluteString];
            image = [UIImage imageWithData:data];
        }
        if(image)
        {
            return image.size;
        }
    }
#endif
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]){
        size =  [self downloadPNGImageSizeWithRequest:request];
    }
    else if([pathExtendsion isEqual:@"gif"])
    {
        size =  [self downloadGIFImageSizeWithRequest:request];
    }
    else{
        size = [self downloadJPGImageSizeWithRequest:request];
    }
    if(CGSizeEqualToSize(CGSizeZero, size))
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
#ifdef dispatch_main_sync_safe
            [[SDImageCache sharedImageCache] storeImage:image recalculateFromImage:YES imageData:data forKey:URL.absoluteString toDisk:YES];
#endif
            size = image.size;
        }
    }
    return size;
}

+(CGSize)downloadPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
+(CGSize)downloadGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
+(CGSize)downloadJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}


+(BOOL)IsChinese:(NSString *)str
{
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}

+(BOOL)IsEnglishAndNum:(NSString *)str
{
    //數字條件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合數字條件的有幾個字元
    NSInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:str options:NSMatchingReportProgress
                                                                  range:NSMakeRange(0, str.length)];
    //英文字條件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    //符合英文字條件的有幾個字元
    NSInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    if (tNumMatchCount == str.length)
    {
        //全部符合數字，表示沒有英文
        return YES;
    }
    else if (tLetterMatchCount == str.length)
    {
        //全不符合英文，表示沒有數字
        return NO;
    }
    else if (tNumMatchCount + tLetterMatchCount == str.length)
    {
        //符合英文和符合數字條件的相加等於密碼長度
        return NO;
    }
    else{
        //可能包含標點符號的情況，或是包含非英文的文字，這裡再依照需求詳細判斷想呈現的錯誤
        return YES;
        
    }
}


+ (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}


+ (NSString *)stringFromInt:(NSString *)formatter :(NSInteger)ts{
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:ts];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    formatter == nil? [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]:[dateFormatter setDateFormat:formatter];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}


+ (NSString *)stringFromDateHMS:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH"];
    
    if ([[dateFormatter stringFromDate:date] integerValue]>=12) {
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *destDateString = [NSString stringWithFormat:@"%@PM",[dateFormatter stringFromDate:date]];
        return destDateString;
    }else{
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *destDateString = [NSString stringWithFormat:@"%@AM",[dateFormatter stringFromDate:date]];
        return destDateString;
    }
}
+ (NSString *)subTheBrandTitle:(NSString *)title
{
    NSString *myTitleStr = title;
    NSArray *myTitleStrArr = [myTitleStr componentsSeparatedByString:@"-"];
    return [myTitleStrArr objectAtIndex:0];
}
+ (NSString *)replaceTheCharator:(NSString *)tagStr
{
    NSArray *newArr = [tagStr componentsSeparatedByString:@","];
    NSMutableString *retutnStr = [[NSMutableString alloc] init];
    for (int i = 0; i < newArr.count; i ++) {
        [retutnStr appendString:[newArr objectAtIndex:i]];
        [retutnStr appendString:@" "];
    }
    return retutnStr;
}


+ (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString *outputStr = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                             
                                                                             NULL, /* allocator */
                                                                             
                                                                             (__bridge CFStringRef)input,
                                                                             
                                                                             NULL, /* charactersToLeaveUnescaped */
                                                                             
                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                             
                                                                             kCFStringEncodingUTF8);
    
    
    return outputStr;
}

+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@""
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0,
                                                      [outputStr length])];
    
    return
    [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


// 检测是否是手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^(0|86|17951)?(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])[0-9]{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


+ (BOOL)verifyIDCardNumber:(NSString *)value
{
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([value length] != 18) {
        return NO;
    }
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![regexTest evaluateWithObject:value]) {
        return NO;
    }
    int summary = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7
    + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9
    + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10
    + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5
    + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8
    + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4
    + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2
    + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6
    + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
    NSInteger remainder = summary % 11;
    NSString *checkBit = @"";
    NSString *checkString = @"10X98765432";
    checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
    return [checkBit isEqualToString:[[value substringWithRange:NSMakeRange(17,1)] uppercaseString]];
}
//是否是邮箱
+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isUrlAddress:(NSString*)url{

    NSString*reg =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    NSPredicate*urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];

    return[urlPredicate evaluateWithObject:url];

}



+(NSString *) image2String:(UIImage *)image{
    //NSData*pictureData = UIImagePNGRepresentation(image);
    NSData* pictureData = UIImageJPEGRepresentation(image,1.0f);//进行图片压缩从0.0到1.0（0.0表示最大压缩，质量最低);
    
    //NSData *data = [[NSData alloc] initWithBase64EncodedString:@"encode string" options:0];
    
    // Data解密并且转字符串
    //NSString *decodeStr = [pictureData base64EncodedStringWithOptions:0];
    NSString* pictureDataString;
    if (![pictureData respondsToSelector:@selector(base64EncodedDataWithOptions:)])
    {
        // Use the old API
        pictureDataString = [pictureData base64Encoding];
    }
    else{
        // Use the new API
        pictureDataString = [pictureData base64EncodedStringWithOptions:0];
    }
    
    
    //NSString* pictureDataString = [pictureData base64Encoding];//图片转码成为base64Encoding，
    return pictureDataString;
}

+(void)saveUserIconPhoto:(UIImage *)image key:(NSString *)key{
    [[SDImageCache sharedImageCache] storeImage:image forKey:key toDisk:NO completion:nil];
}

+(UIImage *)getphoto:(NSString *)url
{

    SDImageCache* cache=[SDImageCache sharedImageCache];
    UIImage* image=[cache imageFromDiskCacheForKey:url];
    //key为URL的下载地址. 这里是取磁盘缓存如果是内存缓存的话使用
    //image=[cache imageFromMemoryCacheForKey:key];
    
    return image;
}


+(NSString *)getdata:(NSString *)string
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:logInUSERDIC];
    NSString *result= userDic[string];
    
    return result;
}

+(NSString *)getuserInfo:(NSString *)string
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userDic = [defaults objectForKey:userInfoDic];
    NSString *result= userDic[string];
    
    return result;
}


+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (NSString *)URItranscodingWithString:(NSString *)str
{
    NSString *encodedString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) str,NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    //CFRelease(<#CFTypeRef cf#>)
    return encodedString;
}

+ (BOOL)isEmpty:(NSString *)str {
    
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
        
    } if([string isEqualToString:@"(null)"]) {
        return YES;
        
    } if ([string isKindOfClass:[NSNull class]]) {
        return YES;
        
    } if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
        
    } return NO;
    
}

+(NSString *)toHexString:(long long int)value{
    NSString *str = [[NSString alloc] initWithFormat:@"%llX",value];
    return str;
}

//获取系统时间
+(NSString *)replyDataAndTime{
    
    //获取系统日期,格式可以随便改
    //    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//不区分大小写,前面是日期,后面是时间 . 注意中间有个空格
    NSString *  locationString=[dateformatter stringFromDate:[NSDate date]];
    // NSLog(@"locationString2:%@",locationString);//2016.03.01 17:03:23
    return locationString;
    
}

/**
 * 倒计时
 *
 * @param endTime 截止的时间戳
 *
 * @return 返回的剩余时间
 */
+ (NSString*)remainingTimeMethodAction:(long long)endTime
{
    //得到当前时间
    NSDate *nowData = [NSDate date];
     
    //把时间戳转换成date格式
    NSDate *endData=[NSDate dateWithTimeIntervalSince1970:endTime];
     
    //创建日历对象
    NSCalendar* chineseClendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier:NSCalendarIdentifierGregorian ];
     
    //设置单元标识 小时 分钟 秒 天 月 年
    NSUInteger unitFlags =
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
     
    //给出开始时间 和 结束时间 获取单位标识的数据
    NSDateComponents *cps = [chineseClendar components:unitFlags fromDate:nowData toDate: endData options:0];
    //NSInteger Hour = [cps hour];
    NSInteger Min = [cps minute];
    NSInteger Sec = [cps second];
    //NSInteger Day = [cps day];
    //NSInteger Mon = [cps month];
    //NSInteger Year = [cps year];
     /*
    NSLog( @" From Now to %@, diff: Years: %ld Months: %ld, Days; %ld, Hours: %ld, Mins:%ld, sec:%ld",[nowData description], Year, Mon, Day, Hour, Min, Sec);
    NSString *countdown = [NSString stringWithFormat:@"还剩: %zi天 %zi小时 %zi分钟 %zi秒 ", Day,Hour, Min, Sec];
      */
    NSString *countdown = [NSString stringWithFormat:@"%zi:%zi",Min, Sec];
    if (Sec<0) {
        countdown=[NSString stringWithFormat:@"订单已失效"];
    }
    return countdown;
}

+(NSString *)getBinaryByhex:(NSString *)hex
{
    //NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    //NSLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
}

+(float)roundFloat:(float)price{
    NSString *temp = [NSString stringWithFormat:@"%.7f",price];
    NSDecimalNumber *numResult = [NSDecimalNumber decimalNumberWithString:temp];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                       scale:2
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:YES];
    return [[numResult decimalNumberByRoundingAccordingToBehavior:roundUp] floatValue];
}
+(UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//获取Window当前显示的ViewController
+ (UIViewController*)currentViewController{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (1){
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        
        if ([vc isKindOfClass:[XYSideViewController class]] || [vc isKindOfClass:[UIAlertController class]]) {
            
            if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")]) {
                vc = ((UINavigationController*)vc.sideViewController.currentNavController).visibleViewController;
            }else if([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"AddBikeViewController")]){
                //vc = ((UINavigationController*)vc).visibleViewController;
            }else{
                //vc = ((UINavigationController*)vc).visibleViewController;
            }
        }
        
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}

+(NSString *)replaceStringWithAsterisk:(NSString *)originalStr startLocation:(NSInteger)startLocation lenght:(NSInteger)lenght
{
    NSString *newStr = originalStr;
    for (int i = 0; i < lenght; i++) {
        NSRange range = NSMakeRange(startLocation, 1);
        newStr = [newStr stringByReplacingCharactersInRange:range withString:@"*"];
        startLocation ++;
    }
    return newStr;
}

/**
 *  调整图片尺寸和大小
 *
 *  @param sourceImage  原始图片
 *  @param maxImageSize 新图片最大尺寸
 *  @param maxSize      新图片最大存储大小
 *
 *  @return 新图片imageData
 */
+ (NSData *)reSizeImageData:(UIImage *)sourceImage maxImageSize:(CGFloat)maxImageSize maxSizeWithKB:(CGFloat) maxSize
{
    
    if (maxSize <= 0.0) maxSize = 1024.0;
    if (maxImageSize <= 0.0) maxImageSize = 1024.0;
    
    //先调整分辨率
    CGSize newSize = CGSizeMake(sourceImage.size.width, sourceImage.size.height);
    
    CGFloat tempHeight = newSize.height / maxImageSize;
    CGFloat tempWidth = newSize.width / maxImageSize;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(sourceImage.size.width / tempWidth, sourceImage.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(sourceImage.size.width / tempHeight, sourceImage.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [sourceImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    CGFloat sizeOriginKB = imageData.length / 1024.0;
    
    CGFloat resizeRate = 0.9;
    while (sizeOriginKB > maxSize && resizeRate > 0.1) {
        imageData = UIImageJPEGRepresentation(newImage,resizeRate);
        sizeOriginKB = imageData.length / 1024.0;
        resizeRate -= 0.1;
    }
    
    return imageData;
}

+ (NSString *)completionStr:(NSString *)str needLength:(NSInteger)length{
    
    NSString *characterStr = str;
    if (characterStr.length <length) {
        NSInteger masterpwdCount = length - characterStr.length;
        for (int i = 0; i<masterpwdCount; i++) {
            characterStr = [@"0" stringByAppendingFormat:@"%@",characterStr];
        }
        return characterStr;
    }else{
        return [characterStr substringFromIndex:characterStr.length - length];
    }
}

+ (NSString *)getParamByName:(NSString *)name URLString:(NSString *)url{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)", name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    // 执行匹配的过程
    NSArray *matches = [regex matchesInString:url
                                      options:0
                                        range:NSMakeRange(0, [url length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *tagValue = [url substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        return tagValue;
    }
    return @"";
}

+ (id)performSelector:(SEL)aSelector withTheObjects:(NSArray*)objects withTarget:(id)target{
    //1、创建签名对象
    //  NSMethodSignature*signature = [self methodSignatureForSelector:aSelector];
    NSMethodSignature*signature = [[target class] instanceMethodSignatureForSelector:aSelector];
    //2、判断传入的方法是否存在
    if (!signature) {
        //传入的方法不存在 就抛异常
        NSString*info = [NSString stringWithFormat:@"-[%@ %@]:unrecognized selector sent to instance",[target class],NSStringFromSelector(aSelector)];
        @throw [[NSException alloc] initWithName:@"方法没有" reason:info userInfo:nil];
        return nil;
    }
    //3、创建NSInvocation对象
    NSInvocation*invocation = [NSInvocation invocationWithMethodSignature:signature];
    //4、保存方法所属的对象
    invocation.target = target;           // index 0
    invocation.selector = aSelector;    // index 1
    
    //5、设置参数
    NSInteger arguments = signature.numberOfArguments -2;
    NSUInteger objectsCount = objects.count;
    NSInteger count = MIN(arguments, objectsCount);
   // [self setInv:invocation andArgs:objects argsCount:count];
    for (int i = 0; i<count; i++) {
        NSObject*obj = objects[i];
        //处理参数是NULL类型的情况
        if ([obj isKindOfClass:[NSNull class]]) {
            obj = nil;
        }
        //对整形数值等的处理
        if([obj isKindOfClass:[NSNumber class]])      //对数值数据的处理
        {
            void *p;
            NSNumber *num = (NSNumber *)obj;
            if(strcmp([num objCType], @encode(float)) == 0)
            {
                float v = [num floatValue];
                p = &v;
            }
            else if(strcmp([num objCType], @encode(double)) == 0)
            {
                double v = [num doubleValue];
                p = &v;
            }
            else
            {
                long v = [num longValue];
                p = &v;
            }
            
            [invocation setArgument:p atIndex:i+2];
            continue;
        }

        [invocation setArgument:&obj atIndex:i+2];
    }
    
    //6、调用NSinvocation对象
    [invocation invoke];
    
    //7、获取返回值
    id res = nil;
    if (signature.methodReturnLength ==0) return nil;
    //getReturnValue获取返回值
    [invocation getReturnValue:&res];
    return res;
}

@end
