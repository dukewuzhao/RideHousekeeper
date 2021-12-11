//
//  GPSSignalPopupView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "GPSSignalPopupView.h"
#import "GPSSignalPopupTableViewCell.h"

@interface GPSSignalPopupView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) BikeStatusInfoModel *model;
@property (nonatomic, assign) GPSSignalPopupDirection direction;

@end

@implementation GPSSignalPopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithModel:(BikeStatusInfoModel *)model
   origin:(CGPoint)origin
    width:(CGFloat)width
   height:(CGFloat)height
    direction:(GPSSignalPopupDirection)direction{
    
    if (self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)]) {
            //背景色为clearColor
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.origin = origin;
            self.height = height;
            self.width = width;
            self.direction = direction;
            self.model = model;
            if (height <= 0) {
                height = 60;
            }
                
            if (direction == GPSSignalPopupDirectionLeft) {
                self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, -width, -height * 2) style:UITableViewStylePlain];
            }else {
                self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, -height * 2) style:UITableViewStylePlain];
            }
            _tableView.bounces = NO;
            _tableView.layer.cornerRadius = 8;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
            _tableView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
            [self addSubview:self.tableView];
            
            //_tableView.tableHeaderView = label2;
            
            //cell线条
            if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [self.tableView setSeparatorInset:CellLineEdgeInsets];
            }
            
            if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
                [self.tableView setLayoutMargins:CellLineEdgeInsets];
            }
        }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GPSSignalPopupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GPSSignalPopup"];
    if (!cell) {
        cell = [[GPSSignalPopupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GPSSignalPopup"];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    if (indexPath.row == 0) {
        
        if (self.model.pos.level >= 0 && self.model.pos.level < 25) {
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_no"];
            cell.signalStrengthLab.text = @"GPS信号无";
        }else if (self.model.pos.level >= 25 && self.model.pos.level < 50){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_low"];
            cell.signalStrengthLab.text = @"GPS信号差";
        }else if (self.model.pos.level >= 50 && self.model.pos.level < 75){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_middle"];
            cell.signalStrengthLab.text = @"GPS信号中";
        }else if (self.model.pos.level >= 75){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_full"];
            cell.signalStrengthLab.text = @"GPS信号良";
        }
        cell.communicationTime.text = [NSString stringWithFormat:@"最后通讯:%@",[QFTools stringFromInt:nil :self.model.pos.ts]];;
    }else{
        
        if (self.model.signal >= 0 && self.model.signal < 25) {
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_no"];
            cell.signalStrengthLab.text = @"GSM信号无";
        }else if (self.model.signal >= 25 && self.model.signal < 50){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_low"];
            cell.signalStrengthLab.text = @"GSM信号差";
        }else if (self.model.signal >= 50 && self.model.signal < 75){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_middle"];
            cell.signalStrengthLab.text = @"GSM信号中";
        }else if (self.model.signal >= 75){
            cell.signalStrengthImg.image = [UIImage imageNamed:@"icon_signal_full"];
            cell.signalStrengthLab.text = @"GSM信号良";
        }
        
        cell.communicationTime.text = [NSString stringWithFormat:@"最后通讯:%@",[QFTools stringFromInt:nil :self.model.updated_ts]];;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismiss];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:CellLineEdgeInsets];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:CellLineEdgeInsets];
    }
    cell.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
}

//画出尖尖
- (void)drawRect:(CGRect)rect {
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    
    if (self.direction == GPSSignalPopupDirectionLeft) {
        CGFloat startX = self.origin.x;
        CGFloat startY = self.origin.y - 35;
        CGContextMoveToPoint(context, startX, startY);//设置起点
        
        CGContextAddLineToPoint(context, startX + 5, startY + 5);
        
        CGContextAddLineToPoint(context, startX, startY + 10);
    }else {
        CGFloat startX = self.origin.x;
        CGFloat startY = self.origin.y - 35;
        CGContextMoveToPoint(context, startX, startY);//设置起点
        
        CGContextAddLineToPoint(context, startX - 5, startY - 5);
        
        CGContextAddLineToPoint(context, startX, startY - 5);
    }
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    [self.tableView.backgroundColor setFill]; //设置填充色
    [self.tableView.backgroundColor setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

- (void)pop {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
    self.alpha = 0;
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        self.tableView.frame = frame;
    }];
}

- (void)dismiss {
    //动画效果淡出
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.tableView.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.dismissOperation) {
                self.dismissOperation();
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.tableView]) {
        [self dismiss];
    }
}

@end
