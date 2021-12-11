//
//  SmartAccessoriesListTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "SmartAccessoriesListTableViewCell.h"
#import "CardCollectionViewCell.h"
#import "CustomFlowLayout.h"
static NSString * const CellReuseIdentify = @"cardIteamCell";

@interface SmartAccessoriesListTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    NSInteger tableNum;
}
@property (strong, nonatomic) UICollectionView *cardCollectionView;
@end

@implementation SmartAccessoriesListTableViewCell

-(void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    BikeModel *bikeModel = bikemodels.firstObject;
    if (bikeModel.tpm_func == 1) {
        tableNum = 3;
    }else{
        tableNum = 2;
    }
    
    [self.cardCollectionView reloadData];
}

-(UICollectionView *)cardCollectionView{
    
    if (!_cardCollectionView) {
        
        CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
        layout.maximumInteritemSpacing = 10;
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake((ScreenWidth - 25)/2, 130);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _cardCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _cardCollectionView.showsVerticalScrollIndicator = false;
        _cardCollectionView.showsHorizontalScrollIndicator = false;
        _cardCollectionView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
        _cardCollectionView.dataSource = self;
        _cardCollectionView.delegate = self;
        [_cardCollectionView registerClass:[CardCollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentify];
        
    }
    return _cardCollectionView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.cardCollectionView];
        [self.cardCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return tableNum;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CardCollectionViewCell *cell = (CardCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.cardView.imageIcon.image = [UIImage imageNamed:@"icon_smart_key"];
        cell.cardView.cardName.text = @"智能钥匙";
        [cell.cardView setParameter:_bikeid :7 :indexPath];
    }else if (indexPath.row == 1){
        cell.cardView.imageIcon.image = [UIImage imageNamed:@"icon_smart_accessories"];
        cell.cardView.cardName.text = @"智能配件";
        [cell.cardView setParameter:_bikeid :2 :indexPath];
    }else if (indexPath.row == 2){
        cell.cardView.imageIcon.image = [UIImage imageNamed:@"icon_tire_pressure_monitor"];
        cell.cardView.cardName.text = @"胎压监测";
        [cell.cardView setParameter:_bikeid :6 :indexPath];
    }
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
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


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
