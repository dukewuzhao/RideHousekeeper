//
//  APPPermissionDetectionManager.m
//  RideHousekeeper
//
//  Created by Apple on 2020/4/26.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import "APPPermissionDetectionManager.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UserNotifications/UserNotifications.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <CoreTelephony/CTCellularData.h>
#import <HealthKit/HealthKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <PassKit/PassKit.h>
#import <Speech/Speech.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Intents/Intents.h>

@implementation APPPermissionDetectionManager


/// 1.iOS开发检测是否开启定位
/// @param returnBlock returnBlock description
+ (void)openLocationServiceWithBlock:(ReturnBlock)returnBlock  {
    BOOL isOPen = NO;
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        isOPen = YES;
    }
    if (returnBlock) {
        returnBlock(isOPen);
    }
}

/// 2.iOS开发检测是否允许消息推送:
/// @param returnBlock returnBlock description
/*
+ (void)openMessageNotificationServiceWithBlock:(ReturnBlock)returnBlock
{
    BOOL isOpen = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        isOpen = YES;
    }
#else
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (type != UIRemoteNotificationTypeNone) {
        isOpen = YES;
    }
#endif
    if (returnBlock) {
        returnBlock(isOpen);
    }
}
*/

+ (void)openMessageNotificationServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (returnBlock) {
            returnBlock(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
        }
    }];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    returnBlock([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
#else
    UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    if (returnBlock) {
        returnBlock(type != UIRemoteNotificationTypeNone);
    }
#endif
}


/// iOS开发检测是否开启摄像头:
/// @param returnBlock returnBlock description
+ (void)openCaptureDeviceServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (returnBlock) {
                returnBlock(granted);
            }
        }];
        //return NO;
    } else if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        returnBlock(NO);
    } else {
        returnBlock(YES);
    }
#endif
}

/// iOS开发检测是否开启相册:
/// @param returnBlock <#returnBlock description#>
+ (void)openAlbumServiceWithBlock:(ReturnBlock)returnBlock
{
    BOOL isOpen;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    isOpen = YES;
    if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
        isOpen = NO;
    }
#else
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    isOpen = YES;
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
        isOpen = NO;
    }
#endif
    if (returnBlock) {
        returnBlock(isOpen);
    }
}


/// iOS开发检测是否开启麦克风:
/// @param returnBlock <#returnBlock description#>
+ (void)openRecordServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (returnBlock) {
                returnBlock(granted);
            }
        }];
    } else if (permissionStatus == AVAudioSessionRecordPermissionDenied) {
        returnBlock(NO);
    } else {
        returnBlock(YES);
    }
#endif
}


/// iOS开发检测是否开启通讯录:
/// @param returnBolck <#returnBolck description#>
+ (void)openContactsServiceWithBolck:(ReturnBlock)returnBolck
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CNAuthorizationStatus cnAuthStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (cnAuthStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
            if (returnBolck) {
                returnBolck(granted);
            }
        }];
    } else if (cnAuthStatus == CNAuthorizationStatusRestricted || cnAuthStatus == CNAuthorizationStatusDenied) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else {
        if (returnBolck) {
            returnBolck(YES);
        }
    }
#else
    //ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus != kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"Error: %@", (__bridge NSError *)error);
                    if (returnBolck) {
                        returnBolck(NO);
                    }
                } else {
                    if (returnBolck) {
                        returnBolck(YES);
                    }
                }
            });
        });
    } else {
        if (returnBolck) {
            returnBolck(YES);
        }
    }
#endif
}


/// iOS开发检测是否开启蓝牙:
/// @param returnBolck <#returnBolck description#>
+ (void)openPeripheralServiceWithBolck:(ReturnBlock)returnBolck
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    CBPeripheralManagerAuthorizationStatus cbAuthStatus = [CBPeripheralManager authorizationStatus];
    if (cbAuthStatus == CBPeripheralManagerAuthorizationStatusNotDetermined) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else if (cbAuthStatus == CBPeripheralManagerAuthorizationStatusRestricted || cbAuthStatus == CBPeripheralManagerAuthorizationStatusDenied) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else {
        if (returnBolck) {
            returnBolck(YES);
        }
    }
#endif
}

/*
/// iOS开发检测是否开启日历/备忘录:
/// @param returnBolck <#returnBolck description#>
/// @param entityType <#entityType description#>
+ (void)openEventServiceWithBolck:(ReturnBlock)returnBolck withType:(EKEntityType)entityType
{
    // EKEntityTypeEvent    代表日历
    // EKEntityTypeReminder 代表备忘
    EKAuthorizationStatus ekAuthStatus = [EKEventStore authorizationStatusForEntityType:entityType];
    if (ekAuthStatus == EKAuthorizationStatusNotDetermined) {
        EKEventStore *store = [[EKEventStore alloc] init];
        [store requestAccessToEntityType:entityType completion:^(BOOL granted, NSError *error) {
            if (returnBolck) {
                returnBolck(granted);
            }
        }];
    } else if (ekAuthStatus == EKAuthorizationStatusRestricted || ekAuthStatus == EKAuthorizationStatusDenied) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else {
        if (returnBolck) {
            returnBolck(YES);
        }
    }
}
*/

/// iOS开发检测是否开启联网:
/// @param returnBolck <#returnBolck description#>
+ (void)openEventServiceWithBolck:(ReturnBlock)returnBolck
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
        if (state == kCTCellularDataRestrictedStateUnknown || state == kCTCellularDataNotRestricted) {
            if (returnBolck) {
                returnBolck(NO);
            }
        } else {
            if (returnBolck) {
                returnBolck(YES);
            }
        }
    };
    CTCellularDataRestrictedState state = cellularData.restrictedState;
    if (state == kCTCellularDataRestrictedStateUnknown || state == kCTCellularDataNotRestricted) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else {
        if (returnBolck) {
            returnBolck(YES);
        }
    }
#endif
}


/// iOS开发检测是否开启健康:
/// @param returnBolck <#returnBolck description#>
+ (void)openHealthServiceWithBolck:(ReturnBlock)returnBolck
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    if (![HKHealthStore isHealthDataAvailable]) {
        if (returnBolck) {
            returnBolck(NO);
        }
    } else {
        HKHealthStore *healthStore = [[HKHealthStore alloc] init];
        HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        HKAuthorizationStatus hkAuthStatus = [healthStore authorizationStatusForType:hkObjectType];
        if (hkAuthStatus == HKAuthorizationStatusNotDetermined) {
            // 1. 你创建了一个NSSet对象，里面存有本篇教程中你将需要用到的从Health Stroe中读取的所有的类型：个人特征（血液类型、性别、出生日期）、数据采样信息（身体质量、身高）以及锻炼与健身的信息。
            NSSet <HKObjectType *> * healthKitTypesToRead = [[NSSet alloc] initWithArray:@[[HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],[HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType],[HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],[HKObjectType workoutType]]];
            // 2. 你创建了另一个NSSet对象，里面有你需要向Store写入的信息的所有类型（锻炼与健身的信息、BMI、能量消耗、运动距离）
            NSSet <HKSampleType *> * healthKitTypesToWrite = [[NSSet alloc] initWithArray:@[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],[HKObjectType workoutType]]];
            [healthStore requestAuthorizationToShareTypes:healthKitTypesToWrite readTypes:healthKitTypesToRead completion:^(BOOL success, NSError *error) {
                if (returnBolck) {
                    returnBolck(success);
                }
            }];
        } else if (hkAuthStatus == HKAuthorizationStatusSharingDenied) {
            if (returnBolck) {
                returnBolck(NO);
            }
        } else {
            if (returnBolck) {
                returnBolck(YES);
            }
        }
    }
#endif
}


#pragma mark - 开启Touch ID服务

/// iOS开发检测是否开启Touch ID:
/// @param returnBlock <#returnBlock description#>
+ (void)openTouchIDServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    LAContext *laContext = [[LAContext alloc] init];
    laContext.localizedFallbackTitle = @"输入密码";
    NSError *error;
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        NSLog(@"恭喜,Touch ID可以使用!");
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"需要验证您的指纹来确认您的身份信息" reply:^(BOOL success, NSError *error) {
            if (success) {
                // 识别成功
                if (returnBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        returnBlock(YES);
                    }];
                }
            } else if (error) {
                if (returnBlock) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        returnBlock(NO);
                    }];
                }
                if (error.code == LAErrorAuthenticationFailed) {
                    // 验证失败
                }
                if (error.code == LAErrorUserCancel) {
                    // 用户取消
                }
                if (error.code == LAErrorUserFallback) {
                    // 用户选择输入密码
                }
                if (error.code == LAErrorSystemCancel) {
                    // 系统取消
                }
                if (error.code == LAErrorPasscodeNotSet) {
                    // 密码没有设置
                }
            }
        }];
    } else {
        NSLog(@"设备不支持Touch ID功能,原因:%@",error);
        if (returnBlock) {
            returnBlock(NO);
        }
    }
#endif
}

#pragma mark - 开启Apple Pay服务

/// iOS开发检测是否开启Apple Pay:
/// @param returnBlock <#returnBlock description#>
+ (void)openApplePayServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
    NSArray<PKPaymentNetwork> *supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkDiscover];
    if ([PKPaymentAuthorizationViewController canMakePayments] && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]) {
        if (returnBlock) {
            returnBlock(YES);
        }
    } else {
        if (returnBlock) {
            returnBlock(NO);
        }
    }
#endif
}

#pragma mark - 开启语音识别服务
/// iOS开发检测是否开启语音识别:
/// @param returnBlock <#returnBlock description#>
+ (void)openSpeechServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    SFSpeechRecognizerAuthorizationStatus speechAuthStatus = [SFSpeechRecognizer authorizationStatus];
    if (speechAuthStatus == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            if (status == SFSpeechRecognizerAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(YES);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(YES);
                    }
                });
            }
        }];
    } else if (speechAuthStatus == SFSpeechRecognizerAuthorizationStatusAuthorized) {
        if (returnBlock) {
            returnBlock(YES);
        }
    } else{
        if (returnBlock) {
            returnBlock(NO);
        }
    }
#endif
}

#pragma mark - 开启媒体资料库/Apple Music 服务

/// iOS开发检测是否开启媒体资料库/Apple Music:
/// @param returnBlock <#returnBlock description#>
+ (void)openMediaPlayerServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_3
    MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
    if (authStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(YES);
                    }
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(NO);
                    }
                });
            }
        }];
    }else if (authStatus == MPMediaLibraryAuthorizationStatusAuthorized){
        if (returnBlock) {
            returnBlock(YES);
        }
    }else{
        if (returnBlock) {
            returnBlock(NO);
        }
    }
#endif
}

#pragma mark - 开启Siri服务
+ (void)openSiriServiceWithBlock:(ReturnBlock)returnBlock
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    INSiriAuthorizationStatus siriAutoStatus = [INPreferences siriAuthorizationStatus];
    if (siriAutoStatus == INSiriAuthorizationStatusNotDetermined) {
        [INPreferences requestSiriAuthorization:^(INSiriAuthorizationStatus status) {
            if (status == INSiriAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(YES);
                    }
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (returnBlock) {
                        returnBlock(YES);
                    }
                });
            }
        }];
    } else if (siriAutoStatus == INSiriAuthorizationStatusAuthorized) {
        if (returnBlock) {
            returnBlock(YES);
        }
    } else{
        if (returnBlock) {
            returnBlock(NO);
        }
    }
#endif
}

@end
