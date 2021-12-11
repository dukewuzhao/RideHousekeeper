//
//  SmartCentralViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2019/10/31.
//  Copyright © 2019 Duke Wu. All rights reserved.
//

#import "SmartCentralViewController.h"
#import "SmartCentralTableViewCell.h"
#import "Manager.h"
@interface SmartCentralViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic) BikeModel *model;
@end

@implementation SmartCentralViewController

-(void)setpGPSParameters:(BikeModel *)model{
    _model = model;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_FirmwareUpgradeCompleted object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        
        self.model = [LVFmdbTool queryBikeData:[NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.model.bikeid]].firstObject;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.table reloadData];
        });
    }];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"智能中控"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}


#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 24)];
    UILabel *textlab = [[UILabel alloc] init];
    textlab.font = FONT_PINGFAN(10);
    textlab.textColor = [QFTools colorWithHexString:@"#666666"];
    [header addSubview:textlab];
    [textlab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).offset(10);
        make.centerY.equalTo(header);
    }];
    
    switch (section) {
        case 0:
            textlab.text = @"配件信息";
            break;
        case 1:
            textlab.text = @"配件操作";
            break;
        default:
            break;
    }
    
    
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SmartCentralTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"SmartCentralTableViewCell"];
    if (!cell) {
        cell = [[SmartCentralTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"SmartCentralTableViewCell"];
    }
    cell.selectionStyle =  UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            cell.nameLab.text = @"配件名称";
            cell.detailLab.text = @"骑管家智能中控";
            cell.arrow.hidden = YES;
        }else if (indexPath.row == 1){
            cell.nameLab.text = @"所属车辆";
            cell.detailLab.text = _model.bikename;
            cell.arrow.hidden = YES;
        }else if (indexPath.row == 2){
            cell.nameLab.text = @"Mac地址";
            cell.detailLab.text = _model.mac;
            cell.arrow.hidden = YES;
        }
        
    }else{
        
        if (indexPath.row == 0) {
            
            cell.nameLab.text = @"固件版本";
            cell.detailLab.text = _model.firmversion;
            if ([USER_DEFAULTS boolForKey:[NSString stringWithFormat:@"%d",_model.bikeid]]) {
                cell.upgrade_red_dot.hidden = NO;
            }else{
                cell.upgrade_red_dot.hidden = YES;
            }
            cell.arrow.hidden = NO;
        }else{
            
            cell.nameLab.text = @"更换中控";
        }
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if (_model.ownerflag == 0) {
            
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        
        [[Manager shareManager] BikeFirmwareUpgrade:_model.bikeid];
    }else if (indexPath.section == 1 && indexPath.row == 1){
        if (_model.ownerflag == 0) {
            
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        id changeECUVc = [[NSClassFromString(@"AddBikeViewController") alloc] init];
        //[changeECUVc setValue:@(BindingChangeECU) forKey:@"bindingType"];
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [QFTools performSelector:@selector(setBikeInfo: bindType:) withTheObjects:@[_model,@(BindingChangeECU)] withTarget:changeECUVc];
        #pragma clang diagnostic pop
        [self.navigationController pushViewController:changeECUVc animated:YES];
    }
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
