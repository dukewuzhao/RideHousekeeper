//
//  UserPrivacyViewController.m
//  XinRideHouse
//
//  Created by Apple on 2018/10/18.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "PublicWebpageViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
@interface PublicWebpageViewController ()<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@end

@implementation PublicWebpageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavView];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    CGFloat progressBarHeight = 2.f;
    CGRect barFrame = CGRectMake(0, navHeight, ScreenWidth, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_webView];
    [self.view addSubview:_progressView];
    NSURLRequest *req = [NSBundle isChineseLanguage]?[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://xinri.m.smart-qgj.com/sunra_privacy_cn.html"]]:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://xinri.m.smart-qgj.com/sunra_privacy_en.html"]];
    [_webView loadRequest:req];
    
}

- (void)setupNavView{
    [super setupNavView];
    self.navView.backgroundColor = [QFTools colorWithHexString:MainColor];
    self.navView.showBottomLabel = NO;
    [self.navView.centerButton setTitle:NSLocalizedString(@"user_privacy_info", nil) forState:UIControlStateNormal];
    @weakify(self);
    [self.navView.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navView.leftButtonBlock = ^{
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
    };
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_progressView setProgress:progress animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [_progressView setProgress:1.000 animated:YES];
    
    [self failLoadView];
}


-(void)failLoadView{
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    
    UIImageView *failImg = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth *.4, ScreenHeight * .2, ScreenWidth *.2, ScreenWidth *.2)];
    failImg.image = [UIImage imageNamed:@"no_network"];
    [backView addSubview:failImg];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(failImg.frame)+20, ScreenWidth - 100, 20)];
    title.text = NSLocalizedString(@"no_network_connect", nil);
    title.textColor = [QFTools colorWithHexString:@"#666666"];
    title.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:title];
    
    UIButton *reloadAgin = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth*.15 , CGRectGetMaxY(title.frame) + 24, ScreenWidth*.7, 44)];
    reloadAgin.backgroundColor = [UIColor whiteColor];
    reloadAgin.layer.borderColor = [QFTools colorWithHexString:@"#666666"].CGColor;
    reloadAgin.layer.borderWidth = 1.0;
    [reloadAgin setTitle:NSLocalizedString(@"reload", nil) forState:UIControlStateNormal];
    [reloadAgin setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    reloadAgin.titleLabel.font = FONT_PINGFAN(16);
    reloadAgin.contentMode = UIViewContentModeCenter;
    [reloadAgin.layer setCornerRadius:10.0]; // 切圆角
    @weakify(self);
    [[reloadAgin rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [backView removeFromSuperview];
        NSURLRequest *req = [NSBundle isChineseLanguage]?[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://xinri.m.smart-qgj.com/sunra_privacy_cn.html"]]:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://xinri.m.smart-qgj.com/sunra_privacy_en.html"]];
        [self->_webView loadRequest:req];
    }];
    [backView addSubview:reloadAgin];
    
    
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
