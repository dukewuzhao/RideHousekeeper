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
        
        [self.contentView addSubview:self.textlabel];
        self.textlabel.frame = CGRectMake(0, 12, 100, 20);
    }
    return self;
}

-(UILabel *)textlabel{
    //NSLog(@"cell size is %@", NSStringFromCGSize(self.contentView.bounds.size));
    if (!_textlabel) {
        _textlabel = [UILabel new];
        _textlabel.textAlignment = NSTextAlignmentCenter;
        _textlabel.font = [UIFont systemFontOfSize:15];
        _textlabel.textColor = [UIColor blackColor];
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
