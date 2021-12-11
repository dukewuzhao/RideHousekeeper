
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface UIView (Extension)
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;

@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;

//设置圆角
-(CAShapeLayer *)UiviewRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
//lable的长度自适应（适用于单行）
-(CGSize)getViewSize:(NSString *) title :(UIFont *)font;

/** 获得字符串大小 */
- (CGSize) boundingRectWithSize:(NSString*) txt Font:(UIFont*) font Size:(CGSize) size;

- (float)getLabelWidthFont:(float)font andSTR:(NSString *)theText andLblSize:(CGSize)lblSize;

- (float)getLabelHeightFont:(float)font andSTR:(NSString *)theText andLblSize:(CGSize)lblSize;

/** 设置阴影 shadowOpacity:透明度*/
-(void)UIviewSetShadow:(UIView *)view ShadowColor:(UIColor *)color ShadowOffset:(CGSize)size ShadowOpacity:(float)opacity shadowRadius:(float)radius;

-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor;

@end
