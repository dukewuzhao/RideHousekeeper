//
//  nameTextFiledController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/7/19.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "nameTextFiledController.h"
#import "Manager.h"

@interface nameTextFiledController ()
{
    UITextField * nameFiled;
}
@end

@implementation nameTextFiledController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self setupNameText];
    [self setTap];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"车辆名" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:NO];
    };
    [self.navView.rightButton setTitle:@"保存" forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        
        @strongify(self);
        [self updateBikeName];
    };
}

-(void)updateBikeName{
    
    if ([QFTools isBlankString:nameFiled.text ]) {
        [SVProgressHUD showSimpleText:@"车名不能为空"];
        return;
    }else if (nameFiled.text.length >6 || nameFiled.text.length < 2) {
        [SVProgressHUD showSimpleText:@"车名限制在2-6位"];
        return;
    }
    
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid = '%zd'", _deviceNum]];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    BikeInfoModel *bikeinfomodel = [BikeInfoModel new];
    bikeinfomodel.bike_name = nameFiled.text;
    bikeinfomodel.firm_version = bikemodel.firmversion;
    bikeinfomodel.bike_id = _deviceNum;
    NSDictionary *bike_info = [bikeinfomodel yy_modelToJSONObject];
    
    NSString *token = [QFTools getdata:@"token"];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updatebikeinfo"];
    NSDictionary *parameters = @{@"token": token, @"bike_info": bike_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bikename = '%@' WHERE bikeid = '%zd'", bikeinfomodel.bike_name,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
            [[Manager shareManager] updatebikeName:self->nameFiled.text :self.deviceNum];
            [self backView];
            
        }else {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

-(void) setTap
{
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPage3)];
    tapGesturRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesturRecognizer];
}
-(void)tapPage3
{
    [nameFiled resignFirstResponder];
}


-(void) setupNameText
{
    nameFiled = [[UITextField alloc]init];
    nameFiled.frame = CGRectMake(10, 20+ navHeight, ScreenWidth - 20, 45);
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:bikemodel.bikename attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#adaaa8"], NSParagraphStyleAttributeName:style}];
    nameFiled.attributedPlaceholder = attri;
    nameFiled.layer.cornerRadius = 5;
    nameFiled.textColor = [UIColor blackColor];
    nameFiled.backgroundColor = CellColor;
    nameFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    nameFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    nameFiled.leftViewMode = UITextFieldViewModeAlways;
    
    @weakify(self);
    nameFiled.keyboardType = UIKeyboardTypeDefault;
    //field.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIButton *ClearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7.5, 20, 20)];
    [ClearBtn setImage:[UIImage imageNamed:@"clear_btnBg"] forState:UIControlStateNormal];
    [[ClearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self->nameFiled.text = nil;
    }];
    nameFiled.rightView = ClearBtn;
    nameFiled.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:nameFiled];
    [nameFiled becomeFirstResponder];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(nameFiled.x, CGRectGetMaxY(nameFiled.frame)+5, nameFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = @"限2-6字符";
    [self.view addSubview:promte];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)backView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
