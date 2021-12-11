//
//  PersonalViewController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/4/6.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PersonalViewController.h"
#import "NSDate+HC.h"
#import "PhotoPickerManager_Edit.h"
#import "TFSheetView.h"
#import "PickerChoiceView.h"
#import "UserIconTableViewCell.h"
#import "UserMessageTableViewCell.h"
#import "UpdateUserNameTableViewCell.h"
#import "Manager.h"

@interface PersonalViewController ()<TFSheetViewDelegate,TFPickerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray *pickerArray;
}

@property (nonatomic, strong) TFSheetView   *tfSheetView;
@property (nonatomic, copy)NSArray *titleArray;
@property (nonatomic, strong)UserInfoModel *userModel;
@property (nonatomic, strong) UITableView *personalMessageView;
@end

@implementation PersonalViewController
    
- (void)viewWillAppear:(BOOL)animated{
        [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _titleArray = @[@"头像", @"昵称", @"手机",@"生日",@"性别"];
    _userModel = [UserInfoModel new];
    _userModel.phone_num = [QFTools getdata:@"phone_num"];
    _userModel.nick_name = [QFTools getuserInfo:@"nick_name"];
    _userModel.birthday = [QFTools getuserInfo:@"birthday"];
    _userModel.gender = [QFTools getuserInfo:@"gender"].intValue;
    _userModel.icon = [QFTools getuserInfo:@"icon"];

    if (![QFTools getphoto:[QFTools getuserInfo:@"icon"]]) {
        NSURL *url=[NSURL URLWithString:[QFTools getuserInfo:@"icon"]];
        
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:url completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (image && finished) {
                _userModel.image = image;
            }else if (error){
                _userModel.image = [UIImage imageNamed:@"small_default_imag"];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_personalMessageView reloadData];
            });
        }];
    }else{
        _userModel.image = [QFTools getphoto:[QFTools getuserInfo:@"icon"]];
    }
    [self setupNavView];
    [self initFootView];
    [self keyboardMonitor];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"个人信息" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navView.rightButton setTitle:@"保存" forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
        
        @strongify(self);
        if (self.userModel.nick_name.length >10) {
            
            [SVProgressHUD showSimpleText:@"昵称长度不能超过10"];
            return;
        }
        
        [self saveBtnClick:NO];
    };
}

- (void)saveBtnClick:(BOOL)updateIMG{
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = @"保存中";
    [loadview show];
    
    NSString *realname = @"";
    NSString *idcard = @"";
    NSString *base64 = @"";
    NSString *nickname = _userModel.nick_name;
    NSString *birthday = _userModel.birthday;
    NSString *token = [QFTools getdata:@"token"];
    
    if (updateIMG) {
        base64 = [QFTools image2String:_userModel.image];
    }
    
    NSNumber * gender = [NSNumber numberWithInteger:_userModel.gender];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updateuserprofile"];
    NSDictionary *parameters = @{@"token":token, @"birthday":birthday,@"nick_name":nickname,@"icon":base64,@"gender":[gender stringValue],@"real_name":realname,@"id_card_no":idcard};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        [loadview hide];
        if ([dict[@"status"] intValue] == 0) {
            
            [SVProgressHUD showSimpleText:@"修改成功"];
            NSDictionary *data = dict[@"data"];
            NSString *icon = data[@"icon"];
            [QFTools saveUserIconPhoto:_userModel.image key:icon];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:[QFTools getdata:@"phone_num"],@"username",birthday,@"birthday",nickname,@"nick_name",gender,@"gender",icon,@"icon",idcard,@"idcard",nil];
            [USER_DEFAULTS setObject:userDic forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            [[Manager shareManager] updateUserMessage:nickname :_userModel.image];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        NSLog(@"error :%@",error);
        [loadview hide];
    }];
}


-(void)initFootView{
    
    _personalMessageView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _personalMessageView.delegate = self;
    _personalMessageView.dataSource = self;
    _personalMessageView.bounces = NO;
    _personalMessageView.backgroundColor = [UIColor clearColor];
    [_personalMessageView setSeparatorColor:[QFTools colorWithHexString:SeparatorColor]];
    [_personalMessageView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_personalMessageView];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.cancelsTouchesInView = NO;
    [_personalMessageView addGestureRecognizer:singleTapGesture];
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    [self.view addSubview:footview];
    _personalMessageView.tableFooterView = footview;
    UIButton *individuaBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, 30, ScreenWidth - 150, 40)];
    individuaBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [individuaBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [individuaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    individuaBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    individuaBtn.contentMode = UIViewContentModeCenter;
    [individuaBtn.layer setCornerRadius:8.0]; // 切圆角
    [individuaBtn addTarget:self action:@selector(signout) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:individuaBtn];
}

- (void)closeKeyboard:(UITapGestureRecognizer *)recognizer {
    //在对应的手势触发方法里面让键盘失去焦点
    //[_textField resignFirstResponder];
    //或者使用第二种方法,该方法会一直找到textField或者内嵌的texfield，让它取消第一响应者
    [self.view endEditing:YES];
}


#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return ScreenHeight *.13;
    }else{
        return 45.0f;
    }
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        UserIconTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UserIconCell"];
        if (!cell) {
            cell = [[UserIconTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UserIconCell"];
        }
        cell.name.text = _titleArray[indexPath.row];
        cell.userIcon.image = [UIImage pq_ClipCircleImageWithImage:_userModel.image circleRect:CGRectMake(0, 0, _userModel.image.size.width, _userModel.image.size.height)];
        return cell;
    }else if (indexPath.row == 1){
        UpdateUserNameTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UpdateUserNameCell"];
        if (!cell) {
            cell = [[UpdateUserNameTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UpdateUserNameCell"];
            [cell.nickNameField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
        }
        cell.name.text = _titleArray[indexPath.row];
        cell.nickNameField.text = _userModel.nick_name;
        cell.nickNameField.delegate = self;
        @weakify(cell);
        @weakify(self);
        cell.clearfieldBlock = ^{
            @strongify(cell);
            @strongify(self);
            cell.nickNameField.text = @"";
            self.userModel.nick_name = @"";
        };
        return cell;
    }else{
        UserMessageTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UserMessageCell"];
        if (!cell) {
            cell = [[UserMessageTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UserMessageCell"];
        }
        cell.name.text = _titleArray[indexPath.row];
        if (indexPath.row == 2) {
            cell.messageLab.text = [NSString stringWithFormat:@"%@",[QFTools replaceStringWithAsterisk:_userModel.phone_num startLocation:3 lenght:_userModel.phone_num.length -7]];
            cell.arrow.hidden = YES;
        }else if (indexPath.row == 3){
            cell.messageLab.text = _userModel.birthday;
        }else if (indexPath.row == 4){
            
            if (_userModel.gender ==1) {
                
                cell.messageLab.text = @"男";
            }else{
                cell.messageLab.text = @"女";
            }
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        
        @weakify(self);
        [[PhotoPickerManager_Edit shared]showActionSheetInView:self.view fromController:self completion:^(NSArray *image) {
            @strongify(self);
            NSData *imgData = [QFTools reSizeImageData:image[0] maxImageSize:800 maxSizeWithKB:1024.0];
            self.userModel.image = [UIImage imageWithData: imgData];
            [self saveBtnClick:YES];
            [self.personalMessageView reloadData];
        } cancelBlock:^{

        } maxCount:1];
        
    }else if (indexPath.row == 3){
        
        PickerChoiceView *picker = [[PickerChoiceView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        picker.delegate = self;
        picker.arrayType = DeteArray;
        picker.selectStr  = _userModel.birthday;
        [[UIApplication sharedApplication].keyWindow addSubview:picker];
    }else if (indexPath.row == 4){
        _tfSheetView = [[TFSheetView alloc]init];
        _tfSheetView.delegate = self;
        [_tfSheetView showInView:self.view];
    }
}

    
#pragma mark -------- TFPickerDelegate
    
- (void)PickerSelectorIndixString:(NSString *)str{
    
    _userModel.birthday = str;
    [_personalMessageView reloadData];
}
    
- (void)PickerSelectorIndixColour:(UIColor *)color{
    
    NSLog(@"p----%@",color);
}
    

-(void)TFSheetViewchooseSex:(NSString *)sexLab{
    
    if ([sexLab isEqualToString:@"男"]) {
        _userModel.gender = 1;
    }else if ([sexLab isEqualToString:@"女"]){
        _userModel.gender = 2;
    }
    [_personalMessageView reloadData];
}

-(void)signout{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否退出" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self individuaBtnClick];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}
    

- (void)individuaBtnClick
    {
        LoadView *loadview = [LoadView sharedInstance];
        loadview.protetitle.text = @"退出中";
        [loadview show];
        [self logoutApp];
        
    }
    
-(void)logoutApp{
    
    NSString *token= [QFTools getdata:@"token"];
    if (token == nil) {
        return;
    }
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/logout"];
    NSDictionary *parameters = @{@"token": token};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        [[HttpRequest sharedInstance] cancelRequest];
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [[HttpRequest sharedInstance] cancelRequest];
    }];
    
}

-(void)backView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)textField1TextChange:(UITextField *)textField{
    _userModel.nick_name = textField.text;
}

#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
        [self.view endEditing:YES];
    }


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
        [self.view endEditing:YES];
        return YES;
    }

/*键盘弹出监听*/
- (void)keyboardWillShow:(NSNotification *)info
{
    CGRect keyboardBounds = [[[info userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _personalMessageView.contentInset = UIEdgeInsetsMake(_personalMessageView.contentInset.top, 0, keyboardBounds.size.height, 0);
    
}
- (void)keyboardWillHide:(NSNotification *)info
{
    _personalMessageView.contentInset = UIEdgeInsetsMake(_personalMessageView.contentInset.top, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
    
@end
