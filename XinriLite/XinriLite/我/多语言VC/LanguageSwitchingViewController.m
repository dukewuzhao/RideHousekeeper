//
//  LanguageSwitchingViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/10/10.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "LanguageSwitchingViewController.h"
#import "SetUpViewController.h"
#import "BaseNavigationController.h"
#import "DAConfig.h"
#import "NSBundle+DAUtils.h"
#import "Manager.h"
@interface LanguageSwitchingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, assign) NSInteger index;
@end

@implementation LanguageSwitchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleArray = @[NSLocalizedString(@"Follow_system", nil),NSLocalizedString(@"language_zh", nil), NSLocalizedString(@"language_en", nil)];
    [self setupNavView];
    
    if (![DAConfig userLanguage].length) {
        _index = 0;
    }else if([DAConfig userLanguage].length){
        if ([NSBundle isChineseLanguage]) {
            _index = 1;
        } else {
            _index = 2;
        }
    }
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.separatorColor = [UIColor colorWithWhite:1 alpha:0.06];
    _table.bounces = NO;
    _table.delegate = self;
    _table.dataSource = self;
    [_table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_table];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"language_zh_en", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navView.rightButton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        [self changgeLanguage];
    };
    
    NSLog(@"%@---%d",[DAConfig userLanguage],[NSBundle isChineseLanguage]);
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
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (_index == indexPath.row) {
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 30, 7.5, 20, 20)];
        arrow.image = [UIImage imageNamed:@"icon_select_language"];
        cell.accessoryView = arrow;
    }else{
        cell.accessoryView = nil;
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
//    for (UITableViewCell *acell in tableView.visibleCells) {
//        acell.accessoryType = acell == cell ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
//    }
    _index = indexPath.row;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_table reloadData];
    });
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

-(void)changgeLanguage{
    if (_index == 0) {
        [DAConfig setUserLanguage:nil];
    } else if (_index == 1) {
        [DAConfig setUserLanguage:@"zh-Hans"];
    } else {
        [DAConfig setUserLanguage:@"en"];
    }
    
    if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:NSClassFromString(@"BikeViewController")]) {
        [AppDelegate currentAppDelegate].mainController = nil;
        [AppDelegate currentAppDelegate].mainController = [NSClassFromString(@"BikeViewController") new];
    }else{
        [AppDelegate currentAppDelegate].mainController = nil;
        [AppDelegate currentAppDelegate].mainController = [NSClassFromString(@"AddBikeViewController") new];
    }
    BaseNavigationController *navOne = [[BaseNavigationController alloc] initWithRootViewController:[AppDelegate currentAppDelegate].mainController];
//    LanguageSwitchingViewController *vc = [LanguageSwitchingViewController new];
//    SetUpViewController *vc2 = [SetUpViewController new];
//    NSMutableArray *vcs = navOne.viewControllers.mutableCopy;
//    [vcs addObject:vc2];
//    [vcs addObject:vc];
    //解决奇怪的动画bug。异步执行
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CATransition *anima = [CATransition animation];
        anima.type = @"push";//设置动画的类型
        anima.subtype = kCATransitionFromLeft; //设置动画的方向
        anima.duration = 0.3f;
        [UIApplication sharedApplication].keyWindow.rootViewController = navOne;
        [[UIApplication sharedApplication].delegate.window.layer addAnimation:anima forKey:@"revealAnimation"];
    });
}

- (void)dealloc
{
    NSLog(@"%s dealloc",object_getClassName(self));
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
