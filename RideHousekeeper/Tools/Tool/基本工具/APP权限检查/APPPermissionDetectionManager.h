//
//  APPPermissionDetectionManager.h
//  RideHousekeeper
//
//  Created by Apple on 2020/4/26.
//  Copyright © 2020 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    EKEntityTypeEvent,        //代表日历
    EKEntityTypeReminder      //代表备忘
} EKEntityType;

#if NS_BLOCKS_AVAILABLE
typedef void(^ReturnBlock)(BOOL isOpen);
#endif  
NS_ASSUME_NONNULL_BEGIN

@interface APPPermissionDetectionManager : NSObject

/// iOS开发检测是否开启定位:
/// @param returnBlock <#returnBlock description#>
+ (void)openLocationServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否允许消息推送:
/// @param returnBlock <#returnBlock description#>
+ (void)openMessageNotificationServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启摄像头:
/// @param returnBlock <#returnBlock description#>
+ (void)openCaptureDeviceServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启相册:
/// @param returnBlock <#returnBlock description#>
+ (void)openAlbumServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启麦克风:
/// @param returnBlock <#returnBlock description#>
+ (void)openRecordServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启通讯录:
/// @param returnBolck <#returnBolck description#>
+ (void)openContactsServiceWithBolck:(ReturnBlock)returnBolck;

/// iOS开发检测是否开启蓝牙:
/// @param returnBolck <#returnBolck description#>
+ (void)openPeripheralServiceWithBolck:(ReturnBlock)returnBolck;

//+ (void)openEventServiceWithBolck:(ReturnBlock)returnBolck withType:(EKEntityType)entityType;

/// iOS开发检测是否开启联网:
/// @param returnBolck <#returnBolck description#>
+ (void)openEventServiceWithBolck:(ReturnBlock)returnBolck;

/// iOS开发检测是否开启健康:
/// @param returnBolck <#returnBolck description#>
+ (void)openHealthServiceWithBolck:(ReturnBlock)returnBolck;

/// iOS开发检测是否开启Touch ID:
/// @param returnBlock <#returnBlock description#>
+ (void)openTouchIDServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启Apple Pay:
/// @param returnBlock <#returnBlock description#>
+ (void)openApplePayServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启语音识别:
/// @param returnBlock <#returnBlock description#>
+ (void)openSpeechServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启媒体资料库/Apple Music:
/// @param returnBlock <#returnBlock description#>
+ (void)openMediaPlayerServiceWithBlock:(ReturnBlock)returnBlock;

/// iOS开发检测是否开启Siri:
/// @param returnBlock <#returnBlock description#>
+ (void)openSiriServiceWithBlock:(ReturnBlock)returnBlock;


@end

NS_ASSUME_NONNULL_END
