//
//  ShoppingTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2020/3/10.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickBtn)(void);
@interface ShoppingTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *mainIcon;
@property(nonatomic,strong)UILabel *mainTitle;
@property(nonatomic,strong)UILabel *usageLab;
@property(nonatomic,strong)UILabel *promptLab;
@property(nonatomic,strong)UILabel *savePriceLab;
@property(nonatomic,strong)UILabel *currentPriceLab;
@property(nonatomic,strong)UILabel *originalPriceLab;
@property(copy,nonatomic)ClickBtn clickBtn;

@end

NS_ASSUME_NONNULL_END
