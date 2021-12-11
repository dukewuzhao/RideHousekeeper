//
//  InputFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "InputFingerprintViewController.h"
#import "SuccessInputFingerprint.h"
#import "FingerprintAnimationView.h"
#import "ConfigureFingerView.h"

@interface InputFingerprintViewController ()<SuccessInputFingerprintDelegate>{
    int time;
    NSInteger fingerNum;
    NSInteger fingerPressNum;
    NSInteger callBackCount;
    NSInteger pressSecond;
    CFAbsoluteTime startTime;
}
@property(nonatomic,weak)UIImageView *fingerIcon;
@property(nonatomic,strong)MSWeakTimer *countTimer;
@property(nonatomic,assign)BOOL fingerPrintComplete;
@property(nonatomic,strong)SuccessInputFingerprint *successVc;
@property(nonatomic,strong)FingerprintAnimationView *animationVc;
@property(nonatomic,strong)ConfigureFingerView *configureVc;
@property(nonatomic,strong)UILabel *countLab;
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, copy) NSString *bleString;
@end

@implementation InputFingerprintViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
    [self setupNavView];
    self.successVc = [[SuccessInputFingerprint alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    self.successVc.delegate = self;
    [self getfingernumber];
    [self setupView];
    [self setupTime];
    LoadView* loadview = [LoadView sharedInstance];
    loadview.protetitle.text = NSLocalizedString(@"fingerpring_set_start", nil);
    [loadview show];
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_FingerPrint object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:self.bleString]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                self.fingerPrintComplete = YES;
                self ->fingerPressNum = 0;
                [self stopTimer];
                [self uploadFingerPrint];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                [self.animationVc removeFromSuperview];
                [self.view addSubview:self.configureVc];
                [self stopTimer];
                [self TestFingerpress];
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[0]];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"02"]){
                [self stopTimer];
                [self TestFingerpress];
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[1]];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"03"]){
                [self stopTimer];
                [self TestFingerpress];
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[2]];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"04"]){
                [self stopTimer];
                [self TestFingerpress];
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[3]];
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"FF"]){
                
                self.fingerPrintComplete = YES;
                [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_set_fail", nil)];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_TestFingerPress object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                
                self ->pressSecond = 0;
                self ->fingerPressNum++;
                self->time = 10;
                [self setupTime];
                self.configureVc.operationLab.text = NSLocalizedString(@"fingerpring_content", nil);
                self.configureVc.operationLab.textColor = [UIColor whiteColor];
                NSString *passwordHEX = [NSString stringWithFormat:@"A5000007%@F%ld",self.bleString,self ->fingerPressNum];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                if (self ->fingerPressNum >= 1 && self ->fingerPressNum < 3){
                    
                    if (self ->pressSecond<1) {
                        self ->pressSecond ++;
                        self ->startTime = CFAbsoluteTimeGetCurrent();
                    }
                    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - self ->startTime);
                    if ((NSInteger)linkTime >=3) {
                        self.configureVc.operationLab.text = NSLocalizedString(@"fingerpring_set_up", nil);
                        self.configureVc.operationLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                    }
                }
                [self TestFingerpress];
            }else{
                [self TestFingerpress];
            }
        }
    }];
    
    [self deleteFingerpress];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"fingerpring_add", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.fp_conf_count == 0) {
        _imageArray = @[NSLocalizedString(@"fingerprint_step_one", nil), NSLocalizedString(@"fingerprint_step_two", nil)];
        _bleString = @"3004";
    }else{
        _imageArray = @[@"fingerprint_other_step_one", @"fingerprint_other_step_two", @"fingerprint_other_step_three",@"fingerprint_other_step_four"];
        _bleString = @"3008";
    }
}

-(void)getfingernumber{
    NSArray *array1 = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    NSMutableArray *posary = [[NSMutableArray alloc] init];
    for (FingerprintModel *fpmodel in fingerprintmodals) {
        [posary addObject:[NSString stringWithFormat:@"%ld",(long)fpmodel.pos]];
    }
    
    NSArray *array2 = [posary copy];
    NSMutableSet *set1 = [NSMutableSet setWithArray:array1];
    NSMutableSet *set2 = [NSMutableSet setWithArray:array2];
    [set1 minusSet:set2];      //取差集后 set1中为2，3，5，6
    NSMutableArray *posary2 = [[NSMutableArray alloc] init];
    for (NSString *num in set1) {
        [posary2 addObject: num];
    }
    
    NSArray *sort2Array = [[posary2 copy] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if (([obj1 integerValue]) > ([obj2 integerValue])) { //不使用intValue比较无效
            return NSOrderedDescending;//降序
        }else if ([obj1 integerValue] < [obj2 integerValue]){
            return NSOrderedAscending;//升序
        }else {
            return NSOrderedSame;//相等
        }
    }];
    fingerNum = [sort2Array.firstObject integerValue];
}

#pragma mark -  SuccessInputFingerprintDelegate
-(void)InputFingerprintNext{
    
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    
    if (fingerprintmodals.count >= 10) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_max_langth", nil)];
        return;
    }
    
    [self.successVc removeFromSuperview];
    [self.view addSubview:self.animationVc];
    [self.view bringSubviewToFront:_countLab];
    self.fingerIcon.image = [UIImage imageNamed:@"fingerprint_nomal"];
    _countLab.text = @"10s";
    _countLab.hidden = NO;
    time = 10;
    [self getfingernumber];
    [self setupTime];
    LoadView* loadview = [LoadView sharedInstance];
    loadview.protetitle.text = NSLocalizedString(@"fingerpring_set_start", nil);
    [loadview show];
    [self deleteFingerpress];
}
#pragma mark -  SuccessInputFingerprintDelegate
-(void)InputFingerprintSuccess{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupView{
    
    [self.view addSubview:self.animationVc];
    time = 10;
    _countLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 20, ScreenHeight - 40, 40, 20)];
    _countLab.textAlignment = NSTextAlignmentCenter;
    _countLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    _countLab.text = @"10s";
    [self.view addSubview:_countLab];
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
}

-(void)sendInputfingerHex{
    NSString *passwordHEX;
    if (fingerNum >= 10) {
        passwordHEX = [NSString stringWithFormat:@"A5000007%@0A",_bleString];
    }else{
        
        passwordHEX = [NSString stringWithFormat:@"A5000007%@0%ld",_bleString,(long)fingerNum];
    }
    
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    [[LoadView sharedInstance] hide];
}

-(void)setupTime{
    
    self.countTimer = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTimerFired) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)stopTimer{
    
    [self.countTimer invalidate];
    self.countTimer = nil;
}

-(void)countTimerFired{
    
    time--;
    _countLab.text = [NSString stringWithFormat:@"%ds",time];
    
    if (time == 0) {
        
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[NSString stringWithFormat:@"A5000007%@FF",_bleString]]];
        //[AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        [self.countTimer invalidate];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"set_key_timeout", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//-(void)fingerPressTest{
//
//    self.testFinger = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(TestFingerpress) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
//}

-(void)TestFingerpress{
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A50000063006"];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

-(void)deleteFingerpress{
    @weakify(self)
    RACSignal * deallocSignal = [self rac_signalForSelector:@selector(sendInputfingerHex)];
    [[[[NSNOTIC_CENTER rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:deallocSignal] timeout:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [[LoadView sharedInstance] hide];
                self.fingerPrintComplete = YES;
                [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_set_fail", nil)];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                
                [self sendInputfingerHex];
            }
        }
    }error:^(NSError *error) {
        [[LoadView sharedInstance] hide];
        [SVProgressHUD showSimpleText:NSLocalizedString(@"fingerpring_set_fail", nil)];
        NSLog(@"%@",error);
    }];
    
    self.animationVc.operationLab.text = NSLocalizedString(@"fingerpring_content", nil);
    self.animationVc.operationLab.textColor = [UIColor whiteColor];
    NSString *passwordHEX;
    if (self ->fingerNum == 10) {
        passwordHEX = [NSString stringWithFormat:@"A500000730050A"];
    }else{
        passwordHEX = [NSString stringWithFormat:@"A500000730050%ld",(long)self ->fingerNum];
    }
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}


-(void)startSpeech{
    if(callBackCount<1){
        callBackCount++;
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(VoiceAnnouncements) object:nil];
        [self performSelector:@selector(VoiceAnnouncements) withObject:nil afterDelay:2.0];//1秒后点击次数清零
    }
}

-(void)VoiceAnnouncements{

    callBackCount = 0;
}

-(void)uploadFingerPrint{
    
    FingerprintModel *fingermodel = [FingerprintModel modalWith:self.deviceNum fp_id:fingerNum pos:fingerNum name:[NSString stringWithFormat:@"%@%ld",NSLocalizedString(@"fingerpring", nil),(long)fingerNum] added_time:[[NSDate date] timeIntervalSince1970]];
    BOOL success =  [LVFmdbTool insertFingerprintModel:fingermodel];
    if (success) {
        if([self.delegate respondsToSelector:@selector(inputFingerprintOver)])
        {
            [self.delegate inputFingerprintOver];
        }
        
        [self.configureVc removeFromSuperview];
        [self.view addSubview:self.successVc];
        _countLab.hidden = YES;
    }else{
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bind_fail", nil)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(SuccessInputFingerprint *)successVc{
    
    if (!_successVc) {
        
        _successVc = [[SuccessInputFingerprint alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
        _successVc.delegate = self;
    }
    return _successVc;
}

-(FingerprintAnimationView *)animationVc{
    
    if (!_animationVc) {
        
        _animationVc = [[FingerprintAnimationView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    }
    return _animationVc;
}

-(ConfigureFingerView *)configureVc{
    
    if (!_configureVc) {
        
        _configureVc = [[ConfigureFingerView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    }
    return _configureVc;
}

-(void)dealloc{
    
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    [self.countTimer invalidate];
    self.countTimer = nil;
    if (!_fingerPrintComplete) {
        NSString *passwordHEX = [NSString stringWithFormat:@"A5000007%@FF",_bleString];
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
//    [self.testFinger invalidate];
//    self.testFinger = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
