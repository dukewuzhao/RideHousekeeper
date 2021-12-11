//
//  PlaceholderView.m
//  TableViewPlaceholder
//
//  Created by administrator on 2017/8/26.
//
//

#import "PlaceholderView.h"

@implementation PlaceholderView


- (instancetype)initWithFrame:(UITableView *)table imageStr:(NSString *)imageStr title:(NSString *)title onTapView:(TapBlock)onTapBlock{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _middleView = [[UIView alloc] init];
        _middleView.userInteractionEnabled = YES;
        [table addSubview:_middleView];
        [_middleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(table);
            make.centerY.equalTo(table);
        }];
        
        UIButton*imageView=[UIButton buttonWithType:UIButtonTypeCustom];
        //imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeCenter;
        [imageView setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
        [_middleView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_middleView);
            make.left.equalTo(_middleView).offset(20);
            make.top.equalTo(_middleView);
        }];
        [[imageView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (onTapBlock) {
                onTapBlock();
            }
        }];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        titleLab.font = FONT_PINGFAN(14);
        titleLab.text = title;
        [_middleView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_middleView);
            make.top.equalTo(imageView.mas_bottom).offset(40);
            make.bottom.equalTo(_middleView);
        }];
        
    }
    return self;
}




@end
