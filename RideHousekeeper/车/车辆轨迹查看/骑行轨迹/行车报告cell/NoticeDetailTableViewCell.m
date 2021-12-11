//
//  NoticeDetailTableViewCell.m
//  RideHousekeeper
//
//  Created by 吴兆华 on 2018/4/2.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "NoticeDetailTableViewCell.h"
@interface NoticeDetailTableViewCell ()

@property (strong, nonatomic) UILabel *noticeLevelLab;

@property (strong, nonatomic) UILabel *timeLab;

@end
@implementation NoticeDetailTableViewCell

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
        
        _noticeLevelLab = [[UILabel alloc] init];
        _noticeLevelLab.text = @"车辆震动";
        _noticeLevelLab.font = [UIFont systemFontOfSize:13];
        _noticeLevelLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_noticeLevelLab];
        [self.noticeLevelLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(40);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(25);
        }];
        
        _timeLab = [[UILabel alloc] init];
        _timeLab.text = @"19:12";
        _timeLab.font = [UIFont systemFontOfSize:13];
        _timeLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.contentView addSubview:_timeLab];
        [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self).priorityLow();
            make.left.greaterThanOrEqualTo(_noticeLevelLab.mas_right).offset(10).priorityHigh();
            make.centerY.equalTo(self);
            make.height.mas_equalTo(25);
        }];
        
        
    }
    return self;
}

- (void)configCellWithModel:(RideReportShockModel *)model{
    
    _timeLab.text = [QFTools stringFromInt:@"HH:mm" :model.ts];
    RideReportShockContentModel *content = model.content;
    _noticeLevelLab.text = content.descriptions;
    /*
    if (content.typ == 1) {
        _noticeLevelLab.text = @"振动";
    }else if (content.typ == 100){
        if (content.level == 0) {
            _noticeLevelLab.text = @"连接丢失";
        }else if (content.level == 1){
            _noticeLevelLab.text = @"连接成功";
        }
    }else if (content.typ == 101){
        if (content.level == 0) {
            _noticeLevelLab.text = @"电池拔出";
        }else if (content.level == 1){
            _noticeLevelLab.text = @"电池插入";
        }
    }else{
        _noticeLevelLab.text = content.descriptions;
    }
    */
}

@end
