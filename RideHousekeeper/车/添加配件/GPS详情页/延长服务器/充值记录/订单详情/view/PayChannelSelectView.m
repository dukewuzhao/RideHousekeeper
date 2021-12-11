//
//  PayChannelSelectView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/18.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "PayChannelSelectView.h"
#import "PayChannelHeadView.h"
#import "PayChannelSelectTableViewCell.h"

@interface PayChannelSelectView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) PayChannelHeadView *header;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) PayChannelSelectModel *model;
//@property (nonatomic,strong) ServiceOrder *serverModel;

@end

@implementation PayChannelSelectView

-(void)setOrderInfo:(ServiceOrder *)model{
    //_serverModel = model;
    
    switch (model.pay_channel) {
        case 0:
            self.model.channel = 0;
            break;
        case 3:
            self.model.channel = 1;
            break;
        case 4:
            self.model.channel = 0;
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

-(PayChannelSelectModel *)model{
    if (!_model) {
        _model = [[PayChannelSelectModel alloc] init];
        _model.channel = 0;
    }
    return _model;
}

-(PayChannelHeadView *)header{
    if (!_header) {
        _header = [[PayChannelHeadView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    }
    return _header;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor whiteColor];
        
        UIView *mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self);
        }];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.scrollEnabled = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [QFTools colorWithHexString:@"#CCCCCC"];
        _tableView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [mainView addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(mainView);
        }];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PayChannelSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayChannelSelectTableViewCell"];
    if (!cell) {
        cell = [[PayChannelSelectTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"PayChannelSelectTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.model.channel == indexPath.row) {
        [cell.selectBtn setImage:[UIImage imageNamed:@"select_icon"] forState:UIControlStateNormal];
    }else{
        [cell.selectBtn setImage:[UIImage imageNamed:@"unselect_icon"] forState:UIControlStateNormal];
    }
    switch (indexPath.row) {
        case 0:
            cell.icon.image = [UIImage imageNamed:@"alipay_icon"];
            cell.titleLab.text = @"支付宝支付";
            break;
        case 1:
            cell.icon.image = [UIImage imageNamed:@"wechat_icon"];
            cell.titleLab.text = @"微信支付";
            break;
        default:
            break;
    }
    @weakify(cell);
    @weakify(self);
    cell.selectBlock =^{
        @strongify(cell);
        @strongify(self);
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.model.channel = indexPath.row;
            [self.tableView reloadData];
            if (self.selectPayChannel) self.selectPayChannel(indexPath.row);
        });
    };
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    @weakify(self);
    self.header.payChannelClickBlock = ^(BOOL select){
        @strongify(self);
        if(self.updatePayChannelBlock) self.updatePayChannelBlock(select);
    };
    
    switch (self.model.channel) {
        case 0:
            self.header.icon.image = [UIImage imageNamed:@"alipay_icon"];
            self.header.selectLab.text = @"支付宝支付";
            break;
        case 1:
            self.header.icon.image = [UIImage imageNamed:@"wechat_icon"];
            self.header.selectLab.text = @"微信支付";
            break;
        default:
            break;
    }
    
    return self.header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end

@implementation PayChannelSelectModel



@end
