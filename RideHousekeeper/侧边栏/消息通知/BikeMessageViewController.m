//
//  BikeMessageViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2018/3/15.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "BikeMessageViewController.h"
#import "BikeMessageTableViewCell.h"
#import "BikeMessageSelectTableViewCell.h"
#import "SeizeSeatView.h"
#import "MessageFootview.h"
#import "switchView.h"
@interface BikeMessageViewController ()<UITableViewDelegate,UITableViewDataSource,switchViewDelegate>
@property (nonatomic,assign) BOOL isEdit;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,strong) UITableView *TableView;
@property (nonatomic,strong) MessageFootview *messageView;
@property (nonatomic,strong) NSMutableArray *selectAry;
@property (nonatomic,strong) NSMutableArray *messageAry;
@end

@implementation BikeMessageViewController

-(NSMutableArray *)selectAry{

    if (!_selectAry) {
        _selectAry = [NSMutableArray new];
    }
    return _selectAry;
}

-(NSMutableArray *)messageAry{
    
    if (!_messageAry) {
        _messageAry = [NSMutableArray new];
    }
    return _messageAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavView];
    
    
    self.messageAry = [[[[[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'",1]] mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
    @weakify(self);
    [self.messageAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        [self.selectAry addObject:@"0"];
    }];
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, 55)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    switchView *segment = [[switchView alloc] init];
    segment.items = @[@"系统消息",@"车辆消息"];
    segment.width = 140;
    segment.height = 35;
    segment.x = (ScreenWidth - segment.width) * 0.5;
    segment.y = 10;
    segment.delegate = self;
    [headView addSubview:segment];
    segment.selectedSegmentIndex = 0;
    
    [self setupTableview];
}

-(void)setupTableview{
    
    _TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight + 55 , self.view.size.width, ScreenHeight - navHeight - 55) style:UITableViewStylePlain];
    [_TableView setSeparatorColor:[UIColor colorWithWhite:1 alpha:0]];
    _TableView.delegate = self;
    _TableView.dataSource = self;
    //TableView.scrollEnabled = NO;
    //TableView.separatorStyle = NO;
    _TableView.backgroundColor = [QFTools colorWithHexString:@"#F5F5F5"];
    [_TableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:_TableView];
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:@"消息通知"forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navView.rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self.navView.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navView.rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.navView.rightButtonBlock = ^{
        @strongify(self);
        
        self.isEdit = !self.isEdit;
        
        if (self.isEdit) {
            self.messageView = [MessageFootview new];
            self.messageView.delClickBlock = ^(NSInteger num){
                @strongify(self);
                if (num == 1) {
                    
                    for (int i = 0; i < self.selectAry.count; i++) {
                        self.selectAry[i] = @"1";
                    }
                    
                }else{
                    
                    if (![self.selectAry containsObject:@"1"]) {
                        [SVProgressHUD showSimpleText:@"请先选择"];
                    }
                    
                    [self.selectAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        @strongify(self);
                        if ([obj isEqualToString:@"1"]) {
                            
                            [LVFmdbTool deleteJPushData:[NSString stringWithFormat:@"DELETE FROM JPushData_models WHERE time = '%@' AND bikeid = '%zd' AND userid = '%zd' AND type = '%zd' AND title = '%@' AND content = '%@' AND category = '%zd'", [(JPushDataModel*)self.messageAry[idx] time],[(JPushDataModel*)self.messageAry[idx] bikeid],[(JPushDataModel*)self.messageAry[idx] userid],[(JPushDataModel*)self.messageAry[idx] type],[(JPushDataModel*)self.messageAry[idx] title],[(JPushDataModel*)self.messageAry[idx] content],[(JPushDataModel*)self.messageAry[idx] category]]];
                            
                        }
                    }];
                    self.messageAry = [[[[[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'", self.type + 1]] mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
                    [self.selectAry removeAllObjects];
                    [self.messageAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        @strongify(self);
                        [self.selectAry addObject:@"0"];
                    }];
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.TableView reloadData];
                });
                
            };
            [self.messageView showInView:self.view];
            [UIView animateWithDuration:0.3 animations:^{
                self.TableView.height = ScreenHeight - navHeight - 55 - 47;
            }];
        }else{
            
            [self.messageView disMissView];
            [UIView animateWithDuration:0.3 animations:^{
                self.TableView.height = ScreenHeight - navHeight - 55;
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.TableView reloadData];
        });
        
    };
    
}

-(void)noMessage{
    
    SeizeSeatView *view = [[SeizeSeatView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    view.seizeImg.frame = CGRectMake(ScreenWidth*.3, ScreenHeight *.31, ScreenWidth *.4, ScreenWidth *.4 *1.354);
    [view addSubview:view.seizeImg];
    view.headlinesLab.frame = CGRectMake(0, CGRectGetMaxY(view.seizeImg.frame) + 50, ScreenWidth, 20);
    [view addSubview:view.headlinesLab];
    view.seizeImg.image = [UIImage imageNamed:@"no_bikemessage"];
    view.headlinesLab.textColor = [QFTools colorWithHexString:@"#cccccc"];
    view.headlinesLab.text = @"暂无消息";
    [self.view addSubview:view];
}

#pragma mark --- tableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.messageAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdit) {
        
        BikeMessageSelectTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"BikeMessageSelectTableViewCell"];
        if (!cell) {
            cell = [[BikeMessageSelectTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"BikeMessageSelectTableViewCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        JPushDataModel *model = [self.messageAry objectAtIndex:indexPath.section];
        cell.newsType.text = [NSString stringWithFormat:@"%@>>>",model.title];
        cell.timeLab.text = model.time;
        cell.RemindLab.text = model.content;
        @weakify(self);
        cell.btnSelect = ^(BOOL isClick) {
            @strongify(self);
            if (isClick) {
                self.selectAry[indexPath.row] = @"1";
            }else{
                self.selectAry[indexPath.row] = @"0";
            }
            
        };
        
        if ([self.selectAry[indexPath.row] isEqualToString:@"1"]) {
            cell.selectBtn.selected = YES;
        }else{
            cell.selectBtn.selected = NO;
        }
        
        return cell;
        
    }else{
        BikeMessageTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"messageCell"];
        if (!cell) {
            cell = [[BikeMessageTableViewCell alloc] initWithStyle:0 reuseIdentifier:@"messageCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        JPushDataModel *model = [self.messageAry objectAtIndex:indexPath.section];
        cell.newsType.text = [NSString stringWithFormat:@"%@>>>",model.title];
        cell.timeLab.text = model.time;
        cell.RemindLab.text = model.content;
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180.0f;
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
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return   UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath{

    if (_isEdit) {
        return NO;
    }
    
    return YES;
}

//侧滑出现的文字
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath{

    return @"删除";
}

//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isEdit) {
        return NO;
    }
    return YES;
}

//执行删除操作

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        JPushDataModel *model = self.messageAry[indexPath.section];
        [self.messageAry removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
        [LVFmdbTool deleteJPushData:[NSString stringWithFormat:@"DELETE FROM JPushData_models WHERE time = '%@' AND bikeid = '%zd' AND userid = '%zd' AND type = '%zd' AND title = '%@' AND content = '%@' AND category = '%zd'", model.time,model.bikeid,model.userid,model.type,model.title,model.content,model.category]];
        
        self.messageAry = [[[[[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'", self.type + 1]] mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
        [self.selectAry removeObjectAtIndex:indexPath.row];
        
    }
    
}
 
//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"关注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        NSLog(@"点击了关注");
//
//    }];
//    action.backgroundColor=[UIColor greenColor];
//
//    return @[action];
//}

#pragma mark 测试
//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
//    //删除
//    if (@available(iOS 11.0, *)) {
//        UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//
//            [LVFmdbTool deleteJPushData:[NSString stringWithFormat:@"DELETE FROM JPushData_models WHERE time = '%@' AND bikeid = '%zd' AND userid = '%zd' AND type = '%zd' AND title = '%@' AND content = '%@' AND category = '%zd'", [(JPushDataModel*)self.messageAry[indexPath.row] time],[(JPushDataModel*)self.messageAry[indexPath.row] bikeid],[(JPushDataModel*)self.messageAry[indexPath.row] userid],[(JPushDataModel*)self.messageAry[indexPath.row] type],[(JPushDataModel*)self.messageAry[indexPath.row] title],[(JPushDataModel*)self.messageAry[indexPath.row] content],[(JPushDataModel*)self.messageAry[indexPath.row] category]]];
//
//            self.messageAry = [[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'", self.type + 1]] mutableCopy];
//            [self.selectAry removeObjectAtIndex:indexPath.row];
//            [self.TableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//
//            completionHandler (YES);
//        }];
////    delete.image = [UIImage imageNamed:@"delete"];//这里还可以设置图片
//    delete.backgroundColor = [UIColor redColor];
//    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[delete]];
//    return config;
//    } else {
//        return nil;
//        // Fallback on earlier versions
//    }
//}

//-(void)clickBtn:(UIButton *)btn{
//
//    if ([self.selectAry[btn.tag] isEqualToString:@"0"]) {
//        self.selectAry[btn.tag] = @"1";
//    }else{
//        self.selectAry[btn.tag] = @"0";
//    }
//
//
//    NSIndexPath *indexPathA = [NSIndexPath indexPathForRow:btn.tag inSection:0];
//    [self.TableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathA,nil] withRowAnimation:UITableViewRowAnimationNone];
//
//}

- (void)switchView:(switchView *)switchView DidBtnClick:(UIButton *)btn{
    
    if (btn.tag == 20) {
        _type = 0;
        self.messageAry = [[[[[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'",1]] mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
        
        [self.selectAry removeAllObjects];
        @weakify(self);
        [self.messageAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            [self.selectAry addObject:@"0"];
        }];
        
    }else if(btn.tag == 21){
        
        _type = 1;
        self.messageAry = [[[[[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'",2]] mutableCopy] reverseObjectEnumerator] allObjects] mutableCopy];
        //self.messageAry = [[LVFmdbTool queryJPushData:[NSString stringWithFormat:@"SELECT * FROM JPushData_models WHERE category LIKE '%zd'",2]] mutableCopy] ;
        [self.selectAry removeAllObjects];
        @weakify(self);
        [self.messageAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            [self.selectAry addObject:@"0"];
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.TableView reloadData];
    });
}

-(void)dealloc{
    
    if (self.isEdit) {
        [self.messageView disMissView];
    }
    self.messageView = nil;
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
