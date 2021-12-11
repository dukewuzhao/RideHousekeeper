//
//  ModelInfo.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelInfo : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger modelid;//车辆型号id
@property (nonatomic, copy) NSString *modelname;//品牌型号
@property (nonatomic, assign) NSInteger batttype;//电池型号
@property (nonatomic, assign) NSInteger battvol;//电池电压
@property (nonatomic, assign) NSInteger wheelsize;//车轮尺寸
@property (nonatomic, assign) NSInteger brandid;//车辆品牌id
@property (nonatomic, copy) NSString *pictures;//车辆大图
@property (nonatomic, copy) NSString *pictureb;//车辆小图


+ (instancetype)modalWith:(NSInteger)bikeid modelid:(NSInteger)modelid modelname:(NSString *)modelname batttype:(NSInteger )batttype battvol:(NSInteger)battvol wheelsize:(NSInteger)wheelsize brandid:(NSInteger)brandid pictures:(NSString *)pictures pictureb:(NSString *)pictureb;

@end
