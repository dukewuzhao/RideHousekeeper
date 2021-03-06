//
//  SportAnnotationView.h
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
@class SportNode;
typedef void (^ Completion)(void);

typedef void (^NextStep)(SportNode *node,NSInteger num);

@class SportNode;
@interface SportAnnotationView : BMKAnnotationView{
    @public
    NSInteger _currentIndex;   // 当前结点索引值
}

/** 轨迹点数组 */
@property (nonatomic, strong) NSArray<SportNode *> *sportNodes;
/** 轨迹回放完成回调 */
@property (nonatomic, copy) Completion completion;
@property (nonatomic, copy) NextStep nextStep;

/** 开始 */
- (void)start;

/** 暂停 */
- (void)pause;

/** 停止 */
- (void)stop;

@end
