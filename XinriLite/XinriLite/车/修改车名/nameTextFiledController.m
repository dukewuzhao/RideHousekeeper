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
    UIButton * saveBtn;
}
@end

@implementation nameTextFiledController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    [self setupNameText];
    [self setTap];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"car_name", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self backView];
    };
    [self.navView.rightButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        
        @strongify(self);
        [self updateBikeName];
    };
}

-(void)updateBikeName{
    
    if ([QFTools isBlankString:nameFiled.text ]) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bikename_null", nil)];
        return;
    }else if (nameFiled.text.length > 16 || nameFiled.text.length < 2) {
        [SVProgressHUD showSimpleText:NSLocalizedString(@"bikename_length_big", nil)];
        return ;
    }
    
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bikename = '%@' WHERE bikeid = '%zd'", nameFiled.text,_deviceNum];
    BOOL update = [LVFmdbTool modifyData:updateSql];
    if (update) {
        [[Manager shareManager] updatebikeName:self->nameFiled.text :self.deviceNum];
        [self backView];
    }else{
        [SVProgressHUD showSimpleText:@"更新失败"];
    }
    
    
}

-(void) setTap
{
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPage3)];
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
    nameFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameFiled.textColor = [UIColor blackColor];
    nameFiled.backgroundColor = [UIColor whiteColor];
    nameFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    nameFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    nameFiled.leftViewMode = UITextFieldViewModeAlways;
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)]];
    [self.view addSubview:nameFiled];
    [nameFiled becomeFirstResponder];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(nameFiled.x, CGRectGetMaxY(nameFiled.frame)+5, nameFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = NSLocalizedString(@"bikename_length_show", nil);
    [self.view addSubview:promte];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)backView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
}

@end
