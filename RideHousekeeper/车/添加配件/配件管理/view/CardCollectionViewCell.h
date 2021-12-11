//
//  CardCollectionViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/22.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"
NS_ASSUME_NONNULL_BEGIN

@interface CardCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) CardView *cardView;
@end

NS_ASSUME_NONNULL_END
