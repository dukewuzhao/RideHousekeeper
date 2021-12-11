//
//  SportAnnotationView.m
//  TrackPlayback
//
//  Created by 张日奎 on 2017/11/30.
//  Copyright © 2017年 bestdew. All rights reserved.
//

#import "SportAnnotationView.h"
#import "SportNode.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
@interface SportAnnotationView (){
    NSInteger _animationState; // 标识动画状态 (0:动画未开始 1:动画中 2:动画暂停 3:动画完成)
}
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SportAnnotationView

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
}

#pragma mark -- 初始化
- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.bounds = CGRectMake(0.f, 0.f, 22.f, 22.f);
        self.draggable = NO;
        
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(10, 15.7));
        }];
        _currentIndex = 1;
        _animationState = 0;
        
    }
    return self;
}

#pragma mark -- Method
- (void)start
{
    switch (_animationState) {
        case 0:
            [self running];
            break;
        case 1:
            break;
        case 2: {
            [self resume];
            break;
        }
        case 3:
            [self reset];
            [self running];
            break;
    }
}

- (void)pause
{
    _animationState = 2;
    
    // 将当前时间CACurrentMediaTime转换为layer上的时间, 即将parent time转换为local time
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置layer的timeOffset, 在继续操作也会使用到
    self.layer.timeOffset = pauseTime;
    self.paopaoView.layer.timeOffset = pauseTime;
    // local time与parent time的比例为0, 意味着local time暂停了
    self.layer.speed = 0;
    self.paopaoView.layer.speed = 0;
}

- (void)stop
{
    _animationState = 0;
    [self.layer removeAllAnimations];
    [self.paopaoView.layer removeAnimationForKey:@"position"];
    [self reset];
}

- (void)resume
{
    // 时间转换
    CFTimeInterval pauseTime = self.layer.timeOffset;
    // 计算暂停时间
    CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime; //CACurrentMediaTime() - pauseTime;
    // 取消
    self.layer.timeOffset = 0;
    self.paopaoView.layer.timeOffset = 0;
    // local time相对于parent time世界的beginTime
    self.layer.beginTime = timeSincePause;
    self.paopaoView.layer.beginTime = timeSincePause;
    // 继续
    self.layer.speed = 1;
    self.paopaoView.layer.speed = 1;
    _animationState = 1;
}

#pragma mark -- Other
- (void)running
{
    _animationState = 1;
    if (_currentIndex == 0) _currentIndex = 1;
    SportNode *node_1 = _sportNodes[_currentIndex - 1];
    [UIView animateWithDuration:0.3 animations:^{
        self.imageView.transform = CGAffineTransformMakeRotation(node_1.angle);
    }];
    //NSLog(@"%.2f计算时间", node_1.distance / node_1.speed);
    if (_currentIndex == _sportNodes.count) {
        _animationState = 3;
        if (self.completion) self.completion();
        return;
    }
    SportNode *node_2 = _sportNodes[_currentIndex];
    if (self.nextStep) self.nextStep(node_2,_currentIndex);
    NSInteger second = node_2.ts - node_1.ts;
    [UIView animateWithDuration:second/10.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        self.annotation.coordinate = node_2.coordinate;
    } completion:^(BOOL finished) {
        if (_animationState == 1) {
            _currentIndex ++;
            [self running];
        }
    }];
}

- (void)reset
{
    _currentIndex = 1;
    
    SportNode *node = [_sportNodes firstObject];
    self.annotation.coordinate = node.coordinate;
    self.imageView.transform = CGAffineTransformMakeRotation(node.angle);
    
    self.layer.timeOffset = 0;
    self.paopaoView.layer.timeOffset = 0;
    self.layer.beginTime = 0;
    self.paopaoView.layer.beginTime = 0;
    self.layer.speed = 1;
    self.paopaoView.layer.speed = 1;
    
    _animationState = 0;
}

-(float)setuImageAngle:(SportNode *)node1 node2:(SportNode *)node2{
    
    float angle = 0.0;
    double s = [self getBearingWithLat1:node1.coordinate.latitude whitLng1:node1.coordinate.longitude whitLat2:node2.coordinate.latitude whitLng2:node2.coordinate.longitude];
    double fabs(double s);
    s =fabs(s);
    if(node2.coordinate.latitude < node1.coordinate.latitude){
        s = 180-s;
    }
    angle = ( M_PI / 180 * (s));
    if (node2.coordinate.longitude < node1.coordinate.longitude) {
        angle = (M_PI*2 - angle);
    }
    return angle;
}

#pragma mark -- Setter && Getter
- (void)setSportNodes:(NSArray<SportNode *> *)sportNodes
{
    _sportNodes = sportNodes;
    if (sportNodes.count >=2) {
        
        for (int i = 1;i<sportNodes.count;i++) {
            CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate([sportNodes[i-1] coordinate]),BMKMapPointForCoordinate([sportNodes[i] coordinate]));
            float speed = distance/([sportNodes[i] ts] - [sportNodes[i - 1] ts]);
            //NSLog(@"行驶距离%.1f----行驶时间%d",distance,([sportNodes[i] ts] - [sportNodes[i-1] ts]));
            SportNode *node = sportNodes[i - 1];
            node.distance = distance;
            node.speed = speed;
            node.angle = [self setuImageAngle:sportNodes[i - 1] node2:sportNodes[i]];
            //NSLog(@"当前车速%.1f----计算车速%.1f",speed,node.speed);
        }
    }
    SportNode *node = [self.sportNodes firstObject];
    self.imageView.transform = CGAffineTransformMakeRotation(node.angle);
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"icon_sport_arrow"];
    }
    return _imageView;
}

-(double)getBearingWithLat1:(double)lat1 whitLng1:(double)lng1 whitLat2:(double)lat2 whitLng2:(double)lng2{

    double d = 0;
    double radLat1 = [self radian:lat1];
    double radLat2 = [self radian:lat2];
    double radLng1 = [self radian:lng1];
    double radLng2 = [self radian:lng2];

    d = sin(radLat1)*sin(radLat2)+cos(radLat1)*cos(radLat2)*cos(radLng2-radLng1);
    d = sqrt(1-d*d);
    d = cos(radLat2)*sin(radLng2-radLng1)/d;
    d =  [self angle:asin(d)];

    return d;
}

-(double)radian:(double)d{

    return d * M_PI/180.0;
}

//根据弧度计算角度
-(double)angle:(double)r{

    return r * 180/M_PI;
}

-(void)dealloc{
    [self stop];
}

@end
