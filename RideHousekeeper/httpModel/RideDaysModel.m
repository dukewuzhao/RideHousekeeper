//
//  RideDaysModel.m
//  RideHousekeeper
//
//  Created by Apple on 2020/1/14.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "RideDaysModel.h"


@implementation RideDaysModel

+ (NSArray *)jsonsToModelsWithJsons:(NSArray *)jsons {
    NSMutableArray *models = [NSMutableArray array];
    for (NSDictionary *json in jsons) {
        id model = [RideOneDayModel yy_modelWithJSON:json];
        if (model) {
            [models addObject:model];
        }
    }
    return models;
}

@end

@implementation RideOneDayModel

@end

@implementation RideDaysSummaryModel

@end
