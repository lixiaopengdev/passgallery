//
//  ThirdViewController.m
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-15.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "ThirdViewController.h"
#import "PayMent.h"
#import "RFRateMe.h"
#import "CommData.h"
#import "AppDelegate.h"
#import "SecondViewController.h"
#import "HelpViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#define SHOW_ME_YEAR  2015
#define SHOW_ME_MONTH  10
#define SHOW_ME_DAY    1


@interface ThirdViewController ()<PayMentDelegate,GADBannerViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    PayMent * payMent;
    
    AppDelegate * appDel;
    
}
- (IBAction)buyClicked;
- (IBAction)restoreBuy;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *bgView2;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UIButton *restoreBtn;
@property (weak, nonatomic) IBOutlet UIButton *app1Btn;
@property (weak, nonatomic) IBOutlet UIButton *app2Btn;
@property (nonatomic ,strong)GADBannerView *bannerView1;

@end

@implementation ThirdViewController

-(BOOL)showMe
{
    NSDateComponents * data = [[NSDateComponents alloc]init];
    NSCalendar * cal = [NSCalendar currentCalendar];
    
    [data setCalendar:cal];
    [data setYear:SHOW_ME_YEAR];
    [data setMonth:SHOW_ME_MONTH];
    [data setDay:SHOW_ME_DAY];
    
    NSDate * farDate = [cal dateFromComponents:data];
    
    NSDate *now = [NSDate date];
    
    NSTimeInterval farSec = [farDate timeIntervalSince1970];
    NSTimeInterval nowSec = [now timeIntervalSince1970];
    
    if( nowSec - farSec >= 0 )
    {
        return YES;
    }
    
    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    appDel = [[UIApplication sharedApplication] delegate];
 
    //
    self.title = NSLocalizedString(@"设置",nil);
    
    payMent = [PayMent new];
    payMent.PayDelegate = self;
    
    //
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    _buyBtn.layer.cornerRadius = 3;
    _buyBtn.layer.masksToBounds = YES;
    
    _restoreBtn.layer.cornerRadius = 3;
    _restoreBtn.layer.masksToBounds = YES;
    
    _shareBtn.layer.cornerRadius = 3;
    _shareBtn.layer.masksToBounds = YES;
    
    //
    _bgView2.layer.cornerRadius = 4;
    _bgView2.layer.masksToBounds = YES;
    
    _app1Btn.layer.cornerRadius = 3;
    _app1Btn.layer.masksToBounds = YES;
    
    _app2Btn.layer.cornerRadius = 3;
    _app2Btn.layer.masksToBounds = YES;
    
    //
    
    if( ![self showMe] )
    {
        _bgView2.hidden = YES;
    }
    //
    [self laytouADVView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma PayMentDelegate
-(NSString*)getProdId
{
    return @"li.passGallery.";
}

-(void)buySuccess:(NSDate*)date
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:date forKey:ADV_BUYED];
    [def synchronize];
}

-(void)buyFailed
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:ADV_BUYED];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [SVProgressHUD dismiss];
}

////////////////////////////////////////////////
- (void)buyClicked
{
    if ([payMent CanMakePay]) {
        [payMent startBuy];
        return;
    }
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"用户已禁止购买" message:@"请到设置－通用－访问限制中设置" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [self buyFailed];
}

- (void)restoreBuy
{
    [self buyClicked];
}


- (IBAction)actionClicked {
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[MobClick beginLogPageView:@"setting"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[MobClick endLogPageView:@"setting"];
}


///

//底部广告
-(void)laytouADVView
{
    if( ![appDel showAdv] )
    {
        return;
    }
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGPoint pt ;
    
    pt = CGPointMake(0, SCREEN_HEIGHT-TAB_HEIGHT);
    [self.view addSubview:self.bannerView1];
    [self.bannerView1 loadRequest:[GADRequest request]];
}

- (GADBannerView *)bannerView1
{
    if (_bannerView1==nil) {
        _bannerView1 = [[GADBannerView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60 - [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom, self.view.bounds.size.width, 60)];
        _bannerView1.adUnitID = @"ca-app-pub-7962668156781439/6458538906";
        _bannerView1.rootViewController = self;
    }
    return _bannerView1;
}

#pragma UITableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * strCellId = @"strCellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellId];
    
    if( !cell )
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellId];
        cell.contentView.backgroundColor = UIColor.whiteColor;
        cell.accessoryView.backgroundColor = UIColor.whiteColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor =RGB(239, 239, 244);
        UILabel * lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, tableView.frame.size.width-20, 50)];
        lab.tag =9999;
        lab.backgroundColor = UIColor.whiteColor;
        lab.textColor = navColor;
        [cell.contentView addSubview:lab];
        UIView *line =[[UIView alloc]initWithFrame:CGRectMake(0,50-0.5 , [UIScreen mainScreen].bounds.size.width, 0.5)];
        line.backgroundColor =[UIColor colorWithWhite:0.9 alpha:1];
        [cell.contentView addSubview:line];
    }
    UILabel *lab =[cell.contentView viewWithTag:9999];
    
    //lab.textAlignment = NSTextAlignmentCenter;
    //lab.textColor = [UIColor grayColor];
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            lab.text = NSLocalizedString(@"设置密码",nil);
        }
    }
    if( indexPath.section == 2)
    {
        if( indexPath.row == 0 )
        {
            lab.text = NSLocalizedString(@"给这个APP打分",nil);
        }else if (indexPath.row == 1){
            lab.text = NSLocalizedString(@"使用帮助",nil);
        }
    }
    else if(indexPath.section == 1 )
    {
        if( indexPath.row == 0 )
        {
            lab.text = NSLocalizedString(@"去掉广告",nil);
        }
        else if( indexPath.row == 1 )
        {
            lab.text = NSLocalizedString(@"恢复购买",nil);
        }
    }
    else if( indexPath.section == 3 )
    {
        if( indexPath.row ==  0 )
        {
            lab.text = NSLocalizedString(@"童年最好玩的智力拼图",nil);
        }
        else if( indexPath.row == 1 )
        {
            lab.text = NSLocalizedString(@"永恒的2048",nil);
        }
        else if( indexPath.row == 2 )
        {
            lab.text = NSLocalizedString(@"经典猜数字游戏启发儿童数学天赋",nil);
        }
        }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if( indexPath.row == 0 )
        {
            SecondViewController *secondVc=[[SecondViewController alloc]init];
            [self.navigationController pushViewController:secondVc animated:YES];
        }
    }
    if( indexPath.section == 2 )
    {
        if( indexPath.row == 0 )
        {
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/tong-nian-pin-tu-puzzle-shen-qi/id1088575286?mt=8"]];
        }else if (indexPath.row ==1){
            
            HelpViewController *helpVc=[[HelpViewController alloc]init];
            [self.navigationController pushViewController:helpVc animated:YES];
            
        }
    }
    else if(indexPath.section ==  1)
    {
        if( indexPath.row == 0 )
        {
            [self buyClicked];
        }
        else if( indexPath.row == 1 )
        {
            [self restoreBuy];
        }
    }
    else if( indexPath.section == 3 )
    {
        if( indexPath.row ==  0 )
        {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/tong-nian-pin-tu-puzzle-shen-qi/id1088575286?mt=8"]];
        }
        else if( indexPath.row == 1 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/2048-jing-dian-wan-fa/id1089122844?mt=8"]];

        }
        else if( indexPath.row == 2 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/cai-shu-zi-guess-shen-qi/id1101608467?mt=8"]];

        }
        else if( indexPath.row == 3 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
        }
        else if( indexPath.row == 4 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
        }
        else if( indexPath.row == 5 )
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

/*
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
}
 */

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section ==  2)
    {
        return 2;
    }
    else if( section == 1 )
    {
        return 2;
    }
    else if( section == 3 )
    {
        return 3;
    }
    
    return 1;
}


@end












