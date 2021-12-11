//
//  WZHTapGestureRecognizer.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/14.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "WZHTapGestureRecognizer.h"

@interface WZHTapGestureRecognizer()<UIGestureRecognizerDelegate>

@property(nonatomic,assign) int disableGestures;
@property(nonatomic,assign) CFTimeInterval timeStamp;

@end

@implementation WZHTapGestureRecognizer

//-(instancetype)initWithTarget:(id)target action:(SEL)action{
//    return [super initWithTarget:target action:action];
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ( self.disableGestures){
        if (CACurrentMediaTime() - self.timeStamp < 0.6 ) return NO;
        self.disableGestures = NO;
        self.timeStamp = CACurrentMediaTime();
    }else{
        self.disableGestures = YES;
        self.timeStamp = CACurrentMediaTime();
    }
    return YES;
}

@end
