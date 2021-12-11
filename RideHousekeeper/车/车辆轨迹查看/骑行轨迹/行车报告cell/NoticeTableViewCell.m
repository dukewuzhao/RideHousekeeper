//
//  NoticeTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/12.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "NoticeTableViewCell.h"
#import "NoticeDetailTableViewCell.h"

@interface NoticeTableViewCell ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *shockAry;
@end

@implementation NoticeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *backView = [[UIView alloc] init];
        backView.layer.cornerRadius = 10;
        backView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(70);
            make.top.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-10);
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
        
        _mainView = [[UIView alloc] init];
        [self.contentView addSubview:_mainView];
        _mainView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMainView)];
        tap.numberOfTapsRequired = 1;
        [_mainView addGestureRecognizer:tap];
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(70);
            make.top.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(50);
        }];
        
        _timeLab = [[UILabel alloc] init];
        _timeLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _timeLab.font = FONT_PINGFAN(12);
        _timeLab.text = @"08:35";
        [self.contentView addSubview:_timeLab];
        [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.mainView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(40, 15));
        }];
        
        _linView = [[UIImageView alloc] init];
        _linView.backgroundColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_linView];
        [_linView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mainView.mas_left).offset(-10);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.width.mas_equalTo(1);
        }];
        
        _dotView = [[UIView alloc] init];
        _dotView.layer.borderWidth = 1;
        _dotView.layer.borderColor = [QFTools colorWithHexString:@"#7EDFD7"].CGColor;
        _dotView.backgroundColor = [QFTools colorWithHexString:@"#7EDFD7"];
        [self.contentView addSubview:_dotView];
        [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_linView);
            make.centerY.equalTo(self.mainView);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _noticeImg = [[UIImageView alloc] init];
        _noticeImg.image = [UIImage imageNamed:@"trajectory_shake"];
        [_mainView addSubview:_noticeImg];
        [_noticeImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mainView).offset(10);
            make.centerY.equalTo(_mainView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        _noticeTitleLab = [[UILabel alloc] init];
        _noticeTitleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _noticeTitleLab.font = FONT_PINGFAN(15);
        _noticeTitleLab.text = @"车辆震动";
        [_mainView addSubview:_noticeTitleLab];
        [_noticeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_noticeImg.mas_right).offset(10);
            make.centerY.equalTo(_noticeImg);
            make.height.mas_equalTo(20);
        }];
        
        _noticeTimeLab = [[UILabel alloc] init];
        _noticeTimeLab.text = @"7次";
        _noticeTimeLab.font = FONT_PINGFAN(15);
        _noticeTimeLab.textColor = [QFTools colorWithHexString:@"#333333"];
        [_mainView addSubview:_noticeTimeLab];
        [_noticeTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_mainView).priorityLow();
            make.left.greaterThanOrEqualTo(_noticeTitleLab.mas_right).offset(10).priorityHigh();
            make.centerY.equalTo(_noticeImg);
            make.height.mas_equalTo(20);
        }];
        
        _arrowImg = [[UIImageView alloc] init];
        _arrowImg.image = [UIImage imageNamed:@"icon_down"];
        [_mainView addSubview:_arrowImg];
        [_arrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_mainView).offset(-20);
            make.centerY.equalTo(_mainView);
        }];
        
        WS(weakSelf);
        self.tableView = [[UITableView alloc] init];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollEnabled = NO;
        [self.contentView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mainView);
            make.right.equalTo(self.mainView);
            make.top.mas_equalTo(weakSelf.mainView.mas_bottom).offset(5);
        }];
        
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoticeDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[NoticeDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RideReportShockModel *model = [_shockAry objectAtIndex:indexPath.row];
    [cell configCellWithModel:model];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([(RideReportShockModel*)[_shockAry objectAtIndex:0] isOpen]) {
        return _shockAry.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([(RideReportShockModel*)[_shockAry objectAtIndex:0] isOpen]) {
        return 35.0f;
    }
    return 0;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{

    cell.backgroundColor = [UIColor clearColor];
}

- (void)configCellWithModel:(NSArray *)shockArry indexPath:(NSIndexPath *)indexPath{
    _shockAry = shockArry;
    RideReportShockModel *model = [_shockAry objectAtIndex:0];
    CGFloat tableViewHeight;
    if (model.isOpen) {
        tableViewHeight = _shockAry.count * 35;
    }else{
        tableViewHeight = 0;
    }
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableViewHeight);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
}

-(void)clickMainView{
    
    if (self.noticeClickBlock) {
        self.noticeClickBlock();
    }
}


- (UIImage *)drawLineOfDashByImageView:(UIImageView *)imageView {
    // 开始划线 划线的frame
    UIGraphicsBeginImageContext(imageView.frame.size);

    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];

    // 获取上下文
    CGContextRef line = UIGraphicsGetCurrentContext();

    // 设置线条终点的形状
    CGContextSetLineCap(line, kCGLineCapRound);
    // 设置虚线的长度 和 间距
    CGFloat lengths[] = {5,3};

    CGContextSetStrokeColorWithColor(line, [QFTools colorWithHexString:@"#707070"].CGColor);
    
    CGContextSetLineWidth(line, 1);
    
    // 开始绘制虚线
    CGContextSetLineDash(line, 0, lengths, 2);

    CGContextMoveToPoint(line, 0, 0);

    CGContextAddLineToPoint(line, 0, imageView.height);

    CGContextStrokePath(line);

    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //self.linView.frame
    //NSLog(@"%@",NSStringFromCGRect(self.linView.frame));
    //self.linView.image = [self drawLineOfDashByImageView:self.linView];
}

@end
