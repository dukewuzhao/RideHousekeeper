//
//  IntroView.m
//  DrawPad
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ABCIntroView.h"
#import "KTPageControl.h"
@interface ABCIntroView () <UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  KTPageControl *pageControl;
@property UIView *holeView;
@property UIView *circleView;
@property UIButton *doneButton;

@end

@implementation ABCIntroView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        backgroundImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:backgroundImageView];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        
        _pageControl = [[KTPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 50, self.frame.size.height*.9 - 10, 100, 10)];
        _pageControl.enabled = NO;
        _pageControl.currentPageIndicatorTintColor = [QFTools colorWithHexString:MainColor];
        _pageControl.currentImage =[UIImage imageNamed:@"detail_tupianlunbo_suiji"];
        _pageControl.defaultImage =[UIImage imageNamed:@"detail_piclunbounselec_suiji"];
        _pageControl.pageSize = CGSizeMake(10, 10);
        [self addSubview:_pageControl];
        _pageControl.numberOfPages = 4;
        [self createViewOne];
        [self createViewTwo];
        [self createViewThree];
        [self createViewFour];
        
        self.scrollView.contentSize = CGSizeMake(self.frame.size.width*4, self.scrollView.frame.size.height);
        self.scrollView.showsVerticalScrollIndicator = FALSE;
        self.scrollView.showsHorizontalScrollIndicator = FALSE;
        //This is the starting point of the ScrollView
        CGPoint scrollPoint = CGPointMake(0, 0);
        self.scrollView.bounces = NO;
        //[self. setAutomaticallyAdjustsScrollViewInsets:NO];
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    return self;
}

- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
    
    if (roundf(pageFraction) == 3) {
        _pageControl.hidden = YES;
    }else{
        _pageControl.hidden = NO;
    }
}


-(void)createViewOne{
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight*.05, ScreenWidth*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"Pixifly"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
  //  [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.layer.contents = (id)[UIImage imageNamed:@"qgjnew1"].CGImage;
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for First Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
  //  [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, self.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}


-(void)createViewTwo{
    
    CGFloat originWidth = self.frame.size.width;
    CGFloat originHeight = self.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth, 0, originWidth, originHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight*.05, ScreenWidth*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, self.frame.size.height*.1);
    titleLabel.text = [NSString stringWithFormat:@"DropShot"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
  //  [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    //imageview.contentMode = UIViewContentModeScaleAspectFill;
    //imageview.image = [UIImage imageNamed:@"qgjnew2.jpg"];
    imageview.layer.contents = (id)[UIImage imageNamed:@"qgjnew2"].CGImage;
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width*.1, self.frame.size.height*.7, self.frame.size.width*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Second Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    //[view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, ScreenHeight*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
}

-(void)createViewThree{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth*2, 0, ScreenWidth, ScreenHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight*.05, ScreenWidth*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, ScreenHeight*.1);
    titleLabel.text = [NSString stringWithFormat:@"Shaktaya"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
   // [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,ScreenWidth, ScreenHeight)];
    
    //imageview.contentMode = UIViewContentModeScaleAspectFill;
    //imageview.image = [UIImage imageNamed:@"qgjnew3.jpg"];
    imageview.layer.contents = (id)[UIImage imageNamed:@"qgjnew3"].CGImage;
    [view addSubview:imageview];
    
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth*.1, ScreenHeight*.7, ScreenWidth*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Third Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    //[view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, ScreenHeight*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
    
}


-(void)createViewFour{
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth*3, 0, ScreenWidth, ScreenHeight)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight*.05, ScreenWidth*.8, 60)];
    titleLabel.center = CGPointMake(self.center.x, ScreenHeight*.1);
    titleLabel.text = [NSString stringWithFormat:@"Punctual"];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:40.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
 //   [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    imageview.layer.contents = (id)[UIImage imageNamed:@"qgjnew4"].CGImage;
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth*.1, ScreenHeight*.7, ScreenWidth*.8, 60)];
    descriptionLabel.text = [NSString stringWithFormat:@"Description for Fourth Screen."];
    descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    //[view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.center.x, ScreenHeight*.7);
    descriptionLabel.center = labelCenter;
    
    self.scrollView.delegate = self;
    [self.scrollView addSubview:view];
    
    //Done Button
    self.doneButton = [[UIButton alloc] init];
    [self.doneButton setTitle:@"立即体验" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.doneButton.titleLabel.font = FONT_PINGFAN(13);
    self.doneButton.backgroundColor = [UIColor whiteColor];
    self.doneButton.layer.borderWidth = 1;
    self.doneButton.layer.borderColor = [[QFTools colorWithHexString:@"#070707"] CGColor];
    [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.doneButton];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.bottom.equalTo(view.mas_bottom).offset(-ScreenHeight*.04);
        make.size.mas_equalTo(CGSizeMake(160, 40));
    }];
    self.doneButton.layer.cornerRadius = 20;
    //self.doneButton.layer.masksToBounds = YES;
}

@end
