//
//  LrdOutputCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/8.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "LrdOutputCell.h"

@implementation LrdOutputCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
//        [self.contentView addSubview:self.image];
//        [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.equalTo(self.contentView);
//            make.left.equalTo(self.contentView).offset(5);
//            make.size.mas_equalTo(CGSizeMake(23, 23));
//        }];
        [self.contentView addSubview:self.textlabel];
        [self.textlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(5);
            make.right.equalTo(self.contentView).offset(-5);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

-(UIImageView *)image{
    
    if (!_image) {
        _image = [UIImageView new];
    }
    return _image;
}

-(UILabel *)textlabel{
    //NSLog(@"cell size is %@", NSStringFromCGSize(self.contentView.bounds.size));
    if (!_textlabel) {
        _textlabel = [UILabel new];
        _textlabel.textAlignment = NSTextAlignmentCenter;
        _textlabel.font = [UIFont systemFontOfSize:15];
        //_textlabel.textColor = [UIColor blackColor];
    }
    return _textlabel;
}
- (void) layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
