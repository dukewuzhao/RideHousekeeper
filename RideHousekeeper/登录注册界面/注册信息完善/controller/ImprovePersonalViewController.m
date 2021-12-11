//
//  ImprovePersonalViewController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/4/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "ImprovePersonalViewController.h"
#import "NSDate+HC.h"
#import "TFSheetView.h"
#import "PickerChoiceView.h"
#import "PhotoPickerManager_Edit.h"
#import "ImproveUserIconTableViewCell.h"
#import "ImproveUserNameTableViewCell.h"
#import "ImproveUserMessageTableViewCell.h"

@interface ImprovePersonalViewController ()<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TFSheetViewDelegate,TFPickerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, copy) NSArray *imageArray;
@property (nonatomic, strong) TFSheetView *tfSheetView;
//@property (nonatomic,assign) CGFloat offSet;//页面移动距离
@property (nonatomic, strong) UITableView *improveMessageView;
@property (nonatomic, strong) UserInfoModel *userModel;
@property (nonatomic, assign) BOOL updateImg;
@end

@implementation ImprovePersonalViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _titleArray = @[@"昵称",@"生日",@"性别"];
    _imageArray = @[@"user_icon_ig",@"icon_birth",@"icon_sex"];
    _userModel = [UserInfoModel new];
    _userModel.nick_name = [QFTools getdata:@"phone_num"];
    _userModel.birthday = [[QFTools replyDataAndTime] substringWithRange:NSMakeRange(0, 10)];
    _userModel.gender = 1;
    _userModel.image = [UIImage imageNamed:@"small_default_imag"];
    [self setupNavView];
    [self setupHeadView];
    [self keyboardMonitor];
}

- (void)keyboardWillShow:(NSNotification *)info{
    CGRect keyboardBounds = [[[info userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _improveMessageView.contentInset = UIEdgeInsetsMake(_improveMessageView.contentInset.top, 0, keyboardBounds.size.height, 0);
    
}
- (void)keyboardWillHide:(NSNotification *)info{
    _improveMessageView.contentInset = UIEdgeInsetsMake(_improveMessageView.contentInset.top, 0, 0, 0);
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"注册信息" forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.rightButton setTitle:@"跳过" forState:UIControlStateNormal];
    self.navView.rightButtonBlock = ^{
      @strongify(self);
    [self improveSaveBtnClick];
    };
}

- (void)setupHeadView{
    
    _improveMessageView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _improveMessageView.delegate = self;
    _improveMessageView.dataSource = self;
    _improveMessageView.bounces = NO;
    _improveMessageView.backgroundColor = [UIColor clearColor];
    [_improveMessageView setSeparatorColor:[QFTools colorWithHexString:@"#a7a9b0"]];
    [_improveMessageView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_improveMessageView];
    [self.view sendSubviewToBack:_improveMessageView];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.cancelsTouchesInView = NO;
    [_improveMessageView addGestureRecognizer:singleTapGesture];
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    [self.view addSubview:footview];
    _improveMessageView.tableFooterView = footview;
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 30, ScreenWidth - 70, 40)];
    [saveBtn setTitle:@"提交" forState:UIControlStateNormal];
    saveBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(improveSaveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn.layer setCornerRadius:5.0]; // 切圆角
    [footview addSubview:saveBtn];
}

- (void)closeKeyboard:(UITapGestureRecognizer *)recognizer {
    
    [self.view endEditing:YES];
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return ScreenHeight *.3;
    }else{
        return 45.0f;
    }
}


- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor clearColor];
    }else cell.backgroundColor = CellColor;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        ImproveUserIconTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"ImproveUserIconCell"];
        if (!cell) {
            cell = [[ImproveUserIconTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"ImproveUserIconCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userIcon.image = [UIImage pq_ClipCircleImageWithImage:_userModel.image circleRect:CGRectMake(0, 0, _userModel.image.size.width, _userModel.image.size.height)];
        }
        @weakify(cell);
        @weakify(self);
        [cell passingClickEvents:^(UITapGestureRecognizer *gesture){

            @strongify(self);
            [[PhotoPickerManager_Edit shared]showActionSheetInView:self.view fromController:self completion:^(NSArray *image) {
                @strongify(cell);
                @strongify(self);
                NSData *imgData = [QFTools reSizeImageData:image[0] maxImageSize:800 maxSizeWithKB:1024.0];
                self.userModel.image = [UIImage imageWithData: imgData];
                cell.userIcon.image = [UIImage pq_ClipCircleImageWithImage:self.userModel.image circleRect:CGRectMake(0, 0, self.userModel.image.size.width, self.userModel.image.size.height)];
                self.updateImg = YES;
            } cancelBlock:^{

            } maxCount:1];
            
        }];
        
        return cell;
    }else if (indexPath.row == 1){
        ImproveUserNameTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UpdateUserNameCell"];
        if (!cell) {
            cell = [[ImproveUserNameTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UpdateUserNameCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.nickNameField addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
        }
        cell.name.text = _titleArray[indexPath.row - 1];
        cell.nickNameField.text = _userModel.nick_name;
        cell.icon.image = [UIImage imageNamed:_imageArray[indexPath.row - 1]];
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
        ImproveUserMessageTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UserMessageCell"];
        if (!cell) {
            cell = [[ImproveUserMessageTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"UserMessageCell"];
        }
        cell.icon.image = [UIImage imageNamed:_imageArray[indexPath.row - 1]];
        cell.name.text = _titleArray[indexPath.row - 1];
        if (indexPath.row == 2){
            cell.messageLab.text = _userModel.birthday;
        }else if (indexPath.row == 3){
            if (_userModel.gender ==1 ) {
                cell.messageLab.text = @"男";
            }else{
                cell.messageLab.text = @"女";
            }
        }
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //[self.view endEditing:YES];
    if (indexPath.row == 2){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PickerChoiceView *picker = [[PickerChoiceView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        picker.delegate = self;
        picker.arrayType = DeteArray;
        picker.selectStr  = _userModel.birthday;
        [[UIApplication sharedApplication].keyWindow addSubview:picker];
    }else if (indexPath.row == 3){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        _tfSheetView = [[TFSheetView alloc]init];
        _tfSheetView.delegate = self;
        [_tfSheetView showInView:self.view];
    }
}



#pragma mark -------- TFPickerDelegate

- (void)PickerSelectorIndixString:(NSString *)str{
    
    _userModel.birthday = str;
    [_improveMessageView reloadData];
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
    [_improveMessageView reloadData];
}


-(void)textField1TextChange:(UITextField *)textField{
    _userModel.nick_name = textField.text;
}

- (void)improveSaveBtnClick{
    
    if ([QFTools isBlankString:_userModel.nick_name]) {
        [SVProgressHUD showSimpleText:@"请输入昵称"];
        return;
    }else if (_userModel.nick_name.length >10) {
                
        [SVProgressHUD showSimpleText:@"昵称长度不能超过10"];
        return;
    }
    
    LoadView *loadview = [LoadView sharedInstance];
    loadview.protetitle.text = @"正在登录中...";
    [loadview show];
    NSNumber *gender = [NSNumber numberWithInteger:_userModel.gender];
    NSString *token = [QFTools getdata:@"token"];
    NSString * _encodedImageStr= @"";
    if (self.updateImg) {
        _encodedImageStr = [QFTools image2String:_userModel.image];
    }
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updateuserprofile"];
    NSDictionary *parameters = @{@"token":token, @"birthday": _userModel.birthday,@"nick_name": _userModel.nick_name,@"icon": _encodedImageStr,@"gender":[gender stringValue],@"real_name":@"",@"id_card_no":@""};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        [loadview hide];
        if ([dict[@"status"] intValue] == 0) {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            NSDictionary *data = dict[@"data"];
            NSString *icon = data[@"icon"];
            if (self.updateImg) {
                [QFTools saveUserIconPhoto:_userModel.image key:icon];
            }
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:[QFTools getdata:@"phone_num"],@"username",_userModel.birthday,@"birthday",_userModel.nick_name,@"nick_name",gender,@"gender",icon,@"icon",@"",@"realname",@"",@"idcard",nil];
            [USER_DEFAULTS setObject:userDic forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }
        else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        [loadview hide];
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}



//#pragma mark - 压缩图片 200*200
//- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
//{
//    UIGraphicsBeginImageContext(newSize);
//    [image drawInRect:CGRectMake(0,0,50,50)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
