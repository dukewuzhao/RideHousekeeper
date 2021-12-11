//
//  UpdateUserNameTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/29.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "UpdateUserNameTableViewCell.h"

@implementation UpdateUserNameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _name = [[UILabel alloc] initWithFrame:CGRectMake(15 , 10, 45, 20)];
        _name.font = [UIFont systemFontOfSize:15];
        _name.textColor = [UIColor blackColor];
        _name.y = self.height/2 - 10;
        _name.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_name];
        
        _nickNameField = [self addOneTextFieldWithTitle:nil imageName:nil imageNameWidth:10 Frame:CGRectMake(ScreenWidth - 260, 5,  220, 35)];
        _nickNameField.backgroundColor = [UIColor clearColor];
        _nickNameField.font = FONT_PINGFAN(14);
        _nickNameField.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nickNameField];
        @weakify(self);
        UIButton *ClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7.5, 20, 20)];
        [ClearBtn setImage:[UIImage imageNamed:@"clear_btnBg"] forState:UIControlStateNormal];
        [[ClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.clearfieldBlock) {
                self.clearfieldBlock();
            }
            
        }];
        _nickNameField.rightView = ClearBtn;
        _nickNameField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, self.height/2 - 7.5, 8.4, 15)];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        
    }
    return self;
}

- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleNone;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.textAlignment = NSTextAlignmentRight;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    field.placeholder = title;
    return field;
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
