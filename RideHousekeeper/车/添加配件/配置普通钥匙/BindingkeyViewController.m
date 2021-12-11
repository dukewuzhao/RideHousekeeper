//
//  BindingkeyViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/15.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BindingkeyViewController.h"

@interface BindingkeyViewController (){
    int time;
    MSWeakTimer *mytime;
}

@property(nonatomic,weak) UIImageView *lockImage;
@property(nonatomic,weak) UIImageView *arrow1;
@property(nonatomic,weak) UIImageView *unlockImage;
@property(nonatomic,weak) UIImageView *arrow2;
@property(nonatomic,weak) UIImageView *chargeImage;
@property(nonatomic,weak) UIImageView *arrow3;
@property(nonatomic,weak) UIImageView *callImage;
@property(nonatomic,weak) UILabel *countdown;
@property(nonatomic,weak) UILabel *binding;
@property(nonatomic,weak) UIButton *nextBtn;

@end

@implementation BindingkeyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = NO;
    [self setupNavView];
    time = 10;
    
    [self setupheadView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"钥匙配置" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self nextBtnClick];
    };
}

- (void)setupheadView{
    
    UILabel *binding = [[UILabel alloc] initWithFrame:CGRectMake(0, 15+navHeight, ScreenWidth, 25)];
    binding.textAlignment = NSTextAlignmentCenter;
    binding.text = @"请根据APP示意图设置普通按钮上的按键功能";
    binding.textColor = [UIColor blackColor];
    binding.font = FONT_PINGFAN(13);
    [self.view addSubview:binding];
    self.binding = binding;
    
    UIImageView *lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(binding.frame) + 50, 40, 40)];
    lockImage.image = [UIImage imageNamed:@"binding_lock_key_next"];
    [self.view addSubview:lockImage];
    self.lockImage = lockImage;
    
    UIImageView *arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lockImage.frame), lockImage.y + 10, ScreenWidth - 200, 20)];
    arrow1.image = [UIImage imageNamed:@"icon_line_right_false"];
    [self.view addSubview:arrow1];
    self.arrow1 = arrow1;
    
    UIImageView *unlockImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 100, lockImage.y, 40, 40)];
    unlockImage.image = [UIImage imageNamed:@"binding_unlock_key"];
    [self.view addSubview:unlockImage];
    self.unlockImage = unlockImage;
    
    UIImageView *arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(unlockImage.x + 10, CGRectGetMaxY(unlockImage.frame), 20, ScreenHeight * .25)];
    arrow2.image = [UIImage imageNamed:@"icon_line_downt_false"];
    [self.view addSubview:arrow2];
    self.arrow2 = arrow2;
    
    UIImageView *chargeImage = [[UIImageView alloc] initWithFrame:CGRectMake(unlockImage.x , CGRectGetMaxY(unlockImage.frame) + ScreenHeight * .25, 40, 40)];
    [self.view addSubview:chargeImage];
    self.chargeImage = chargeImage;
    
    UIImageView *arrow3 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lockImage.frame), chargeImage.y + 10, ScreenWidth - 200, 20)];
    arrow3.image = [UIImage imageNamed:@"icon_line_left_false"];
    [self.view addSubview:arrow3];
    self.arrow3 = arrow3;
    
    UIImageView *callImage = [[UIImageView alloc] initWithFrame:CGRectMake(lockImage.x , chargeImage.y, 40, 40)];
    callImage.image = [UIImage imageNamed:@"binding_onstart_key"];
    [self.view addSubview:callImage];
    self.callImage = callImage;
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, ScreenHeight - 60, ScreenWidth - 120, 35)];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setTitle:@"暂不绑定" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = FONT_PINGFAN(17);
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
    
    UILabel *countdown = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 20, CGRectGetMaxY(unlockImage.frame) +ScreenHeight * .125 , 40, 40)];
    countdown.font = FONT_PINGFAN(16);
    countdown.textAlignment = NSTextAlignmentCenter;
    countdown.textColor = [UIColor blackColor];
    countdown.text = [NSString stringWithFormat:@"%d",time];
    [self.view addSubview:countdown];
    self.countdown = countdown;
    
    if (self.keyversion.intValue == 0 || self.keyversion.intValue == 1 || self.keyversion.intValue == 2) {
        
        switch (self.keyversion.intValue) {
            case 0:
                chargeImage.image = [UIImage imageNamed:@"binding_find_key"];
                break;
                
            case 1:
                chargeImage.image = [UIImage imageNamed:@"binding_mute_key"];
                break;
                
            case 2:
                chargeImage.image = [UIImage imageNamed:@"binding_seat_key"];
                break;
                
            default:
                break;
        }
        
    }else if (self.keyversion.intValue == 4 || self.keyversion.intValue == 5 || self.keyversion.intValue == 6 || self.keyversion.intValue == 8 || self.keyversion.intValue == 9){
        
        switch (self.keyversion.intValue) {
            case 4:
                chargeImage.image = [UIImage imageNamed:@"binding_find_key"];
                break;
                
            case 5:
                chargeImage.image = [UIImage imageNamed:@"binding_mute_key"];
                break;
                
            case 6:
                chargeImage.image = [UIImage imageNamed:@"binding_seat_key"];
                break;
             
            case 8:
                chargeImage.image = [UIImage imageNamed:@"binding_onstart_key"];
                break;
            case 9:
                chargeImage.image = [UIImage imageNamed:@"binding_onstart_key"];
                break;
            default:
                break;
        }
        
        self.callImage.hidden = YES;
        self.arrow3.hidden = YES;
        
    }else if (self.keyversion.intValue == 3){
        
        self.chargeImage.hidden = YES;
        self.callImage.hidden = YES;
        self.arrow2.hidden = YES;
        self.arrow3.hidden = YES;
        
    }else if (self.keyversion.intValue == 7){
        
        self.unlockImage.hidden = YES;
        self.chargeImage.hidden = YES;
        self.callImage.hidden = YES;
        self.arrow1.hidden = YES;
        self.arrow2.hidden = YES;
        self.arrow3.hidden = YES;
        
    }
    @weakify(self);
    [CommandDistributionServices addNomalKeyConfiguration:self.seq hardwareNum:self.keyversion.intValue step:^(ConfigurationSteps step) {
        @strongify(self);
        switch (step) {
            case FirstStep:
                self.lockImage.image = [UIImage imageNamed:@"binding_lock_key_ok"];
                self.arrow1.image = [UIImage imageNamed:@"icon_line_right_true"];
                self.unlockImage.image = [UIImage imageNamed:@"binding_unlock_key_next"];
                break;
            case SecondStep:
                self.unlockImage.image = [UIImage imageNamed:@"binding_unlock_key_ok"];
                self.arrow2.image = [UIImage imageNamed:@"icon_line_downt_true"];
                
                switch (self.keyversion.intValue) {
                        
                    case 0:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_next"];
                        break;
                        
                    case 1:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_next"];
                        break;
                        
                    case 2:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_next"];
                        break;
                        
                    case 4:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_next"];
                        break;
                        
                    case 5:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_next"];
                        break;
                        
                    case 6:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_next"];
                        break;
                        
                    case 8:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 9:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                    default:
                        break;
                }
                
                break;
            case ThirdStep:
                self.arrow3.image = [UIImage imageNamed:@"icon_line_left_true"];
                switch (self.keyversion.intValue) {
                        
                    case 0:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_ok"];
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 1:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_ok"];
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 2:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_ok"];
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 4:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_ok"];
                        break;
                        
                    case 5:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_ok"];
                        break;
                        
                    case 6:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_ok"];
                        break;
                        
                    case 8:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                    case 9:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                    default:
                        break;
                }
                break;
            case FourthStep:
                [self->mytime invalidate];
                self.countdown.hidden = YES;
                switch (self.keyversion.intValue) {
                    case 0:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    case 1:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    case 2:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    default:
                        break;
                }
                break;
            case KeyRepeat:
                [SVProgressHUD showSimpleText:@"按键重复"];
                [self endprogress];
                break;
            case KeyConflict:
                [SVProgressHUD showSimpleText:@"钥匙冲突"];
                [self endprogress];
                break;
            case Success:
                [self bindingSuccess];
                break;
                
            default:
                break;
        }
        
    } error:^(CommandStatus status) {
        @strongify(self);
        switch (status) {
            case SendSuccess:
                NSLog(@"开始配置钥匙");
                break;
                
            default:
                [SVProgressHUD showSimpleText:@"配置钥匙失败"];
                [self endprogress];
                break;
        }
    }];
    
    mytime = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)bindingSuccess{
    
    self.binding.text = @"恭喜你,绑定成功";
    self.nextBtn.frame = CGRectMake(ScreenWidth/2 - 50, ScreenHeight - 60 , 100, 40);
    [self bindKey];
    [SVProgressHUD showSimpleText:@"普通钥匙配置成功"];
}

- (void)bindKey{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)self.deviceNum];
    NSNumber *seqnumber = [NSNumber numberWithInteger:self.seq];
    NSString *sn = @"R000000000";
    NSNumber *type = [NSNumber numberWithInt:3];
    NSDictionary *device_info = [NSDictionary dictionaryWithObjectsAndKeys:seqnumber,@"seq",sn,@"sn",type,@"type",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_info":device_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",3,self.seq];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            
            if (modals.count > 0) {
                
                NSString *delateKeySql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",3,self.seq];
                [LVFmdbTool deletePeripheraData:delateKeySql];
            }
            
            NSDictionary *deviceDic = dict[@"data"];
            NSMutableArray *deviceinfo = deviceDic[@"device_info"];
            for (NSDictionary *devicedic in deviceinfo) {
                DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                if (self.seq == deviceInfoModel.seq && deviceInfoModel.type == 3) {
                    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:deviceInfoModel.device_id type:deviceInfoModel.type seq:deviceInfoModel.seq mac:deviceInfoModel.mac sn:sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                    BOOL isInsertp = [LVFmdbTool insertDeviceModel:pmodel];
                    
                    if (isInsertp) {
                        
                        [self.nextBtn setTitle:@"返回配件管理" forState:UIControlStateNormal];
                    }
                }
            }
            if ([self.delegate respondsToSelector:@selector(bidingKeyOver)]) {
                [self.delegate bidingKeyOver];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

- (void)timeFired:(MSWeakTimer *)timer{
    
    time--;
    self.countdown.text = [NSString stringWithFormat:@"%d",time];
    
    if (time == 0) {
        [timer invalidate];
        [SVProgressHUD showSimpleText:@"绑定超时"];
        
        [CommandDistributionServices quiteNomalKeyConfiguration:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"退出要是配置发送成功");
                    break;
                    
                default:
                    NSLog(@"退出要是配置发送失败");
                    break;
            }
        }];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

-(void)nextBtnClick{
    
    [CommandDistributionServices quiteNomalKeyConfiguration:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"退出普通钥匙匹配成功");
                break;
                
            default:
                break;
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)endprogress{
    [mytime invalidate];
    [CommandDistributionServices quiteNomalKeyConfiguration:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"退出普通钥匙匹配成功");
                break;
                
            default:
                break;
        }
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

-(void)dealloc{
    [mytime invalidate];
    mytime = nil;
}

@end
