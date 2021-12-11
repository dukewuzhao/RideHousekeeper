//
//  SetUpViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/25.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SetUpViewController.h"
#import "PublicWebpageViewController.h"
@interface SetUpViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *titleArray;

@end

@implementation SetUpViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavView];
    _titleArray = @[@"用户协议",@"隐私政策",@"服务热线", @"软件版本"];
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    [table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    table.backgroundColor = [UIColor clearColor];
    table.separatorColor = [QFTools colorWithHexString:SeparatorColor];
    [self.view addSubview:table];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"关于我们" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark --- tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"setupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = [NSString stringWithFormat:@"  %@", _titleArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *editionl = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth- 160, 12.5, 120, 20)];
    
    if (indexPath.row == 0) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 1){
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.row == 2){
        
        editionl.text =  @"400-885-0061";
        editionl.textColor = [QFTools colorWithHexString:MainColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else if (indexPath.row == 3) {
        
        editionl.text =  [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        editionl.textColor = [QFTools colorWithHexString:@"#999999"];
        
    }else if (indexPath.row == 3) {
        
    }
    
    
    editionl.textAlignment = NSTextAlignmentRight;
    editionl.font = [UIFont systemFontOfSize:15];
    [cell addSubview:editionl];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
        PublicWebpageViewController *agreeVc = [PublicWebpageViewController new];
        agreeVc.topTitle = @"骑管家用户协议";
        agreeVc.userPrivacyUrl = @"https://m.smart-qgj.com/qgj_user_agreement.html";
        [self.navigationController pushViewController:agreeVc animated:YES];
        
    }else if (indexPath.row == 1){
        
        PublicWebpageViewController *userPrivarcyVc = [PublicWebpageViewController new];
        userPrivarcyVc.topTitle = @"骑管家隐私政策";
        userPrivarcyVc.userPrivacyUrl = @"https://www.smart-qgj.com/privacy.html";
        [self.navigationController pushViewController:userPrivarcyVc animated:YES];
        
    }else if (indexPath.row == 2){
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4008850061"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath *)indexPath{
    cell.backgroundColor  = CellColor;
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImage *arrowImage = [UIImage imageNamed:@"arrow"];
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
        cell.accessoryView = arrowImageView;
    }
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
