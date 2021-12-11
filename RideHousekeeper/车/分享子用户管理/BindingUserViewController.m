//
//  BindingUserViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BindingUserViewController.h"
#import "AddUserViewController.h"

@interface BindingUserViewController ()<UITableViewDataSource,UITableViewDelegate,AddUserViewControllerDelegate>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datarray;

@end

@implementation BindingUserViewController

// 即将进来页面后关闭抽屉
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

// 即将出去后再打开 因为可能其他页面需要抽屉效果
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (NSMutableArray *)datarray {
    if (!_datarray) {
        _datarray = [[NSMutableArray alloc] init];
    }
    return _datarray;
}

-(void)getBikeUser{
    @weakify(self);
    [self.datarray removeAllObjects];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeid = @(_bikeid);
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikeusers"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid};
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        @strongify(self);
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSMutableArray *userArray = data[@"user_info"];
            
            for (NSDictionary *userDic in userArray) {
                
                UserInfoModel *userInfo = [UserInfoModel yy_modelWithDictionary:userDic];
                [self.datarray addObject:userInfo];
            }
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bindedcount = '%zd' WHERE bikeid = '%zd'", self.datarray.count,self.bikeid];
            [LVFmdbTool modifyData:updateSql];
            
            if([self.delegate respondsToSelector:@selector(UpdateUsernumberSuccess)]){
                [self.delegate UpdateUsernumberSuccess];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            
            
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavView];
    [self setupview];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"分享车辆" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

- (void)setupview{
    
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.13, 30 + navHeight, ScreenWidth *.26, ScreenWidth *.26)];
    backview.backgroundColor = [QFTools colorWithHexString:MainColor];
    backview.layer.masksToBounds = YES;
    backview.layer.cornerRadius = ScreenWidth *.13;
    [self.view addSubview:backview];
    
    UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0,  0, backview.width, backview.height)];
    backIcon.image = [UIImage imageNamed:@"icon_default_logo"];
    [backview addSubview:backIcon];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 75, CGRectGetMaxY(backview.frame)+10, 150, 20)];
    nameLabel.text = bikemodel.bikename;
    nameLabel.textColor = [QFTools colorWithHexString:MainColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:nameLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+ 30, ScreenWidth, ScreenHeight - navHeight - CGRectGetMaxY(nameLabel.frame) - 30) style:UITableViewStyleGrouped];
    _tableView.bounces = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [QFTools colorWithHexString:SeparatorColor];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_tableView];
    
    if (bikemodel.ownerflag != 0) {
        UIButton *addbike = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
        [addbike setTitle:@"添加成员" forState:UIControlStateNormal];
        [addbike setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        addbike.backgroundColor = CellColor;
        [addbike addTarget:self action:@selector(addbikeClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addbike];
        _tableView.tableFooterView = addbike;
    }
    
    [self getBikeUser];
}

- (void)addbikeClick{

    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
        
    }
    
    AddUserViewController *addVc = [AddUserViewController new];
    addVc.bikeId = self.bikeid;
    addVc.delegate = self;
    [self.navigationController pushViewController:addVc animated:YES];

}

/**
 添加用户成员成功后回调
 */
-(void)AddUserSuccess{

    [self getBikeUser];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return self.datarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.1)];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10.0)];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    if (bikemodel.ownerflag == 1) {
        
        if (indexPath.section != 0) {
            
            UIButton *delate = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 0, 50, 45)];
            [delate setTitle:@"删除" forState:UIControlStateNormal];
            delate.backgroundColor = [UIColor redColor];
            delate.tag = indexPath.section;
            [delate addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:delate];
        }
    }
    UIImageView *mianIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    
    if (indexPath.section == 0) {
        mianIcon.image = [UIImage imageNamed:@"main_user_icon"];
    }else{
        mianIcon.image = [UIImage imageNamed:@"icon_p2"];
    }
    [[cell contentView] addSubview:mianIcon];
    cell.textLabel.text = [NSString stringWithFormat:@"         %@",[self.datarray[indexPath.section] phone_num]];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
        
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    cell .backgroundColor  = CellColor;
        
}



-(void)deleteUser:(UIButton *)btn{
    @weakify(self);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除该子用户" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        if (bikemodel.ownerflag == 0) {
            [SVProgressHUD showSimpleText:@"子用户无此权限"];
            return;
        }
        
        if (btn.tag>= self.datarray.count) {
            return;
        }
        NSString *token = [QFTools getdata:@"token"];
        NSNumber *bikeid = @(_bikeid);
        NSNumber *childId = [NSNumber numberWithInt:[self.datarray[btn.tag] user_id]];
        NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/unbindchild"];
        NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid , @"child_id":childId};
        
        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            @strongify(self);
            if ([dict[@"status"] intValue] == 0) {
                
                if (btn.tag < self.datarray.count) {
                    [self.datarray removeObjectAtIndex:btn.tag];
                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bindedcount = '%zd' WHERE bikeid = '%zd'", self.datarray.count,_bikeid];
                    [LVFmdbTool modifyData:updateSql];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                [SVProgressHUD showSimpleText:@"删除子用户成功"];
            }
            else if([dict[@"status"] intValue] == 1001){
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
            }else{
                [SVProgressHUD showSimpleText:dict[@"status_info"]];
            }
            
        }failure:^(NSError *error) {
            
            NSLog(@"error :%@",error);
            [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        }];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
