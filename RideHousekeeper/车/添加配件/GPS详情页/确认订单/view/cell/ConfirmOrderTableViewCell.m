//
//  ConfirmOrderTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/3.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "ConfirmOrderTableViewCell.h"
#import "GoodServiceDetailTableViewCell.h"

@interface ConfirmOrderTableViewCell()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) ServiceOrder *model;
@property(nonatomic,strong) UILabel *titleLab;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UILabel* currentPrice;
@property(nonatomic,strong) UILabel* discountedPriceLab;
@property(nonatomic,strong) UILabel* obtainPriceLab;
@property(nonatomic,strong) UILabel* totalPrice;
@end

@implementation ConfirmOrderTableViewCell

-(void)setOrderInfo:(ServiceOrder *)model{
    _model = model;
    if (model.commodities.count > 1) {
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(model.commodities.count *55);
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = FONT_PINGFAN(16);
        _titleLab.textColor = [QFTools colorWithHexString:@"#333333"];
        _titleLab.text = @"骑管家平台服务包";
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(15);
            make.top.equalTo(self.contentView).offset(15);
            make.height.mas_equalTo(21);
        }];
        
        _currentPrice = [[UILabel alloc] init];
        [self.contentView addSubview:_currentPrice];
        [_currentPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-10);
            make.height.mas_equalTo(24);
        }];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-14);
            make.left.equalTo(self.contentView).offset(16);
            make.bottom.equalTo(_currentPrice.mas_top).offset(-11);
            make.height.mas_equalTo(0.5);
        }];
        
        UILabel* discountedLab = [[UILabel alloc] init];
        discountedLab.text = @"优惠金额";
        discountedLab.textColor = [QFTools colorWithHexString:@"#999999"];
        discountedLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:discountedLab];
        [discountedLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(20);
            make.bottom.equalTo(lineView.mas_top).offset(-12);
            make.height.mas_equalTo(16);
        }];
        
        _discountedPriceLab = [[UILabel alloc] init];
        _discountedPriceLab.text = @"-￥220";
        _discountedPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _discountedPriceLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:_discountedPriceLab];
        [_discountedPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(discountedLab);
            make.height.mas_equalTo(16);
        }];
        
        UILabel* obtainLab = [[UILabel alloc] init];
        obtainLab.text = @"运费（在线充值）";
        obtainLab.textColor = [QFTools colorWithHexString:@"#999999"];
        obtainLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:obtainLab];
        [obtainLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(discountedLab);
            make.bottom.equalTo(discountedLab.mas_top).offset(-7);
            make.height.mas_equalTo(16);
        }];
        
        _obtainPriceLab = [[UILabel alloc] init];
        _obtainPriceLab.text = @"+￥0";
        _obtainPriceLab.textColor = [QFTools colorWithHexString:@"#666666"];
        _obtainPriceLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:_obtainPriceLab];
        [_obtainPriceLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_discountedPriceLab);
            make.top.equalTo(obtainLab);
            make.height.mas_equalTo(16);
        }];
        
        UILabel* totalGoodLab = [[UILabel alloc] init];
        totalGoodLab.text = @"商品总额";
        totalGoodLab.textColor = [QFTools colorWithHexString:@"#999999"];
        totalGoodLab.font = FONT_PINGFAN(11);
        [self.contentView addSubview:totalGoodLab];
        [totalGoodLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(discountedLab);
            make.bottom.equalTo(obtainLab.mas_top).offset(-7);
            make.height.mas_equalTo(16);
        }];
        
        _totalPrice = [[UILabel alloc] init];
        _totalPrice.text = @"￥340";
        _totalPrice.textColor = [QFTools colorWithHexString:@"#666666"];
        _totalPrice.font = FONT_PINGFAN(11);
        [self.contentView addSubview:_totalPrice];
        [_totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_discountedPriceLab);
            make.top.equalTo(totalGoodLab);
            make.height.mas_equalTo(16);
        }];
        
        UIView *secondLineView = [[UIView alloc] init];
        secondLineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
        [self.contentView addSubview:secondLineView];
        [secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineView);
            make.right.equalTo(lineView);
            make.bottom.equalTo(totalGoodLab.mas_top).offset(-7);
            make.height.mas_equalTo(0.5);
        }];
        
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self.contentView addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(55);
            make.bottom.equalTo(secondLineView.mas_top).offset(-10);
            make.top.equalTo(_titleLab.mas_bottom).offset(5);
        }];
        
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return !_model? 1:_model.commodities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodServiceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodServiceDetailTableViewCell"];
    if (!cell) {
        cell = [[GoodServiceDetailTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"GoodServiceDetailTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLab.text = [(ServiceCommoity *)_model.commodities[indexPath.row] title];
    TFHpple * doc = [[TFHpple alloc] initWithHTMLData:[[(ServiceCommoity *)_model.commodities[indexPath.row] descriptions] dataUsingEncoding:NSUTF8StringEncoding]];
    TFHppleElement *e = [doc peekAtSearchWithXPathQuery:@"//text()"];
    cell.durationLab.text = [e content];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    return 55;
}


- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

@end
