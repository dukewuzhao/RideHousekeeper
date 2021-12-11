//
//  YXCalendarView.m
//  Calendar
//
//  Created by Vergil on 2017/7/6.
//  Copyright © 2017年 Vergil. All rights reserved.
//

#import "YXCalendarView.h"

#define ViewW (self.frame.size.width*6)/7    //当前视图宽度
#define ViewH self.frame.size.height    //当前视图高度

@interface YXCalendarView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollV;    //scrollview
@property (nonatomic, assign) CalendarType type;        //选择类型
@property (nonatomic, strong) NSDate *currentDate;      //当前月份
@property (nonatomic, strong) NSDate *selectDate;       //选中日期
@property (nonatomic, strong) NSDate *tmpCurrentDate;   //记录上下滑动日期
@property (nonatomic, strong) YXMonthView *middleView;  //中间日历

@end

@implementation YXCalendarView

- (instancetype)initWithFrame:(CGRect)frame Date:(NSDate *)date Type:(CalendarType)type {
    
    if (self = [super initWithFrame:frame]) {
        _type = type;
        //_currentDate = date;原先的当前界面末尾滚动时间
        _currentDate = [[YXDateHelpObject manager]getEarlyOrLaterDate:date LeadTime:-1 Type:2];
        _selectDate = date;
        if (type == CalendarType_Week) {
            _tmpCurrentDate = date;
            //_currentDate = [[YXDateHelpObject manager] getLastdayOfTheWeek:date];
        }
        [self settingViews];
        //[self addSwipes];
    }
    return self;
}

- (void)setNowSelectDate:(NSString *)date{
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDate *newDate = [format dateFromString:date];
    _selectDate = newDate;
    _middleView.selectDate = newDate;
    NSInteger dayNum = [[YXDateHelpObject manager] NumberDaysBetweenTwoDates:newDate toDate:_currentDate] + 1;
    [_middleView.collectionV scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:DateLength-dayNum inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}


//MARK: - otherMethod
+ (CGFloat)getMonthTotalHeight:(NSDate *)date type:(CalendarType)type {
    if (type == CalendarType_Week) {
        return dayCellH;//yearMonthH+ weeksH + dayCellH;
    } else {
        NSInteger rows = [[YXDateHelpObject manager] getRows:date];
        return rows * dayCellH;//yearMonthH + weeksH + rows * dayCellH;
    }
    
}

- (void)settingViews {
    [self settingScrollView];
}

- (void)settingScrollView {
    
    //_scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yearMonthH + weeksH, ViewW, ViewH - yearMonthH - weeksH)];
    _scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ViewW, ViewH)];
    _scrollV.delegate = self;
    _scrollV.pagingEnabled = YES;
    _scrollV.showsHorizontalScrollIndicator = NO;
    _scrollV.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollV];
    
    __weak typeof(self) weakSelf = self;
    _middleView = [[YXMonthView alloc] initWithFrame:CGRectMake(0, 0, ViewW, dayCellH) Date:_currentDate];
    _middleView.type = _type;
    _middleView.selectDate = _selectDate;
    _middleView.sendSelectDate = ^(NSDate *selDate) {
        weakSelf.selectDate = selDate;
        if (weakSelf.sendSelectDate) {
            weakSelf.sendSelectDate(selDate);
        }
        [weakSelf setData];
    };
    [_scrollV addSubview:_middleView];
    
    [_middleView.collectionV scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:DateLength - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    UIView *dayView = [[UIView alloc] init];
    dayView.userInteractionEnabled = YES;
    dayView.backgroundColor = [UIColor whiteColor];
    dayView.layer.cornerRadius = dayCellH / 2;
    [self addSubview:dayView];
    [dayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_scrollV.mas_right).offset(5);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [dayView addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    @weakify(self);
    [[self rac_signalForSelector:@selector(SingleTap:)] subscribeNext:^(RACTuple* x) {
        @strongify(self);
        NSLog(@"%@",[x class]);
        self.selectDate = [NSDate date];
        if (self.sendSelectDate) {
            self.sendSelectDate([NSDate date]);
        }
        [self setData];
    }];
    #pragma clang diagnostic pop

    UILabel *dayL = [[UILabel alloc] init];
    dayL.textColor = [QFTools colorWithHexString:MainColor];
    dayL.textAlignment = NSTextAlignmentCenter;
    dayL.text = @"18";
    dayL.font = FONT_PINGFAN(14);
    [dayView addSubview:dayL];
    [dayL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(dayView);
        make.top.equalTo(dayView).offset(3);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *monL = [[UILabel alloc] init];
    monL.textColor = [QFTools colorWithHexString:MainColor];
    monL.textAlignment = NSTextAlignmentCenter;
    monL.text = @"十一月";
    monL.font = FONT_PINGFAN(8);
    [dayView addSubview:monL];
    [monL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(dayView);
        make.top.equalTo(dayL.mas_bottom);
        make.height.mas_equalTo(10);
    }];
    
    dayL.text = [[YXDateHelpObject manager] getStrFromDateFormat:@"d" Date:[NSDate date]];
    monL.text = [NSString stringWithFormat:@"%@月",[[YXDateHelpObject manager] translationArabicNum:[[[YXDateHelpObject manager] getStrFromDateFormat:@"MM" Date:[NSDate date]] integerValue]]];
}

- (void)setData {
    
    if (_type == CalendarType_Month) {
        _middleView.currentDate = _currentDate;
        _middleView.selectDate = _selectDate;
    } else {
        _middleView.currentDate = _currentDate;
        _middleView.selectDate = _selectDate;
    }
    self.type = _type;
}

- (BOOL)checkProductDate: (NSString *)tempDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date = [dateFormatter dateFromString:tempDate];
    
    // 判断是否大于当前时间
    if ([date earlierDate:[[YXDateHelpObject manager]getEarlyOrLaterDate:[NSDate new] LeadTime:-1 Type:2]] != date) {
        
        return true;
    } else {
        
        return false;
    }
}

@end
