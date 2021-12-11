//
//  LrdOutputView.h
//  LrdOutputView
//
//  Created by 键盘上的舞者 on 4/14/16.
//  Copyright © 2016 键盘上的舞者. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissWithOperation)();
typedef void(^didSelectedAtIndexPath)(NSIndexPath *indexPath);

typedef NS_ENUM(NSUInteger, LrdOutputViewDirection) {
    kLrdOutputViewDirectionLeft = 1,
    kLrdOutputViewDirectionRight,
    kLrdOutputViewDirectionCenter
};

@interface LrdOutputView : UIView

@property (nonatomic, copy) dismissWithOperation dismissOperation;
@property (nonatomic, copy) didSelectedAtIndexPath selectedIndexPath;

//初始化方法
//传入参数：模型数组，弹出原点，宽度，高度（每个cell的高度）
- (instancetype)initWithDataArray:(NSArray *)dataArray
                           origin:(CGPoint)origin
                            width:(CGFloat)width
                           height:(CGFloat)height
                        direction:(LrdOutputViewDirection)direction;

//弹出
- (void)pop;
//消失
- (void)dismiss;

@end


@interface LrdCellModel : NSObject

@property (nonatomic, copy) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end
