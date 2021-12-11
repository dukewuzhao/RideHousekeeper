//
//  TailSwitch.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/1.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "TailSwitch.h"

@implementation TailSwitch

//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event{
//
//
//    return NO;
//}
//
//
//- (void)switchClicked:(UISwitch *)sender withEvent:(UIEvent *)event
//{
//    NSLog(@"被调用---%d-----",sender.on);
//    NSLog(@"---%d-----",sender.on);
//}
//
//- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
//
//}

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
//
//    return YES;
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //UIView *hitView = [super hitTest:point withEvent:event];
    CGPoint btnP = [self convertPoint:point toView:self];
    if ([self pointInside:btnP withEvent:event]) {
        if (![CommandDistributionServices isConnect]) {
            [SVProgressHUD showSimpleText:@"车辆未连接"];
            return nil;
        }
        return [super hitTest:point withEvent:event];
    }
    return [super hitTest:point withEvent:event];
}

@end
