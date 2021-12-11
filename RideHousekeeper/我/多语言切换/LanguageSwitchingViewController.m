//
//  LanguageSwitchingViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/10/10.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "LanguageSwitchingViewController.h"
#import "SetUpViewController.h"
#import "SideMenuViewController.h"
#import "BaseNavigationController.h"
#import "DAConfig.h"
#import "NSBundle+DAUtils.h"
@interface LanguageSwitchingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSArray *titleArray;
@end

@implementation LanguageSwitchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.fd_fullscreenPopGestureRecognizer.enabled = YES;
    _titleArray = @[@"跟随手机系统",@"简体中文", @"English"];
    [self setupNavView];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    [table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:table];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"ahh", nil) forState:UIControlStateNormal];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"languageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }
    // Configure the cell...
    //用户没有自己设置的语言，则跟随手机系统
    cell.textLabel.text = _titleArray[indexPath.row];
    if (![DAConfig userLanguage].length) {
        cell.accessoryType = indexPath.row == 0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    } else {
        if (indexPath.row == 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        return;
    }
    for (UITableViewCell *acell in tableView.visibleCells) {
        acell.accessoryType = acell == cell ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 0) {
        [DAConfig setUserLanguage:nil];
    } else if (indexPath.row == 1) {
        [DAConfig setUserLanguage:@"zh-Hans"];
    } else {
        [DAConfig setUserLanguage:@"en"];
    }
    
    BaseNavigationController *navOne = [[BaseNavigationController alloc] initWithRootViewController:[NSClassFromString(@"BikeViewController") new]];
    UIViewController *tbc = [[XYSideViewController alloc] initWithSideVC:[[SideMenuViewController alloc] init] currentVC:navOne change:YES];
    LanguageSwitchingViewController *vc = [LanguageSwitchingViewController new];
    SetUpViewController *vc2 = [SetUpViewController new];
    NSMutableArray *vcs = navOne.viewControllers.mutableCopy;
    [vcs addObject:vc2];
    [vcs addObject:vc];
    
    //解决奇怪的动画bug。异步执行
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].keyWindow.rootViewController = tbc;
        navOne.viewControllers = vcs;
        NSLog(@"已切换到语言 %@", [NSBundle currentLanguage]);
    });
    
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
