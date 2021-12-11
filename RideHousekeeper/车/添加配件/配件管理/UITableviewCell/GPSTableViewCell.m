//
//  GPSTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "GPSTableViewCell.h"
#import "GPSTableViewCellMaskView.h"
@interface GPSTableViewCell()

@property (nonatomic, strong) UILabel *brandName;
@property (nonatomic, strong) GPSTableViewCellMaskView *maskView;
@property (nonatomic, strong) UILabel *deviceDesc;
@property (nonatomic, strong) UILabel *leftDays;
@property (nonatomic, strong) UIButton *rechargeBtn;

@end

@implementation GPSTableViewCell

-(void)setBikeModel:(BikeModel *)bikeModel brandModel:(BrandModel *)brandModel peripheraAry:(NSArray *)ary{
    
    PerpheraServicesInfoModel *serviceInfo = [[LVFmdbTool queryPerpheraServicesInfoData:[NSString stringWithFormat:@"SELECT * FROM peripheraServicesInfo_modals WHERE (type = '%zd' OR type = '%zd') AND bikeid = '%zd'", 0,1,bikeModel.bikeid]] firstObject];
    
    switch (serviceInfo.type) {
        case 0:{
            
            if (serviceInfo.left_days >0 && serviceInfo) {
                self.maskView.type = 0;
            }else if(serviceInfo.left_days <= 0 && serviceInfo){
                self.maskView.type = 2;
            }else{
                self.maskView.type = 1;
            }
            
            break;
            
        }
        case 1:{
            
            if (serviceInfo.left_days >0&& serviceInfo) {
                self.maskView.type = 1;
            }else if(serviceInfo.left_days <= 0 && serviceInfo){
                self.maskView.type = 2;
            }else{
                self.maskView.type = 1;
            }
            
            break;
            
        }
        default:
            break;
    }
    
    if (![QFTools isBlankString:bikeModel.sn]) {
        if (bikeModel.builtin_gps == 1) {
            [self cellWithGPS:bikeModel brandModel:brandModel serviceInfo:serviceInfo peripheraAry:ary];
        }else{
            if (ary.count == 0) {
                [self cellWithOutGPS:bikeModel brandModel:brandModel peripheraAry:ary];
            }else{
                [self cellWithGPS:bikeModel brandModel:brandModel serviceInfo:serviceInfo peripheraAry:ary];
            }
        }
    }
    
    
    
}

-(void)cellWithGPS:(BikeModel *)bikeModel brandModel:(BrandModel *)brandModel serviceInfo:(PerpheraServicesInfoModel *)service peripheraAry:(NSArray *)ary{
    
    if (_deviceDesc) {
        [_deviceDesc removeFromSuperview];
        _deviceDesc = nil;
    }
    
    self.brandName.font = FONT_PINGFAN(15);
    self.brandName.text = [NSString stringWithFormat:@"%@定位追踪器",brandModel.brandname];
    [_maskView addSubview:self.brandName];
    [self.brandName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_maskView).offset(26);
        make.left.equalTo(_icon.mas_right).offset(20);
        make.height.mas_equalTo(20);
    }];
    
    self.leftDays.textColor = [QFTools colorWithHexString:@"#06C1AE"];
    self.leftDays.font = FONT_PINGFAN(14);
    self.leftDays.text = [NSString stringWithFormat:@"剩余服务天数  %d天",service.left_days];
    [self setTextColor:_leftDays FontNumber:FONT_PINGFAN(13) AndRange:NSMakeRange(0, 6) AndColor:[QFTools colorWithHexString:@"#666666"]];
    [_maskView addSubview:self.leftDays];
    [self.leftDays mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.brandName);
        make.top.equalTo(self.brandName.mas_bottom).offset(5);
        make.height.mas_equalTo(18);
    }];
    
    self.rechargeBtn.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [self.rechargeBtn setTitle:@"续费充值" forState:UIControlStateNormal];
    self.rechargeBtn.titleLabel.font = FONT_PINGFAN(10);
    [self.rechargeBtn setTitleColor:[QFTools colorWithHexString:@"#06C1AE"] forState:UIControlStateNormal];
    [_maskView addSubview:self.rechargeBtn];
    [self.rechargeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.brandName);
        make.top.equalTo(_leftDays.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(120, 28));
    }];
    @weakify(self);
    [[self.rechargeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.rechargeBtnClick) self.rechargeBtnClick();
    }];
}

-(void)cellWithOutGPS:(BikeModel *)bikeModel brandModel:(BrandModel *)brandModel  peripheraAry:(NSArray *)ary{
    
    
    
    if (_leftDays) {
        [_leftDays removeFromSuperview];
        _leftDays = nil;
    }
    
    if (_rechargeBtn) {
        [_rechargeBtn removeFromSuperview];
        _rechargeBtn = nil;
    }
    
    self.brandName.font = FONT_PINGFAN(15);
    self.brandName.text = [NSString stringWithFormat:@"%@定位追踪器",brandModel.brandname];
    [_maskView addSubview:self.brandName];
    [self.brandName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_maskView);
        make.bottom.equalTo(_maskView.mas_centerY).offset(-2);
        make.height.mas_equalTo(20);
    }];
    
    self.deviceDesc = [[UILabel alloc] init];
    self.deviceDesc.textColor = [QFTools colorWithHexString:MainColor];
    self.deviceDesc.text = @"还未添加定位器";
    self.deviceDesc.font = FONT_PINGFAN(13);
    [_maskView addSubview:self.deviceDesc];
    [self.deviceDesc mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.brandName);
        make.top.equalTo(_maskView.mas_centerY).offset(2);
        make.height.mas_equalTo(20);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _title = [[UILabel alloc] init];
        _title.font = FONT_PINGFAN(16);
        [[self contentView] addSubview:_title];
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(self).offset(5);
            make.height.mas_equalTo(20);
        }];
        
        _maskView = [[GPSTableViewCellMaskView alloc] init];
        _maskView.backgroundColor = [UIColor whiteColor];
        _maskView.layer.cornerRadius = 10;
        _maskView.layer.masksToBounds = YES;
        [[self contentView] addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.equalTo(_title.mas_bottom).offset(10);
            make.right.equalTo(self).offset(-15);
            make.bottom.equalTo(self).offset(-5);
        }];
        
        _icon = [[UIImageView alloc] init];
        [_maskView addSubview:_icon];
        [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_maskView).offset(20);
            make.centerY.equalTo(_maskView);
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [_maskView addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_maskView).offset(-10);
            make.centerY.equalTo(_maskView);
        }];
    }
    return self;
}

-(UILabel *)brandName{
    if (!_brandName) {
        _brandName = [[UILabel alloc] init];
    }
    return _brandName;
}

-(UILabel *)deviceDesc{
    if (!_deviceDesc) {
        _deviceDesc = [[UILabel alloc] init];
    }
    return _deviceDesc;
}

-(UILabel *)leftDays{
    if (!_leftDays) {
        _leftDays = [[UILabel alloc] init];
    }
    return _leftDays;
}

-(UIButton *)rechargeBtn{
    if (!_rechargeBtn) {
        _rechargeBtn = [[UIButton alloc] init];
    }
    return _rechargeBtn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
