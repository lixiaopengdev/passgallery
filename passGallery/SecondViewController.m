//
//  SecondViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "SecondViewController.h"
#import "PassWordViewController.h"
#import "AppDelegate.h"
#import "HelpViewController.h"
#import "CommData.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SecondViewController ()<UITableViewDataSource,UITableViewDelegate,GADFullScreenContentDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong)GADInterstitialAd *interstitial;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"设置密码",nil);
    _tableView.backgroundColor =RGB(239, 239, 244);
    _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    [self layoutADV];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
    
    if (self.interstitial) {
        [_interstitial presentFromRootViewController:self];
    }
    // Dispose of any resources that can be recreated.
}

#pragma UITableView
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * strCell = @"UITableViewCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    
    if( !cell )
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, tableView.frame.size.width-10, 50)];
        lab.tag = 999;
        [cell.contentView addSubview:lab];
        UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0, 50-0.5, self.view.frame.size.width, 0.5)];
        line.backgroundColor =[UIColor colorWithWhite:0.9 alpha:1];
        [cell.contentView addSubview:line];
    }
    UILabel *lab = [cell.contentView viewWithTag:999];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    if( 0 == indexPath.section )
    {
        if( 0 == indexPath.row )
        {
            lab.text = NSLocalizedString(@"修改密码",nil);
        }
        else if ( 1 == indexPath.row )
        {
            lab.text = NSLocalizedString(@"修改伪装密码",nil);
        }
    }
    
    [cell.contentView addSubview:lab];
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,30)];
    lab.backgroundColor = RGB(242, 242, 242);
    lab.font = [UIFont systemFontOfSize:14];
    
    if( section == 0 )
    {
        lab.text = @"    ";
    }
    else if( section == 1 )
    {
        lab.text = @"   使用帮助";
    }
    
    return lab;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 )
    {
        if( [self showPretendPass] )
        {
            return 2;
        }
        
        return 1;
    }
    else if( section == 1 )
    {
        return 1;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( 0 == indexPath.section )
    {
        if( 0 == indexPath.row )
        {
            PassWordViewController * vc = [[PassWordViewController alloc]initWithNibName:@"PassWordViewController" bundle:nil];
            vc.passType = PASSOWRD_MODIFY_TRUEPASS;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( 1 == indexPath.row )
        {
            PassWordViewController * vc = [[PassWordViewController alloc]initWithNibName:@"PassWordViewController" bundle:nil];
            vc.passType = PASSWORD_INIT_PRETENDPASS;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if( 1 == indexPath.section )
    {
        if( 0 == indexPath.row )
        {
            HelpViewController * vc = [[HelpViewController alloc]initWithNibName:@"HelpViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

///显示伪装密码
-(BOOL)showPretendPass
{
    AppDelegate * appDel = [[UIApplication sharedApplication]delegate];
    return !appDel.bPretendLogo;
}


- (NSString *)publisherId
{
    return @"";
}

/**
 *  应用在union.baidu.com上的APPID
 */
- (NSString*) appSpec
{
    return @"";
}


-(void)layoutADV
{
    if ([(AppDelegate *)([UIApplication sharedApplication].delegate) showAdv]) {
        
        GADBannerView * _baiduView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60 - SAFE_BOTTOM, [UIScreen mainScreen].bounds.size.width, 60)];
        _baiduView.rootViewController = self;
        _baiduView.adUnitID =@"ca-app-pub-7962668156781439/7935272101";
        GADRequest *requeset =[GADRequest request];

        [_baiduView loadRequest:requeset];
        [self.view addSubview:_baiduView];
        [self loadInterstitial];
    }
    
}

- (void)loadInterstitial {
    self.interstitial = nil;
  GADRequest *request = [GADRequest request];
  [GADInterstitialAd
       loadWithAdUnitID:@"ca-app-pub-7962668156781439/8768949303"
                request:request
      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
          return;
        }
        self.interstitial = ad;
        self.interstitial.fullScreenContentDelegate = self;
      }];
}


@end
