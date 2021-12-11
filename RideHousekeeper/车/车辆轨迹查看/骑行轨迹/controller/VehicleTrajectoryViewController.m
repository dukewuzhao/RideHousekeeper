//
//  VehicleTrajectoryViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/8.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "VehicleTrajectoryViewController.h"
#import "VehiclePositionViewController.h"
#import "VehicleTrackPlaybackViewController.h"
#import "CyclingScrollView.h"
#import "GridDayTripStatisticsView.h"
#import "HorizontalDayTripStatisticsView.h"
#import "ZXMutipleGestureTableView.h"
#import "TrackSwitchView.h"
#import "YXCalendarView.h"
#import "DateSelectionView.h"
#import "NSDate+HC.h"
#import "TrajectoryTableViewCell.h"
#import "TrafficReportHeadView.h"
#import "PlaceholderView.h"
#import "NoticeTableViewCell.h"
#import "RideReportModel.h"

@interface VehicleTrajectoryViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UIImageView  *gradientImgView;
@property (nonatomic,strong) YXCalendarView *calendar;
@property (nonatomic,strong) CyclingScrollView  *scrollView;
@property (nonatomic,strong) UIView  *scrollContentView;
@property (nonatomic,strong) GridDayTripStatisticsView  *gridDayTripStatisticsView;
@property (nonatomic,strong) HorizontalDayTripStatisticsView  *horizontalDayTripStatisticsView;
@property (nonatomic,strong) TrackSwitchView *switchView;
@property (nonatomic,strong) DateSelectionView *dateView;
@property (nonatomic,strong) NSMutableDictionary *daysDic;
@property (nonatomic,strong) NSMutableDictionary *rideReportDic;
@property (nonatomic,assign) float cyclingScrollViewOffset;
@property (nonatomic,strong) ZXMutipleGestureTableView *trajectoryTab;
@property (nonatomic,assign) BOOL trajectoryTabCanScroll;
@property (nonatomic,copy)   NSString *date;
@end

@implementation VehicleTrajectoryViewController

- (NSMutableDictionary *)daysDic {
    if (_daysDic == nil) {
        _daysDic = [NSMutableDictionary dictionary];
    }

    return _daysDic;
}

- (NSMutableDictionary *)rideReportDic {
    if (_rideReportDic == nil) {
        _rideReportDic = [NSMutableDictionary dictionary];
    }

    return _rideReportDic;
}

-(void)getBikeridedays:(NSString *)day success:(void(^)())success{
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeNum = [NSNumber numberWithInteger:_bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikeridedays"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeNum,@"end_day": day,@"size": @10};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            if ([data[@"days"] isEqual:[NSNull null]]) {
                RideOneDayModel *model = [[RideOneDayModel alloc] init];
                model.summary = [[RideDaysSummaryModel alloc] init];
                model.day = day;
                if (![self.daysDic objectForKey:day]) {
                    [self.daysDic setObject:model forKey:day];
                }
                if (success) success();
                return ;
            }
            NSArray *daysModel = [RideDaysModel jsonsToModelsWithJsons:data[@"days"]];
            for (RideOneDayModel *oneDay in daysModel) {
                if (![self.daysDic objectForKey:oneDay.day]) {
                    [self.daysDic setObject:oneDay forKey:oneDay.day];
                }
            }
            
            if (![self.daysDic objectForKey:day]) {
                RideOneDayModel *model = [[RideOneDayModel alloc] init];
                model.summary = [[RideDaysSummaryModel alloc] init];
                model.day = day;
                [self.daysDic setObject:model forKey:day];
            }
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        if (success) success();
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        if (success) success();
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)getBikeRideReport:(NSString *)day success:(void(^)())success{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeNum = @(_bikeid);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikeridereport"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeNum,@"begin_day":day,@"end_day": day};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSDictionary *data = dict[@"data"];
            NSArray *rideReportAry = data[@"ride_report"];
            if ([rideReportAry isEqual:[NSNull null]]){
                if (success) success();
                return ;
            }
            for (NSDictionary *rideReport in rideReportAry) {
                
                RideReportModel *rideReportModel = [RideReportModel yy_modelWithDictionary:rideReport];
                NSArray *detail = [rideReportModel detail];
                NSMutableArray *newArray = [NSMutableArray array];
                for (int i = 0; i<detail.count; i++) {
                    NSMutableArray *sameArray = [NSMutableArray array];
                    if ([[detail[i] objectForKey:@"type"] intValue] == 1) {
                        DayRideReportModel *model = [DayRideReportModel yy_modelWithDictionary:detail[i]];
                        [sameArray addObject:model];
                        [newArray addObject:sameArray];
                        continue;
                    }else if ([[detail[i] objectForKey:@"type"] intValue] == 2){
                        
                        RideReportShockModel *model = [RideReportShockModel yy_modelWithDictionary:detail[i]];
                        [sameArray addObject:model];
                        if (i == detail.count - 1) {
                            [newArray addObject:sameArray];
                        }
                    }
                    for (int j = i+1; j<detail.count; j++) {
                        if ([[detail[j] objectForKey:@"type"] intValue] == 1) {
                            [newArray addObject:sameArray];
                            break;
                        }else if ([[detail[j] objectForKey:@"type"] intValue] == 2){
                            RideReportShockModel *model = [RideReportShockModel yy_modelWithDictionary:detail[j]];
                            
                            if (model.content.typ == [(RideReportShockModel *)sameArray.firstObject content].typ) {
                                [sameArray addObject:model];
                            }else{
                                [newArray addObject:sameArray];
                                break;
                            }
                            
                            if (j == detail.count - 1) {
                                [newArray addObject:sameArray];
                            }
                        }
                        i = j;
                    }
                }
                rideReportModel.detail = newArray;
                if (![self.rideReportDic objectForKey:day]) {
                    [self.rideReportDic setObject:rideReportModel forKey:day];
                }
            }
            
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        if (success) success();
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        if (success) success();
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)getbikeRideData:(NSString *)day{
    
    self.date = day;
    if (![self.daysDic objectForKey:day]) {
        [self getBikeridedays:day success:^{
            RideOneDayModel *model = [self.daysDic objectForKey:day];
            [self.gridDayTripStatisticsView setOneDayModel:model];
            [self.horizontalDayTripStatisticsView setOneDayModel:model];
        }];
    }else{
        RideOneDayModel *model = [self.daysDic objectForKey:day];
        [self.gridDayTripStatisticsView setOneDayModel:model];
        [self.horizontalDayTripStatisticsView setOneDayModel:model];
    }
    
    if (![self.rideReportDic objectForKey:day]) {
        
        [self getBikeRideReport:day success:^{
            [self.trajectoryTab reloadData];
        }];
    }else{
        [self.trajectoryTab reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self addSubViews];
    self.date = [[NSDate new] dateWithYMDHMS];
    [self getBikeridedays:[[NSDate new] dateWithYMDHMS] success:^{
        
        RideOneDayModel *model = [self.daysDic objectForKey:[[NSDate new] dateWithYMDHMS]];
        [self.gridDayTripStatisticsView setOneDayModel:model];
        [self.horizontalDayTripStatisticsView setOneDayModel:model];
    }];
    [self getBikeRideReport:[[NSDate new] dateWithYMDHMS] success:^{
        
        [self.trajectoryTab reloadData];
    }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"行车报告" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"signout_input"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navView.rightButton setImage:[UIImage imageNamed:@"date_selection"] forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        self.dateView = [[DateSelectionView alloc] init];
        [self.dateView showInView:self.view];
        self.dateView.dateSelectBlock = ^(NSString * _Nonnull date) {
            @strongify(self);
            //NSLog(@"选择日期%@",date);
            
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy-MM-dd";
            format.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            NSDate *newDate = [format dateFromString:date];
            
            if (![[YXDateHelpObject manager] date:newDate isBetweenDate:[[YXDateHelpObject manager] getEarlyOrLaterDate:[NSDate date] LeadTime: -DateLength Type:2] andDate:[NSDate date]]) {
                [SVProgressHUD showSimpleText:@"选择时间超出范围"];
                return;
            }
            
            [self.calendar setNowSelectDate:date];
            [self getbikeRideData:date];
        };
    };
    
}

- (void)addSubViews{
    
    _gradientImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 190)];
    _gradientImgView.userInteractionEnabled = YES;
    [self.view addSubview:_gradientImgView];
    [self.view insertSubview:_gradientImgView belowSubview:self.navView];
    
    _gradientImgView.image = [self buildImage:0 :1.0 :_gradientImgView.bounds.size];
    
    _calendar = [[YXCalendarView alloc] initWithFrame:CGRectMake(10, navHeight +6, ScreenWidth - 20, [YXCalendarView getMonthTotalHeight:[NSDate date] type:CalendarType_Week]) Date:[NSDate date] Type:CalendarType_Week];
    __weak typeof(_calendar) weakCalendar = _calendar;
    _calendar.refreshH = ^(CGFloat viewH) {
        [UIView animateWithDuration:0.3 animations:^{
            weakCalendar.frame = CGRectMake(15, navHeight +6, ScreenWidth - 30, viewH);
        }];
        
    };
    @weakify(self);
    _calendar.sendSelectDate = ^(NSDate *selDate) {
        @strongify(self);
        NSLog(@"%@",[[YXDateHelpObject manager] getStrFromDateFormat:@"yyyy-MM-dd" Date:selDate]);
        [self getbikeRideData:[[YXDateHelpObject manager] getStrFromDateFormat:@"yyyy-MM-dd" Date:selDate]];
    };
    [self.view addSubview:_calendar];
    
    self.scrollView.frame = CGRectMake(15,navHeight + 40 + 6 + 6, ScreenWidth - 30, ScreenHeight - navHeight - 52);
    [self.view addSubview:self.scrollView];
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        if ([self.rideReportDic objectForKey:self.date]) {
            [self.rideReportDic removeObjectForKey:self.date];
        }
        
        if ([self.daysDic objectForKey:self.date]) {
            [self.daysDic removeObjectForKey:self.date];
        }
        
        [self getBikeRideReport:self.date success:^{
            
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.trajectoryTab reloadData];
            });
            [self.trajectoryTab.mj_header endRefreshing];
            
        }];
        [self getBikeridedays:self.date success:^{
            RideOneDayModel *model = [self.daysDic objectForKey:self.date];
            [self.gridDayTripStatisticsView setOneDayModel:model];
            [self.horizontalDayTripStatisticsView setOneDayModel:model];
            [self.scrollView.mj_header endRefreshing];
        }];
    }];
    
    self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
    }];
    [self.scrollView.mj_footer endRefreshingWithNoMoreData];
    
    [self.scrollView addSubview:self.scrollContentView];
    [self.scrollContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(ScreenHeight- navHeight - 52 + 60);
    }];
    
    self.gridDayTripStatisticsView.frame = CGRectMake(0, 0, self.scrollView.width, 120);
    [self.scrollContentView addSubview:self.gridDayTripStatisticsView];
    
    self.horizontalDayTripStatisticsView.frame = CGRectMake(0, 0, self.scrollView.width, 60);
    self.horizontalDayTripStatisticsView.alpha = 0;
    [self.scrollContentView addSubview:self.horizontalDayTripStatisticsView];
    
    _switchView = [[TrackSwitchView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.gridDayTripStatisticsView.frame) + 10, self.scrollView.width, 45)];
    _switchView.hidden = YES;
    [self.scrollContentView addSubview:_switchView];
    
    _trajectoryTab = [[ZXMutipleGestureTableView alloc] initWithFrame:CGRectZero];
    _trajectoryTab.layer.cornerRadius = 10;
    _trajectoryTab.delegate = self;
    _trajectoryTab.dataSource = self;
    _trajectoryTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[self.showDic setObject:@"1" forKey:[NSString stringWithFormat:@"%d",0]];
    [self.scrollContentView addSubview:_trajectoryTab];
    
    MJRefreshBackGifFooter *footer = [MJRefreshBackGifFooter footerWithRefreshingBlock:^{}];
    _trajectoryTab.mj_footer = footer;
    [_trajectoryTab.mj_footer endRefreshingWithNoMoreData];
    [_trajectoryTab mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(_switchView.mas_top);
        make.right.left.mas_equalTo(self.scrollContentView);
        make.bottom.mas_equalTo(self.scrollContentView);
    }];
    
    PlaceholderView *view = [[PlaceholderView alloc]initWithFrame:_trajectoryTab imageStr:@"icon_no_bike_track" title:@"车辆安全无恙，静止了一天~" onTapView:^{
        
    }];
    _trajectoryTab.placeHolderView = view.middleView;
}
- (BOOL)getCanScroll{
    return _trajectoryTabCanScroll;
}
- (void)setCanScroll:(BOOL)canScroll{
    _trajectoryTabCanScroll = canScroll;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.scrollView) {
        
        NSLog(@"ScrollView滚动%f",scrollView.contentOffset.y);
        _cyclingScrollViewOffset = scrollView.contentOffset.y;
        CGFloat tableCountDistance = 60;
        CGRect gradientImgViewFrame = _gradientImgView.frame;
        CGRect calendarFrame = self.gridDayTripStatisticsView.frame;
        CGRect horizontalDayTripStatisticsFrame = self.horizontalDayTripStatisticsView.frame;
        
        if (scrollView.contentOffset.y >= 0) {
                self.gridDayTripStatisticsView.alpha = (60-ABS(scrollView.contentOffset.y))/tableCountDistance;
                gradientImgViewFrame.size.height = 190 - (ABS(scrollView.contentOffset.y)/tableCountDistance)*50;
            calendarFrame.origin.y =  scrollView.contentOffset.y;
        }else{
            calendarFrame.origin.y =  0;
        }
            
        if (scrollView.contentOffset.y >= tableCountDistance) {
            //[scrollView setContentOffset:CGPointMake(0, 60)];
            [self.scrollView setScrollEnabled:NO];
            [self setCanScroll:YES];
            //[UIView animateWithDuration:0.3 animations:^{
                _horizontalDayTripStatisticsView.alpha = 1;
            //}];
            
            //_horizontalDayTripStatisticsView.alpha = ABS(offsetY)/tableCountDistance;
        }else if (tableCountDistance - scrollView.contentOffset.y >= 5){
            
            //[UIView animateWithDuration:0.3 animations:^{
                _horizontalDayTripStatisticsView.alpha =0;
            //}];
        }
        
        horizontalDayTripStatisticsFrame.origin.y = scrollView.contentOffset.y;
        _gradientImgView.frame = gradientImgViewFrame;
        self.gridDayTripStatisticsView.frame = calendarFrame;
        self.horizontalDayTripStatisticsView.frame = horizontalDayTripStatisticsFrame;
        
    }else if (scrollView == self.trajectoryTab){
        
        NSLog(@"tableView滚动%f",scrollView.contentOffset.y);
        if (![self getCanScroll]) {
            [scrollView setContentOffset:CGPointZero];
        }
        
        CGRect rec = [self.switchView convertRect:self.switchView.bounds toView:self.view];
        if (_cyclingScrollViewOffset <= 0) {

            if (rec.origin.y >= navHeight + 120 + 57 + 5) { //246
                [self setCanScroll:NO];
                [self.scrollView setScrollEnabled:true];
            }

        }else if(_cyclingScrollViewOffset >= 60){

            if (rec.origin.y <= navHeight+ 57 + 60 + 5) {
                [self setCanScroll:YES];
                //[self.scrollView setContentOffset:CGPointMake(0, 60)];
                if (scrollView.contentOffset.y > 0) {
                    [self.scrollView setScrollEnabled:NO];
                }else if (scrollView.contentOffset.y < 5){
                    [self.scrollView setScrollEnabled:YES];
                    [scrollView setContentOffset:CGPointZero];
                }
            }
        }
        
    }
}

/*
-(void)childScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    ///表需要滑动的距离
    CGFloat tableCountDistance = 60;
    point.y<0向上
    CGPoint point =  [scrollView.panGestureRecognizer translationInView:scrollView];

    if (point.y<=0) {
        if (scrollView.contentOffset.y>=20) {

            [self.scrollView setContentOffset:CGPointMake(0, 60) animated:false];
        }else{
            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:false];
        }
    }else{
        if (scrollView.contentOffset.y<tableCountDistance-20) {
           [self.scrollView setContentOffset:CGPointMake(0, 0) animated:false];
        }else{
            [self.scrollView setContentOffset:CGPointMake(0, 60) animated:false];
        }
    }
}
*/




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[[[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row] objectAtIndex:0] valueForKeyPath:@"type"] intValue] == 1) {
        
        return 120.0f;
    }else{
        
        
        if ([[[[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row] objectAtIndex:0] isOpen]) {
            return 60.0f + [[[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row] count] *35.0f;
        }else{
            return 60.0f;
        }
    }
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{

    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[[[[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row] objectAtIndex:0] valueForKeyPath:@"type"] intValue] == 1) {
        DayRideReportModel *model = [[[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row] objectAtIndex:0];
        TrajectoryTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"trajectory"];
        if (!cell) {
            cell = [[TrajectoryTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"trajectory"];
        }
        @weakify(self);
        cell.trajectoryClickBlock = ^{
            @strongify(self);
            
            VehicleTrackPlaybackViewController *TrackPlayVc = [[VehicleTrackPlaybackViewController alloc] init];
            TrackPlayVc.bikeid = self.bikeid;
            [TrackPlayVc DrawingCyclingRoute:model];
            [self.navigationController pushViewController:TrackPlayVc animated:YES];
        };
        cell.dotView.layer.cornerRadius = 5;
        cell.dotView.backgroundColor = [UIColor whiteColor];
        cell.timeLab.text = [QFTools stringFromInt:@"HH:mm" :model.content.begin_ts];
        cell.startLab.text = model.content.begin_loc.road;
        cell.endLab.text = model.content.end_loc.road;
        cell.mileageLab.text = [NSString stringWithFormat:@"%.1fkm",(float)model.content.distance/1000];
        cell.timeConsumingLab.text = [NSString stringWithFormat:@"%.1f分钟",(float)model.content.time/60];
        cell.speedImgLab.text = [NSString stringWithFormat:@"%.1fkm/h",(float)model.content.speed * 0.001];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] count] <= 1) {
            cell.linView.hidden = YES;
        }else{
            cell.linView.hidden = NO;
            
            if (indexPath.row == 0) {
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView).offset(60);
                    make.bottom.equalTo(cell.contentView);
                    make.width.mas_equalTo(1);
                }];
            }else if (indexPath.row == [[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] count] - 1){
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView);
                    make.bottom.equalTo(cell.contentView.mas_top).offset(60);
                    make.width.mas_equalTo(1);
                }];
            }else{
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView);
                    make.bottom.equalTo(cell.contentView);
                    make.width.mas_equalTo(1);
                }];
            }
            
        }
        
        
        return cell;
    }else {
        
        NoticeTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"notice"];
        if (!cell) {
            cell = [[NoticeTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"notice"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSArray *rideReportShockAry = [[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] objectAtIndex:indexPath.row];
        cell.timeLab.text =  [NSString stringWithFormat:@"%@",[QFTools stringFromInt:@"HH:mm" :[(RideReportShockModel*)rideReportShockAry.lastObject ts]]] ;
        cell.noticeTimeLab.text = [NSString stringWithFormat:@"%d次",rideReportShockAry.count];
        [cell configCellWithModel:rideReportShockAry indexPath:indexPath];
        RideReportShockModel*shockModel = (RideReportShockModel*)[rideReportShockAry objectAtIndex:0];
        cell.dotView.backgroundColor = [QFTools colorWithHexString:@"#7EDFD7"];
        
        if (rideReportShockAry.count <= 1) {
            cell.arrowImg.hidden = YES;
            cell.noticeTimeLab.hidden = YES;
            cell.noticeTitleLab.text = shockModel.content.descriptions;
            if (shockModel.content.typ == 1) {
                cell.noticeImg.image = [UIImage imageNamed:@"trajectory_shake"];
                cell.dotView.layer.cornerRadius = 5;
            }else if (shockModel.content.typ == 100){
                cell.noticeImg.image = [UIImage imageNamed:@"icon_gps_ble_connect_status"];
                cell.dotView.layer.cornerRadius = 0;
            }else if (shockModel.content.typ == 101){
                cell.noticeImg.image = [UIImage imageNamed:@"icon_gps_battery"];
                cell.dotView.layer.cornerRadius = 0;
            }
        }else{
            cell.arrowImg.hidden = NO;
            cell.noticeTimeLab.hidden = NO;
            if (shockModel.content.typ == 1) {
                cell.noticeTitleLab.text = @"车辆震动";
                cell.noticeImg.image = [UIImage imageNamed:@"trajectory_shake"];
                cell.dotView.layer.cornerRadius = 5;
            }else if (shockModel.content.typ == 100){
                cell.noticeTitleLab.text = @"智能中控连接";
                cell.noticeImg.image = [UIImage imageNamed:@"icon_gps_ble_connect_status"];
                cell.dotView.layer.cornerRadius = 0;
            }else if (shockModel.content.typ == 101){
                cell.noticeTitleLab.text = @"车辆电池连接";
                cell.noticeImg.image = [UIImage imageNamed:@"icon_gps_battery"];
                cell.dotView.layer.cornerRadius = 0;
            }
        }
        @weakify(self);
        cell.noticeClickBlock = ^{
            @strongify(self);
            if (rideReportShockAry.count <= 1) {
                return;
            }
            if ([(RideReportShockModel*)[rideReportShockAry objectAtIndex:0] isOpen]) {
                [(RideReportShockModel*)[rideReportShockAry objectAtIndex:0] setValue:@NO forKey:@"isOpen"];
            }else [(RideReportShockModel*)[rideReportShockAry objectAtIndex:0] setValue:@YES forKey:@"isOpen"];
            //[self.trajectoryTab beginUpdates];
            //[self.trajectoryTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.trajectoryTab reloadData];
            //[self.trajectoryTab endUpdates];
        };
        
        if ([[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] count] <= 1) {
            cell.linView.hidden = YES;
        }else{
            cell.linView.hidden = NO;
            
            if (indexPath.row == 0) {
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView).offset(30);
                    make.bottom.equalTo(cell.contentView);
                    make.width.mas_equalTo(1);
                }];
            }else if (indexPath.row == [[(RideReportModel *)[self.rideReportDic objectForKey:_date] detail] count] - 1){
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView);
                    make.bottom.equalTo(cell.contentView.mas_top).offset(30);
                    make.width.mas_equalTo(1);
                }];
            }else{
                [cell.linView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    
                    make.right.equalTo(cell.mainView.mas_left).offset(-10);
                    make.top.equalTo(cell.contentView);
                    make.bottom.equalTo(cell.contentView);
                    make.width.mas_equalTo(1);
                }];
            }
        }
        
        return cell;
    }
}


- (GridDayTripStatisticsView *)gridDayTripStatisticsView
{
    if (!_gridDayTripStatisticsView) {
        _gridDayTripStatisticsView = [[GridDayTripStatisticsView alloc] init];
    }
    return _gridDayTripStatisticsView;
}

- (HorizontalDayTripStatisticsView *)horizontalDayTripStatisticsView
{
    if (!_horizontalDayTripStatisticsView) {
        _horizontalDayTripStatisticsView = [[HorizontalDayTripStatisticsView alloc] init];
    }
    return _horizontalDayTripStatisticsView;
}

- (UIView *)scrollContentView
{
    if (!_scrollContentView) {
        _scrollContentView = [[UIView alloc] init];
        _scrollContentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }
    return _scrollContentView;
}
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[CyclingScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        //_scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        //_scrollView.alwaysBounceVertical = YES;
        _scrollView.tag = 666;
    }
    return _scrollView;
}

- (UIImage *)buildImage:(CGFloat)startLocations :(CGFloat)endLocations :(CGSize)targetSize{
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[8]={
        6/255.0,193/255.0,174/255.0,1,
        224/255.0,224/255.0,224/255.0,1
    };
    CGFloat locations[2]={startLocations,endLocations};
    CGGradientRef gradient= CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(0, targetSize.height), kCGGradientDrawsAfterEndLocation);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//- (TrackSwitchView *)switchView
//{
//    if (!_switchView) {
//        _switchView = [[TrackSwitchView alloc] init];
//        _switchView.selectedSegmentIndex = 0;
//    }
//    return _switchView;
//}

@end
