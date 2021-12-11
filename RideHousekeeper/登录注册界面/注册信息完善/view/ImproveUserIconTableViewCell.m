//
//  ImproveUserIconTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/12/4.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "ImproveUserIconTableViewCell.h"

@implementation ImproveUserIconTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenHeight * 0.3 *.275, ScreenHeight * 0.3/2 - ScreenHeight * 0.3 *.275, ScreenHeight * 0.3 *.55, ScreenHeight * 0.3 *.55)];
        [self.contentView addSubview:_userIcon];
        _userIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *takePhotoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainusericonImageClicked:)];
        takePhotoTap.numberOfTapsRequired = 1;
        [_userIcon addGestureRecognizer:takePhotoTap];
        
        [_userIcon lm_addCorner:_userIcon.width/2.0 borderWidth:2.5 borderColor:[QFTools colorWithHexString:MainColor] backGroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)passingClickEvents:(UserIconClickedBlock)block {//block的实现方法
    self.userIconClickedBlock = block;
}  

- (void)mainusericonImageClicked:(UITapGestureRecognizer *)gesture{
    
    if (self.userIconClickedBlock) {
        self.userIconClickedBlock(gesture);
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
