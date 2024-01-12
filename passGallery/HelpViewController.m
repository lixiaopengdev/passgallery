//
//  HelpViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/9.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "HelpViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CommData.h"
@interface HelpViewController ()
@property(nonatomic,strong)GADBannerView *bannerView;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _bannerView=[[GADBannerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60 - SAFE_BOTTOM, [UIScreen mainScreen].bounds.size.width, 60)];
    _bannerView.rootViewController = self;
    _bannerView.adUnitID = @"ca-app-pub-7962668156781439/7431816901";
    GADRequest *request = [GADRequest request];
    [_bannerView loadRequest:request];
    [self.view addSubview:_bannerView];
    // Do any additional setup after loading the view from its nib.
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
