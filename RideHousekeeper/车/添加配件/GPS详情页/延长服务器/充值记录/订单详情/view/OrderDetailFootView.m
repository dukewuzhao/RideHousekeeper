//
//  OrderDetailFootView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/13.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "OrderDetailFootView.h"
#import "GoodServiceDetailHeadView.h"
#import "GoodServiceDetailTableViewCell.h"


@interface OrderDetailFootView()<UITableViewDelegate ,UITableViewDataSource>
@property(nonatomic,strong) ServiceOrder *model;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UIButton *moreBtn;
@property(nonatomic,strong) UILabel* currentPrice;
@property(nonatomic,strong) UILabel* discountedPriceLab;
@property(nonatomic,strong) UILabel* obtainPriceLab;
@property(nonatomic,strong) UILabel* totalPrice;



@end
@implementation OrderDetailFootView

-(void)setOrderInfo:(ServiceOrder *)model{
    _model = model;
    if (model.commodities.count > 1) {
        _moreBtn.hidden = NO;
        
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.height.mas_equalTo(30);
        }];
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([model.commodities.firstObject items].count *55 +60);
        }];
    }else{
        _moreBtn.hidden = YES;
        
        [_moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.height.mas_equalTo(1);
        }];
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([model.commodities.firstObject items].count *55 +60);
        }];
    }
    
    NSString *price = [NSString stringWithFormat:@"小计：￥%.1f",model.amount/100.0];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:price attributes:@{NSFontAttributeName: FONT_PINGFAN(17), NSForegroundColorAttributeName: [QFTools colorWithHexString:@"#FF5E00"]}];
    [string addAttributes:@{NSFontAttributeName: FONT_PINGFAN(13), NSForegroundColorAttributeName: [QFTools colorWithHexString:@"#333333"]} range:NSMakeRange(0, 3)];
    _currentPrice.attributedText = string;
    _discountedPriceLab.text = [NSString stringWithFormat:@"-￥%.1f",model.promotion_amount/100.0];
    _totalPrice.text = [NSString stringWithFormat:@"￥%.1f",model.amount/100.0];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *mainView = [[UIView alloc] init];
        mainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:mainView];
        [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [mainView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).offset(10);
            make.top.equalTo(mainView).offset(13);
            make.size.mas_equalTo(CGSizeMake(2, 16));
        }];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = @"商品信息";
        titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        titleLab.font = FONT_PINGFAN(15);
        [mainView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineView.mas_right).offset(5);
            make.centerY.equalTo(lineView);
            make.height.mas_equalTo(21);
        }];
        
        _currentPrice = [[UILabel alloc] init];
        [mainView addSubview:_currentPrice];
        [_currentPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(mainView).offset(-10);
            make.bottom.equalTo(mainView).offset(-10);
            make.height.mas_equalTo(24);
        }];
        
        
        
        UILabel* discountedLab = [[UILabel alloc] init];
        discountedLab.text = @"优惠金额";
        discountedLab.textColor = [QFTools colorWithHexString:@"#999999"];
        discountedLab.font = FONT_PINGFAN(11);
        [mainView addSubview:discountedLab];
        [discountedLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).offset(17);
            make.bottom.equalTo(_currentPrice.mas_top).offset(-20);
            make.height.mas_equalTo(16);
        }];
        
        _discountedPriceLab = [[UILabel alloc] init];
        _discountedPriceLab.text = @"-￥220";
        _discountedPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _discountedPriceLab.font = FONT_PINGFAN(11);
        [mainView addSubview:_discountedPriceLab];
        [_discountedPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(mainView).offset(-10);
            make.top.equalTo(discountedLab);
            make.height.mas_equalTo(16);
        }];
        
        UILabel* obtainLab = [[UILabel alloc] init];
        obtainLab.text = @"运费（在线充值）";
        obtainLab.textColor = [QFTools colorWithHexString:@"#999999"];
        obtainLab.font = FONT_PINGFAN(11);
        [mainView addSubview:obtainLab];
        [obtainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(discountedLab);
            make.bottom.equalTo(discountedLab.mas_top).offset(-7);
            make.height.mas_equalTo(16);
        }];
        
        _obtainPriceLab = [[UILabel alloc] init];
        _obtainPriceLab.text = @"+￥0";
        _obtainPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _obtainPriceLab.font = FONT_PINGFAN(11);
        [mainView addSubview:_obtainPriceLab];
        [_obtainPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_discountedPriceLab);
            make.top.equalTo(obtainLab);
            make.height.mas_equalTo(16);
        }];
        
        UILabel* totalGoodLab = [[UILabel alloc] init];
        totalGoodLab.text = @"商品总额";
        totalGoodLab.textColor = [QFTools colorWithHexString:@"#999999"];
        totalGoodLab.font = FONT_PINGFAN(11);
        [mainView addSubview:totalGoodLab];
        [totalGoodLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(discountedLab);
            make.bottom.equalTo(obtainLab.mas_top).offset(-7);
            make.height.mas_equalTo(16);
        }];
        
        _totalPrice = [[UILabel alloc] init];
        _totalPrice.text = @"￥340";
        _totalPrice.textColor = [QFTools colorWithHexString:@"#666666"];
        _totalPrice.font = FONT_PINGFAN(11);
        [mainView addSubview:_totalPrice];
        [_totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_discountedPriceLab);
            make.top.equalTo(totalGoodLab);
            make.height.mas_equalTo(16);
        }];
        
        UIView *secondLineView = [[UIView alloc] init];
        secondLineView.backgroundColor = [QFTools colorWithHexString:@"#06C1AE"];
        [mainView addSubview:secondLineView];
        [secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).offset(10);
            make.bottom.equalTo(totalGoodLab.mas_top).offset(-7);
            make.size.mas_equalTo(CGSizeMake(2, 16));
        }];
        
        UILabel *secondTitleLab = [[UILabel alloc] init];
        secondTitleLab.text = @"费用明细";
        secondTitleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        secondTitleLab.font = FONT_PINGFAN(15);
        [mainView addSubview:secondTitleLab];
        [secondTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(secondLineView.mas_right).offset(5);
            make.centerY.equalTo(secondLineView);
            make.height.mas_equalTo(21);
        }];
        
        
        UIView *horizontalView = [[UIView alloc] init];
        horizontalView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [mainView addSubview:horizontalView];
        [horizontalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainView).offset(6);
            make.centerX.equalTo(mainView);
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(secondTitleLab.mas_top).offset(-9);
        }];
        
        _moreBtn = [[UIButton alloc] init];
        [mainView addSubview:_moreBtn];
        [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(mainView);
            make.bottom.equalTo(horizontalView.mas_top);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.bounces = NO;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [mainView addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(mainView);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(_moreBtn.mas_top);
            make.top.equalTo(titleLab.mas_bottom).offset(5);
        }];
        
    }
    return self;
}


////

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return !_model? 1: _model.commodities.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return !_model? 1:[_model.commodities[section] items].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodServiceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodServiceDetailTableViewCell"];
    if (!cell) {
        cell = [[GoodServiceDetailTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"GoodServiceDetailTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLab.text = [(ServiceItem *)[(ServiceCommoity *)_model.commodities[indexPath.section] items][indexPath.row] title];
    cell.durationLab.text = [NSString stringWithFormat:@"%d天",[(ServiceItem *)[(ServiceCommoity *)_model.commodities[indexPath.section] items][indexPath.row] duration]];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    GoodServiceDetailHeadView *header = [[GoodServiceDetailHeadView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    header.titleLab.text = [(ServiceCommoity *)_model.commodities[section] title];
    TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[[(ServiceCommoity *)_model.commodities[section] descriptions] dataUsingEncoding:NSUTF8StringEncoding]];
    TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//text()"];
    header.descriptionLab.text = [e content];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}



- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}


@end
