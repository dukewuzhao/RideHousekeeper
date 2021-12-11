//
//  MultipleBindingLogicProcessingView.m
//  RideHousekeeper
//
//  Created by Apple on 2019/12/5.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "MultipleBindingLogicProcessingView.h"
#import "BindingHitView.h"
@interface MultipleBindingLogicProcessingView()

@end

@implementation MultipleBindingLogicProcessingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)switchScanGPSView{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_gps_real"];
    [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight *.12);
        make.width.mas_equalTo(ScreenWidth * .5);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.222);
    }];

    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在搜索车辆GPS设备(15s)...";
    [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
    }];

    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"搜索过程中靠近车辆";
    [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
}

-(void)switchBindBikeView{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight *.112);
        make.width.mas_equalTo(ScreenWidth * .6);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在绑定车辆...";
    [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"搜索过程中靠近车辆";
    [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
}

- (void)switchChangeGPSView{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupChangeGPSHead];
}

- (void)bindFailedWithCode:(NSInteger)code{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
    if (code == 1) {//扫码后绑定找不到GPS
        [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitle:@"直接绑定" forState:UIControlStateNormal];
        [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        @weakify(self);
        [(BaseViewController *)[QFTools viewController:self] navView].rightButtonBlock = ^{
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
            if (self.noGPSBindingBlock) {
                self.noGPSBindingBlock(code);
            }
            [[(BaseViewController *)[QFTools viewController:self] navView].rightButton removeFromSuperview];
            [(BaseViewController *)[QFTools viewController:self] navView].rightButton = nil;
        };
        
        [self addSubview:self.mainPictureView];
        self.mainPictureView.image = [UIImage imageNamed:@"icon_search_fail"];
        [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(ScreenHeight *.142);
            make.width.mas_equalTo(ScreenWidth *.413);
            make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.0);
        }];
        
        [self addSubview:self.operatingSubtitleLab];
        self.operatingSubtitleLab.text = @"没有找到车辆定位器";
        [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mainPictureView.mas_bottom).offset(10);
        }];

        [self addSubview:self.tipsForNextStepsLab];
        self.tipsForNextStepsLab.text = @"请检查\n车辆是否安装有GPS设备\n手机是否离车辆GPS设备足够近";
        self.tipsForNextStepsLab.font = FONT_PINGFAN(12);
        self.tipsForNextStepsLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(15);
        }];
        
        UIButton *scanAgainBtn = [[UIButton alloc] init];
        [scanAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
        [scanAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        scanAgainBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        scanAgainBtn.contentMode = UIViewContentModeCenter;
        [scanAgainBtn.layer setMasksToBounds:YES];
        [scanAgainBtn.layer setCornerRadius:10.0]; // 切圆角
        [[scanAgainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
            if (self.scanAgainBlock) {
                self.scanAgainBlock(code);
            }
            [[(BaseViewController *)[QFTools viewController:self] navView].rightButton removeFromSuperview];
            [(BaseViewController *)[QFTools viewController:self] navView].rightButton = nil;
        }];
        [self addSubview:scanAgainBtn];
        [scanAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-90);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
        }];
        
    }else if (code == 2){//车辆绑定失败
        
        [self addSubview:self.mainPictureView];
        self.mainPictureView.image = [UIImage imageNamed:@"icon_search_fail"];
        [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(ScreenHeight *.142);
            make.width.mas_equalTo(ScreenWidth *.413);
            make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.0);
        }];
        
        [self addSubview:self.operatingSubtitleLab];
        self.operatingSubtitleLab.text = @"找不到车辆定位器";
        [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mainPictureView.mas_bottom).offset(10);
        }];

        [self addSubview:self.tipsForNextStepsLab];
        self.tipsForNextStepsLab.text = @"请检查\n手机网络和蓝牙是否良好\n绑定时是否足够靠近了车辆";
        self.tipsForNextStepsLab.font = FONT_PINGFAN(12);
        self.tipsForNextStepsLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(15);
        }];
        @weakify(self);
        UIButton *BindingAgainBtn = [[UIButton alloc] init];
        [BindingAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
        [BindingAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        BindingAgainBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        BindingAgainBtn.contentMode = UIViewContentModeCenter;
        [BindingAgainBtn.layer setMasksToBounds:YES];
        [BindingAgainBtn.layer setCornerRadius:10.0]; // 切圆角
        [[BindingAgainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
            if (self.scanAgainBlock) {
                self.scanAgainBlock(code);
            }
        }];
        [self addSubview:BindingAgainBtn];
        [BindingAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-90);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
        }];
        
    }else if (code == 3){//钥匙绑定后找不到GPS
        [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitle:@"直接绑定" forState:UIControlStateNormal];
        [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        @weakify(self);
        [(BaseViewController *)[QFTools viewController:self] navView].rightButtonBlock = ^{
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            if (self.noGPSBindingBlock) {
                self.noGPSBindingBlock(code);
            }
            [[(BaseViewController *)[QFTools viewController:self] navView].rightButton removeFromSuperview];
            [(BaseViewController *)[QFTools viewController:self] navView].rightButton = nil;
        };
        
        [self addSubview:self.mainPictureView];
        self.mainPictureView.image = [UIImage imageNamed:@"icon_search_fail"];
        [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(ScreenHeight *.142);
            make.width.mas_equalTo(ScreenWidth *.413);
            make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.0);
        }];
        
        [self addSubview:self.operatingSubtitleLab];
        self.operatingSubtitleLab.text = @"没有找到车辆定位器";
        [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mainPictureView.mas_bottom).offset(10);
        }];

        [self addSubview:self.tipsForNextStepsLab];
        self.tipsForNextStepsLab.text = @"请检查\n车辆是否安装有GPS设备\n手机是否离车辆GPS设备足够近";
        self.tipsForNextStepsLab.font = FONT_PINGFAN(12);
        self.tipsForNextStepsLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(15);
        }];
        
        UIButton *BindingAgainBtn = [[UIButton alloc] init];
        [BindingAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
        [BindingAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        BindingAgainBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        BindingAgainBtn.contentMode = UIViewContentModeCenter;
        [BindingAgainBtn.layer setMasksToBounds:YES];
        [BindingAgainBtn.layer setCornerRadius:10.0]; // 切圆角
        [[BindingAgainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
            if (self.scanAgainBlock) {
                self.scanAgainBlock(code);
            }
            [[(BaseViewController *)[QFTools viewController:self] navView].rightButton removeFromSuperview];
            [(BaseViewController *)[QFTools viewController:self] navView].rightButton = nil;
        }];
        [self addSubview:BindingAgainBtn];
        [BindingAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-90);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
        }];
        
        UIButton *ScanSearchBtn = [[UIButton alloc] init];
        [ScanSearchBtn setTitle:@"扫码搜索" forState:UIControlStateNormal];
        ScanSearchBtn.titleLabel.font = FONT_PINGFAN(12);
        [ScanSearchBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        ScanSearchBtn.backgroundColor = [UIColor whiteColor];
        ScanSearchBtn.contentMode = UIViewContentModeCenter;
        [[ScanSearchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.scanSearchBlock) {
                self.scanSearchBlock(code);
            }
        }];
        [self addSubview:ScanSearchBtn];
        [ScanSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(BindingAgainBtn.mas_bottom).offset(5);
            make.size.mas_equalTo(CGSizeMake(150, 45));
        }];
    }else if (code == 4){//钥匙绑定套装无GPS属性
        [self setupECUKitWithOutGPS];
    }else if (code == 5){//更换GPS扫描不到GPS设备
        [self addSubview:self.mainPictureView];
        self.mainPictureView.image = [UIImage imageNamed:@"icon_search_fail"];
        [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(ScreenHeight *.142);
            make.width.mas_equalTo(ScreenWidth *.413);
            make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.0);
        }];
        
        [self addSubview:self.operatingSubtitleLab];
        self.operatingSubtitleLab.text = @"更换GPS设备失败";
        [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mainPictureView.mas_bottom).offset(10);
        }];

        [self addSubview:self.tipsForNextStepsLab];
        self.tipsForNextStepsLab.text = @"请检查\n手机网络和蓝牙是否良好\n绑定时是否足够靠近了车辆";
        self.tipsForNextStepsLab.font = FONT_PINGFAN(12);
        self.tipsForNextStepsLab.textColor = [QFTools colorWithHexString:@"#666666"];
        [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(15);
        }];
        @weakify(self);
        UIButton *BindingAgainBtn = [[UIButton alloc] init];
        [BindingAgainBtn setTitle:@"重新更换" forState:UIControlStateNormal];
        [BindingAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        BindingAgainBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        BindingAgainBtn.contentMode = UIViewContentModeCenter;
        [BindingAgainBtn.layer setMasksToBounds:YES];
        [BindingAgainBtn.layer setCornerRadius:10.0]; // 切圆角
        [[BindingAgainBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) ];
            if (self.scanAgainBlock) {
                self.scanAgainBlock(code);
            }
        }];
        [self addSubview:BindingAgainBtn];
        [BindingAgainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-90);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 150, 45));
        }];
    }
}

- (instancetype)initWithType:(ProcessingtType)type{
    if (self = [super init]) {
        
        switch (type) {
            case DuplicateBinding:
                [self setupDuplicateBindingHead];
            break;
            case DuplicateBindingKitWithGPS:
                [self setupDuplicateBindingHead];
            break;
            case DuplicateBindingWithOutGPS:
                [self setupDuplicateBindingHead];
            break;
            case DuplicateBindingWithOutECU:
                [self setupDuplicateBindingHead];
            break;
                
            case DuplicateBindingKitWithECU:
                [self setupDuplicateBindingHead];
            break;
            
            case DuplicateChangeECU:
                [self setupDuplicateChangeECUHead];
            break;
             
            case ChangeGPS:
                [self setupChangeGPSHead];
            break;
                
            case DuplicateChangeGPS:
                [self setupDuplicateChangeGPSHead];
            break;
                
            case SingleGPSBinding:
                [self setupSingleGPSBindingHead];
            break;
                
            case DuplicateSingleGPSBinding:
                [self setupDuplicateSingleGPSBindingHead];
            break;
                
            case AccessoriesGPSBinding:
                [self setupAccessoriesGPSbBindingHead];
            break;
            
            case DuplicateAccessoriesGPSBinding:
                [self setupAccessoriesGPSbBindingHead];
            break;
                
            case GPSKitWithECU:
                [self setupGPSKitHead];
            break;
             
            case DuplicateGPSKitWithECU:
                [self setupGPSKitHead];
            break;
                
            case GPSKitWithOutECU:
                [self setupGPSKitHead];
            break;
            
            case DuplicateGPSKitWithOutECU:
                [self setupGPSKitHead];
            break;
            
            case ECUKitWithGPS:
                [self setupAccessoriesGPSbBindingHead];
            break;
            case ECUKitWithOutGPS:
                [self setupECUKitWithOutGPS];
            break;
            case UnbindingBike:
                [self setupUnbindingBikeHead];
            break;
            case UnbindingGPS:
                [self setupUnbindingGPS:type];
            break;
            case UnbindingSingelGPS:
                [self setupUnbindingGPS:type];
            break;
            default:
            break;
        }
        
    }
    return self;
}

-(void)setupDuplicateBindingHead{
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.text = @"该车辆已被其它账号绑定";
    self.operatingPromptLab.textColor = [UIColor blackColor];
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(60);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"若不是您的车辆\n可以请车辆主人解绑车辆";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: DuplicateBinding];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupDuplicateChangeECUHead{
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.text = @"该中控已被其它账号绑定";
    self.operatingPromptLab.textColor = [UIColor blackColor];
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(60);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"若不是您的智能中控\n可以请车辆主人解绑车辆";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: DuplicateBinding];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupChangeGPSHead{
    
    BindingHitView *hitView = [[BindingHitView alloc] initWithFrame:CGRectZero title:@"更换定位器前请确认车辆配件信息，更换后车辆轨迹信息将丢失。" color:[UIColor colorWithRed:255/255.0 green:94/255.0 blue:0/255.0 alpha:.15]];
    [self addSubview:hitView];
    [hitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_replace_search_bike"];
    [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(ScreenWidth * .272);
        make.top.equalTo(self).offset(ScreenHeight *.12);
        make.bottom.equalTo(self).offset(-ScreenHeight *.226);
        //make.width.mas_equalTo(self.mainPictureView.mas_height).multipliedBy(0.717);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在搜索车辆定位追踪器(15s)...";
    [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
    }];

    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"搜索过程中靠近车辆";
    [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
}

-(void)setupDuplicateChangeGPSHead{
    
    BindingHitView *hitView = [[BindingHitView alloc] initWithFrame:CGRectZero title:@"更换定位器前请确认车辆配件信息，更换后车辆轨迹信息将丢失。" color:[UIColor colorWithRed:255/255.0 green:94/255.0 blue:0/255.0 alpha:.15]];
    [self addSubview:hitView];
    [hitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.text = @"该定位器已被其他账号绑定";
    self.operatingPromptLab.textColor = [UIColor blackColor];
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_changeGPS"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(60);
        make.width.mas_equalTo(ScreenWidth * .4);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.438);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"若不是您的定位器\n可以请车辆主人删除配件定位器";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: DuplicateChangeGPS];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupSingleGPSBindingHead{
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight*.15);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
        
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在搜索当前车辆...";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"搜索过程中靠近车辆";
    [self.tipsForNextStepsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: SingleGPSBinding];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupDuplicateSingleGPSBindingHead{
    
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.text = @"该车辆已被其它账号绑定";
    self.operatingPromptLab.textColor = [UIColor blackColor];
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(60);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"若不是您的车辆\n可以请车辆主人解绑车辆";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: DuplicateBinding];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupAccessoriesGPSbBindingHead{
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_gps_real"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight *.12);
        make.width.mas_equalTo(ScreenWidth * .5);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.222);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在搜索车辆GPS设备(15s)...";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"搜索过程中靠近车辆";
    [self.tipsForNextStepsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: AccessoriesGPSBinding];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupGPSKitHead{
    //缺失单GPS绑定
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight*.15);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
        
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"正在搜索该车辆...";
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(35);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: GPSKitWithECU];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupECUKitWithOutGPS{
    
    //钥匙绑定后没有GPS
    [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitle:@"直接绑定" forState:UIControlStateNormal];
    [[(BaseViewController *)[QFTools viewController:self] navView].rightButton setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    @weakify(self);
    [(BaseViewController *)[QFTools viewController:self] navView].rightButtonBlock = ^{
        @strongify(self);
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (self.noGPSBindingBlock) {
            self.noGPSBindingBlock(4);
        }
        [[(BaseViewController *)[QFTools viewController:self] navView].rightButton removeFromSuperview];
        [(BaseViewController *)[QFTools viewController:self] navView].rightButton = nil;
    };
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_search_fail"];
    [self.mainPictureView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(ScreenHeight *.142);
        make.width.mas_equalTo(ScreenWidth *.413);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.0);
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"没有找到车辆定位器";
    [self.operatingSubtitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(10);
    }];

    [self addSubview:self.tipsForNextStepsLab];
    self.tipsForNextStepsLab.text = @"请检查\n车辆是否安装有GPS设备\n手机是否离车辆GPS设备足够近";
    self.tipsForNextStepsLab.font = FONT_PINGFAN(12);
    self.tipsForNextStepsLab.textColor = [QFTools colorWithHexString:@"#666666"];
    [self.tipsForNextStepsLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(15);
    }];
    
    UIButton *ScanSearchBtn = [[UIButton alloc] init];
    [ScanSearchBtn setTitle:@"扫码搜索" forState:UIControlStateNormal];
    ScanSearchBtn.titleLabel.font = FONT_PINGFAN(12);
    [ScanSearchBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    ScanSearchBtn.backgroundColor = [UIColor whiteColor];
    ScanSearchBtn.contentMode = UIViewContentModeCenter;
    [[ScanSearchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.scanSearchBlock) {
            self.scanSearchBlock(4);
        }
    }];
    [self addSubview:ScanSearchBtn];
    [ScanSearchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-60);
        make.size.mas_equalTo(CGSizeMake(150, 45));
    }];
}

-(void)setupUnbindingBikeHead{
    
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.font = FONT_PINGFAN(20);
    self.operatingPromptLab.textColor = [QFTools colorWithHexString:@"#333333"];
    self.operatingPromptLab.text = @"正在解绑智能车辆";
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
        make.height.mas_equalTo(28);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"two_wheeler_icon"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(62);
        make.width.mas_equalTo(ScreenWidth * .48);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(.649);
        
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.font = FONT_PINGFAN(15);
    self.operatingSubtitleLab.text = @"解绑会清空车辆信息仅保留配件";
    self.operatingSubtitleLab.textColor = [QFTools colorWithHexString:@"#333333"];
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(18);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
        make.height.mas_equalTo(20);
    }];
    
    [self addSubview:self.unbindPromptLab];
    self.unbindPromptLab.font = FONT_PINGFAN(12);
    self.unbindPromptLab.text = @"解绑时需要连接车辆";
    self.unbindPromptLab.textColor = [QFTools colorWithHexString:@"#666666"];
    [self.unbindPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
        make.height.mas_equalTo(17);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType: UnbindingBike];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(void)setupUnbindingGPS:(ProcessingtType)type{
    
    [self addSubview:self.operatingPromptLab];
    self.operatingPromptLab.text = @"正在解绑车辆定位器";
    self.operatingPromptLab.font = FONT_PINGFAN(20);
    self.operatingPromptLab.textColor = [QFTools colorWithHexString:@"#333333"];
    [self.operatingPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.mainPictureView];
    self.mainPictureView.image = [UIImage imageNamed:@"icon_gps_real"];
    [self.mainPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.operatingPromptLab.mas_bottom).offset(5);
        make.width.mas_equalTo(ScreenWidth * .42);
        make.height.mas_equalTo(self.mainPictureView.mas_width).multipliedBy(1.2);
        
    }];
    
    [self addSubview:self.operatingSubtitleLab];
    self.operatingSubtitleLab.text = @"解绑会清空定位器设备信息且无法恢复";
    self.operatingSubtitleLab.font = FONT_PINGFAN(15);
    self.operatingSubtitleLab.textColor = [QFTools colorWithHexString:@"#333333"];
    [self.operatingSubtitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainPictureView.mas_bottom).offset(40);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
    }];
    
    [self addSubview:self.unbindPromptLab];
    self.unbindPromptLab.font = FONT_PINGFAN(12);
    self.unbindPromptLab.text = @"解绑时需要靠近车辆检索设备";
    self.unbindPromptLab.textColor = [QFTools colorWithHexString:@"#666666"];
    [self.unbindPromptLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.operatingSubtitleLab.mas_bottom).offset(10);
        make.left.equalTo(self).offset(45);
        make.right.equalTo(self).offset(-45);
        make.height.mas_equalTo(17);
    }];
    
    _footView = [[MultipleBindingLogicProcessingFootView alloc] initWithType:type];
    [self addSubview:_footView];
    [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

-(UILabel *)operatingPromptLab{
    if (!_operatingPromptLab) {
        _operatingPromptLab = [[UILabel alloc]init];
        _operatingPromptLab.numberOfLines = 0;
        _operatingPromptLab.textAlignment = NSTextAlignmentCenter;
    }
    return _operatingPromptLab;
}

-(UIImageView *)mainPictureView{
    if (!_mainPictureView) {
        _mainPictureView = [[UIImageView alloc]init];
    }
    return _mainPictureView;
}

-(UILabel *)operatingSubtitleLab{
    if (!_operatingSubtitleLab) {
        _operatingSubtitleLab = [[UILabel alloc]init];
        _operatingSubtitleLab.numberOfLines = 0;
        _operatingSubtitleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _operatingSubtitleLab;
}



-(UILabel *)unbindPromptLab{
    if (!_unbindPromptLab) {
        _unbindPromptLab = [[UILabel alloc]init];
        _unbindPromptLab.numberOfLines = 0;
        _unbindPromptLab.textAlignment = NSTextAlignmentCenter;
    }
    return _unbindPromptLab;
}

-(UILabel *)tipsForNextStepsLab{
    if (!_tipsForNextStepsLab) {
        _tipsForNextStepsLab = [[UILabel alloc]init];
        _tipsForNextStepsLab.numberOfLines = 0;
        _tipsForNextStepsLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipsForNextStepsLab;
}

@end
