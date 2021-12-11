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
    NSInteger fingerPrintType;
}
@property(nonatomic,weak)UIImageView *fingerIcon;
@property(nonatomic,strong)MSWeakTimer *countTimer;
@property(nonatomic,assign)BOOL fingerPrintComplete;
@property(nonatomic,strong)SuccessInputFingerprint *successVc;
@property(nonatomic,strong)FingerprintAnimationView *animationVc;
@property(nonatomic,strong)ConfigureFingerView *configureVc;
@property(nonatomic,strong)UILabel *countLab;
@property(nonatomic,copy)NSArray *imageArray;
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
    LoadView *loadView = [LoadView sharedInstance];
    loadView.protetitle.text = @"指纹准备中";
    [loadView show];
    
    BikeModel *bikemodel = [[LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", self.deviceNum]] firstObject];
    if (bikemodel.fp_conf_count == 0) {
        _imageArray = @[@"fingerprint_step_one", @"fingerprint_step_two"];
        fingerPrintType = 3;
    }else{
        _imageArray = @[@"fingerprint_other_step_one", @"fingerprint_other_step_two", @"fingerprint_other_step_three",@"fingerprint_other_step_four"];
        fingerPrintType = 5;
    }
    
    [self addFingerPrint];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"录入指纹" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
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
    
    if (![CommandDistributionServices isConnect]) {
        [SVProgressHUD showSimpleText:@"车辆未连接"];
        return;
    }
    
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    
    if (fingerprintmodals.count >= 10) {
        [SVProgressHUD showSimpleText:@"录入已达上限"];
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
    LoadView* loadView = [LoadView sharedInstance];
    loadView.protetitle.text = @"指纹准备中";
    [loadView show];
    [self addFingerPrint];
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
    _countLab.textColor = [UIColor blackColor];
    _countLab.text = @"10s";
    [self.view addSubview:_countLab];
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
        
        [CommandDistributionServices quiteFingerPrint:fingerNum fingerPrintType:fingerPrintType error:nil];
        [self.countTimer invalidate];
        [SVProgressHUD showSimpleText:@"绑定超时"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)addFingerPrint{
    @weakify(self);
    [CommandDistributionServices addFingerPrint:fingerNum fingerPrintType:fingerPrintType status:^(FingerPrintStatus status) {
        @strongify(self);
        switch (status) {
            case PrintFirst:
                self->time = 10;
                [self.animationVc removeFromSuperview];
                [self.view addSubview:self.configureVc];
                [self.view bringSubviewToFront:self.countLab];
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[0]];
                break;
            case PrintSecond:
                self->time = 10;
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[1]];
                break;
            case PrintThird:
                self->time = 10;
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[2]];
                break;
            case PrintFourth:
                self->time = 10;
                self.configureVc.fingerIcon.image = [UIImage imageNamed:self.imageArray[3]];
                break;
            case PrintSuccess:
                self.fingerPrintComplete = YES;
                [self stopTimer];
                [self uploadFingerPrint];
                break;
            case PrintTooLong:
                self.configureVc.operationLab.text = @"请抬起手指";
                self.configureVc.operationLab.textColor = [UIColor redColor];
                break;
            case PrintLiftUp:
                self.configureVc.operationLab.text = @"将手指放置在车辆指纹传感器上按压再抬起，手指覆盖金属圈以内，重复此操作";
                self.configureVc.operationLab.textColor = [UIColor blackColor];
                break;
            case PrintFail:
                self.fingerPrintComplete = YES;
                [SVProgressHUD showSimpleText:@"指纹录入失败"];
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                self.animationVc.operationLab.text = @"将手指放置在车辆指纹传感器上按压再抬起，手指覆盖金属圈以内，重复此操作";
                self.animationVc.operationLab.textColor = [UIColor blackColor];
                [[LoadView sharedInstance] hide];
                break;
                
            default:
                [[LoadView sharedInstance] hide];
                self.fingerPrintComplete = YES;
                [SVProgressHUD showSimpleText:@"指纹录入失败"];
                [self.navigationController popViewControllerAnimated:YES];
                break;
        }
    }];
    
}

-(void)uploadFingerPrint{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/addfingerprint"];
    NSString *token = [QFTools getdata:@"token"];
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    NSNumber* dTime = [NSNumber numberWithDouble:nowTime];
    NSNumber *pos = [NSNumber numberWithDouble:fingerNum];
    NSString *name = [NSString stringWithFormat:@"指纹%ld",(long)fingerNum];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *fp_info = [NSDictionary dictionaryWithObjectsAndKeys:pos,@"pos",name,@"name",dTime,@"added_time",nil];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_info": fp_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [SVProgressHUD showSimpleText:@"录入成功"];
            NSDictionary *data = dict[@"data"];
            NSMutableArray *fpsAry = data[@"fps"];
            
            for (NSDictionary *fpsInfo in fpsAry) {
                
                NSNumber *pos = fpsInfo[@"pos"];
                if (pos.integerValue == fingerNum) {
                    NSNumber *fpid = fpsInfo[@"fp_id"];
                    NSNumber *pos = fpsInfo[@"pos"];
                    NSString *name = fpsInfo[@"name"];
                    NSNumber *addedtime = fpsInfo[@"added_time"];
                    
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:self.deviceNum fp_id:fpid.integerValue pos:pos.integerValue name:name added_time:addedtime.integerValue];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            if([self.delegate respondsToSelector:@selector(inputFingerprintOver)])
            {
                [self.delegate inputFingerprintOver];
            }
            
            [self.configureVc removeFromSuperview];
            [self.view addSubview:self.successVc];
            _countLab.hidden = YES;
        }else{
            [SVProgressHUD showSimpleText:@"绑定指纹失败"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
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
    
    [self.countTimer invalidate];
    self.countTimer = nil;
    if (!_fingerPrintComplete) {
        [CommandDistributionServices quiteFingerPrint:fingerNum fingerPrintType:fingerPrintType error:nil];
    }
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
