//
//  HelpDetailViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "HelpDetailViewController.h"
#import "TopLeftLabel.h"
@interface HelpDetailViewController ()

@end

@implementation HelpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    [self setupView];
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

-(void)setupView{

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin)];
    [self.view addSubview:scrollView];
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    CGPoint scrollPoint = CGPointMake(0, 0);
    scrollView.bounces = NO;
    [scrollView setContentOffset:scrollPoint animated:YES];
    
    UIView *cursorView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, 2, 20)];
    cursorView.backgroundColor = [QFTools colorWithHexString:NSLocalizedString(@"VCControlColor", nil)];
    [scrollView addSubview:cursorView];
    
    UILabel *helpDetail = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cursorView.frame)+20, cursorView.y, ScreenWidth - 40, 20)];
    helpDetail.textColor = [UIColor whiteColor];
    helpDetail.text = self.helpDetail;
    helpDetail.font = [UIFont systemFontOfSize:16];
    helpDetail.numberOfLines = 0;
    [scrollView addSubview:helpDetail];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(cursorView.x, CGRectGetMaxY(helpDetail.frame)+20, ScreenWidth - 15, 0.5)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [scrollView addSubview:lineView];
    
    if (self.needPicture) {
        
        scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
        UIImageView *mainImg = [[UIImageView alloc] init];
        switch (self.selectNum) {
            case 0:
                mainImg.image = [UIImage imageNamed:NSLocalizedString(@"binding_help", nil)];
                break;
            case 2:
                mainImg.image = [UIImage imageNamed:NSLocalizedString(@"remote_key_description", nil)];
                break;
//            case 5:
//                mainImg.image = [UIImage imageNamed:NSLocalizedString(@"induction_key_description", nil)];
//                break;
            default:
                break;
        }
        
        
        [scrollView addSubview:mainImg];
        [mainImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(scrollView);
            make.top.equalTo(lineView.mas_bottom).offset(20);
            make.width.mas_equalTo(ScreenWidth - 60);
            
//            if (self.selectNum == 0) {
//                make.height.equalTo(mainImg.mas_width).multipliedBy(0.5);
//            }else if (self.selectNum == 2){
//                make.height.equalTo(mainImg.mas_width).multipliedBy(0.5);
//            }else if (self.selectNum == 5){
//                make.height.equalTo(mainImg.mas_width).multipliedBy(0.5);
//            }
        }];
        TopLeftLabel *detailLab = [[TopLeftLabel alloc] init];
        detailLab.text = self.detailLab;
        detailLab.font = [UIFont systemFontOfSize:14];
        detailLab.textColor = [UIColor whiteColor];
        detailLab.numberOfLines = 0;
        detailLab.attributedText = [self getAttributedStringWithString:self.detailLab lineSpace:5];
        [scrollView addSubview:detailLab];
        [detailLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scrollView).offset(15);
            make.top.equalTo(mainImg.mas_bottom).offset(20);
            make.width.mas_equalTo(ScreenWidth - 30);
        }];
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(detailLab.frame)+20);
    }else{
        //scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin);
        TopLeftLabel *detailLab = [[TopLeftLabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(lineView.frame)+20, ScreenWidth - 30, ScreenHeight - 75)];
        detailLab.text = self.detailLab;
        detailLab.font = [UIFont systemFontOfSize:14];
        detailLab.textColor = [UIColor whiteColor];
        detailLab.numberOfLines = 0;
        detailLab.attributedText = [self getAttributedStringWithString:self.detailLab lineSpace:5];
        [scrollView addSubview:detailLab];
        [detailLab sizeToFit];
        scrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY(detailLab.frame)+20);
    }
}

-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

- (void)dealloc{
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
