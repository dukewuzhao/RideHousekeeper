//
//  SetUpViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/25.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SetUpViewController.h"
#import "AgreementViewController.h"
#import "PublicWebpageViewController.h"
#import "LanguageSwitchingViewController.h"
#import "HelpViewController.h"
#import "DAConfig.h"
@interface SetUpViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *sectionTitleOneArray;
@property (nonatomic, copy) NSArray *sectionTitleTwoArray;

@end

@implementation SetUpViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    _sectionTitleOneArray = @[NSLocalizedString(@"language_zh_en", nil)];
    
    _sectionTitleTwoArray = @[NSLocalizedString(@"help", nil),NSLocalizedString(@"user_protocol", nil),NSLocalizedString(@"user_privacy_info", nil)];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor colorWithWhite:1 alpha:0.06];
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    [table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:table];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"set", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark --- tableView Delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return _sectionTitleOneArray.count;
    }else {
        return _sectionTitleTwoArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(nonnull UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"setupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    cell.accessoryView = arrow;
    
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.text = [NSString stringWithFormat:@"  %@", _sectionTitleOneArray[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
//        NSString *a = [NSBundle currentLanguage];
//        NSString *b = [DAConfig userLanguage];
        if (![DAConfig userLanguage].length) {
            cell.detailTextLabel.text = NSLocalizedString(@"Follow_system", nil);
        } else {
            if ([NSBundle isChineseLanguage]) {
                cell.detailTextLabel.text = NSLocalizedString(@"language_zh", nil);
            } else {
                cell.detailTextLabel.text = NSLocalizedString(@"language_en", nil);
            }
        }
        return cell;
    }else{
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.text = [NSString stringWithFormat:@"  %@", _sectionTitleTwoArray[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        [self.navigationController pushViewController:[LanguageSwitchingViewController new] animated:YES];
    }else{
        if (indexPath.row == 0) {
            [self.navigationController pushViewController:[HelpViewController new] animated:YES];
        }else if (indexPath.row == 1) {
            AgreementViewController *agreeVc = [AgreementViewController new];
            [self.navigationController pushViewController:agreeVc animated:YES];
        }else if (indexPath.row == 2){
            PublicWebpageViewController *userVc = [PublicWebpageViewController new];
            [self.navigationController pushViewController:userVc animated:YES];
        }
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
