/*
 * QRCodeReaderViewController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "QRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>
#import "BottomBtn.h"
#define widthRate ScreenWidth/320

#define contentTitleColorStr @"#000000" //正文颜色较深

@interface QRCodeReaderView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession * session;
    
}
@property (nonatomic, strong) CAShapeLayer *overlay;
@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {

        [self instanceDevice];
  }
  
  return self;
}

- (void)instanceDevice
{
    //扫描区域
    UIImageView * scanZomeBack=[[UIImageView alloc] init];
    scanZomeBack.backgroundColor = [UIColor clearColor];
//    scanZomeBack.layer.borderColor = [UIColor whiteColor].CGColor;
//    scanZomeBack.layer.borderWidth = 2.5;
    scanZomeBack.image = [UIImage imageNamed:@"scan_Bg"];
    //添加一个背景图片
    CGRect mImagerect = CGRectMake(60*widthRate, (ScreenHeight-navHeight-200*widthRate)/2 -ScreenHeight *0.096, 200*widthRate, 200*widthRate);
    [scanZomeBack setFrame:mImagerect];
    CGRect scanCrop=[self getScanCrop:mImagerect readerViewBounds:self.frame];
    [self addSubview:scanZomeBack];
    
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.rectOfInterest = scanCrop;
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [session addInput:input];
    }
    if (output) {
        [session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    [self setOverlayPickerView:self];
    //开始捕获
    [session startRunning];
    [self loopDrawLine];
}

-(void)loopDrawLine{
    
    //_is_AnmotionFinished = NO;
    CGRect rect = CGRectMake(60*widthRate, (ScreenHeight-navHeight-200*widthRate)/2-10 -ScreenHeight *0.096, 200*widthRate, 20);
    if (_readLineView) {
        _readLineView.alpha = 1;
        _readLineView.frame = rect;
    }else{
        _readLineView = [[UIImageView alloc] initWithFrame:rect];
        [_readLineView setImage:[UIImage imageNamed:@"scanLine"]];
        [self addSubview:_readLineView];
    }
    
//    [UIView animateWithDuration:1.5 animations:^{
//        //修改frame的代码写在这里
//        _readLineView.frame =CGRectMake(60*widthRate, (ScreenHeight-navHeight-200*widthRate)/2+200*widthRate-20 - ScreenHeight *0.096, 200*widthRate, 20);
//    } completion:^(BOOL finished) {
//        if (!_is_Anmotion) {
//            [self loopDrawLine];
//        }
//        //_is_AnmotionFinished = YES;
//    }];
    
    [self qresumeLayer:_readLineView.layer];
    
}

- (void)setOverlayPickerView:(QRCodeReaderView *)reader
{
    
    CGFloat wid = 60*widthRate;
    CGFloat heih = (ScreenHeight-navHeight-200*widthRate)/2 - ScreenHeight *0.096;
    
    //最上部view
    CGFloat alpha = 0.3;
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, heih)];
    upView.alpha = alpha;
    upView.backgroundColor = [QFTools colorWithHexString:contentTitleColorStr];
    [reader addSubview:upView];
    
    //左侧的view
    UIView * cLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, heih, wid, 200*widthRate)];
    cLeftView.alpha = alpha;
    cLeftView.backgroundColor = [QFTools colorWithHexString:contentTitleColorStr];
    [reader addSubview:cLeftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth-wid, heih, wid, 200*widthRate)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [QFTools colorWithHexString:contentTitleColorStr];
    [reader addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, heih+200*widthRate, ScreenWidth, ScreenHeight-navHeight-heih-200*widthRate)];
    downView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [reader addSubview:downView];
    
    //用于说明的label
    UILabel * PromptLab= [[UILabel alloc] init];
    PromptLab.backgroundColor = [UIColor clearColor];
    PromptLab.frame=CGRectMake(0, 40, ScreenWidth, 40);
    PromptLab.textAlignment = NSTextAlignmentCenter;
    PromptLab.textColor=[UIColor whiteColor];
    PromptLab.font = [UIFont systemFontOfSize:15];
    PromptLab.text=  NSLocalizedString(@"scan_content", nil);
    PromptLab.numberOfLines = 0;
    [downView addSubview:PromptLab];
    
    //开关灯button
//    UIButton * turnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    turnBtn.backgroundColor = [UIColor clearColor];
//    [turnBtn setBackgroundImage:[UIImage imageNamed:@"lightSelect"] forState:UIControlStateNormal];
//    [turnBtn setBackgroundImage:[UIImage imageNamed:@"lightNormal"] forState:UIControlStateSelected];
//    turnBtn.frame=CGRectMake((DeviceMaxWidth-50*widthRate)/2, (CGRectGetHeight(downView.frame)-50*widthRate)/2, 50*widthRate, 50*widthRate);
//    [turnBtn addTarget:self action:@selector(turnBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
//    [downView addSubview:turnBtn];
    
    BottomBtn *SetupBtn = [[BottomBtn alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 80, downView.height * .513, 160, 35)];
    [SetupBtn setTitle:NSLocalizedString(@"change_sn", nil) forState:UIControlStateNormal];
    [SetupBtn setTitleColor:[QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)] forState:UIControlStateNormal];
    [SetupBtn setImage:[UIImage imageNamed:@"input"] forState:UIControlStateNormal];
    SetupBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    SetupBtn.contentMode = UIViewContentModeCenter;
    [SetupBtn addTarget:self action:@selector(SetupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    SetupBtn.backgroundColor = [UIColor clearColor];
    [downView addSubview:SetupBtn];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(SetupBtn.x, CGRectGetMaxY(SetupBtn.frame)-5, SetupBtn.width, 1)];
    partingline.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    [downView addSubview:partingline];
}

-(void)SetupBtnClick{
    
    if (_delegate && [_delegate respondsToSelector:@selector(SetupBtnClickTrue)]) {
        [_delegate SetupBtnClickTrue];
    }
}

- (void)turnBtnEvent:(UIButton *)button_
{
    button_.selected = !button_.selected;
    if (button_.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}

- (void)turnTorchOn:(bool)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    
    CGFloat x,y,width,height;
    
//    width = (CGFloat)(rect.size.height+10)/readerViewBounds.size.height;
//    
//    height = (CGFloat)(rect.size.width-50)/readerViewBounds.size.width;
//    
//    x = (1-width)/2;
//    y = (1-height)/2;
    
    x = (CGRectGetHeight(readerViewBounds)-CGRectGetHeight(rect))/2/CGRectGetHeight(readerViewBounds);
    y = (CGRectGetWidth(readerViewBounds)-CGRectGetWidth(rect))/2/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
    
}

- (void)start
{
    [session startRunning];
}

- (void)stop
{
    [session stopRunning];
}

#pragma mark - 扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects && metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        if (_delegate && [_delegate respondsToSelector:@selector(readerScanResult:)]) {
            [_delegate readerScanResult:metadataObject.stringValue];
        }
    }
}

#pragma mark - 颜色
//获取颜色
- (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

-(void)qpauseLayer:(CALayer*)layer
{
    layer.hidden = YES;
    [layer removeAnimationForKey:@"PostionKeyframeValueAni"];
}

-(void)qresumeLayer:(CALayer*)layer {
    layer.hidden = NO;
    CAKeyframeAnimation * ani = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    ani.duration = 2.0;
    ani.removedOnCompletion = NO;
    ani.repeatCount = HUGE_VALF;
    ani.fillMode = kCAFillModeForwards;
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    NSValue *value1 = [NSValue valueWithCGPoint:CGPointMake(_readLineView.centerX, _readLineView.centerY - 5)];
    NSValue *value2 = [NSValue valueWithCGPoint:CGPointMake(_readLineView.centerX, _readLineView.centerY + 200*widthRate - 10)];
    ani.values = @[value1, value2];
    [layer addAnimation:ani forKey:@"PostionKeyframeValueAni"];
}

@end
