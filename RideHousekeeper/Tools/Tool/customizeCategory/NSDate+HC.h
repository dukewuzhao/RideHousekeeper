
#import <Foundation/Foundation.h>

@interface NSDate (HC)
/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  返回一个只有时分秒的时间
 */
- (NSDate *)dateWithHMS;

/**
 *  返回一个超级详细时间
 */
- (NSString *)dateWithYMDHMS;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)deltaWithNow;

/**
*  时间戳转周几
*/
-(NSString *)getDateDisplayString:(long long) miliSeconds;



///日期转周几
/// @param format 时间格式 传入例如"2018-05-09"或者"2016/05/09"格式
- (NSString*)weekDayStr:(NSString*)format;

- (NSString *)getAfterDate:(NSString *)currentDay day:(NSInteger)day;

- (NSString *)getBeforeDate:(NSString *)currentDay day:(NSInteger)day;

@end
