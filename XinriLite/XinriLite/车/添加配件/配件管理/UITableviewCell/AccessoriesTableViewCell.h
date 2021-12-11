//
//  AccessoriesTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2018/11/21.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AccessoriesTableViewCellDelegate <NSObject>

@optional

-(void) clickWitchItem:(NSMutableArray *)keymodals :(NSIndexPath *)index :(NSIndexPath *)tableIndex;

-(void) popDeleteView:(UICollectionView *)collectView :(UILongPressGestureRecognizer *)longPress ;

@end

@interface AccessoriesTableViewCell : UITableViewCell
@property (copy, nonatomic) UILabel *titleLab;
@property(nonatomic,assign) NSInteger deviceNum;
@property (nonatomic,weak) id<AccessoriesTableViewCellDelegate> delegate;

-(void)addAnnotationLab:(NSString *)text;
-(void)reloadModel:(NSMutableArray *)ary :(NSIndexPath *)index ;
@end

NS_ASSUME_NONNULL_END
