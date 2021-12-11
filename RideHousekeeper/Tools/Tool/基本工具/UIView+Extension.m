
#import "UIView+Extension.h"

@implementation UIView (Extension)
- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

-(CAShapeLayer *)UiviewRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii{
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

-(CGSize)getViewSize:(NSString *) title :(UIFont *)font{
    
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: font}];
    //ceilf()向上取整函数, 只要大于1就取整数2. floor()向下取整函数, 只要小于2就取整数1.
    CGSize adaptionSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return adaptionSize;
}

- (CGSize) boundingRectWithSize:(NSString*) txt Font:(UIFont*) font Size:(CGSize) size
{
    
    CGSize _size;
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    
    NSStringDrawingUsesLineFragmentOrigin |
    
    NSStringDrawingUsesFontLeading;
    
    _size = [txt boundingRectWithSize:size options: options attributes:attribute context:nil].size;
    
#else
    
    _size = [txt sizeWithFont:font constrainedToSize:size];
    
#endif
    
    return _size;
    
}

//获取lbl宽度
- (float)getLabelWidthFont:(float)font andSTR:(NSString *)theText andLblSize:(CGSize)lblSize
{
    NSDictionary *textDict = @{NSFontAttributeName : [UIFont systemFontOfSize:font]};
    CGRect textRect = [theText boundingRectWithSize:CGSizeMake(lblSize.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textDict context:nil];
    return textRect.size.width;
}
//获取lbl高度
- (float)getLabelHeightFont:(float)font andSTR:(NSString *)theText andLblSize:(CGSize)lblSize
{
    NSDictionary *textDict = @{NSFontAttributeName : [UIFont systemFontOfSize:font]};
    CGRect textRect = [theText boundingRectWithSize:CGSizeMake(lblSize.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:textDict context:nil];
    return textRect.size.height;
}

-(void)UIviewSetShadow:(UIView *)view ShadowColor:(UIColor *)color ShadowOffset:(CGSize) size ShadowOpacity:(float)opacity shadowRadius:(float)radius {
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = size;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
    view.layer.shadowPath = shadowPath.CGPath;
    
}

#pragma mark -  改变label中部分字体的颜色和字体大小
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

@end
