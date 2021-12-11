//
//  RequestModel.h
//  RideHousekeeper
//
//  Created by Apple on 2019/11/19.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^successBlock)(id dict);
typedef void(^failureBlock)(NSError *);
@interface RequestModel : NSObject

@property(nonatomic, copy)      NSString *url;
@property(nonatomic, strong)    id parameters;
@property(nonatomic, copy)      successBlock success;
@property(nonatomic, copy)      failureBlock failure;
@end

NS_ASSUME_NONNULL_END
