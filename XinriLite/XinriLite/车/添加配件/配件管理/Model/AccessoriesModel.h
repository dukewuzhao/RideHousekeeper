//
//  AccessoriesModel.h
//  RideHousekeeper
//
//  Created by Apple on 2018/11/22.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccessoriesModel : NSObject

@property (strong, nonatomic) NSMutableArray *infoAry;
@property (strong, nonatomic) UIImage* pictureName;
@property (copy, nonatomic) NSString* titleName;
@property (assign, nonatomic) BOOL addLongPress;
@end

NS_ASSUME_NONNULL_END
