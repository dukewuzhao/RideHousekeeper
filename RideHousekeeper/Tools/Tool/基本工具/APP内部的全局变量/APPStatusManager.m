//
//  GPSActivationManager.m
//  RideHousekeeper
//
//  Created by Apple on 2020/3/27.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "APPStatusManager.h"
#import <pthread.h>

//定义block类型
typedef void(^KYSBlock)();

//定义获取全局队列方法
#define KYS_GLOBAL_QUEUE(block) \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ \
    while (1) { \
        block();\
    }\
})

@interface APPStatusManager ()

@property (nonatomic,assign)  BOOL binding;//绑定

@property (nonatomic,assign)  BOOL blueToothOpen;//蓝牙开关

@property (nonatomic,assign)  BOOL upgrate;//固件升级

@property (nonatomic,assign)  BOOL needUpdate;

@property (nonatomic,assign)  BOOL updatePaymentStatus;

@property (nonatomic,assign)  BindingType bindingType;

@end

@implementation APPStatusManager

pthread_mutex_t bindingLock,blueToothOpenLock ,upgrateLock,needUpdateLock,updatePaymentStatusLock;

static inline void pthread_mutex_init_recursive(pthread_mutex_t *mutex, bool recursive) {
#define YYMUTEX_ASSERT_ON_ERROR(x_) do { \
__unused volatile int res = (x_); \
assert(res == 0); \
} while (0)
    assert(mutex != NULL);
    if (!recursive) {
        //普通锁
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init(mutex, NULL));
    } else {
        //递归锁
        pthread_mutexattr_t attr;
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_init (&attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_settype (&attr, PTHREAD_MUTEX_RECURSIVE));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutex_init (mutex, &attr));
        YYMUTEX_ASSERT_ON_ERROR(pthread_mutexattr_destroy (&attr));
    }
#undef YYMUTEX_ASSERT_ON_ERROR
}

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static APPStatusManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[APPStatusManager alloc] init];
        pthread_mutex_init_recursive(&bindingLock,YES);
        pthread_mutex_init_recursive(&blueToothOpenLock,YES);
        pthread_mutex_init_recursive(&upgrateLock,YES);
        pthread_mutex_init_recursive(&needUpdateLock,YES);
        pthread_mutex_init_recursive(&updatePaymentStatusLock,YES);
    });
    return instance;
}

-(void)setActivatedJumpStstus:(BOOL)status{
    
    pthread_mutex_lock(&needUpdateLock);
    _needUpdate = status;
    pthread_mutex_unlock(&needUpdateLock);
}
-(BOOL)getActivatedJumpStstus{
    return _needUpdate;
}

-(void)setBikeBindingStstus:(BOOL)status{
    pthread_mutex_lock(&bindingLock);
    _binding = status;
    pthread_mutex_unlock(&bindingLock);
}
-(BOOL)getBikeBindingStstus{
    return _binding;
}

-(void)setBLEStstus:(BOOL)status{
    pthread_mutex_lock(&blueToothOpenLock);
    _blueToothOpen = status;
    pthread_mutex_unlock(&blueToothOpenLock);
}
-(BOOL)getBLEStstus{
    return _blueToothOpen;
}

-(void)setBikeFirmwareUpdateStstus:(BOOL)status{
    pthread_mutex_lock(&upgrateLock);
    _upgrate = status;
    pthread_mutex_unlock(&upgrateLock);
}
-(BOOL)getBikeFirmwareUpdateStstus{
    return _upgrate;
}

-(void)setUpdatePaymentStatus:(BOOL)status{
    pthread_mutex_lock(&updatePaymentStatusLock);
    _updatePaymentStatus = status;
    pthread_mutex_unlock(&updatePaymentStatusLock);
}
-(BOOL)getUpdatePaymentStatus{
    return _updatePaymentStatus;
}

-(void)setChangeDeviceType:(BindingType)type{
    
    _bindingType = type;
}

-(BindingType)getChangeDeviceType{
    return _bindingType;
}

/*
-(void)aasas{
    
    __block pthread_mutex_t lock;
    pthread_mutex_init_recursive(&lock,false);
    KYSBlock block0=^{
        NSLog(@"线程 0：加锁");
        pthread_mutex_lock(&lock);
        NSLog(@"线程 0：睡眠 1 秒");
        sleep(1);
        pthread_mutex_unlock(&lock);
        NSLog(@"线程 0：解锁");
    };
    KYS_GLOBAL_QUEUE(block0);
    
    KYSBlock block1=^(){
        NSLog(@"线程 1：加锁");
        pthread_mutex_lock(&lock);
        NSLog(@"线程 1：睡眠 2 秒");
        sleep(2);
        pthread_mutex_unlock(&lock);
        NSLog(@"线程 1：解锁");
    };
    KYS_GLOBAL_QUEUE(block1);

    KYSBlock block2=^{
        NSLog(@"线程 2：加锁");
        pthread_mutex_lock(&lock);
        NSLog(@"线程 2：睡眠 3 秒");
        sleep(3);
        pthread_mutex_unlock(&lock);
        NSLog(@"线程 2：解锁");
    };
    KYS_GLOBAL_QUEUE(block2);
    
}
*/
@end
