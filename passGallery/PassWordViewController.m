//
//  PassWordViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "PassWordViewController.h"
#import "AppDelegate.h"
#import "STAlertView.h"
#import "CommData.h"
#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
@interface PassWordViewController ()<UITextFieldDelegate, GADFullScreenContentDelegate>
{
    NSMutableString * pwsStr1;
    NSMutableString * pwsStr2;
    BOOL bFistPWD;//第一遍密码，第二遍密码
    
    PASSWORD_TYPE assType;//辅助的类型
}

@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UITextField *passField;
@property (weak, nonatomic) IBOutlet UIImageView *pwImgV1;
@property (weak, nonatomic) IBOutlet UIImageView *pwImgV2;
@property (weak, nonatomic) IBOutlet UIImageView *pwImgV3;
@property (weak, nonatomic) IBOutlet UIImageView *pwImgV4;
@property (weak, nonatomic) IBOutlet UILabel *pretendLab;
@property (strong, nonatomic) GADBannerView *banerView;
@property (strong, nonatomic) GADInterstitialAd *interstitial;

- (IBAction)btnClicked;

@end

@implementation PassWordViewController

-(void)tapAction{
    [_passField becomeFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *pan =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_backView addGestureRecognizer:pan];
    [_pwImgV2 setUserInteractionEnabled:NO];
    [_pwImgV3 setUserInteractionEnabled:NO];
    [_pwImgV4 setUserInteractionEnabled:NO];
    [_pwImgV1 setUserInteractionEnabled:NO];
    
    [self resetImgView];
    
    [_passField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_passField becomeFirstResponder];
    
    bFistPWD = YES;//第一遍的密码
    
    
    
    if( _passType == PASSWORD_INIT_PRETENDPASS )
    {
        _tipLab.text = @"请输入伪装密码";
        _pretendLab.hidden = NO;
        _pretendLab.text = NSLocalizedString(@"通过使用假密码登录，则会显示另一组照片，而使用真实密码导入的照片将不会显示，以防止被审查.", nil);
    }
    else
    {
        _pretendLab.hidden = YES;
    }
    
    if( ![self getTurePassWord] )
    {
        _passType = PASSWORD_INIT_TUREPASS;
        _tipLab.text = NSLocalizedString(@"请设置密码",nil);

    }else
        _tipLab.text = NSLocalizedString(@"请输入密码",nil);
    if (_passType ==PASSOWRD_MODIFY_TRUEPASS) {
        _tipLab.text = NSLocalizedString(@"请输入旧密码",nil);
    }
    AppDelegate *aapp= [UIApplication sharedApplication].delegate;
        
    if ([aapp showAdv]) {
        int aa = SCREEN_HEIGHT-90;
        if (_passType == PASSOWRD_MODIFY_TRUEPASS) {
            aa =204;
        }
        _banerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0, self.tipLab.frame.origin.y + 80, [UIScreen mainScreen].bounds.size.width, 50)];
        _banerView.rootViewController = self;
        _banerView.adUnitID =@"ca-app-pub-7962668156781439/7571417704";
        GADRequest *request= [GADRequest request];
        [self.view addSubview:_banerView];
        [_banerView loadRequest:request];
    }
    
    
}

- (void)loadInterstitial {
    self.interstitial = nil;
    
      GADRequest *request = [GADRequest request];
      [GADInterstitialAd
           loadWithAdUnitID:@"ca-app-pub-7962668156781439/7292216106"
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _backView.layer.borderColor = [UIColor greenColor].CGColor;
    _backView.layer.borderWidth = 1;
    _backView.layer.cornerRadius = 5;
    // Dispose of any resources that can be recreated.
  
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.interstitial) {
        [self.interstitial presentFromRootViewController:self];
    }
}
//设置伪密码登录标志
-(void)setPretendLogo:(BOOL)b
{
    AppDelegate * appDel = [[UIApplication sharedApplication]delegate];
    appDel.bPretendLogo = b;
}

-(void)resetImgView
{
    _pwImgV1.image = [UIImage imageNamed:@"pwdUnInputed"];
    _pwImgV2.image = [UIImage imageNamed:@"pwdUnInputed"];
    _pwImgV3.image = [UIImage imageNamed:@"pwdUnInputed"];
    _pwImgV4.image = [UIImage imageNamed:@"pwdUnInputed"];
    
}

-(void)textFieldDidChange:(UITextField*)textField
{
    NSLog(@"text:%@",textField.text);
    
    if( !pwsStr1 )
    {
        pwsStr1 = [NSMutableString new];
    }
    
    if( !pwsStr2 )
    {
        pwsStr2 = [NSMutableString new];
    }
    
    //
    if( bFistPWD )
    {
        [pwsStr1 setString:textField.text];
    }
    else
    {
        [pwsStr2 setString:textField.text];
    }
    
    NSString * str = textField.text;
    
    [self resetImgView];
    
    if( [str length] == 1 )
    {
        _pwImgV1.image = [UIImage imageNamed:@"pwd"];
    }
    
    if( [str length] == 2 )
    {
        _pwImgV1.image = [UIImage imageNamed:@"pwd"];
        _pwImgV2.image = [UIImage imageNamed:@"pwd"];
    }
    
    if( [str length] == 3 )
    {
        _pwImgV1.image = [UIImage imageNamed:@"pwd"];
        _pwImgV2.image = [UIImage imageNamed:@"pwd"];
        _pwImgV3.image = [UIImage imageNamed:@"pwd"];
    }
    
    if( [str length] == 4 )
    {
        _pwImgV1.image = [UIImage imageNamed:@"pwd"];
        _pwImgV2.image = [UIImage imageNamed:@"pwd"];
        _pwImgV3.image = [UIImage imageNamed:@"pwd"];
        _pwImgV4.image = [UIImage imageNamed:@"pwd"];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.2*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            
        if( bFistPWD )
        {
            bFistPWD = NO;
            
            if( _passType == PASSWORD_INIT_TUREPASS )//初始化真密码
            {
                _tipLab.text = NSLocalizedString(@"请再次输入密码",nil);
                
                _passField.text = @"";
                
                [self resetImgView];
            }
            else if( _passType == PASSWORD_INIT_PRETENDPASS )//设置假密码
            {
                if( [pwsStr1 isEqualToString:[self getTurePassWord]] )
                {
                    bFistPWD = YES;
                    _passField.text = @"";
                    [self resetImgView];
                    
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"伪装密码请不要跟真密码一样!",nil)];
                    return;
                }
                
                _tipLab.text = NSLocalizedString(@"请再次输入密码",nil);
                
                _passField.text = @"";
                
                [self resetImgView];
            }
            else if( _passType == PASSWORD_CHECK )//登录
            {
                //真密码登录
                if( [[self getTurePassWord] isEqualToString:pwsStr1] )
                {
                    [self setPretendLogo:NO];
                    
                    [self gotoMainVC];
                }
                //假密码登录
                else if( [[self getPretendPassWord] isEqualToString:pwsStr1] )
                {
                    NSLog(@"假密码登录");
                    
                    [self setPretendLogo:YES];
                    
                    [self gotoMainVC];
                }
                else//错误
                {
                    [self resetImgView];
                    _passField.text = @"";
                    bFistPWD = YES;
                    _tipLab.text = NSLocalizedString(@"密码错误，重新输入",nil);
                    [self animateIncorrectPassword];
                }
            }
            else if( _passType == PASSWORD_ANY_VIEW_CHECK )//登录
            {
                //真密码登录
                if( [[self getTurePassWord] isEqualToString:pwsStr1] )
                {
                    [self setPretendLogo:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                //假密码登录
                else if( [[self getPretendPassWord] isEqualToString:pwsStr1] )
                {
                    NSLog(@"假密码登录");
                    
                    [self setPretendLogo:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else//错误
                {
                    [self resetImgView];
                    _passField.text = @"";
                    bFistPWD = YES;
                    _tipLab.text = NSLocalizedString(@"密码错误，重新输入",nil);
                    [self animateIncorrectPassword];
                }
            }
            else if( _passType == PASSOWRD_MODIFY_TRUEPASS )
            {
                if( [[self getTurePassWord] isEqualToString:pwsStr1] )
                {
                    assType = PASSOWRD_MODIFY_TRUEPASS;
                    
                    bFistPWD = YES;
                    _passType = PASSWORD_INIT_TUREPASS;
                    
                    _passField.text = @"";
                    _tipLab.text = NSLocalizedString(@"请输入新的密码",nil);
                    
                    [self resetImgView];
                }
                else
                {
                    [self resetImgView];
                    _passField.text = @"";
                    bFistPWD = YES;
                    _tipLab.text = NSLocalizedString(@"密码错误，重新输入",nil);
                    [self animateIncorrectPassword];
                }
            }
        }
        else
        {
            if( [pwsStr1 isEqualToString:pwsStr2] )
            {
                NSLog(@"密码设置成功");
                
                if( _passType == PASSWORD_INIT_TUREPASS )
                {
                    [self setTurePassWord:pwsStr1];
                }
                else if( _passType == PASSWORD_INIT_PRETENDPASS )
                {
                    [self setPretendPassWord:pwsStr1];
                }
                
                //如果是修改真密码，不需要gotoMainVC 直接dismiss 就可以
                if( assType == PASSOWRD_MODIFY_TRUEPASS || _passType == PASSWORD_INIT_PRETENDPASS )
                {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"密码修改成功",nil)];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD dismiss];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }
                else
                {
                    [self gotoMainVC];
                }

                //
            }
            //两次密码不一样
            else
            {
                [self animateIncorrectPassword];
                
                [self resetImgView];
                _passField.text = @"";
                _tipLab.text = NSLocalizedString(@"两次密码不一致,请重新输入",nil);
                
                
                
                bFistPWD = YES;

            }
        }
        });
   
    }
}
- (void)animateIncorrectPassword {
    _backView.layer.borderColor = [UIColor redColor].CGColor;

    CGAffineTransform moveRight = CGAffineTransformTranslate(CGAffineTransformIdentity, 20, 0);
    CGAffineTransform moveLeft = CGAffineTransformTranslate(CGAffineTransformIdentity, -20, 0);
    CGAffineTransform resetTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    
    [UIView animateWithDuration:0.05 animations:^{
        // Translate left
        _backView.transform = moveLeft;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.05 animations:^{
            
            // Translate right
            _backView.transform = moveRight;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.05 animations:^{
                
                // Translate left
                _backView.transform = moveLeft;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.05 animations:^{
                    
                    // Translate to origin
                    _backView.transform = resetTransform;
                }];
            }];
            
        }];
    }];
    
}
////////////////////////////////////////////////
-(NSString*)getTurePassWord
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSString * pass = [def objectForKey:STORE_TURE_PASSWORD];
    
    return pass;
}

-(void)setTurePassWord:(NSString*)strPass
{
    [self setPretendLogo:NO];
    
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:strPass forKey:STORE_TURE_PASSWORD];
    [def synchronize];
}

-(NSString*)getPretendPassWord
{
    [self setPretendLogo:YES];
    
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSString * pass = [def objectForKey:STORE_PRETEND_PASSWORD];
    
    return pass;
}

-(void)setPretendPassWord:(NSString*)strPass
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:strPass forKey:STORE_PRETEND_PASSWORD];
    [def synchronize];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not
{
    NSLog(@"aaa");
    return YES;
}


- (void)gotoMainVC
{
    [self removeFromParentViewController];
    
    AppDelegate * app = [[UIApplication sharedApplication ]delegate];
    [app changeRootVC];
}
- (void)btnClicked __attribute__((ibaction)) {
}

@end
