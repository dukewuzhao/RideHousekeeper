//
//  GPSFootView.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/13.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "GPSFootView.h"
#import "UIView+i7Rotate360.h"
@implementation GPSFootView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setupDate];
        
        [self setupUI];
    }
    return self;
}

-(void)setupDate{
    NSArray *ary = @[@"检查定位器是否激活",@"检查服务器通讯状态", @"检查移动SIM卡网络信号"];
    for (int i = 0; i<3; i++) {
        
        GPSFootModel *model = [GPSFootModel new];
        model.titleLab = ary[i];
        model.styleNum = imgSpot;
        [self.titleArray addObject:model];
    }
    
}

-(NSMutableArray *)titleArray{
    
    if (!_titleArray) {
        _titleArray = [NSMutableArray new];
    }
    return _titleArray;
}

-(void)setupUI{
    
    _checkTab = [[UITableView alloc] init];
    _checkTab.delegate = self;
    _checkTab.dataSource = self;
    _checkTab.backgroundColor = [UIColor clearColor];
    _checkTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_checkTab];
    [_checkTab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(self);
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _titleArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 30.0f;
}


- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor clearColor];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GPSFootViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"gpscell"];
    if (!cell) {
        cell = [[GPSFootViewCell alloc] initWithStyle:0 reuseIdentifier:@"gpscell"];
    }
    
    GPSFootModel *model = self.titleArray[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (model.styleNum == imgComplete) {
        cell.stateLab.textColor = [QFTools colorWithHexString:@"#666666"];
        cell.stateLab.font = [UIFont systemFontOfSize:10];
        cell.stateImg.image = [UIImage imageNamed:@"prompt_complete"];
    }else if (model.styleNum == imgCheck){
        cell.stateLab.textColor = [QFTools colorWithHexString:@"#111111"];
        cell.stateLab.font = [UIFont systemFontOfSize:12];
        cell.stateImg.image = [UIImage imageNamed:@"gps_connecting"];
        [cell.stateImg rotate360WithDuration:1.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
    }else if (model.styleNum == imgSpot){
        cell.stateLab.textColor = [QFTools colorWithHexString:@"#666666"];
        cell.stateLab.font = [UIFont systemFontOfSize:10];
        cell.stateImg.image = [UIImage imageNamed:@"prompt_prepare"];
    }
    //GPSFootModel *model =
    
    cell.stateLab.text = [_titleArray[indexPath.row] titleLab];
    
    return cell;
    
}

-(void)dealloc{
    
}

@end
