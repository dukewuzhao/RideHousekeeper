//
//  BindBikeTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BindBikeTableViewCell.h"

@implementation BindBikeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon  = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 25, 25)];
        [self.contentView addSubview:_Icon];
        
        _IntelligenceBike = [[UILabel alloc] init];
        _IntelligenceBike.textAlignment = NSTextAlignmentLeft;
        _IntelligenceBike.textColor = [UIColor blackColor];
        _IntelligenceBike.font = [UIFont systemFontOfSize:17];
        _IntelligenceBike.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_IntelligenceBike];
        [_IntelligenceBike mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_Icon.mas_right).offset(25);
            make.right.equalTo(self.contentView).offset(-10);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
        
        UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(15, 44, ScreenWidth-15, 0.5)];
        partingline.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self.contentView addSubview:partingline];
    }
    return self;
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
