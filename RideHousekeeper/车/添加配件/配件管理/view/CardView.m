//
//  CardView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/21.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "CardView.h"
#import "AccessoriesIteamCell.h"
#import "TwoDimensionalCodecanViewController.h"
#import "BindingkeyViewController.h"
#import "BindingBleKeyViewController.h"
#import "DeviceModifyViewController.h"
#import "Manager.h"

static NSString * const CellReuseIdentify = @"AccessoriesIteamCell";
@interface CardView ()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,BindingkeyDelegate,BindingBlekeyDelegate,ManagerDelegate>
@property(nonatomic, assign)NSInteger bikeid;
@property(nonatomic, assign)NSInteger type;
@property(nonatomic, assign)NSIndexPath *selectIndex;
@property(nonatomic, strong)NSMutableArray *accessoriesAry;
@property(nonatomic, strong)UIView *coverView;
@property(nonatomic, strong)UICollectionView *accessoriesListView;
@property(nonatomic, strong)BikeModel *bikeModel;
@end
@implementation CardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setParameter:(NSInteger)bikeid :(NSInteger)type :(NSIndexPath*)selectIndex{
    _selectIndex = selectIndex;
    _bikeid = bikeid;
    _type = type;
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    _bikeModel = bikemodels.firstObject;
    [self reloadListView:bikeid :type];
}

-(void)reloadListView:(NSInteger)bikeid :(NSInteger)type{
    
    if (type == 2) {
        _accessoriesAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE (type = '%zd' OR type = '%zd') AND bikeid = '%zd'",2,5,bikeid]];
    }else if (type == 6){
        NSMutableArray *arry = [NSMutableArray array];
        NSMutableArray *pressureModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND seq = '%zd' AND bikeid = '%zd'",6,1,bikeid]];
        if (pressureModals.count != 0) {
            [arry addObject:pressureModals.firstObject];
        }else{
            PeripheralModel *model = [[PeripheralModel alloc] init];
            model.type = 6;
            model.seq = 1;
            [arry addObject:model];
        }
        
        NSMutableArray *pressureModals2 = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND seq = '%zd' AND bikeid = '%zd'",6,2,bikeid]];
        if (pressureModals2.count != 0) {
            [arry addObject:pressureModals2.firstObject];
        }else{
            PeripheralModel *model = [[PeripheralModel alloc] init];
            model.type = 6;
            model.seq = 2;
            [arry addObject:model];
        }
        
        NSMutableArray *pressureModals3 = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND seq = '%zd' AND bikeid = '%zd'",6,3,bikeid]];
        if (pressureModals3.count != 0) {
            [arry addObject:pressureModals3.firstObject];
        }else{
            PeripheralModel *model = [[PeripheralModel alloc] init];
            model.type = 6;
            model.seq = 3;
            [arry addObject:model];
        }
        NSMutableArray *pressureModals4 = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND seq = '%zd' AND bikeid = '%zd'",6,4,bikeid]];
        if (pressureModals4.count != 0) {
            [arry addObject:pressureModals4.firstObject];
        }else{
            PeripheralModel *model = [[PeripheralModel alloc] init];
            model.type = 6;
            model.seq = 4;
            [arry addObject:model];
        }
        _accessoriesAry = [arry copy];
    }else{
        _accessoriesAry = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%zd' AND bikeid = '%zd'",type,bikeid]];
    }
    
    if (_accessoriesAry.count == 0 && type != 6) {
        _coverView.hidden = false;
    }else{
        _coverView.hidden = true;
    }
    [self.accessoriesListView reloadData];
}

- (instancetype)init{
    if (self = [super init]) {
        [[Manager shareManager] addDelegate:self];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self setupUI];
    }
    return self;
}

-(UICollectionView *)accessoriesListView{
    
    if (!_accessoriesListView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(40, 40);
        _accessoriesListView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _accessoriesListView.backgroundColor = [UIColor clearColor];
        _accessoriesListView.dataSource = self;
        _accessoriesListView.delegate = self;
        //注册
        [_accessoriesListView registerClass:[AccessoriesIteamCell class] forCellWithReuseIdentifier:CellReuseIdentify];

    }
    return _accessoriesListView;
}

-(void)setupUI{
    
    _imageIcon = [[UIImageView alloc] init];
    [self addSubview:_imageIcon];
    [_imageIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    _cardName = [[UILabel alloc] init];
    _cardName.font = FONT_PINGFAN(14);
    _cardName.textColor = [QFTools colorWithHexString:@"#111111"];
    [self addSubview:_cardName];
    [_cardName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_imageIcon);
        make.left.equalTo(_imageIcon.mas_right).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.accessoriesListView];
    [self.accessoriesListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(_imageIcon.mas_bottom);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        
    }];
    
    _coverView = [[UIView alloc] init];
    _coverView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_coverView];
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(_imageIcon.mas_bottom);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        
    }];
    
    UIButton *addBtn = [[UIButton alloc] init];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"icon_add_accessories"] forState:UIControlStateNormal];
    [_coverView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_coverView);
        make.centerY.equalTo(_coverView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    _coverView.hidden = true;
    @weakify(self);
    [[addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        
        if (![CommandDistributionServices isConnect]) {
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return;
        }
        
        if (self.selectIndex.row == 0) {
            BindingBleKeyViewController *vc = [[BindingBleKeyViewController alloc] init];
            vc.deviceNum = self.bikeid;
            vc.seq = 1;
            vc.delegate = self;
            [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
        }else {
            TwoDimensionalCodecanViewController *vc = [[TwoDimensionalCodecanViewController alloc] init];
            vc.naVtitle = @"添加配件";
            vc.bikeid = self.bikeid;
            vc.type = self.type;
            vc.seq = 1;
            [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
        }
    }];
    
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (_selectIndex.row == 0) {
        
        if (_accessoriesAry.count>=2) {
            return 2;
        }else{
            return _accessoriesAry.count +1;
        }
        
    }else if (_selectIndex.row == 1){
        return _accessoriesAry.count +1;
    }else {
        
        if (_bikeModel.wheels == 0) {
            return 2;
        }else if (_bikeModel.wheels == 1){
            return 3;
        }else if (_bikeModel.wheels == 2){
            return 4;
        }else{
            return _accessoriesAry.count;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AccessoriesIteamCell *cell = (AccessoriesIteamCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    if (indexPath.row<_accessoriesAry.count) {
        PeripheralModel *model = _accessoriesAry[indexPath.row];
        if (model.type == 2) {
            cell.icon.image = [UIImage imageNamed:@"icon_ble_key"];
        }else if (model.type == 5){
            cell.icon.image = [UIImage imageNamed:@"icon_bracelet_key"];
        }else if (model.type == 6){
            
            if (_bikeModel.wheels == 0) {
                
                if (model.seq == 1) {
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_frontlwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_frontlwheel"];
                    }
                    
                }else if (model.seq == 2){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_realwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_realwheel"];
                    }
                }
                
            }else if (_bikeModel.wheels == 1){
                
                if (model.seq == 1) {
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_frontlwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_frontlwheel"];
                    }
                    
                }else if (model.seq == 2){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_left_realwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_left_realwheel"];
                    }
                    
                }else if (model.seq == 3){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_right_realwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_right_realwheel"];
                    }
                }
                
            }else if (_bikeModel.wheels == 2){
                
                if (model.seq == 1) {
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_left_frontlwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_left_frontlwheel"];
                    }
                    
                }else if (model.seq == 2){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_right_frontlwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_right_frontlwheel"];
                    }
                    
                }else if (model.seq == 3){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_left_realwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_left_realwheel"];
                    }
                    
                }else if (model.seq == 4){
                    
                    if (model.bikeid == 0) {
                        cell.icon.image = [UIImage imageNamed:@"nomal_peripheral_pressure_right_realwheel"];
                    }else{
                        cell.icon.image = [UIImage imageNamed:@"peripheral_pressure_right_realwheel"];
                    }
                }
            }
        }else if (model.type == 7){
            cell.icon.image = [UIImage imageNamed:@"icon_new_ble_key"];
        }
    }else{
        cell.icon.image = [UIImage imageNamed:@"icon_add_accessories"];
    }
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 5, 10);//分别为上、左、下、右
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<_accessoriesAry.count) {
        
        PeripheralModel *model = _accessoriesAry[indexPath.row];
        
        if (model.bikeid == 0) {
            TwoDimensionalCodecanViewController *vc = [[TwoDimensionalCodecanViewController alloc] init];
            vc.naVtitle = @"添加配件";
            vc.bikeid = _bikeid;
            vc.type = model.type;
            vc.seq = model.seq;
            [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
            return;
        }
        
        DeviceModifyViewController *vc = [[DeviceModifyViewController alloc] init];
        vc.deviceNum = model.bikeid;
        vc.deviceId = model.deviceid;
        vc.sn = model.sn;
        [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
    }else{
        
        if (_selectIndex.row == 0) {
            
            BindingBleKeyViewController *vc = [[BindingBleKeyViewController alloc] init];
            vc.deviceNum = _bikeid;
            vc.seq = indexPath.row +1;
            vc.delegate = self;
            [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
        }else{
            TwoDimensionalCodecanViewController *vc = [[TwoDimensionalCodecanViewController alloc] init];
            vc.naVtitle = @"添加配件";
            vc.bikeid = _bikeid;
            vc.type = _type;
            vc.seq = indexPath.row + 1;
            [[QFTools viewController:self].navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
}

////长按cell，显示编辑菜单 当用户长按cell时
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"])
//        return YES;
//    return NO;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    NSLog(@"复制之后，可以插入一个新的cell");
//}
//
//#pragma mark - UICollectionViewDelegateFlowLayout method
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//
//    return CGSizeMake(100, 0.1);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(100, 0.1);
//}

#pragma mark - ManagerDelegate
-(void)manager:(Manager *)manager bindingPeripheralSucceeded:(PeripheralModel *)model{
    
    [self reloadListView:_bikeid :_type];
}

-(void)manager:(Manager *)manager deletePeripheralSucceeded:(PeripheralModel *)model{
    
    [self reloadListView:_bikeid :_type];
}

-(void)dealloc{
    
    [[Manager shareManager] deleteDelegate:self];
}

- (void)bidingKeyOver {
    [self reloadListView:_bikeid :_type];
}

- (void)bidingBleKeyOver {
    [self reloadListView:_bikeid :_type];
}



@end
