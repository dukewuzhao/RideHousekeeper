//
//  GPSFootViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/13.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "GPSFootViewCell.h"

@implementation GPSFootViewCell

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
        
        _stateImg = [[UIImageView alloc] init];
        _stateImg.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_stateImg];
        [_stateImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView.mas_centerX).offset(-60);
            make.size.mas_equalTo(CGSizeMake(10, 10));
        }];
        
        _stateLab = [[UILabel alloc] init];
        _stateLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _stateLab.font = FONT_PINGFAN(10);
        [self.contentView addSubview:_stateLab];
        [_stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_stateImg.mas_right).offset(5);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(17);
        }];
    }
    return self;
}


@end
