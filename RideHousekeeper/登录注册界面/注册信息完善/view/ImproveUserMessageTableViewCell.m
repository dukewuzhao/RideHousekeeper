//
//  ImproveUserMessageTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/3/8.
//  Copyright © 2019年 Duke Wu. All rights reserved.
//

#import "ImproveUserMessageTableViewCell.h"

@implementation ImproveUserMessageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _icon = [[UIImageView alloc]initWithFrame:CGRectMake(15 , 10, 30, 30)];
        _icon.y = self.height/2 - 15;
        [self.contentView addSubview:_icon];
        
        _name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_icon.frame)+10 , 10, 45, 20)];
        _name.font = [UIFont systemFontOfSize:15];
        _name.textColor = [UIColor blackColor];
        _name.y = self.height/2 - 10;
        _name.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_name];
        
        _messageLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 140, 12.5, 100, 20)];
        _messageLab.textAlignment = NSTextAlignmentRight;
        _messageLab.font = [UIFont systemFontOfSize:14];
        _messageLab.textColor = [QFTools colorWithHexString:@"#a7a9b0"];
        [self.contentView addSubview:_messageLab];
        
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, self.height/2 - 7.5, 8.4, 15)];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        
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
