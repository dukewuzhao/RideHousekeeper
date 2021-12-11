//
//  YXDateHelpObject.m
//  LaiApp_OC
//
//  Created by Jonas on 16/11/15.
//  Copyright © 2016年 Softtek. All rights reserved.
//

#import "YXDateHelpObject.h"

@interface YXDateHelpObject ()

@property (nonatomic, strong) NSDateFormatter *formate;

@end

static YXDateHelpObject *yxDate = nil;

@implementation YXDateHelpObject

+ (YXDateHelpObject *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yxDate = [[YXDateHelpObject alloc] init];
    });
    return yxDate;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _formate = [[NSDateFormatter alloc] init];
    }
    return self;
    
}

//返回传入时间月份的第一天时间
- (NSDate *)GetFirstDayOfMonth:(NSDate *)pDate
{
    NSCalendar *myCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [myCalendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:pDate];
    NSDate* rt = [myCalendar dateFromComponents:components];
    return rt;
}

//返回传入格式的日期字符
- (NSString *)getStrFromDateFormat:(NSString *)format Date:(NSDate *)date {
    
    [_formate setDateFormat:format];
    return [_formate stringFromDate:date];
    
}

//获取下一个月的时间
- (NSDate*)getNextMonth:(NSDate*)_date {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:_date];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    // NSLog(@"%d === %d === %d",year,month,day);
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 12) {
        
        comps.month = month+1;
        rt = [cal dateFromComponents:comps];
        
    } else {
        
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, month+1];
        [_formate setDateFormat:@"yyyy-MM-dd"];
        
        NSDate* the_month = [_formate dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, month+1, MIN(day, day_in_month)];
        rt = [_formate dateFromString:datestring];
        
        //NSLog(@" ss = %@  the_month = %@ day_in_month = %ld datestring = %@ rt = %@",ss,the_month,(long)day_in_month,datestring,rt);
    }
    
    
    
    return rt;
}

//获取传入时间当前周最后一天(日 -> 六,也就是周六日期)
- (NSDate *)getLastdayOfTheWeek:(NSDate *)date {
    
    NSInteger week = [self getNumberInWeek:date];
    return [self getEarlyOrLaterDate:date LeadTime:7 - week Type:2];
    
}

//获取今天是周几
- (NSInteger)getNumberInWeek:(NSDate *)date {
    NSUInteger num =[[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:date];
    return num;
}

//获取上个月的时间
- (NSDate*)getPreviousMonth:(NSDate*)_date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:_date];
    
    NSInteger year  = comps.year;
    NSInteger month = comps.month;
    NSInteger day   = comps.day;
    
    // NSLog(@"%d === %d === %d 0000",year,month,day);
    
    NSDate* rt = nil;
    
    if (day <= 28 || month == 1) {
        
        comps.month = month-1;
        rt = [cal dateFromComponents:comps];
        
    } else {
        
        NSString* ss = [NSString stringWithFormat:@"%ld-%ld-3", (long)year, month-1];
        [_formate setDateFormat:@"yyyy-MM-dd"];
        NSDate* the_month = [_formate dateFromString:ss];
        NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:the_month];
        NSInteger day_in_month = rng.length;
        
        NSString* datestring = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)year, month-1, MIN(day, day_in_month)];
        rt = [_formate dateFromString:datestring];
        
        //NSLog(@" ss = %@  the_month = %@ day_in_month = %ld datestring = %@ rt = %@",ss,the_month,(long)day_in_month,datestring,rt);
        
    }
    return rt;
}

//获取本月第一天是星期几
- (NSInteger)currentFirstDay:(NSDate *)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//1.mon
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday;
}

//获取本月总天数
- (NSInteger)currentMonthOfDay:(NSDate *)date {
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

//判断两个月份是不是一样的
- (BOOL)checkSameMonth:(NSDate*)_month1 AnotherMonth:(NSDate*)_month2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* m1 = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_month1];
    NSDateComponents* m2 = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:_month2];
    BOOL rt = NO;
    if ((m1.year == m2.year) && (m1.month == m2.month))
    {
        rt = YES;
    }
    return rt;
}

//获取一个月有多少行
- (NSInteger)getRows:(NSDate *)myDate {
    NSDate *firstday;
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&firstday interval:NULL forDate:myDate];
    NSUInteger zhouji =[[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:firstday];
    NSRange daysOfMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:myDate];
    //该月的行数
    NSInteger shenyu = daysOfMonth.length - (8 - zhouji);
    NSInteger hangshu;
    hangshu = shenyu % 6 > 0 ? shenyu/6 + 2 : shenyu/6 + 1;
    return hangshu;
}

//字符串返回时间
- (NSDate *)getDataFromStrFormat:(NSString *)format String:(NSString *)str {
    
    [_formate setDateFormat:format];
    return [_formate dateFromString:str];
    
}

//判断两天是不是同一天
- (BOOL)checkSameDate:(NSString *)date1 AnotherDate:(NSDate *)date2 {
    
    [_formate setDateFormat:@"yyyy-MM-dd"];
//    NSString *str1 = [format stringFromDate:date1];
    NSString *str2 = [_formate stringFromDate:date2];
    return [date1 isEqualToString:str2];
    
}

//获取某天零点时间
- (NSDate *)getStartDateWithDate:(NSDate *)date {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
//    NSDate *startDate = [calendar dateFromComponents:components];
    return [calendar dateFromComponents:components];
    
}

/**
 * 判断两天是不是同一天
 */
- (BOOL)isSameDate:(NSDate *)date1 AnotherDate:(NSDate *)date2 {

    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];

}

/**
 将时间字符串转换成新的时间字符串
 
 @param oldStrDate 旧的时间
 @param oldFormat 旧的格式
 @param newFormat 新的时间格式
 @return 返回
 */
- (NSString *)getStrDateFromStrDate:(NSString *)oldStrDate OldFormat:(NSString *)oldFormat ByNewFormat:(NSString *)newFormat {
 
    [_formate setDateFormat:oldFormat];
    NSDate *oldDate = [_formate dateFromString:oldStrDate];
    [_formate setDateFormat:newFormat];
    return [_formate stringFromDate:oldDate];
    
}

/**
 获取某个时间前后时间
 
 @param currentDate 当前时间
 @param lead 距离时间
 @param timeType 时间类型(0-年  1-月 2-日 3-时 4-分 5-秒)
 @return 返回结果时间
 */
- (NSDate *)getEarlyOrLaterDate:(NSDate *)currentDate LeadTime:(NSInteger)lead Type:(NSInteger)timeType {
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateCom = [[NSDateComponents alloc] init];
    if (timeType == 0) {
        [dateCom setYear:lead];
    } else if (timeType == 1) {
        [dateCom setMonth:lead];
    } else if (timeType == 2) {
        [dateCom setDay:lead];
    } else if (timeType == 3) {
        [dateCom setHour:lead];
    } else if (timeType == 4) {
        [dateCom setMinute:lead];
    } else if (timeType == 5) {
        [dateCom setSecond:lead];
    }
    
    return [calendar dateByAddingComponents:dateCom toDate:currentDate options:0];
    
}

/**
获取某个时间中文月数
*/
- (NSString *)translationArabicNum:(NSInteger)arabicNum {
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    //NSArray *chineseNumeralsArray = @[@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"玖",@"拾",@"冬",@"腊"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    NSString *chinese = [dictionary objectForKey:arabicNumStr];
    return chinese;
}

/**
获取两个时间差多少天
*/
- (NSInteger)NumberDaysBetweenTwoDates:(NSDate *)startDate toDate:(NSDate *)endDate{
    //创建两个日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //利用NSCalendar比较日期的差异
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /**
     * 要比较的时间单位,常用如下,可以同时传：
     *    NSCalendarUnitDay : 天
     *    NSCalendarUnitYear : 年
     *    NSCalendarUnitMonth : 月
     *    NSCalendarUnitHour : 时
     *    NSCalendarUnitMinute : 分
     *    NSCalendarUnitSecond : 秒
     */
    NSCalendarUnit unit = NSCalendarUnitDay;//只比较天数差异
    //比较的结果是NSDateComponents类对象
    NSDateComponents *delta = [calendar components:unit fromDate:startDate toDate:endDate options:0];
    return delta.day;
}

/**
判断某一日期是否在一日期区间

@param date 判断时间
@param beginDate 开始时间
@param endDate 结束时间
@return 返回结果
*/
-(BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

@end
