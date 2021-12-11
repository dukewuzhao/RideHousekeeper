//
//  QRViewController.m
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import "TwoDimensionalCodecanViewController.h"
#import "ManualInputViewController.h"
#import "BottomBtn.h"
#import "QRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "Manager.h"


@interface TwoDimensionalCodecanViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    QRCodeReaderView * readview;//二维码扫描对象
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}
@property(nonatomic,strong) DeviceInfoModel *deviceInfoModel;
@end

@implementation TwoDimensionalCodecanViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirst || isPush) {
        if (readview) {
            [self reStartScan];
        }
    }
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
    [self checkCameraPermissions];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceInfoModel = [DeviceInfoModel new];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavView];
//    [self configureRightBarButtonWithTitle:@"相册" action:^{
//        @strongify(self);
//        [self alumbBtnEvent];
//    }];
    isFirst = YES;
    isPush = NO;
    [self InitScan];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"bind_smart_accessories", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)bindKey{
    
    PeripheralModel *pmodel = [PeripheralModel modalWith:_deviceNum deviceid:_seq + 30 type:_deviceInfoModel.type seq:_deviceInfoModel.seq mac:_deviceInfoModel.sn sn:_deviceInfoModel.sn firmversion:@""];
    [LVFmdbTool insertDeviceModel:pmodel];
    [[Manager shareManager] bindingPeripheralSucceeded:pmodel];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reStartScan) object:nil];
    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_success", nil)];
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        ALAuthorizationStatus  author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            
            if (IOS8) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:@"未开启访问相册权限，现在去开启！" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if (@available(iOS 10.0, *)) {
                        NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                        [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                    } else {
                        // Fallback on earlier versions
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alert addAction:action1];
                [alert addAction:action2];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
                
            }
            return;
        }
    }
    
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    [[[[AppDelegate currentAppDelegate] window] rootViewController] presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
}

-(void)checkCameraPermissions{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 用户是否允许摄像头使用
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusRestricted|| authorizationStatus == PHAuthorizationStatusDenied) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:@"未开启访问相册权限，现在去开启！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if (@available(iOS 10.0, *)) {
                    NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                    [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
            
            if (readview) {
                [readview stop];
            }
            
            return;
        }else{
            // 这里是摄像头可以使用的处理逻辑
        }
    } else {
        // 硬件问题提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"reminders", nil) message:@"请检查手机摄像头设备" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        if (readview) {
            [readview stop];
        }
        return;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            [self accordingQcode:scannedResult];
        }];
        
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"reminders", nil) message:@"无法识别！" delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", nil) otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            [readview start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    [readview stop];
    [readview qpauseLayer:readview.readLineView.layer];
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    [self accordingQcode:result];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reStartScan) object:nil];
    [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
}

-(void)SetupBtnClickTrue{
    
    isPush = YES;
    ManualInputViewController *manualVc = [ManualInputViewController new];
    manualVc.deviceNum = _deviceNum;
    manualVc.seq = _seq;
    manualVc.type = _type;
    [self.navigationController pushViewController:manualVc animated:NO];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)code{
    NSString *str = [QFTools completionStr:code needLength:8];
    if (self.type == 6) {
        
        if (str.length != 8) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"no_tirt_type", nil)];
            return;
        }
        
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", _deviceNum];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.tpm_func == 0) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"device_no_tirt_func", nil)];
            return;
        }
        
        NSMutableArray *properModels = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE mac LIKE '%@'", str]];
        
        if (properModels.count >0) {
            [SVProgressHUD showSimpleText:NSLocalizedString(@"tire_has", nil)];
            return;
        }
        
        _deviceInfoModel = [DeviceInfoModel new];
        _deviceInfoModel.device_id = 0;
        _deviceInfoModel.type = self.type;
        _deviceInfoModel.mac = str;
        _deviceInfoModel.sn = [NSString stringWithFormat:@"3000%@",str];
        _deviceInfoModel.seq = self.seq;
        NSString *passwordHEX = [NSString stringWithFormat:@"A500000C3007010%ld%@",_deviceInfoModel.seq - 1,_deviceInfoModel.mac];
        @weakify(self);
        RACSignal * deallocSignal = [self rac_signalForSelector:@selector(bindKey)];
        [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:KNotification_BindingBLEKEY object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            @strongify(self);
            NSNotification *userInfo = x;
            NSString *date = userInfo.userInfo[@"data"];
            if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3007"]){
                if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                    
                    [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
                }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                    [self bindKey];
                }
            }
        }error:^(NSError *error) {
            
            [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
        }];
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }else{
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
    }
}

- (void)reStartScan{
    [readview qresumeLayer:readview.readLineView.layer];
    [readview start];
}
#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
    
}

-(void)dealloc{
    
    if (readview) {
        readview = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end
