
#import "NSDate+HC.h"

@implementation NSDate (HC)
/**
 *  是否为今天
 */
- (BOOL)isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    return
    (selfCmps.year == nowCmps.year) &&
    (selfCmps.month == nowCmps.month) &&
    (selfCmps.day == nowCmps.day);
}

/**
 *  是否为昨天
 */
- (BOOL)isYesterday
{
    // 2014-05-01
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    // 2014-04-30
    NSDate *selfDate = [self dateWithYMD];
    
    // 获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"YYYY-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
   // return selfStr;
}

- (NSDate *)dateWithHMS
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm:ss";
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

- (NSString *)dateWithYMDHMS
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"YYYY-MM-dd";
    [fmt setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSString *selfStr = [fmt stringFromDate:self];
    return selfStr;
}

/**
 *  是否为今年
 */
- (BOOL)isThisYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return nowCmps.year == selfCmps.year;
}

- (NSDateComponents *)deltaWithNow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

-(NSString *)getDateDisplayString:(long long) miliSeconds{

    NSTimeInterval seconds = miliSeconds;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSCalendar *calendar = [NSCalendar currentCalendar ];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    
    //2. 指定日历对象,要去取日期对象的那些部分.
    NSDateComponents *comp =  [calendar components:NSCalendarUnitWeekday fromDate:myDate];
        switch (comp.weekday) {
            case 1:
                dateFmt.dateFormat = @"星期日";
                break;
            case 2:
                dateFmt.dateFormat = @"星期一";
                break;
            case 3:
                dateFmt.dateFormat = @"星期二";
                break;
            case 4:
                dateFmt.dateFormat = @"星期三";
                break;
            case 5:
                dateFmt.dateFormat = @"星期四";
                break;
            case 6:
                dateFmt.dateFormat = @"星期五";
                break;
            case 7:
                dateFmt.dateFormat = @"星期六";
                break;
            default:
                break;
        }
    return [dateFmt stringFromDate:myDate];
}

- (NSString*)weekDayStr:(NSString*)format{
    
    NSString *weekDayStr = nil;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    if(format.length>=10) {
        NSString *nowString = [format substringToIndex:10];
        NSArray *array = [nowString componentsSeparatedByString:@"-"];
        if(array.count==0) {
            array = [nowString componentsSeparatedByString:@"/"];
        }
        
        if(array.count>=3) {
            NSInteger year = [[array objectAtIndex:0] integerValue];
            NSInteger month = [[array objectAtIndex:1] integerValue];
            NSInteger day = [[array objectAtIndex:2] integerValue];
            [comps setYear:year];
            [comps setMonth:month];
            [comps setDay:day];
        }
    }
    //日历
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //获取传入date
    NSDate *_date = [gregorian dateFromComponents:comps];
    
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:_date];
    NSInteger week = [weekdayComponents weekday];
    switch(week) {
        case 1:
            weekDayStr =@"星期日";
            break;
        case 2:
            weekDayStr =@"星期一";
            break;
        case 3:
            weekDayStr =@"星期二";
            break;
        case 4:
            weekDayStr =@"星期三";
            break;
        case 5:
            weekDayStr =@"星期四";
            break;
        case 6:
            weekDayStr =@"星期五";
            break;
        case 7:
            weekDayStr =@"星期六";
            break;
        default:
            weekDayStr =@"";
            break;
    }
    return weekDayStr;
}

- (NSString *)getAfterDate:(NSString *)currentDay day:(NSInteger)day {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *currentDate = [dateFormatter dateFromString:currentDay];
    
    NSTimeInterval days = 24 * 60 * 60 * day;  // 一天一共有多少秒
    NSDate *appointDate = [currentDate dateByAddingTimeInterval:days];
    NSString *strDate = [dateFormatter stringFromDate:appointDate];
    return strDate;
}

- (NSString *)getBeforeDate:(NSString *)currentDay day:(NSInteger)day {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *currentDate = [dateFormatter dateFromString:currentDay];
    
    NSTimeInterval days = 24 * 60 * 60 * day;  // 一天一共有多少秒
    NSDate *appointDate = [currentDate dateByAddingTimeInterval:-days];
    NSString *strDate = [dateFormatter stringFromDate:appointDate];
    return strDate;
}



@end
