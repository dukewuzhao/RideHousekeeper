//
//  CardView.h
//  RideHousekeeper
//
//  Created by Apple on 2019/10/21.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CardView : UIView

@property(nonatomic, strong)UIImageView *imageIcon;
@property(nonatomic, strong)UILabel *cardName;

-(void)setParameter:(NSInteger)bikeid :(NSInteger)type :(NSIndexPath*)selectIndex;

@end

NS_ASSUME_NONNULL_END
