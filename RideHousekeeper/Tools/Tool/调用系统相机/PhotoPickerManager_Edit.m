//
//  PhotoPickerManager.m
//  ShunTian
//
//  Created by zhanshu on 15/9/6.
//  Copyright (c) 2015年 zhanshu. All rights reserved.
//

#import "PhotoPickerManager_Edit.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
@interface PhotoPickerManager_Edit () <UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate>

@property (nonatomic, weak)     UIViewController          *fromController;
@property (nonatomic, copy)     HYBPickerCompelitionBlock completion;
@property (nonatomic, copy)     HYBPickerCancelBlock      cancelBlock;

@end
@implementation PhotoPickerManager_Edit

+ (PhotoPickerManager_Edit *)shared {
    static PhotoPickerManager_Edit *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock {
    self.completion = [completion copy];
    self.cancelBlock = [cancelBlock copy];
    self.fromController = fromController;
    
    //BOOL isCamera=[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"头像上传" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        @weakify(self);
        [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [APPPermissionDetectionManager openAlbumServiceWithBlock:^(BOOL isOpen) {
                if (isOpen) {
                    @strongify(self);
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
                    picker.allowsEditing = YES;
                    picker.navigationBar.translucent=NO;
                    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
                    [self.fromController presentViewController:picker animated:YES completion:nil];
                }else{
                    DW_AlertView *alert = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"未开启访问相册权限，现在去开启！" sureButtionTitle:@"确定" cancelButtionTitle:@"取消"];
                    alert.sureBolck = ^(BOOL clickStatu) {
                        NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if (@available(iOS 10.0, *)) {
                            NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                            [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                        } else {
                            // Fallback on earlier versions
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    };
                }
            }];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [APPPermissionDetectionManager openCaptureDeviceServiceWithBlock:^(BOOL isOpen) {
                if (!isOpen) {
                    DW_AlertView *alert = [[DW_AlertView alloc] initBackroundImage:nil Title:@"提示" contentString:@"未开启访问相机权限，现在去开启！" sureButtionTitle:@"确定" cancelButtionTitle:@"取消"];
                    alert.sureBolck = ^(BOOL clickStatu) {
                        NSURL * url= [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if (@available(iOS 10.0, *)) {
                            NSDictionary *options = @{UIApplicationOpenURLOptionsSourceApplicationKey : @YES};
                            [[UIApplication sharedApplication] openURL:url options:options completionHandler:nil];
                        } else {
                            // Fallback on earlier versions
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    };
                }else{
                    @strongify(self);
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.navigationBar.translucent=NO;
                    // 设置导航默认标题的颜色及字体大小
                    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};
                    [fromController presentViewController:picker animated:YES completion:nil];
                }
            }];
        }]];
        
        //添加取消选项
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //[alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        //显示alertController
        //[self.fromController.view addSubview:alertController.view];
        [self.fromController presentViewController:alertController animated:YES completion:nil];
    
    //});
    
    
    return;
}
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock
                      clickAt:(NSInteger)index {
    self.completion = [completion copy];
    self.cancelBlock = [cancelBlock copy];
    self.fromController = fromController;
    [self actionSheet:nil clickedButtonAtIndex:index];
}
- (void)showActionSheetInView:(UIView *)inView fromController:(UIViewController *)fromController completion:(HYBPickerCompelitionBlock)completion cancelBlock:(HYBPickerCancelBlock)cancelBlock maxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    [self showActionSheetInView:inView fromController:fromController completion:completion cancelBlock:cancelBlock];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL isCamera=[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (buttonIndex == 0) {
        // 从相册选择
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.allowsEditing = YES;
        picker.navigationBar.translucent=NO;
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
        [self.fromController presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) { // 拍照
        if (isCamera) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.navigationBar.translucent=NO;
            // 设置导航默认标题的颜色及字体大小
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};
            [self.fromController presentViewController:picker animated:YES completion:nil];
        }else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"没有摄像头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    return;
}

#pragma mark - UIImagePickerControllerDelegate
// 选择了图片或者拍照了
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.fromController setNeedsStatusBarAppearanceUpdate];
    if (image && self.completion) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.completion) {
                    self.completion(@[image]);
                }
            });
        });
    }
    return;
}

// 取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker {
    [aPicker dismissViewControllerAnimated:YES completion:nil];  
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.fromController setNeedsStatusBarAppearanceUpdate];
    if (self.cancelBlock) {  
        
        self.cancelBlock();
    }  
    return;  
}  




-(void)dealloc{
    
    self.fromController = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

@end
