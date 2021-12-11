//
//  HttpRequest.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/26.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "HttpRequest.h"
#import "RequestModel.h"
#import <PromiseKit/PromiseKit.h>
@interface HttpRequest()
@property(nonatomic, assign) BOOL isFreshing;
@property(nonatomic, strong) NSMutableArray *requestAry;
@end

@implementation HttpRequest

-(NSMutableArray *)requestAry{
    if (!_requestAry) {
        _requestAry = [NSMutableArray array];
    }
    return _requestAry;
}

static id _instance = nil;
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [super init];
    });
    return _instance;
}

-(void)networkMonitor{
    
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未识别的网络");
                self.available = NO;
                [SVProgressHUD showSimpleText:@"未识别的网络"];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"不可达的网络(未连接)");
                self.available = NO;
                [SVProgressHUD showSimpleText:@"网络异常，请检查网络状况"];
                
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"2G,3G,4G...的网络");
                self.available = YES;
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"wifi的网络");
                self.available = YES;
                break;
            default:
                break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}

#pragma mark -- GET请求 --
- (void)getWithURLString:(NSString *)URLString
              parameters:(id)parameters
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    /**
     *  可以接受的类型
     */
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    /**
     *  请求队列的最大并发数
     */
    //    manager.operationQueue.maxConcurrentOperationCount = 5;
    /**
     *  请求超时的时间
     */
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 5.0;//设置请求超时时间
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- POST请求 --
- (void)postWithURLString:(NSString *)URLString
               parameters:(id)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
//    if (!self.available) {
//        if (failure) {
//            NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
//            NSString *desc = NSLocalizedString(@"Unable to…", @"");
//            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
//            NSError *error = [NSError errorWithDomain:domain
//                                                 code:-101
//                                             userInfo:userInfo];
//            failure(error);
//        }
//        return;
//    }
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            
            if ([responseObject[@"status"] intValue] == 0){
                success(responseObject);
            }else if([responseObject[@"status"] intValue] == 1002){
                
                [self cancelRequest];
                [self.requestAry removeAllObjects];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSimpleText:@"用户名或密码错误,请重新登录"];
                });
            }else if ([responseObject[@"status"] intValue] == 1009){
                //NSLog(@"token失效了  ------");
                if (!_isFreshing) {
                    _isFreshing = YES;
                    //[self login:URLString parameters:parameters success:success failure:failure];
                    RequestModel *model = [[RequestModel alloc] init];
                    model.url = URLString;
                    model.parameters = parameters;
                    model.success = success;
                    model.failure = failure;
                    
                    NSString *password= [QFTools getdata:@"password"];
                    NSString *phonenum= [QFTools getdata:@"phone_num"];
                    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"BLE"];
                    NSString * md5=[[QFTools md5:pwd] uppercaseString];
                    NSString *modelname = [NSString stringWithFormat:@"%@|%@|%@",[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],[[UIDevice currentDevice].identifierForVendor UUIDString]];
                    NSString *did=[[QFTools md5:modelname] uppercaseString];
                    NSString *regid = [JPUSHService registrationID]?:@"";
                    NSString *loginURL = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
                    NSDictionary *push = @{@"device_name": modelname,@"channel": @1,@"reg_id": regid};
                    NSDictionary *loginParameters = @{@"account":phonenum, @"passwd": md5,@"did": did,@"pkg": [[NSBundle mainBundle] bundleIdentifier],@"push":push};
                    
                    [self jsonPostUrl:loginURL params:loginParameters].then(^(id dic){
                        NSLog(@"刷新token  ------");
                        NSDictionary *data = dic[@"data"];
                        LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
                        NSString * token=loginModel.token;
                        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)model.parameters];
                        [newDict setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithURLString:model.url parameters:newDict success:model.success failure:model.failure];
                        _isFreshing = NO;
                        return token;
                        
                        }).catch(^(NSError* error){
                            NSLog(@"刷新失败token  ------ ");
                            if (error.code == 1001) {
                                [SVProgressHUD showSimpleText:@"请求超时"];
                            }else{
                                [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                            }
                        }).then(^(NSString * token){
                            NSLog(@"继续刷新token %@ ------ 数量%d",token,self.requestAry.count);
                            for (RequestModel *model in self.requestAry) {
                                NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)model.parameters];
                                [newDict setValue:token forKey:@"token"];
                                [[HttpRequest sharedInstance] postWithURLString:model.url parameters:newDict success:model.success failure:model.failure];
                            }
                            [self.requestAry removeAllObjects];
                        });
                    
                }else{
                    RequestModel *model = [[RequestModel alloc] init];
                    model.url = URLString;
                    model.parameters = parameters;
                    model.success = success;
                    model.failure = failure;
                    [self.requestAry addObject:model];
                }
            }
            else if ([responseObject[@"status"] intValue] == 1023){
                
                if ([QFTools isBlankString:[QFTools getdata:@"phone_num"]]) {
                    return;
                }
                
                [self cancelRequest];
                [self.requestAry removeAllObjects];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSimpleText:@"账号已在其它设备上登录"];
                });
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (error.code == -1005){
            
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                 dispatch_group_t downloadGroup = dispatch_group_create();
                 dispatch_group_enter(downloadGroup);
                 dispatch_group_wait(downloadGroup, dispatch_time(DISPATCH_TIME_NOW, 2000000000)); // Wait 2 seconds before trying again.
                 dispatch_group_leave(downloadGroup);
                 dispatch_async(dispatch_get_main_queue(), ^{
                    //重新请求的方法
                     [self postWithURLString:URLString parameters:parameters success:success failure:failure];
                 });
             });
        }else{
            if (failure) {
                failure(error);
            }
        }
    }];
}

//  -1005重新请求
//-(void)rePostWith_URL:(NSString *)url Param:(NSDictionary *)dic Method:(NSString *)method Timeout:(NSInteger)timeout Finsh:(XYNetBlock)Block
//{
//
//    int recount =  [self.code_1005_method_count_dic[method] intValue];
//    recount++;
//    [self.code_1005_method_count_dic setObject:@(recount) forKey:method];
//
//
//    //签名
//    NSDictionary *PostDic = [XYSignManager signXinyiWithDic:dic method:method];
//
//
//    self.manager.requestSerializer.timeoutInterval = timeout;
//
//
//    [self.manager POST:url parameters:PostDic progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        XYLog(@"重新请求成功");
//        NSString *resStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSDictionary *dic = [resStr mj_JSONObject];
//        Block(YES,dic);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//         if (error.code == -1005) {
//
//             int count =  [self.code_1005_method_count_dic[method] intValue];
//             if (count >= 5) {
//
//                 XYLog(@"重新请求超过限制，停止请求");
//                  Block(NO,nil);
//                 return ;
//             }
//             else
//             {
//
//                 [self rePostWith_URL:url Param:dic Method:method Timeout:15 Finsh:^(BOOL isSuccess, NSDictionary *responseDic) {
//                     if (isSuccess) {
//                         Block(YES,responseDic);
//                     }
//                     else
//                     {
//                         Block(NO,nil);
//                     }
//                 }];
//
//                 //return ;
//             }
//
//
//         }
//        else
//        {
//
//            XYLog(@"重新请求失败");
//            Block(NO,nil);
//        }
//
//    }];
//
//}

#pragma mark -- POST/GET网络请求 --
- (void)requestWithURLString:(NSString *)URLString
                  parameters:(id)parameters
                        type:(HttpRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    switch (type) {
        case HttpRequestTypeGet:
        {
            [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case HttpRequestTypePost:
        {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
    }
}

//- (void)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(NSArray<UploadParam *> *)uploadParams success:(void (^)())success failure:(void (^)(NSError *))failure {
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        for (UploadParam *uploadParam in uploadParams) {
//            [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
//        }
//    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (success) {
//            success(responseObject);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            failure(error);
//        }
//    }];
//}

#pragma mark - 下载数据
- (void)downLoadWithURLString:(NSString *)URLString parameters:(id)parameters progerss:(void (^)())progress success:(void (^)())success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress();
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    [downLoadTask resume];
}

-(void)login:(NSString *)URLString
parameters:(id)parameters
   success:(void (^)(id))success
   failure:(void (^)(NSError *))failure{
    
    NSString *password= [QFTools getdata:@"password"];
    [self postWithURLString:URLString parameters:parameters success:^(id responseObject) {
        
        if ([responseObject[@"status"] intValue] == 0){
            
            NSDictionary *data = responseObject[@"data"];
            LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
            NSString * token=loginModel.token;
            NSString * defaultlogo = loginModel.default_brand_logo;
            NSString * defaultimage = loginModel.default_model_picture;
            UserInfoModel *userinfo = loginModel.user_info;
            NSString * birthday=userinfo.birthday;
            NSString * nick_name=userinfo.nick_name;
            NSNumber * gender = [NSNumber numberWithInteger:userinfo.gender];
            NSString * icon = userinfo.icon;
            NSString * realName = userinfo.real_name;
            NSString *idcard = userinfo.id_card_no;
            NSNumber *userId = [NSNumber numberWithInteger:userinfo.user_id];
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",parameters[@"account"],@"phone_num",password,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
            [USER_DEFAULTS setObject:userDic forKey:logInUSERDIC];
            
            NSDictionary *userDic2 = [NSDictionary dictionaryWithObjectsAndKeys:parameters[@"account"],@"username",birthday,@"birthday",nick_name,@"nick_name",gender,@"gender",icon,@"icon",realName,@"realname",idcard,@"idcard",nil];
            [USER_DEFAULTS setObject:userDic2 forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
//            NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
//            [dict002 setValue:token forKey:@"token"];
//            [[HttpRequest sharedInstance] postWithURLString:URLString parameters:dict002 success:success failure:failure];
//            _isFreshing = NO;
        }
        success(responseObject);
    } failure:^(NSError *error) {
        
        failure(error);
    }];
    
}


//let isRefreshing = false
//// 重试队列，每一项将是一个待执行的函数形式
//let requests = []
//
//instance.interceptors.response.use(response => {
//  const { code } = response.data
//  if (code === 1234) {
//    const config = response.config
//    if (!isRefreshing) {
//      isRefreshing = true
//      return refreshToken().then(res => {
//        const { token } = res.data
//        instance.setToken(token)
//        config.headers['X-Token'] = token
//        config.baseURL = ''
//        // 已经刷新了token，将所有队列中的请求进行重试
//        requests.forEach(cb => cb(token))
//        requests = []
//        return instance(config)
//      }).catch(res => {
//        console.error('refreshtoken error =>', res)
//        window.location.href = '/'
//      }).finally(() => {
//        isRefreshing = false
//      })
//    } else {
//      // 正在刷新token，将返回一个未执行resolve的promise
//      return new Promise((resolve) => {
//        // 将resolve放进队列，用一个函数形式来保存，等token刷新后直接执行
//        requests.push((token) => {
//          config.baseURL = ''
//          config.headers['X-Token'] = token
//          resolve(instance(config))
//        })
//      })
//    }
//  }
//  return response
//}

-(AnyPromise*)jsonPostUrl:(NSString*)url params:(id)params{
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        
        [self login:url parameters:params success:^(id dic) {
            
            if ([dic[@"status"] intValue] != 0){
                
                NSError *err = [NSError errorWithDomain:@"ServiceError" code:[dic[@"status"] intValue] userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"请求失败", @"")}];
                resolve(err);
            }else{
                resolve(dic);
            }
        } failure:^(NSError *error) {
            resolve(error);
        }];
    }];

}

- (void)cancelRequest{
    
    if ([[QFTools sharedManager].tasks count] > 0) {
        NSLog(@"返回时取消网络请求");
        [[QFTools sharedManager].tasks makeObjectsPerformSelector:@selector(cancel)];
        //NSLog(@"tasks = %@",manager.tasks);
    }
    
    [LVFmdbTool deleteBrandData:nil];
    [LVFmdbTool deleteBikeData:nil];
    [LVFmdbTool deleteModelData:nil];
    [LVFmdbTool deletePeripheraData:nil];
    [LVFmdbTool deleteFingerprintData:nil];
    [LVFmdbTool deletePerpheraServicesInfoData:nil];
    [[SDImageCache sharedImageCache] removeImageFromMemoryForKey:[QFTools getuserInfo:@"icon"]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[LoadView sharedInstance] hide];
        [CommandDistributionServices removePeripheral:nil];
        [USER_DEFAULTS removeObjectForKey:logInUSERDIC];
        [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
        [USER_DEFAULTS removeObjectForKey:Key_BikeId];
        [USER_DEFAULTS synchronize];
        [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        
    });
    
}

@end
