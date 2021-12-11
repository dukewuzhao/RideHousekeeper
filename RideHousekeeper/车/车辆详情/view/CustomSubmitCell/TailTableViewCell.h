//
//  TailTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2019/8/1.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TailTableViewCell : UITableViewCell
@property(nonatomic,assign)     NSInteger deviceNum;
@property(nonatomic,copy)       NSString* shockState;
@property(nonatomic, strong)    UITableView *tailView;

-(void)reloadModel:(NSMutableArray *)ary :(NSIndexPath *)index;
@end

NS_ASSUME_NONNULL_END
