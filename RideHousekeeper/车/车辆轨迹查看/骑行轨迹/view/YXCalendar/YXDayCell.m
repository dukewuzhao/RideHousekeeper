//
//  YXDayCell.m
//  Calendar
//
//  Created by Vergil on 2017/7/6.
//  Copyright © 2017年 Vergil. All rights reserved.
//

#import "YXDayCell.h"

@interface YXDayCell ()

@property (strong, nonatomic) UIView *dayView;
@property (strong, nonatomic) UILabel *dayL;     //日期
@property (strong, nonatomic) UILabel *monL;     //日期
@property (strong, nonatomic) UIView *pointV;    //点

@end

@implementation YXDayCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//    _dayL.layer.cornerRadius = dayCellH / 2;
//    _pointV.layer.cornerRadius = 1.5;
//
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        _dayView = [[UIView alloc] init];
        [self.contentView addSubview:_dayView];
        [_dayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        _dayView.layer.cornerRadius = dayCellH / 2;
        _dayL = [[UILabel alloc] init];
        _dayL.textAlignment = NSTextAlignmentCenter;
        _dayL.text = @"18";
        _dayL.font = FONT_PINGFAN(14);
        [self.contentView addSubview:_dayL];
        [_dayL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(3);
            make.height.mas_equalTo(20);
        }];
        
        _monL = [[UILabel alloc] init];
        _monL.textAlignment = NSTextAlignmentCenter;
        _monL.text = @"十一月";
        _monL.font = FONT_PINGFAN(8);
        [self.contentView addSubview:_monL];
        [_monL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(_dayL.mas_bottom);
            make.height.mas_equalTo(10);
        }];
    }
    
    return self;
}

//MARK: - setmethod

- (void)setCellDate:(NSDate *)cellDate {
    _cellDate = cellDate;
    if (_type == CalendarType_Week) {
        [self showDateFunction];
    } else {
        if ([[YXDateHelpObject manager] checkSameMonth:_cellDate AnotherMonth:_currentDate]) {
            [self showDateFunction];
        } else {
            [self showSpaceFunction];
        }
    }
}

//MARK: - otherMethod

- (void)showSpaceFunction {
    self.userInteractionEnabled = NO;
    _dayL.text = @"";
    _dayL.backgroundColor = [UIColor clearColor];
    _dayL.layer.borderWidth = 0;
    _dayL.layer.borderColor = [UIColor clearColor].CGColor;
    _pointV.hidden = YES;
}

- (void)showDateFunction {
    
    self.userInteractionEnabled = YES;
    _dayL.text = [[YXDateHelpObject manager] getStrFromDateFormat:@"d" Date:_cellDate];
    NSString *monStr = [[YXDateHelpObject manager] getStrFromDateFormat:@"MM" Date:_cellDate];
    NSString *dae = [[YXDateHelpObject manager] translationArabicNum:[monStr integerValue]];
    _monL.text = [NSString stringWithFormat:@"%@月",dae];
    if ([[YXDateHelpObject manager] isSameDate:_cellDate AnotherDate:[NSDate date]]) {
        _dayView.layer.borderWidth = 1.5;
        _dayView.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        _dayView.layer.borderWidth = 0;
        _dayView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    if (_selectDate) {
        
        if ([[YXDateHelpObject manager] isSameDate:_cellDate AnotherDate:_selectDate]) {
            _dayView.backgroundColor = [UIColor whiteColor];
            _dayL.textColor = [QFTools colorWithHexString:MainColor];
            _monL.textColor = [QFTools colorWithHexString:MainColor];
            _dayView.backgroundColor = [UIColor whiteColor];
        } else {
            _dayView.backgroundColor = [UIColor clearColor];
            _dayL.textColor = [UIColor whiteColor];
            _monL.textColor = [UIColor whiteColor];
            _pointV.backgroundColor = [UIColor orangeColor];
        }
        
    }
    NSString *currentDate = [[YXDateHelpObject manager] getStrFromDateFormat:@"MM-dd" Date:_cellDate];
    _pointV.hidden = YES;
    if (_eventArray.count) {
        for (NSString *strDate in _eventArray) {
            if ([strDate isEqualToString:currentDate]) {
                _pointV.hidden = NO;
            }
        }
    }
    
}


@end
