//
//  BottomUserReminderTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/12.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "BottomUserReminderTableViewCell.h"

@implementation BottomUserReminderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _detailLab = [[UILabel alloc] init];
        _detailLab.text = @"1.本服务包购买成功后即刻生效，购买后不可退款，敬请谅解；\n2.本服务包仅限在骑管家服务平台使用，其他平台无效；\n3.本权益由骑管家-智能出行平台提供，有任何疑问请联系骑管家官方客服：400 885 0061";
        _detailLab.numberOfLines = 0;
        _detailLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _detailLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:_detailLab];
        [_detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.top.equalTo(self.contentView).offset(5);
        }];
        
    }
    return self;
}

@end
