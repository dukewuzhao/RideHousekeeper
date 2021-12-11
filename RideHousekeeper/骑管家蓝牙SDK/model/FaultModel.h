//
//  FaultModel.h
//  myTest
//
//  Created by Apple on 2019/6/21.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaultModel : NSObject

@property(nonatomic, assign) NSInteger motorfault;//电机故障

@property(nonatomic, assign) NSInteger rotationfault;

@property(nonatomic, assign) NSInteger controllerfault;

@property(nonatomic, assign) NSInteger brakefault;

@property(nonatomic, assign) NSInteger lackvoltage;

@property(nonatomic, assign) NSInteger motordefectNum;

@end

NS_ASSUME_NONNULL_END
