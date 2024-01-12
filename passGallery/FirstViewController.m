//
//  FirstViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "FirstViewController.h"
#import "FirstTableViewCell.h"
#import "STAlertView.h"
#import "CommData.h"
#import "StructInfo.h"
#import "PicListViewController.h"
#import "AppDelegate.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GalleryManager.h"
#import "ThirdViewController.h"

//
@interface FirstViewController ()<UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate,UIAlertViewDelegate>
{
    STAlertView * stAlertView ;
    STAlertView *alert;
    NSMutableArray * galleryArray;
    
    AppDelegate * appDel;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
    _tableView.backgroundColor =RGB(237, 230, 222);
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _tableView.separatorStyle =UITableViewCellSeparatorStyleNone;
    [self initNavView];
    
    [self getGalleryList];
    
    [self laytouADVView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGalleryList) name:@"refresh" object:nil];
}

-(void)getGalleryList
{
    [galleryArray removeAllObjects];
    
    //
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSData * data;
    
    if( appDel.bPretendLogo )
    {
        data = [def objectForKey:STORE_PRETEND_GALLERY];
    }
    else
    {
        data = [def objectForKey:STORE_TRUE_GALLERY];
    }
    NSError *unarchiveError;

    
    NSSet *classSet = [NSSet setWithObjects:[NSArray class],[NSMutableArray class],[GalleryInfo class],[NSData class],[NSNumber class],[NSString class], nil];
    galleryArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:classSet fromData:data error:&unarchiveError];
    NSLog(@"Error unarchiving data: %@", unarchiveError);

    if(!galleryArray)
    {
        galleryArray = [NSMutableArray new];
    }
    
    //
    [_tableView reloadData];
}

-(void)addGallery:(NSString*)name video:(BOOL)isVideo
{
    GalleryInfo * info = [GalleryInfo new];
    info.name = name;
    info.isVideo = isVideo;
    [galleryArray addObject:info];
    //
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSError *saveError;
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:galleryArray requiringSecureCoding:YES error:&saveError];
    NSLog(@"Error unarchiving data: %@", saveError);

    if( appDel.bPretendLogo )
    {
        [def setObject:data forKey:STORE_PRETEND_GALLERY];
    }
    else
    {
        [def setObject:data forKey:STORE_TRUE_GALLERY];
    }
    
    
    [def synchronize];
    
}

-(void)initNavView
{
    self.title = NSLocalizedString(@"私密相册",nil);
    
    {
        
        self.navigationController.navigationBar.barTintColor = navColor;
        self.navigationController.navigationBar.tintColor = navColor;
        self.navigationController.navigationBar.titleTextAttributes =[NSDictionary dictionaryWithObject:navColor forKey:NSForegroundColorAttributeName];
    }
    
    {
        
        UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightClicked)];
        [self.navigationItem setLeftBarButtonItem:leftBtn];
        leftBtn.tintColor = navColor;
        
        //
        UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"设置",nil) style:UIBarButtonItemStyleDone target:self action:@selector(leftClick)];
        rightBtn.tintColor = navColor;
        [self.navigationItem setRightBarButtonItem:rightBtn];
        
    }
    
    {
        //[self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
    }
}
-(void)leftClick{
    ThirdViewController *thirdVc =[[ThirdViewController alloc]init];
    [self.navigationController pushViewController:thirdVc animated:YES];
}

-(void)rightClicked
{
     alert = [[STAlertView alloc]initWithTitle:NSLocalizedString(@"相册类型",nil) message:nil cancelButtonTitle:NSLocalizedString(@"图片相册",nil) otherButtonTitles:NSLocalizedString(@"视频相册",nil) cancelButtonBlock:^{
        [self showFile:NO];
    } otherButtonBlock:^{
        [self showFile:YES];
    }];
}

-(void)showFile:(BOOL)isVideo {
    stAlertView = [[STAlertView alloc] initWithTitle:NSLocalizedString(@"新建相册",nil)
                                                  message:NSLocalizedString(@"请输入相册名字",nil)
                                            textFieldHint:NSLocalizedString(@"新建相册",nil)
                                           textFieldValue:nil
                                        cancelButtonTitle:NSLocalizedString(@"取消",nil)
                                        otherButtonTitles:NSLocalizedString(@"确定",nil)
                        
                                        cancelButtonBlock:^{
                                            NSLog(@"Please, give me some feedback!");
                                        } otherButtonBlock:^(NSString * result){
                                            NSLog(@"result:%@",result);
                                            if (result.length==0) {
                                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"名字不能为空",nil)];
                                                return ;
                                            }
                                            BOOL ishas = NO;
                                            for (GalleryInfo *info in galleryArray) {
                                                if ([info.name isEqualToString:result]) {
                                                    ishas = YES;
                                                    break;
                                                    
                                                }
                                            }
                                            if (ishas) {
                                                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"相册已存在",nil)];
                                                return;
                                            }
                                            if( appDel.bPretendLogo )
                                            {
                                                [self addGallery:[NSString stringWithFormat:@" %@ ",result] video:isVideo];
                                            }
                                            else
                                            {
                                                [self addGallery:result video:isVideo];
                                            }
                                            
                                            
                                            [_tableView reloadData];
                                        }];

}

#pragma UITableView
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * strCell = @"FirstTableViewCell";
    
    FirstTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    if( !cell )
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:strCell owner:self options:nil]lastObject];
    }
    
    [cell refreshCell:[galleryArray objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [galleryArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryInfo * info = [galleryArray objectAtIndex:indexPath.row];
    
    PicListViewController * vc = [[PicListViewController alloc]init];
    vc.dirName = info.name;
    vc.isvideo  = info.isVideo;
    vc.galleryArray = galleryArray;
    [self.navigationController pushViewController:vc animated:YES];
    
    
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTF_HIED_TABVIEW object:nil userInfo:@{NOTF_HIED_TABVIEW:@"0"}];
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete )
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"警告",nil) message:NSLocalizedString(@"确定删除所选相册?相册所有内容将会全部删除",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:NSLocalizedString(@"取消",nil), nil];
        alert.tag = indexPath.row;
        [alert show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        GalleryInfo * info = galleryArray[alertView.tag];
        
        [SVProgressHUD showWithStatus:NSLocalizedString(@"删除中,请稍候",nil) maskType:SVProgressHUDMaskTypeClear];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
            
            dispatch_sync(dispatch_get_global_queue(0, 0), ^(void){
                
                [GalleryManager removeDir:info.name];
            });
            
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"删除成功",nil)];
                
                NSData * data;
                 NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
                 
                 [galleryArray removeObjectAtIndex:alertView.tag];
                 data = [NSKeyedArchiver archivedDataWithRootObject:galleryArray requiringSecureCoding:YES error:nil];
                 
                 if( appDel.bPretendLogo )
                 {
                 [def setObject:data forKey:STORE_PRETEND_GALLERY];
                 }
                 else
                 {
                 [def setObject:data forKey:STORE_TRUE_GALLERY];
                 }
                //
                [_tableView reloadData];
                
            });
            
        });
        
        
        
        //
       
    }
}

//底部广告
-(void)laytouADVView
{
    if( ![appDel showAdv] )
    {
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height );
        return;
    }
    
    if( YES )
    {
        CGPoint pt ;
        
        pt = CGPointMake(0, SCREEN_HEIGHT- 60 - SAFE_BOTTOM);
        
        GADBannerView * _bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, pt.y, SCREEN_WIDTH, 60)];
        _bannerView.rootViewController = self;//调用你的id
        _bannerView.adUnitID = @"ca-app-pub-7962668156781439/8214473704";
        _bannerView.delegate = self;
        [_bannerView loadRequest:[GADRequest request]];
        
        [self.view addSubview:_bannerView];
        
    }


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



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // [self getGalleryList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
