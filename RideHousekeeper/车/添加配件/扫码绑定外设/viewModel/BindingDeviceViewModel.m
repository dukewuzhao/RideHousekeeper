//
//  BindingDeviceViewModel.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/12.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "BindingDeviceViewModel.h"
#import "SearchBleModel.h"
#import<libkern/OSAtomic.h>
@interface BindingDeviceViewModel ()
@property(nonatomic,strong)RACDisposable *dispoable;
@end
@implementation BindingDeviceViewModel



- (void)checkKey:(NSInteger)bikeid :(NSString *)sn success:(void (^)(id))success
failure:(void (^)(NSError *))failure{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevice"];
    NSDictionary *parameters = @{@"token": token, @"sn":sn, @"bike_id":@(bikeid) };
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *devicedata = dict[@"data"];
            DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedata[@"device_info"]];
            
            if (![QFTools isBlankString:deviceInfoModel.bind_sn] && deviceInfoModel.type == 4) {//gps套件
                
                if (deviceInfoModel.is_used == 1) {//已被使用
                    
                    if (bikeid == 0) {//车辆绑定
                        if (![QFTools isBlankString:deviceInfoModel.bind_mac]) {
                            //匹配ECU，找到对应的ECU设备绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@2100,@"status",@"套件绑定有ECU",@"status_info",devicedata,@"data", nil]);
                        }else{
                            //没有匹配ECU，提示用户选择一个新的ECU绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@4100,@"status",@"套件绑定没有ECU",@"status_info",devicedata,@"data", nil]);
                        }
                    }else{//配件绑定
                        //配件绑定，禁止绑定，提示用户点击重新绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@6000,@"status",@"该GPS配件已被绑定",@"status_info",devicedata,@"data", nil]);
                    }
                    
                }else if (deviceInfoModel.is_used == 2){
                    
                    if (bikeid == 0) {//车辆绑定
                        if (![QFTools isBlankString:deviceInfoModel.bind_mac]) {
                            //匹配ECU，找到对应的ECU设备绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@2100,@"status",@"套件试用绑定GPS有ECU",@"status_info",devicedata,@"data", nil]);
                        }else{
                            //没有匹配ECU，提示用户选择一个新的ECU绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@4100,@"status",@"套件试用绑定GPS没有ECU",@"status_info",devicedata,@"data", nil]);
                        }
                    }else{
                        //配件绑定，可以绑定，不用管是否是套件
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3100,@"status",@"配件试用绑定GPS",@"status_info",devicedata,@"data", nil]);
                    }
                    
                } else{//未被使用
                    
                    if (bikeid == 0) {//车辆绑定
                        if (![QFTools isBlankString:deviceInfoModel.bind_mac]) {
                            //匹配ECU，找到对应的ECU设备绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@2000,@"status",@"套件绑定有ECU",@"status_info",devicedata,@"data", nil]);
                        }else{
                            //没有匹配ECU，提示用户选择一个新的ECU绑定
                            success([NSDictionary dictionaryWithObjectsAndKeys:@4000,@"status",@"套件绑定没有ECU",@"status_info",devicedata,@"data", nil]);
                        }
                    }else{
                        //配件绑定，可以绑定，不用管是否是套件
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3000,@"status",@"配件绑定GPS",@"status_info",devicedata,@"data", nil]);
                    }
                }

            }else if([QFTools isBlankString:deviceInfoModel.bind_sn] && deviceInfoModel.type == 4){//单GPS，不是套件
                
                if (deviceInfoModel.is_used == 1) {//已被使用
                    
                    if (bikeid == 0) {//车辆绑定
                        //单GPS绑定，但被使用，不允许绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@6000,@"status",@"该GPS配件已被绑定",@"status_info",devicedata,@"data", nil]);
                        
                    }else{//配件绑定
                        //配件GPS绑定，但被使用，不允许绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@6000,@"status",@"该GPS配件已被绑定",@"status_info",devicedata,@"data", nil]);
                    }
                    
                }else if (deviceInfoModel.is_used == 2){
                    
                    if (bikeid == 0) {//车辆绑定
                        //单GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3100,@"status",@"单GPS试用绑定",@"status_info",devicedata,@"data", nil]);
                    }else{//配件绑定
                        //配件GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3100,@"status",@"配件GPS试用绑定",@"status_info",devicedata,@"data", nil]);
                    }
                    
                }else{//未被使用
                    
                    if (bikeid == 0) {//车辆绑定
                        //单GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3000,@"status",@"单GPS绑定",@"status_info",devicedata,@"data", nil]);
                    }else{//配件绑定
                        //配件GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3000,@"status",@"配件GPS绑定",@"status_info",devicedata,@"data", nil]);
                    }
                }
                
            }else{
                [self nextStep:bikeid :deviceInfoModel success:success failure:failure];
            }
        }else if ([dict[@"status"] intValue] == 1042){
            success(dict);
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            [self getFailure:failure];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        failure(error);
    }];
}

- (void)checkECUDevices:(NSString *)sn success:(void (^)(id))success
                failure:(void (^)(NSError *))failure{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevicenew"];
    NSDictionary *parameters = @{@"token": token, @"sn":sn};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *devicedata = dict[@"data"];
            DeviceInfoModel* deviceInfoModel = [DeviceInfoModel yy_modelWithDictionary:devicedata[@"device_info"]];
            
            if (![QFTools isBlankString:deviceInfoModel.bind_sn]) {//gps套件
                
                if (deviceInfoModel.is_used == 1) {//ECU已被使用
                    
                    if (![QFTools isBlankString:deviceInfoModel.bind_mac]) {
                        //匹配GPS，找到对应的GPS设备绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@2000,@"status",@"套件绑定有GPS",@"status_info",devicedata,@"data", nil]);
                    }else{
                        //没有匹配GPS，提示用户选择一个新的GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@3000,@"status",@"套件绑定没有GPS",@"status_info",devicedata,@"data", nil]);
                    }
                    
                }else{//未被使用
                    
                    if (![QFTools isBlankString:deviceInfoModel.bind_mac]) {
                        //匹配GPS，找到对应的GPS设备绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@4000,@"status",@"套件绑定有GPS",@"status_info",devicedata,@"data", nil]);
                    }else{
                        //没有匹配GPS，提示用户选择一个新的GPS绑定
                        success([NSDictionary dictionaryWithObjectsAndKeys:@5000,@"status",@"套件绑定没有GPS",@"status_info",devicedata,@"data", nil]);
                    }
                }

            }else{//单ECU，不是套件
                
                if (deviceInfoModel.is_used == 1) {//已被使用
                    //单ECU绑定，钥匙绑定
                    success([NSDictionary dictionaryWithObjectsAndKeys:@6000,@"status",@"该ECU已被绑定",@"status_info",devicedata,@"data", nil]);
                        
                }else{//未被使用
                    //单ECU绑定
                    success([NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",@"单ECU绑定",@"status_info",devicedata,@"data", nil]);
                }
                
            }
        }else if ([dict[@"status"] intValue] == 1017){
            success(dict);
        } else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            [self getFailure:failure];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        failure(error);
    }];
}

- (void)bindKey:(NSInteger)bikeid :(DeviceInfoModel *)deviceInfoModel success:(void (^)(id))success
failure:(void (^)(NSError *))failure{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bike_id= [NSNumber numberWithInteger:bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
    NSDictionary *device_info = [deviceInfoModel yy_modelToJSONObject];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_info":device_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        success(dict);
    }failure:^(NSError *error) {
        failure(error);
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void)BindingDeviceWithBikeId:(NSInteger)bikeid messageinfo:(id)model success:(void (^)(id))success
failure:(void (^)(NSError *))failure{
    
    if (bikeid == 0) {
        
         if ([LVFmdbTool queryBikeData:nil].count >= 5) {
             
             [SVProgressHUD showSimpleText:@"最多同时只能绑定5辆车"];
             [self getFailure:failure];
             return;
         }
         
         BikeInfoModel *bikeModel = (BikeInfoModel *)model;
         NSDictionary *bike_info = [bikeModel yy_modelToJSONObject];
         NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/bindbike"];
         NSString *token = [QFTools getdata:@"token"];
         NSDictionary *parameters = @{@"token": token,@"bike_info":bike_info};
         
        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            
            if ([dict[@"status"] intValue] == 0) {
                [CommandDistributionServices removePeripheral:nil];
            }
            success(dict);
        }failure:^(NSError *error) {
            NSLog(@"error :%@",error);
            [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
            failure(error);
        }];
        
    }else{
        DeviceInfoModel *DeviceModel = (DeviceInfoModel *)model;
        NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
        NSString *token = [QFTools getdata:@"token"];
        NSDictionary *device_info = [DeviceModel yy_modelToJSONObject];
        NSDictionary *parameters = @{@"token": token,@"bike_id":[NSNumber numberWithInteger:bikeid],@"device_info":device_info};
        
        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            
            success(dict);
        }failure:^(NSError *error) {
            [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
            failure(error);
        }];
    }
}

-(void)setSuccess:(void (^)(id))success{
    
    if (success) {
        success = nil;
    }
}

-(void)getFailure:(void (^)(NSError *))failure{
    
    if (failure) {
        NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
        NSString *desc = NSLocalizedString(@"Unable to…", @"");
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
        NSError *error = [NSError errorWithDomain:domain
                                             code:-101
                                         userInfo:userInfo];
        failure(error);
    }
}

- (void)startblescan:(DeviceScanType)scanType :(NSString *)mac :(NSInteger)timeNum scanCallBack:(void (^)(id))callBack countDown:(nonnull void (^)(NSInteger))countDownBack{
    __block int32_t timeOutCount = timeNum;
    @weakify(self);
    self.dispoable = [[[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        timeOutCount--;
        if (countDownBack) countDownBack(timeOutCount);
        NSLog(@"每秒执行一次");
        if (timeOutCount == 0) {
            [self.dispoable dispose];
            [CommandDistributionServices stopScan];
            if (callBack) callBack([NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil]);
        }
    }];
    [CommandDistributionServices startScan:scanType PeripheralList:^(NSMutableArray * arry) {
        @strongify(self);
        if (scanType == DeviceGPSType){
            for (SearchBleModel *model in arry) {
                
                if ([model.mac.uppercaseString isEqualToString:mac.uppercaseString]){
                    [self.dispoable dispose];
                    [CommandDistributionServices stopScan];
                    if (callBack) callBack([NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",model,@"data", nil]);
                }
            }
        }else if (scanType == DeviceNomalType){
            
            for (SearchBleModel *model in arry) {
                
                if ([model.mac.uppercaseString isEqualToString:mac.uppercaseString]){
                    [self.dispoable dispose];
                    [CommandDistributionServices stopScan];
                    if (callBack) callBack([NSDictionary dictionaryWithObjectsAndKeys:@0,@"status",model,@"data", nil]);
                }
            }
        }
    }];
}

-(void)nextStep:(NSInteger)bikeid :(DeviceInfoModel *)deviceInfoModel success:(void (^)(id))success
failure:(void (^)(NSError *))failure {
    if (deviceInfoModel.type == 2 || deviceInfoModel.type == 5) {
        NSInteger number;
        if (bikeid == 0) {
            [SVProgressHUD showSimpleText:@"无效的是设备"];
            [self getFailure:failure];
            return ;
        }
        
        NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE (type LIKE '%zd' OR type LIKE '%zd') AND bikeid LIKE '%zd'", 2,5,bikeid]];
        
        if (peripheraModals.count>=2) {
            [SVProgressHUD showSimpleText:@"感应设备最多配置两个"];
            [self getFailure:failure];
            return ;
        }
        
        if (peripheraModals.count == 0) {
            number = 1;
        }else if (peripheraModals.count == 1){
            
            PeripheralModel *perierMod = peripheraModals.firstObject;
            if (perierMod.seq == 1) {
                number = 2;
            }else{
                number = 1;
            }
        }else{
            number = 2;
        }
        deviceInfoModel.seq = number;
        
        @weakify(self);
        [CommandDistributionServices addInductionKey:deviceInfoModel.seq mac:deviceInfoModel.mac data:^(id data) {
            @strongify(self);
            if ([data intValue] == ConfigurationFail) {
                [SVProgressHUD showSimpleText:@"绑定感应配件失败"];
                [self getFailure:failure];
            }else{
                [self bindKey:bikeid :deviceInfoModel success:success failure:failure];
            }
            
        } error:^(CommandStatus status) {
            @strongify(self);
            switch (status) {
                case SendSuccess:
                    NSLog(@"添加感应配件发送成功");
                    break;
                    
                default:
                    [SVProgressHUD showSimpleText:@"绑定感应配件失败"];
                    [self getFailure:failure];
                    break;
            }
        }];
        
    }else if (deviceInfoModel.type == 4){
        
        NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd'  AND bikeid LIKE '%zd'", deviceInfoModel.type,bikeid]];
        if (peripheraModals.count>=1) {
            [SVProgressHUD showSimpleText:@"最多绑定一个GPS"];
            [self getFailure:failure];
            return ;
        }
        id model;
        if (bikeid == 0) {
            
            BikeInfoModel *bikeInfoModel = [[BikeInfoModel alloc] init];
            NSArray *ary = [NSArray arrayWithObject:deviceInfoModel];
            bikeInfoModel.device_info = [ary copy];
            model = bikeInfoModel;
        }else{
            model = deviceInfoModel;
        }
        
        [self BindingDeviceWithBikeId:bikeid messageinfo:model success:success failure:failure];
        
    }else if (deviceInfoModel.type == 6){
        if (bikeid == 0) {
            [SVProgressHUD showSimpleText:@"无效的设备"];
            [self getFailure:failure];
            return ;
        }
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.tpm_func == 0) {
            [SVProgressHUD showSimpleText:@"该中控不支持胎压监测"];
            [self getFailure:failure];
            return;
        }
        
        NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", deviceInfoModel.type,bikeid]];
        if (peripheraModals.count>=2) {
            [SVProgressHUD showSimpleText:@"最多配置两个胎压监测"];
            [self getFailure:failure];
            return ;
        }else if (peripheraModals.count == 1){
            PeripheralModel *permodel = peripheraModals.firstObject;
            if(permodel.seq == deviceInfoModel.seq){
                
                switch (permodel.seq) {
                    case 1:
                        [SVProgressHUD showSimpleText:@"已配置前轮胎压监测器"];
                        break;
                    case 2:
                        [SVProgressHUD showSimpleText:@"已配置后轮胎压监测器"];
                        break;
                    default:
                        break;
                }
                [self getFailure:failure];
                return;
            }
        }
        [CommandDistributionServices addTirePressure:deviceInfoModel.seq - 1 mac:deviceInfoModel.mac data:^(id data) {
            
            if ([data intValue] == ConfigurationFail) {
                [SVProgressHUD showSimpleText:@"胎压绑定失败"];
                [self getFailure:failure];
            }else{
                [self bindKey:bikeid :deviceInfoModel success:success failure:failure];
            }
            
        } error:^(CommandStatus status) {
            switch (status) {
                case SendSuccess:
                    NSLog(@"添加胎压配件发送成功");
                    break;
                    
                default:
                    [SVProgressHUD showSimpleText:@"胎压绑定失败"];
                    [self getFailure:failure];
                    break;
            }
        }];
    }else{
        [SVProgressHUD showSimpleText:@"无法识别该配件"];
        [self getFailure:failure];
    }
}

-(void)dealloc{
    [self.dispoable dispose];
}

@end
