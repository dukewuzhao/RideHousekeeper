//
//  MainScrollerView.m
//  RideHousekeeper
//
//  Created by Apple on 2020/5/14.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "MainScrollerView.h"

@interface MainScrollerView ()<UIScrollViewDelegate>

@end

@implementation MainScrollerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [QFTools colorWithHexString:MainColor];
        self.delegate = self;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0) {
        [scrollView setContentOffset:CGPointZero];
    }
    
}
//开始拖拽的时候停止计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}
//结束拖拽的时候开始定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}
//结束拖拽的时候更新image内容
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}
//scroll滚动动画结束的时候更新image内容
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

@end
