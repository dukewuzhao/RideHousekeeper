//
//  adressModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/3/2.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface adressModel : NSObject

@property (nonatomic,copy) NSString *placename;
@property(nonatomic,copy)  NSString* adress;
@property(nonatomic,copy)  NSString* city;
@property(nonatomic)  CLLocationCoordinate2D destinationCoor;

@end
