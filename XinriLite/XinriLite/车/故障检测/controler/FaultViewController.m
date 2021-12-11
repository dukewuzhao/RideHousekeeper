//
//  FaultViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "FaultViewController.h"
#if __has_include(<YYImage/YYImage.h>)
#import <YYImage/YYImage.h>
#elif __has_include("YYImage.h")
#import "YYImage.h"
#endif
@interface FaultViewController ()
{
    NSMutableArray *faultArray;
}
@property(nonatomic,strong) MSWeakTimer *animation;
@property(nonatomic,assign) NSInteger tagnum;
@property(nonatomic,weak) UIView *headview;
@property(nonatomic,weak) UIScrollView *footView;
@property(nonatomic,weak) UIView *electric;
@property(nonatomic,weak) UIView *rotation;
@property(nonatomic,weak) UIView *controller;
@property(nonatomic,weak) UIView *checkPressureView;
@property(nonatomic,weak) UIView *undervoltage;
@property(nonatomic,weak) UIButton *experien;
@property(nonatomic,strong) YYAnimatedImageView *imageView;
@property(nonatomic,weak) UILabel *checkLab;
@property(nonatomic,assign) BOOL checkPressure;
@property(nonatomic,strong) BikeModel *bikeModel;
@property(nonatomic,assign) NSInteger pressureNum;
@property(nonatomic,assign) BOOL frontIsNormal;
@property(nonatomic,assign) NSInteger frontPressureCode;
@property(nonatomic,assign) BOOL rearIsNormal;
@property(nonatomic,assign) NSInteger rearPressureCode;
@end

@implementation FaultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)setBikeid:(NSInteger)bikeid{
    _bikeid = bikeid;
    NSMutableArray *bikemodels = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid]];
    _bikeModel = bikemodels.firstObject;
    NSMutableArray *peripheraModals = [LVFmdbTool queryPeripheraData:[NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%d' AND bikeid LIKE '%zd'", 6,bikeid]];
    if (_bikeModel.tpm_func == 1 && peripheraModals.count > 0) {
        _checkPressure = YES;
        _pressureNum = peripheraModals.count;
    }else{
        _checkPressure = NO;
    }
}

- (void)setQuerydate:(NSString *)querydate{
    _querydate = querydate;
    NSInteger firstTireValue,secondTireValue = 0;
    Byte *byte=(Byte *)[[ConverUtil stringToByte:querydate] bytes];
    
    if (byte[16]==255) {
        firstTireValue = -1*3.1333;
    }else if (byte[16]==254){
        firstTireValue = -2*3.1333;
    }else{
        firstTireValue = byte[16]*3.1333;
    }
    
    if (byte[17]==255) {
        secondTireValue = -1*3.1333;
    }else if (byte[17]==254){
        secondTireValue = -2*3.1333;
    }else{
        secondTireValue = byte[17]*3.1333;
    }
        
    if ((firstTireValue >=200 && firstTireValue <=300 )||firstTireValue==0 ||firstTireValue==-3){
        _frontIsNormal = YES;
        _frontPressureCode = 0;
    }else if ((firstTireValue <=6 && firstTireValue>0)){
        _frontIsNormal = YES;
        _frontPressureCode = 0;
    }else if ((firstTireValue <200 && firstTireValue>6)){
        _frontIsNormal = NO;
        _frontPressureCode = 1;
    }else if(firstTireValue >300){
        _frontIsNormal = NO;
        _frontPressureCode = 2;
    }else if(firstTireValue == -6){
        _frontIsNormal = NO;
        _frontPressureCode = 3;
    }
    
    if ((secondTireValue >=200 && secondTireValue <=300 )||secondTireValue==0 ||secondTireValue==-3){
        _rearIsNormal = YES;
        _rearPressureCode = 0;
    }else if ((secondTireValue <=6 && secondTireValue>0)){
        _rearIsNormal = YES;
        _rearPressureCode = 0;
    }else if ((secondTireValue <200 && secondTireValue>6)){
        _rearIsNormal = NO;
        _rearPressureCode = 1;
    }else if(secondTireValue >300){
        _rearIsNormal = NO;
        _rearPressureCode = 2;
    }else if(secondTireValue == -6){
        _rearIsNormal = NO;
        _rearPressureCode = 3;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight *.45 - navHeight)];
    headview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headview];
    self.headview = headview;
    
    faultArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"electric_fault", nil),NSLocalizedString(@"turn_fault", nil),NSLocalizedString(@"controller_fault", nil),NSLocalizedString(@"electric_face", nil),NSLocalizedString(@"batt_vol_fault", nil),nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(queryFaultSuccess:) name:KNotification_QueryData object:nil];
    [self setupView];
    UIImageView *defaultImage = [[UIImageView alloc] init];
    defaultImage.frame = _imageView.frame;
    defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked"];
    [headview addSubview:defaultImage];
    self.tagnum = 1500;
    [self experienClick];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"fault_check", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}


- (void)setupView{
    
    YYImage *image = [YYImage imageNamed:@"testing.gif"];
    _imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    _imageView.autoPlayAnimatedImage = NO;
    
    if(ScreenHeight <= 568){
    
        _imageView.frame = CGRectMake(ScreenWidth*.31,20,ScreenWidth*.38,ScreenWidth*.38);
    }else{
    
        _imageView.frame = CGRectMake(ScreenWidth*.27,20,ScreenWidth*.46,ScreenWidth*.46);
    }
    [self.headview addSubview:_imageView];
    _imageView.hidden = YES;
    
    UILabel *checkLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 10, ScreenWidth, 22)];
    checkLab.textColor = [UIColor whiteColor];
    checkLab.textAlignment = NSTextAlignmentCenter;
    checkLab.font = [UIFont systemFontOfSize:14];
    checkLab.textColor = [UIColor whiteColor];
    [self.headview addSubview:checkLab];
    self.checkLab = checkLab;
    
    UIScrollView *footView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headview.frame), ScreenWidth, ScreenHeight*.55)];
    [self .view addSubview:footView];
    self.footView = footView;
    
    UIView *electric = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    electric.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    electric.tag = 1500;
    [footView addSubview:electric];
    self.electric = electric;
    
    UIImageView *electricIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    electricIcon.image = [UIImage imageNamed:@"electric"];
    [electric addSubview:electricIcon];
    
    UILabel *electricLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(electricIcon.frame)+22, 10, 120, 22)];
    electricLable.text = NSLocalizedString(@"electric_fault", nil);
    electricLable.textColor = [UIColor whiteColor];
    electricLable.textAlignment = NSTextAlignmentLeft;
    electricLable.font = [UIFont systemFontOfSize:16];
    [electric addSubview:electricLable];
    
    UIImageView *eletricstayImg = [[UIImageView alloc] init];
    [electric addSubview:eletricstayImg];
    [eletricstayImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(electric);
        make.right.equalTo(electric).offset(-20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
        eletricstayImg.image = [UIImage imageNamed:@"icon_fault_down"];
    }else if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
        eletricstayImg.image = [UIImage imageNamed:@"icon_fault_ok"];
    }
    
    UIView *rotation = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(electric.frame)+5, ScreenWidth, 44)];
    rotation.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    rotation.tag = 1501;
    [footView addSubview:rotation];
    self.rotation = rotation;
    
    UIImageView *rotationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    rotationIcon.image = [UIImage imageNamed:@"rotation"];
    [rotation addSubview:rotationIcon];
    
    UILabel *rotationLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rotationIcon.frame)+22, 10, 120, 22)];
    rotationLab.text = NSLocalizedString(@"turn_fault", nil);
    rotationLab.textColor = [UIColor whiteColor];
    rotationLab.textAlignment = NSTextAlignmentLeft;
    rotationLab.font = [UIFont systemFontOfSize:16];
    [rotation addSubview:rotationLab];
    
    UIImageView *rotationStateImg = [[UIImageView alloc] init];
    [rotation addSubview:rotationStateImg];
    [rotationStateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rotation);
        make.right.equalTo(rotation).offset(-20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]) {
        rotationStateImg.image = [UIImage imageNamed:@"icon_fault_down"];
    }else if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
        rotationStateImg.image = [UIImage imageNamed:@"icon_fault_ok"];
    }
    
    UIView *controller = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(rotation.frame)+5, ScreenWidth, 44)];
    controller.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    controller.tag = 1502;
    [footView addSubview:controller];
    self.controller = controller;
    
    UIImageView *controllerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    controllerIcon.image = [UIImage imageNamed:@"controller"];
    [controller addSubview:controllerIcon];
    
    UILabel *controllerIconLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(electricIcon.frame)+22, 10, 120, 22)];
    controllerIconLab.text = NSLocalizedString(@"controller_fault", nil);
    controllerIconLab.textColor = [UIColor whiteColor];
    controllerIconLab.textAlignment = NSTextAlignmentLeft;
    controllerIconLab.font = [UIFont systemFontOfSize:16];
    [controller addSubview:controllerIconLab];
    
    UIImageView *controllerStateImg = [[UIImageView alloc] init];
    [controller addSubview:controllerStateImg];
    [controllerStateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controller);
        make.right.equalTo(controller).offset(-20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]) {
        controllerStateImg.image = [UIImage imageNamed:@"icon_fault_down"];
    }else if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]){
        controllerStateImg.image = [UIImage imageNamed:@"icon_fault_ok"];
    }
    
    UIView *undervoltage = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(controller.frame)+5, ScreenWidth, 44)];
    undervoltage.tag = 1503;
    undervoltage.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [footView addSubview:undervoltage];
    self.undervoltage = undervoltage;
    
    UIImageView *undervoltageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    undervoltageIcon.image = [UIImage imageNamed:@"undervoltage"];
    [undervoltage addSubview:undervoltageIcon];
    
    UILabel *undervoltageLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(undervoltageIcon.frame)+22, 10, 120, 22)];
    undervoltageLab.text = NSLocalizedString(@"batt_vol_fault", nil);
    undervoltageLab.textColor = [UIColor whiteColor];
    undervoltageLab.textAlignment = NSTextAlignmentLeft;
    undervoltageLab.font = [UIFont systemFontOfSize:16];
    [undervoltage addSubview:undervoltageLab];
    
    UIImageView *undervoltageStateImg = [[UIImageView alloc] init];
    [undervoltage addSubview:undervoltageStateImg];
    [undervoltageStateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(undervoltage);
        make.right.equalTo(undervoltage).offset(-20);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]) {
        undervoltageStateImg.image = [UIImage imageNamed:@"icon_fault_down"];
    }else if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
        undervoltageStateImg.image = [UIImage imageNamed:@"icon_fault_ok"];
    }
    
    if (_checkPressure) {
        footView.contentSize = CGSizeMake(ScreenWidth, 370);
        UIView *checkPressureView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(undervoltage.frame)+5, ScreenWidth, 44)];
        checkPressureView.tag = 1504;
        checkPressureView.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
        [footView addSubview:checkPressureView];
        self.checkPressureView = checkPressureView;

        UIImageView *checkPressureIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
        checkPressureIcon.image = [UIImage imageNamed:@"icon_fault_tirt_ok"];
        [checkPressureView addSubview:checkPressureIcon];

        UILabel *checkPressureLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkPressureIcon.frame)+22, 10, 120, 22)];
        checkPressureLab.text = NSLocalizedString(@"tire_pressure", nil);
        checkPressureLab.textColor = [UIColor whiteColor];
        checkPressureLab.textAlignment = NSTextAlignmentLeft;
        checkPressureLab.font = [UIFont systemFontOfSize:16];
        [checkPressureView addSubview:checkPressureLab];

        UIImageView *checkPressureImg = [[UIImageView alloc] init];
        [checkPressureView addSubview:checkPressureImg];
        [checkPressureImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(checkPressureView).offset(10);
            make.right.equalTo(checkPressureView).offset(-20);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];

        if (_frontIsNormal && _rearIsNormal) {
            checkPressureImg.image = [UIImage imageNamed:@"icon_fault_ok"];
        }else{
            
            if (!_frontIsNormal &&! _rearIsNormal) {
                checkPressureView.height = 84;
                checkPressureImg.image = [UIImage imageNamed:@"icon_fault_down"];
                UILabel *checkPressureSubLab = [[UILabel alloc] init];
                checkPressureSubLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                checkPressureSubLab.textAlignment = NSTextAlignmentLeft;
                checkPressureSubLab.font = FONT_PINGFAN(15);
                [checkPressureView addSubview:checkPressureSubLab];
                [checkPressureSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(checkPressureLab.mas_bottom).offset(10);
                    make.left.equalTo(checkPressureLab);
                    make.height.mas_equalTo(15);
                }];
                
                switch (_frontPressureCode) {
                    case 1:
                        checkPressureSubLab.text = NSLocalizedString(@"tirt_f_to_low", nil);
                    break;
                    case 2:
                        checkPressureSubLab.text = NSLocalizedString(@"tirt_f_to_high", nil);
                    break;
                    case 3:
                        checkPressureSubLab.text = NSLocalizedString(@"tirt_f_abnormal", nil);
                    break;
                    default:
                        break;
                }
                
                UILabel *checkPressureSecLab = [[UILabel alloc] init];
                checkPressureSecLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                checkPressureSecLab.textAlignment = NSTextAlignmentLeft;
                checkPressureSecLab.font = FONT_PINGFAN(15);
                [checkPressureView addSubview:checkPressureSecLab];
                [checkPressureSecLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(checkPressureSubLab.mas_bottom).offset(5);
                    make.left.equalTo(checkPressureLab);
                    make.height.mas_equalTo(15);
                }];
                
                switch (_rearPressureCode) {
                    case 1:
                        checkPressureSecLab.text = NSLocalizedString(@"tirt_r_to_low", nil);
                    break;
                    case 2:
                        checkPressureSecLab.text = NSLocalizedString(@"tirt_r_to_high", nil);
                    break;
                    case 3:
                        checkPressureSecLab.text = NSLocalizedString(@"tirt_r_abnormal", nil);
                    break;
                    default:
                        break;
                }
                
            }else if (_frontIsNormal &&! _rearIsNormal){
                checkPressureImg.image = [UIImage imageNamed:@"icon_fault_down"];
                if (_pressureNum == 1) {
                    checkPressureView.height = 64;
                    UILabel *checkPressureSubLab = [[UILabel alloc] init];
                    checkPressureSubLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                    checkPressureSubLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSubLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSubLab];
                    [checkPressureSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureLab.mas_bottom).offset(10);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_rearPressureCode) {
                        case 1:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_to_low", nil);
                            
                        break;
                        case 2:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_to_high", nil);
                        break;
                        case 3:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_abnormal", nil);
                        break;
                        default:
                            break;
                    }
                    
                }else{
                    checkPressureView.height = 84;
                    UILabel *checkPressureSubLab = [[UILabel alloc] init];
                    checkPressureSubLab.textColor = [UIColor whiteColor];
                    checkPressureSubLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSubLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSubLab];
                    [checkPressureSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureLab.mas_bottom).offset(10);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_frontPressureCode) {
                        case 0:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_f_ok", nil);
                        break;
                        default:
                            break;
                    }
                    
                    UILabel *checkPressureSecLab = [[UILabel alloc] init];
                    checkPressureSubLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                    checkPressureSecLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSecLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSecLab];
                    [checkPressureSecLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureSubLab.mas_bottom).offset(5);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_rearPressureCode) {
                        case 1:
                            checkPressureSecLab.text = NSLocalizedString(@"tirt_r_to_low", nil);
                        break;
                        case 2:
                            checkPressureSecLab.text = NSLocalizedString(@"tirt_r_to_high", nil);
                        break;
                        case 3:
                            checkPressureSecLab.text = NSLocalizedString(@"tirt_r_abnormal", nil);
                        break;
                        default:
                            break;
                    }
                }
                
                
            }else if (!_frontIsNormal && _rearIsNormal){
                checkPressureImg.image = [UIImage imageNamed:@"icon_fault_down"];
                if (_pressureNum == 1) {
                    checkPressureView.height = 64;
                    UILabel *checkPressureSubLab = [[UILabel alloc] init];
                    checkPressureSubLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                    checkPressureSubLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSubLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSubLab];
                    [checkPressureSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureLab.mas_bottom).offset(10);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_rearPressureCode) {
                        case 1:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_to_low", nil);
                        break;
                        case 2:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_to_high", nil);
                        break;
                        case 3:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_r_abnormal", nil);
                        break;
                        default:
                            break;
                    }
                }else{
                    checkPressureView.height = 84;
                    
                    UILabel *checkPressureSubLab = [[UILabel alloc] init];
                    checkPressureSubLab.textColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
                    checkPressureSubLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSubLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSubLab];
                    [checkPressureSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureLab.mas_bottom).offset(10);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_frontPressureCode) {
                        case 1:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_f_to_low", nil);
                        break;
                        case 2:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_f_to_high", nil);
                        break;
                        case 3:
                            checkPressureSubLab.text = NSLocalizedString(@"tirt_f_abnormal", nil);
                        break;
                        default:
                            break;
                    }
                    
                    UILabel *checkPressureSecLab = [[UILabel alloc] init];
                    checkPressureSecLab.textColor = [UIColor whiteColor];
                    checkPressureSecLab.textAlignment = NSTextAlignmentLeft;
                    checkPressureSecLab.font = FONT_PINGFAN(15);
                    [checkPressureView addSubview:checkPressureSecLab];
                    [checkPressureSecLab mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(checkPressureSubLab.mas_bottom).offset(5);
                        make.left.equalTo(checkPressureLab);
                        make.height.mas_equalTo(15);
                    }];
                    
                    switch (_rearPressureCode) {
                        case 0:
                            checkPressureSecLab.text = NSLocalizedString(@"tirt_r_ok", nil);
                            checkPressureSecLab.textColor = [QFTools colorWithHexString:@"#37b211"];
                        break;
                        default:
                            break;
                    }
                }
            }
        }
    }else{
        footView.contentSize = CGSizeMake(ScreenWidth,300);
    }
    
    UIButton *experien = [[UIButton alloc] init];
    if (_checkPressure) {
        experien.frame = CGRectMake(ScreenWidth *.32, 30 + CGRectGetMaxY(self.checkPressureView.frame), ScreenWidth *.36,44);
    }else{
        experien.frame = CGRectMake(ScreenWidth *.32, 30 + CGRectGetMaxY(undervoltage.frame), ScreenWidth *.36,44);
    }
    [experien addTarget:self action:@selector(experienClick) forControlEvents:UIControlEventTouchUpInside];
    [experien setTitle:NSLocalizedString(@"start_check", nil) forState:UIControlStateNormal];
    experien.titleLabel.font = [UIFont systemFontOfSize:16];
    [experien setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [experien.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [experien.layer setCornerRadius:10];
    experien.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    [footView addSubview:experien];
    self.experien = experien;
}

-(void)experienClick{
    
    [self.headview removeFromSuperview];
    [self.footView removeFromSuperview];
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight *.45 - navHeight)];
    headview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headview];
    self.headview = headview;
    
    [self setupView];
    _imageView.hidden = NO;
    self.checkLab.text = [NSString stringWithFormat:@"%@ %@...",NSLocalizedString(@"now_checking", nil),NSLocalizedString(@"electric_fault", nil)];
    self.experien.hidden = YES;
    [_imageView startAnimating];

    self.electric.hidden = YES;
    self.rotation.hidden = YES;
    self.controller.hidden = YES;
    self.checkPressureView.hidden = YES;
    self.undervoltage.hidden = YES;
    
    self.animation = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(delayMethod) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)delayMethod{
    
    if (self.tagnum == 1500) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = [NSString stringWithFormat:@"%@ %@...",NSLocalizedString(@"now_checking", nil),NSLocalizedString(@"electric_fault", nil)];
            self.electric.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1501){
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = [NSString stringWithFormat:@"%@ %@...",NSLocalizedString(@"now_checking", nil),NSLocalizedString(@"controller_fault", nil)];
            self.rotation.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1502){
        
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = [NSString stringWithFormat:@"%@ %@...",NSLocalizedString(@"now_checking", nil),NSLocalizedString(@"batt_vol_fault", nil)];
            self.controller.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1503){
    
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = [NSString stringWithFormat:@"%@ %@...",NSLocalizedString(@"now_checking", nil),NSLocalizedString(@"turn_fault", nil)];
            self.undervoltage.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1504){
    
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            
            self.checkPressureView.hidden = NO;
            
        }completion:^(BOOL finished) {
            UIImageView *defaultImage = [UIImageView new];
            defaultImage.frame = _imageView.frame;
            if ([[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"] &&
                [[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]&&
                [[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]&&
                [[[QFTools getBinaryByhex:[_querydate substringWithRange:NSMakeRange(28, 2)]] substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]) {
                
                if (_checkPressure) {
                    if (_frontIsNormal && _rearIsNormal) {
                        defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked_ok"];
                    }else{
                        defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked_error"];
                    }
                }else{
                    defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked_ok"];
                }
            }else{
                defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked_error"];
            }
            
            [self.headview addSubview:defaultImage];
            [UIView animateWithDuration:0.2 animations:^{
                
                self.experien.hidden = NO;
                self.checkLab.text = NSLocalizedString(@"now_checking_over", nil);
                self.tagnum = 1500;
                [self.animation invalidate];
                self.animation = nil;
                [_imageView stopAnimating];
                _imageView.hidden = YES;
            }];
        }];
    }
}

-(void)queryFaultSuccess:(NSNotification *)data{

    NSString *date = data.userInfo[@"data"];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
        self.querydate = date;
    }
}

//- (void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
//{
//    
//    cell.backgroundColor = [UIColor colorWithRed:30.0/255 green:36.0/255 blue:49.0/255 alpha:1.0];

    //cell动画效果
//    CATransform3D rotation;
//    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    rotation.m34 = 1.0/ -600;
//    
//    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//    cell.layer.transform = rotation;
//    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.8];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
    
//}

-(void)dealloc{
    
    if (self.animation) {
        [self.animation invalidate];
        self.animation = nil;
    }
    //****************//
    [NSNOTIC_CENTER removeObserver:self
                             name:KNotification_QueryData
                           object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
