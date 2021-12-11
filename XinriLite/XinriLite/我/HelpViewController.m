//
//  HelpViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/11/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpDetailViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_sectionArray;//每个section的数据
    NSMutableDictionary *_showDic;//用来判断分组展开与收缩的
}
@property (nonatomic, weak) UITableView *setingTable;

@end

@implementation HelpViewController
    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
    }
    
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    _sectionArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"help_one", nil),NSLocalizedString(@"help_two", nil),NSLocalizedString(@"help_three", nil),NSLocalizedString(@"help_four", nil),NSLocalizedString(@"help_five", nil),NSLocalizedString(@"help_six", nil),NSLocalizedString(@"help_seven", nil),NSLocalizedString(@"help_eight", nil),NSLocalizedString(@"help_nine", nil),NSLocalizedString(@"help_ten", nil),NSLocalizedString(@"help_ten_one", nil),nil];
    UITableView *setingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin) style:UITableViewStyleGrouped];
    setingTable.backgroundColor = [UIColor clearColor];
    setingTable.delegate = self;
    setingTable.dataSource = self;
    setingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [setingTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:setingTable];
    self.setingTable = setingTable;
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"help", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
}


#pragma mark -UITableViewDataSource
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sectionArray.count;
}
    
    
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}
    
    
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_id = @"profile";
    // 先从重用池中找cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        //cell必须先进行初始化
        cell = [[UITableViewCell alloc]init];
        //  cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID andDataArr:[_courArrayM objectAtIndex:indexPath.row] andIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone; //选中cell时无色
        cell.separatorInset=UIEdgeInsetsZero;
        cell.clipsToBounds = YES;
        
        //设置cell点击无任何效果和背景色
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    return cell;
}
    
    
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        [self.view endEditing:YES];
    }
    
- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
    {
        
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 45;
    
}
    
    //section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
    {
        
        return 5.0;
    }
    

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}
    
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
        if (indexPath.section == 0) {
            return 80;
        }else if (indexPath.section == 1){
            return 250;
        }else if (indexPath.section == 2){
            return 440;
        }else if (indexPath.section == 3){
            return 140;
        }else if (indexPath.section == 4){
            return 140;
        }else if (indexPath.section == 5){
            return 160;
        }else if (indexPath.section == 6){
            return 80;
        }else if (indexPath.section == 7){
            return 270;
        }else if (indexPath.section == 8){
            return 100;
        }
    }
    
    return 0;
}
    
    
    //section头部显示的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    header.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, ScreenWidth - 40, 20)];
    myLabel.text = [NSString stringWithFormat:@"%@",_sectionArray[section]];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.font = [UIFont systemFontOfSize:15];
    [header addSubview:myLabel];
    
    // 单击的 Recognizer ,收缩分组cell
    header.tag = section;
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    image.image = [UIImage imageNamed:@"arrow"];
    [header addSubview:image];
    
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [header addGestureRecognizer:singleRecognizer];//添加一个手势监测；
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *header = [UIView new];
    return header;
}

#pragma mark 展开收缩section中cell 手势监听
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    NSInteger didSection = recognizer.view.tag;
    HelpDetailViewController *helpVc = [HelpDetailViewController new];
    helpVc.selectNum = didSection;
    if (didSection == 0) {
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_one_info", nil);
        helpVc.needPicture = YES;
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 1){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_two_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 2){
        helpVc.needPicture = YES;
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_three_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 3){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_four_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 4){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_five_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 5){
        helpVc.needPicture = YES;
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_six_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
        
        
    }else if (didSection == 6){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_seven_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 7){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_eight_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
        
    }else if (didSection == 8){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_nine_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 9){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_ten_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (didSection == 10){
        
        helpVc.helpDetail = _sectionArray[didSection];
        helpVc.detailLab = NSLocalizedString(@"help_ten_one_info", nil);
        [self.navigationController pushViewController:helpVc animated:YES];
    }
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
    
- (void)dealloc
    {
        NSLog(@"%s dealloc",object_getClassName(self));
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
