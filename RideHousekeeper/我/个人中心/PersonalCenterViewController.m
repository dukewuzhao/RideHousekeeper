//
//  PersonalCenterViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PersonalCenterViewController.h"
#import "IdeaViewController.h"
#import "PersonalViewController.h"
#import "PublicWebpageViewController.h"
#import "Manager.h"
@interface PersonalCenterViewController ()<UITableViewDataSource,UITableViewDelegate,ManagerDelegate>

{
    NSMutableArray *datarray;
}
@property (nonatomic, weak) UIView *headView;
@property (nonatomic, weak) UIImageView *userImage;
@property (nonatomic, weak) UILabel *name;
@end



@implementation PersonalCenterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[Manager shareManager] addDelegate:self];
    datarray = [NSMutableArray arrayWithObjects:@"帮助中心",@"意见反馈",@"免费热线",@"软件版本",nil];
    [self setupNavView];
    [self setupHeadview];
    [self setupTable];
    
}
- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    @weakify(self);
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    NSArray *vcsArray = self.navigationController.viewControllers;
    NSInteger vcCount = vcsArray.count;
    
    if (vcCount >1) {
        
        UIViewController *lastVC = vcsArray[vcCount-2];//最后一个vc是自己，倒数第二个是上一个控制器。
        if([lastVC isKindOfClass:NSClassFromString(@"AddBikeViewController")])
        {
            [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
            self.navView.leftButtonBlock = ^{
                @strongify(self);
                
                [self.navigationController popViewControllerAnimated:YES];
            };
        }else{
            //VCClass2 push我来的~
        }
    }
}

- (void)setupHeadview{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight * .3)];
    headView.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headView];
    self.headView = headView;
    
//    UIView *userimageback = [[UIView alloc] initWithFrame:CGRectMake(headView.centerX - ScreenHeight *.09 - 2.5, 7.5, ScreenHeight *.18+5, ScreenHeight *.18+5)];
//    userimageback.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
//    userimageback.layer.masksToBounds = YES;
//    userimageback.layer.cornerRadius = userimageback.height/2;
//    [headView addSubview:userimageback];
    
    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(headView.centerX - ScreenHeight *.09 - 2.5, 7.5, ScreenHeight *.18+5, ScreenHeight *.18+5)];
    
    if (![QFTools getphoto:[QFTools getuserInfo:@"icon"]]) {
        NSURL *url=[NSURL URLWithString:[QFTools getuserInfo:@"icon"]];
        [userImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"small_default_imag"] completed:^(UIImage *image, NSError*error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                userImage.image = [UIImage pq_ClipCircleImageWithImage:image circleRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            }
        }];
    }else{
        UIImage *image = [QFTools getphoto:[QFTools getuserInfo:@"icon"]];
        userImage.image = [UIImage pq_ClipCircleImageWithImage:image circleRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }
    [headView addSubview:userImage];
    self.userImage = userImage;
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = userImage.frame;
    [btn addTarget:self action:@selector(choseHeadImage) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];
    
    UILabel *name = [[UILabel alloc] init];
    name.font = [UIFont systemFontOfSize:18];  //UILabel的字体大小
    
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentCenter;  //文本对齐方式
    if ([QFTools getuserInfo:@"nick_name"].length == 0) {
        name.text = [QFTools getdata:@"phone_num"];
    }else{
        name.text = [QFTools getuserInfo:@"nick_name"];
    }
    name.frame = CGRectMake(0, CGRectGetMaxY(userImage.frame) + 20, ScreenWidth, 20);
    [headView addSubview:name];
    self.name = name;
    
}

-(void)personcenterBtnClick{
    
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)choseHeadImage{
    
    PersonalViewController *perVc = [PersonalViewController new];
    [self.navigationController pushViewController:perVc animated:YES];
    
}


- (void) setupTable{
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headView.frame), ScreenWidth, ScreenHeight - navHeight - tabHeight -CGRectGetMaxY(self.headView.frame)- 10 )];
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    table.separatorColor = [QFTools colorWithHexString:SeparatorColor];
    [table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:table];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return datarray.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
        if (indexPath.row == 0){
        
            image.image = [UIImage imageNamed:@"help_center"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 1){
            
            image.image = [UIImage imageNamed:@"fade_back"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }else if (indexPath.row == 2){
            image.image = [UIImage imageNamed:@"customer_service"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UILabel *editionl = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth- 160, 12.5, 120, 20)];
            editionl.text =  @"400-885-0061";
            editionl.textColor = [QFTools colorWithHexString:MainColor];
            editionl.textAlignment = NSTextAlignmentRight;
            editionl.font = [UIFont systemFontOfSize:15];
            [cell addSubview:editionl];
        }else if (indexPath.row == 3){
            image.image = [UIImage imageNamed:@"software_version"];
            UILabel *editionl = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth- 160, 12.5, 120, 20)];
            editionl.text =  [NSString stringWithFormat:@"V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
            editionl.textColor = [QFTools colorWithHexString:@"#999999"];
            editionl.textAlignment = NSTextAlignmentRight;
            editionl.font = [UIFont systemFontOfSize:15];
            [cell addSubview:editionl];
        }
        
        [cell addSubview:image];
        
        UILabel *chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(image.frame) + 10, 10, 100, 25)];
        chooseLabel.text = datarray[indexPath.row];
        chooseLabel.textColor = [UIColor blackColor];
        chooseLabel.font = [UIFont systemFontOfSize:15];
        [cell addSubview:chooseLabel];
    //cell.textLabel.text = datarray[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        PublicWebpageViewController *helpVc = [PublicWebpageViewController new];
        helpVc.topTitle = @"骑管家帮助中心";
        helpVc.userPrivacyUrl = @"http://m.smart-qgj.com/qgj_help.html";;
        [self.navigationController pushViewController:helpVc animated:YES];
    }else if (indexPath.row == 1){
    
        IdeaViewController *ideaVc = [IdeaViewController new];
        [self.navigationController pushViewController:ideaVc animated:YES];
        
    }else if (indexPath.row == 2){
        
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",@"4008850061"];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
        
    }else if (indexPath.row == 3){
        
        //[self.navigationController pushViewController:[LanguageSwitchingViewController new] animated:YES];
    }
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}


- (void)headViewClicked:(UITapGestureRecognizer *)singleTap{
    
    PersonalViewController *perVc = [PersonalViewController new];
    [self.navigationController pushViewController:perVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)manager:(Manager *)manager updateUserMessage:(NSString *)name :(UIImage *)img{
    self.userImage.image = [UIImage pq_ClipCircleImageWithImage:img circleRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    self.name.text = name;
}

-(void)dealloc{
    [[Manager shareManager] deleteDelegate:self];
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
