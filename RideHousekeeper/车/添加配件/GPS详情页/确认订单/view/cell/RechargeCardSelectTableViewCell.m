//
//  RechargeCardSelectTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "RechargeCardSelectTableViewCell.h"

@implementation RechargeCardSelectTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *RechargeCardImg = [[UIImageView alloc] init];
        RechargeCardImg.image = [UIImage imageNamed:@"recharge_card_icon"];
        [self.contentView addSubview:RechargeCardImg];
        [RechargeCardImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(34, 34));
        }];

        UILabel* RechargeCardLab = [[UILabel alloc] init];
        RechargeCardLab.font = FONT_PINGFAN(13);
        RechargeCardLab.textColor = [UIColor blackColor];
        RechargeCardLab.text = @"充值卡支付";
        [self.contentView addSubview:RechargeCardLab];
        [RechargeCardLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(RechargeCardImg.mas_right).offset(20);
            make.centerY.equalTo(RechargeCardImg);
            make.height.mas_equalTo(18);
        }];
        
        UIButton *RechargeCardSelectBtn = [[UIButton alloc] init];
        [RechargeCardSelectBtn setImage:[UIImage imageNamed:@"unselect_icon"] forState:UIControlStateNormal];
        [RechargeCardSelectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [self.contentView addSubview:RechargeCardSelectBtn];
        [RechargeCardSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-50);
            make.centerY.equalTo(RechargeCardImg);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        @weakify(self);
        @weakify(RechargeCardSelectBtn);
        [[RechargeCardSelectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            @strongify(RechargeCardSelectBtn);
            RechargeCardSelectBtn.selected = !RechargeCardSelectBtn.selected;
            [self payChoose:RechargeCardSelectBtn.selected tag:1];
        }];
    }
    return self;
}

-(void)payChoose:(BOOL)iselect tag:(NSInteger)tag{
    
    if (iselect && self.selectPayChannel) {
        self.selectPayChannel(1);
    }else if (self.selectPayChannel){
        self.selectPayChannel(0);
    }
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
