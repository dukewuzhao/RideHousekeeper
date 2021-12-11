//
//  AccessoriesTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2018/11/21.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AccessoriesTableViewCell.h"
#import "CustomFlowLayout.h"
#import "CollectionViewCell.h"
#import "AccessoriesModel.h"
@interface AccessoriesTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *collectionArry;
@property (strong, nonatomic) NSIndexPath *tableIndex;
@property(nonatomic,strong) UILabel *annotationLab;

@end

static NSString * const CellReuseIdentify = @"CellReuseIdentify";
static NSString * const SupplementaryViewHeaderIdentify = @"SupplementaryViewHeaderIdentify";
static NSString * const SupplementaryViewFooterIdentify = @"SupplementaryViewFooterIdentify";

@implementation AccessoriesTableViewCell

-(NSMutableArray *)collectionArry{
    
    if (!_collectionArry) {
        _collectionArry = [NSMutableArray new];
        
    }
    return _collectionArry;
}

-(NSIndexPath *)tableIndex{
    
    if (!_tableIndex) {
        _tableIndex = [NSIndexPath new];
    }
    return _tableIndex;
}

-(void)setDeviceNum:(NSInteger)deviceNum{
    _deviceNum = deviceNum;
}

-(void)reloadModel:(NSMutableArray *)ary :(NSIndexPath *)index{
    //NSLog(@"-------%@",ary);
    self.collectionArry = ary;
    self.tableIndex = index;
    [self.collectionView reloadData];
}

-(void)addAnnotationLab:(NSString *)text{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    self.annotationLab.attributedText = attributedString;
    [self.annotationLab setLineBreakMode:NSLineBreakByCharWrapping];
    [self.contentView addSubview:self.annotationLab];
    [self.annotationLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 200, 20)];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLab];
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

-(UILabel *)annotationLab{
    
    if (!_annotationLab) {
        
        _annotationLab = [[UILabel alloc] init];
        _annotationLab.textColor = [QFTools colorWithHexString:@"#999999"];
        _annotationLab.font = [UIFont systemFontOfSize:13];
        [_annotationLab setNumberOfLines:0];
    }
    return _annotationLab;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

-(UICollectionView *)collectionView{
    
    if (!_collectionView) {
        
        CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
        layout.maximumInteritemSpacing = ScreenWidth * 0.186;
        layout.minimumInteritemSpacing = ScreenWidth * 0.186;
        layout.minimumLineSpacing = 10;
        layout.itemSize = CGSizeMake(65, 120);
        //    layout.headerReferenceSize = CGSizeMake(100, 10);
        //    layout.footerReferenceSize = CGSizeMake(100, 20);
        //ScreenHeight*.315+45+navHeight
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLab.frame), ScreenWidth, ScreenHeight*.25) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //注册
        [_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentify];
        //[collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellReuseIdentify];
        //UICollectionElementKindSectionHeader注册是固定的
//        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify];
//        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify];
    }
    return _collectionView;
}


#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.collectionArry.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *iconButton = cell.icon;
    NSMutableArray *keymodals = [self.collectionArry[indexPath.row] infoAry];
    if (keymodals.count == 0) {
        cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
        iconButton.image = [self.collectionArry[indexPath.row] pictureName];
        iconButton.userInteractionEnabled = NO;
    }else {
        if (indexPath.row < keymodals.count) {
            PeripheralModel *permodel = keymodals[indexPath.row];
            if (permodel.type == 2) {
                cell.textLabel.text = NSLocalizedString(@"key_model_smart", nil);
                iconButton.image = [UIImage imageNamed:@"bluetooth_have"];
                iconButton.userInteractionEnabled = YES;
                iconButton.tag = permodel.deviceid;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                longPress.numberOfTouchesRequired = 1;
                [iconButton addGestureRecognizer:longPress];
            }else if (permodel.type == 5){
                cell.textLabel.text = NSLocalizedString(@"key_model_sh", nil);
                iconButton.image = [UIImage imageNamed:@"bracelet_have"];
                iconButton.userInteractionEnabled = YES;
                iconButton.tag = permodel.deviceid;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                longPress.numberOfTouchesRequired = 1;
                [iconButton addGestureRecognizer:longPress];
            }else if (permodel.type == 3 || permodel.type == 6 || permodel.type == 7){
                
                cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
                iconButton.image = [self.collectionArry[indexPath.row] pictureName];
                if ([self.collectionArry[indexPath.row] addLongPress]) {
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }else{
                    cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
                    iconButton.image = [self.collectionArry[indexPath.row] pictureName];
                    iconButton.userInteractionEnabled = NO;
                }
            }else{
                cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
                iconButton.image = [self.collectionArry[indexPath.row] pictureName];
                iconButton.userInteractionEnabled = NO;
            }
            
        }else{
            
            cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
            iconButton.image = [self.collectionArry[indexPath.row] pictureName];
            if ([self.collectionArry[indexPath.row] addLongPress]) {
                PeripheralModel *permodel = keymodals[indexPath.row - 1];
                iconButton.userInteractionEnabled = YES;
                iconButton.tag = permodel.deviceid;
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                longPress.numberOfTouchesRequired = 1;
                [iconButton addGestureRecognizer:longPress];
            }else{
                cell.textLabel.text = [self.collectionArry[indexPath.row] titleName];
                iconButton.image = [self.collectionArry[indexPath.row] pictureName];
                iconButton.userInteractionEnabled = NO;
            }
        }
    }
    
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
//        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify forIndexPath:indexPath];
//        supplementaryView.backgroundColor = [UIColor whiteColor];
//        //for (UIView *view in supplementaryView.subviews) { [view removeFromSuperview]; }
//        return supplementaryView;
//    }
//    else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
//        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify forIndexPath:indexPath];
//        supplementaryView.backgroundColor = [UIColor whiteColor];
//        return supplementaryView;
//    }
//    return nil;
//}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 30, 5, 30);//分别为上、左、下、右
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
    
    NSString *QuerykeySql;
    if (self.tableIndex.section == 0) {
        QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'",3,self.deviceNum];
    }else if (self.tableIndex.section == 1){
        
        QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND bikeid = '%zd'", 7,self.deviceNum];
        
    }
//    else if (self.tableIndex.section == 2){
//
//        QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE (type = '%d' OR type = '%d') AND bikeid = '%zd'", 2,5,self.deviceNum];
//
//    }
    else {
        QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type = '%d' AND seq = '%zd' AND bikeid = '%zd'", 6,indexPath.row+1,self.deviceNum];
    }
    
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    if([self.delegate respondsToSelector:@selector(clickWitchItem:::)])
    {
        [self.delegate clickWitchItem:keymodals :indexPath :self.tableIndex];
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

//长按cell，显示编辑菜单 当用户长按cell时
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]
//        || [NSStringFromSelector(action) isEqualToString:@"paste:"])
//        return YES;
//    return NO;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    NSLog(@"复制之后，可以插入一个新的cell");
//}

//#pragma mark - UICollectionViewDelegateFlowLayout method
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//
//    return CGSizeMake(100, 20);
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(100, 0.1);
//}



- (void)deleteinductionKey:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan){
        if([self.delegate respondsToSelector:@selector(popDeleteView::)])
        {
            [self.delegate popDeleteView:self.collectionView :longPress];
        }
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
