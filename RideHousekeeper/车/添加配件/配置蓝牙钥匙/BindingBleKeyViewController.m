//
//  BindingBleKeyViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/2/13.
//  Copyright © 2019年 Duke Wu. All rights reserved.
//

#import "BindingBleKeyViewController.h"

@interface BindingBleKeyViewController ()
{
    NSInteger time;
}
@property(nonatomic,strong)UILabel *countNumLab;
@property(nonatomic,strong)MSWeakTimer *mytime;
@end

@implementation BindingBleKeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    time = 10;
    [self setupNavView];
    [self setupView];
    @weakify(self);
    [CommandDistributionServices addBLEKey:self.seq - 1 data:^(id data) {
        @strongify(self);
        if ([data intValue] == ConfigurationSuccess) {
            [self bindBleKey];
        }else{
            [SVProgressHUD showSimpleText:@"绑定失败"];
        }
    } error:^(CommandStatus status) {
        switch (status) {
            case SendSuccess:
                NSLog(@"添加蓝牙钥匙发送成功");
                break;
                
            default:
                [SVProgressHUD showSimpleText:@"绑定失败"];
                break;
        }
    }];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"智能钥匙配置" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setupView{
    
    UILabel *binding = [[UILabel alloc] initWithFrame:CGRectMake(0, 55+navHeight, ScreenWidth, 25)];
    binding.textAlignment = NSTextAlignmentCenter;
    binding.text = @"请点击钥匙按钮";
    binding.textColor = [UIColor blackColor];
    binding.font = FONT_PINGFAN(15);
    [self.view addSubview:binding];
    
    UIImageView *clickIcon = [UIImageView new];
    clickIcon.image = [UIImage imageNamed:@"binding_lock_key_ok"];
    [self.view addSubview:clickIcon];
    
    [clickIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(binding.mas_top).offset(70);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    _countNumLab = [UILabel new];
    _countNumLab.text = @"10s";
    _countNumLab.textColor = [UIColor blackColor];
    _countNumLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_countNumLab];
    [_countNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(clickIcon.mas_bottom).offset(40);
        make.size.mas_equalTo(CGSizeMake(70, 20));
    }];
    
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:@"暂不绑定" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    [self.view addSubview:cancleBtn];
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-75);
        make.size.mas_equalTo(CGSizeMake(100, 45));
    }];
    @weakify(self);
    [[cancleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    _mytime = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

- (void)timeFired:(MSWeakTimer *)timer{
    
    time--;
    _countNumLab.text = [NSString stringWithFormat:@"%d",time];
    
    if (time == 0) {
        [timer invalidate];
        [SVProgressHUD showSimpleText:@"绑定超时"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)bindBleKey{
    
    [LoadView sharedInstance].protetitle.text = @"添加配件中";
    [[LoadView sharedInstance] show];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)self.deviceNum];
    NSNumber *seqnumber = [NSNumber numberWithInteger:self.seq];
    NSString *sn = @"R000000000";
    NSNumber *type = [NSNumber numberWithInt:7];
    NSDictionary *device_info = [NSDictionary dictionaryWithObjectsAndKeys:seqnumber,@"seq",sn,@"sn",type,@"type",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_info":device_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",7,self.seq];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            
            if (modals.count > 0) {
                
                NSString *delateKeySql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",7,self.seq];
                [LVFmdbTool deletePeripheraData:delateKeySql];
            }
            
            NSDictionary *deviceDic = dict[@"data"];
            NSMutableArray *deviceinfo = deviceDic[@"device_info"];
            for (NSDictionary *devicedic in deviceinfo) {
                DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedic];
                if (self.seq == deviceInfoModel.seq && deviceInfoModel.type == 7) {
                    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:deviceInfoModel.device_id type:deviceInfoModel.type seq:deviceInfoModel.seq mac:deviceInfoModel.mac sn:sn qr:deviceInfoModel.qr firmversion:deviceInfoModel.firm_version default_brand_id:deviceInfoModel.default_brand_id default_model_id:deviceInfoModel.default_model_id prod_date:deviceInfoModel.prod_date imei:deviceInfoModel.imei imsi:deviceInfoModel.imsi sign:deviceInfoModel.sign desc:deviceInfoModel.desc ts:deviceInfoModel.ts bind_sn:deviceInfoModel.bind_sn bind_mac:deviceInfoModel.bind_mac is_used:deviceInfoModel.is_used];
                    [LVFmdbTool insertDeviceModel:pmodel];
                }
            }
            if ([self.delegate respondsToSelector:@selector(bidingBleKeyOver)]) {
                [self.delegate bidingBleKeyOver];
            }
            [[LoadView sharedInstance] hide];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)dealloc{
    [self.mytime invalidate];
    self.mytime = nil;
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
