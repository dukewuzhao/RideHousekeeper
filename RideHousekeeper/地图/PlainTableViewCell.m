//
//  PlainTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "PlainTableViewCell.h"

@implementation PlainTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _cityLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 150, 20)];
        _cityLab.font = [UIFont systemFontOfSize:16];
        _cityLab.backgroundColor = [UIColor whiteColor];
        _cityLab.textColor = [UIColor blackColor];
//        _cityLab.numberOfLines = 0;//根据最大行数需求来设置
//        _cityLab.lineBreakMode = NSLineBreakByTruncatingTail;
//        CGSize maximumLabelSize = CGSizeMake(self.frame.size.width - 150, 9999);//labelsize的最大值
//        CGSize expectSize = [_cityLab sizeThatFits:maximumLabelSize];
//        //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
//        _cityLab.frame = CGRectMake(10, 15, expectSize.width, expectSize.height);
        [self.contentView addSubview:_cityLab];
        
        _sizelabel =[[UILabel alloc] init];
        //sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
        _sizelabel.textAlignment = NSTextAlignmentRight;
        _sizelabel.font = [UIFont systemFontOfSize:13];
        _sizelabel.textColor = [UIColor blackColor];
        _sizelabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_sizelabel];
        
        _processView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _processView.progressTintColor = [QFTools colorWithHexString:MainColor];
        [self.contentView addSubview:_processView];
        
        _down  = [[UIImageView alloc] init];
        _down.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_down];
        
        _stopBtn = [[UIButton alloc] init];
        _stopBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
        [_stopBtn.layer setCornerRadius:5];
        [_stopBtn.layer setBorderWidth:1];//设置边界的宽度
        _stopBtn.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
        [self.contentView addSubview:_stopBtn];
        
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_deleteBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
        [_deleteBtn.layer setCornerRadius:5];
        [_deleteBtn.layer setBorderWidth:1];//设置边界的宽度
        _deleteBtn.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
        [self.contentView addSubview:_deleteBtn];
        
    }
    return self;
}

-(void)layoutSubviews{
    
    _sizelabel.frame = CGRectMake(self.width - 140, 15, 100, 20);
    _processView.frame = CGRectMake(10, CGRectGetMaxY(_cityLab.frame) + 15,self.width - 60, 20);
    _down.frame = CGRectMake(self.width - 25, 25, 15, 15);
    _stopBtn.frame = CGRectMake(self.width/2 - 35, 65, 70, 25);
    _deleteBtn.frame = CGRectMake(self.width - 110, 65, 70, 25);
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
