//
//  PaymentOptionsTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PaymentOptionsTableViewCell.h"

@implementation PaymentOptionsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *wChatImg = [[UIImageView alloc] init];
        wChatImg.image = [UIImage imageNamed:@"wechat_icon"];
        [self.contentView addSubview:wChatImg];
        [wChatImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.top.equalTo(self.contentView).offset(20);
            make.size.mas_equalTo(CGSizeMake(34, 34));
        }];

        UILabel* wechatLab = [[UILabel alloc] init];
        wechatLab.font = FONT_PINGFAN(13);
        wechatLab.textColor = [UIColor blackColor];
        wechatLab.text = @"微信支付";
        [self.contentView addSubview:wechatLab];
        [wechatLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wChatImg.mas_right).offset(20);
            make.top.equalTo(wChatImg);
            make.height.mas_equalTo(18);
        }];

        UILabel* remindLab = [[UILabel alloc] init];
        remindLab.font = FONT_PINGFAN(8);
        remindLab.textColor = [QFTools colorWithHexString:@"#999999"];
        remindLab.text = @"仅支持微信4.2及以上版本";
        [self.contentView addSubview:remindLab];
        [remindLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wechatLab);
            make.bottom.equalTo(wChatImg);
            make.height.mas_equalTo(11);
        }];

        UIButton *wechatSelectBtn = [[UIButton alloc] init];
        [wechatSelectBtn setImage:[UIImage imageNamed:@"unselect_icon"] forState:UIControlStateNormal];
        [wechatSelectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [self.contentView addSubview:wechatSelectBtn];
        [wechatSelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-50);
            make.centerY.equalTo(wChatImg);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        
        
        UIImageView *alipayImg = [[UIImageView alloc] init];
        alipayImg.image = [UIImage imageNamed:@"alipay_icon"];
        [self.contentView addSubview:alipayImg];
        [alipayImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.bottom.equalTo(self.contentView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(34, 34));
        }];
        
        UILabel* alipayLab = [[UILabel alloc] init];
        alipayLab.font = FONT_PINGFAN(13);
        alipayLab.textColor = [UIColor blackColor];
        alipayLab.text = @"支付宝支付";
        [self.contentView addSubview:alipayLab];
        [alipayLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(alipayImg.mas_right).offset(20);
            make.top.equalTo(alipayImg);
            make.height.mas_equalTo(18);
        }];
        
        UILabel* alipayRemindLab = [[UILabel alloc] init];
        alipayRemindLab.font = FONT_PINGFAN(8);
        alipayRemindLab.textColor = [QFTools colorWithHexString:@"#999999"];
        alipayRemindLab.text = @"推荐支付宝用户使用";
        [self.contentView addSubview:alipayRemindLab];
        [alipayRemindLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(alipayLab);
            make.bottom.equalTo(alipayImg);
            make.height.mas_equalTo(11);
        }];
        
        UIButton *alipaySelectBtn = [[UIButton alloc] init];
        [alipaySelectBtn setImage:[UIImage imageNamed:@"unselect_icon"] forState:UIControlStateNormal];
        [alipaySelectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateSelected];
        [self.contentView addSubview:alipaySelectBtn];
        [alipaySelectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-50);
            make.centerY.equalTo(alipayImg);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        @weakify(self);
        @weakify(alipaySelectBtn);
        @weakify(wechatSelectBtn);
        [[alipaySelectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            @strongify(alipaySelectBtn);
            @strongify(wechatSelectBtn);
            alipaySelectBtn.selected = !alipaySelectBtn.selected;
            
            if (alipaySelectBtn.selected) {
                wechatSelectBtn.selected = NO;
            }
            [self payChoose:alipaySelectBtn.selected tag:2];
        }];
        
        [[wechatSelectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            @strongify(wechatSelectBtn);
            @strongify(alipaySelectBtn);
            wechatSelectBtn.selected = !wechatSelectBtn.selected;
            if (wechatSelectBtn.selected) {
                alipaySelectBtn.selected = NO;
            }
            [self payChoose:wechatSelectBtn.selected tag:1];
        }];
    }
    return self;
}

-(void)payChoose:(BOOL)iselect tag:(NSInteger)tag{
    if (tag == 1) {
        if (iselect && self.selectPayChannel) {
            self.selectPayChannel(WeChat);
        }else if (self.selectPayChannel){
            self.selectPayChannel(SelectNone);
        }
    }else{
        if (iselect && self.selectPayChannel) {
            self.selectPayChannel(Alipay);
        }else if (self.selectPayChannel){
            self.selectPayChannel(SelectNone);
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
