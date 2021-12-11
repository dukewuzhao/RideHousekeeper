//
//  GPSSignalPopupTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/11.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "GPSSignalPopupTableViewCell.h"

@implementation GPSSignalPopupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.signalStrengthImg];
        [self.signalStrengthImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(10);
            make.size.mas_equalTo(CGSizeMake(24, 20));
        }];
        
        
        [self.contentView addSubview:self.signalStrengthLab];
        [self.signalStrengthLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.signalStrengthImg.mas_right).offset(5);
            make.centerY.equalTo(self.signalStrengthImg);
            make.height.mas_equalTo(20);
        }];
        
        [self.contentView addSubview:self.communicationTime];
        [self.communicationTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.top.equalTo(self.signalStrengthImg.mas_bottom).offset(5);
            make.height.mas_equalTo(10);
        }];
    }
    return self;
}

-(UIImageView *)signalStrengthImg{
    
    if (!_signalStrengthImg) {
        _signalStrengthImg = [[UIImageView alloc] init];
    }
    return _signalStrengthImg;
}

-(UILabel *)signalStrengthLab{
    if (!_signalStrengthLab) {
        _signalStrengthLab = [[UILabel alloc] init];
        _signalStrengthLab.textAlignment = NSTextAlignmentCenter;
        _signalStrengthLab.font = FONT_PINGFAN(15);
        _signalStrengthLab.textColor = [QFTools colorWithHexString:@"#666666"];
    }
    return _signalStrengthLab;
}

-(UILabel *)communicationTime{
    if (!_communicationTime) {
        _communicationTime = [[UILabel alloc] init];
        _communicationTime.textAlignment = NSTextAlignmentCenter;
        _communicationTime.font = FONT_PINGFAN(12);
        _communicationTime.textColor = [QFTools colorWithHexString:@"#999999"];
    }
    return _communicationTime;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
