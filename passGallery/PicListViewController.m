//
//  PicListViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "PicListViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "StructInfo.h"
#import "GalleryManager.h"
#import "SVProgressHUD.h"
#import "EditImgView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ZYQAssetPickerController.h"
#import "MJPhotoBrowser.h"
#import "CommData.h"
#import "AppDelegate.h"
#import "MJPhoto.h"
#import <Photos/Photos.h>
#import <PHASE/PHASE.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <KNPhotoBrowser/KNPhotoBrowser.h>
#import <SDWebImage/SDWebImage.h>
#define EDIT_VIEW_HEIGHT  50

#define ALERT_DEL_TAG   10086
#define ALERT_MOVE_TAG  10087 



@interface PicListViewController ()<UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,EditImgViewDelegate,ZYQAssetPickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, KNPhotoBrowserDelegate>
{
    
    BOOL allSelected;
    
}
@property(nonatomic,strong)UICollectionView * tcollectionView;
@property(nonatomic,strong)NSMutableArray * picInfoArray;
@property(nonatomic,strong)NSMutableArray * eidtImgViewArray;
@property(nonatomic,strong)UIView * editView;
@property(nonatomic,strong)NSIndexPath *lastAccessed;
@property(nonatomic,weak)AppDelegate *appDel;
@property(nonatomic,strong)UIButton *delBtn;
@property(nonatomic,strong)UIButton *allBtn;
@property(nonatomic,strong)GADBannerView *bBannerView1;
@property(nonatomic,strong)GADBannerView *bBannerView2;

@end

@implementation PicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
    self.appDel = (AppDelegate *)delegate;
    //
    
    UICollectionViewFlowLayout *flowl=[[UICollectionViewFlowLayout alloc]init];
    flowl.sectionInset = UIEdgeInsetsMake(10 , 10, 10, 10);
    _tcollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)collectionViewLayout:flowl];
    _tcollectionView.delegate = self;
    _tcollectionView.dataSource = self;
    _tcollectionView.backgroundColor = RGB(239, 239, 244);
    _tcollectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_tcollectionView];
    self.view.backgroundColor = _tcollectionView.backgroundColor;

    if (![self.appDel showAdv]) {
        _tcollectionView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } else {
        GADBannerView *baner = [[GADBannerView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 60 - SAFE_BOTTOM, self.view.frame.size.width, 60)];
        baner.rootViewController = self;
        baner.adUnitID =@"ca-app-pub-7962668156781439/9691206909";
        GADRequest *request =[GADRequest request];

        [baner loadRequest:request];
        [self.view addSubview:baner];
    }
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
        [self refreshPics];
        dispatch_sync(dispatch_get_main_queue(), ^(void){
            [_tcollectionView reloadData];
            [SVProgressHUD dismiss];
        });
    });
    
    //
    
    _editView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width , EDIT_VIEW_HEIGHT )];
    _editView.backgroundColor = [UIColor whiteColor];
    _editView.userInteractionEnabled = YES;
    [self.view addSubview:_editView];
    
    
    //
    self.title = _dirName;
    //
    _delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_editView.frame)/2, CGRectGetHeight(_editView.frame))];
    [_delBtn setTitle:NSLocalizedString(@"删除",nil) forState:UIControlStateNormal];
    [_delBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [_editView addSubview:_delBtn];
    [_delBtn addTarget:self action:@selector(delClicked) forControlEvents:UIControlEventTouchDown];
    UIView  *line= [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_delBtn.frame), 0, 1, CGRectGetHeight(_editView.frame))];
    line.backgroundColor =[UIColor colorWithWhite:0.9 alpha:1];
    [_editView addSubview:line];
    
    _allBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_delBtn.frame), 0, CGRectGetWidth(_delBtn.frame),CGRectGetHeight(_delBtn.frame))];
    [_allBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_allBtn setTitle:NSLocalizedString(@"全选",nil) forState:UIControlStateNormal];
    [_editView addSubview:_allBtn];
    [_allBtn addTarget:self action:@selector(allClcied) forControlEvents:UIControlEventTouchDown];
    //
    {
        
        _selectedIdx = [[NSMutableDictionary alloc] init];
        
        [_tcollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [_tcollectionView setAllowsMultipleSelection:YES];
        
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self.view addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer setMinimumNumberOfTouches:1];
        [gestureRecognizer setMaximumNumberOfTouches:1];
    }
    [self resetNavBtn];
    
}

- (GADBannerView *)bBannerView1
{
    if (_bBannerView1 == nil) {
        _bBannerView1 = [[GADBannerView alloc] initWithFrame:CGRectMake(0, SAFE_TOP + 20, SCREEN_WIDTH, 60)];
        _bBannerView1.rootViewController = self;
        _bBannerView1.adUnitID = @"ca-app-pub-7962668156781439/2972853517";
    }
    return _bBannerView1;
}

- (GADBannerView *)bBannerView2
{
    if (_bBannerView2 == nil) {
        _bBannerView2 = [[GADBannerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - SAFE_BOTTOM - 60, SCREEN_WIDTH, 60)];
        _bBannerView2.rootViewController = self;
        _bBannerView2.adUnitID = @"ca-app-pub-7962668156781439/5252382555";
    }
    return _bBannerView2;
}

- (void)resetNavBtn
{
    
//    UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClicked)];
//    leftBtn.tintColor = COLORHEX(0xea8010);
    [self.navigationItem setLeftBarButtonItem:nil];
    UIBarButtonItem * rightBtn1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked)];
    UIBarButtonItem * spaceBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBtn.width = 10;
    UIBarButtonItem * rightBtn2 = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"编辑",nil) style:UIBarButtonItemStyleDone target:self action:@selector(editClicked)];
    rightBtn2.tintColor = navColor;
    [self.navigationItem setRightBarButtonItems:@[rightBtn2, spaceBtn, rightBtn1] animated:YES];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( alertView.tag == ALERT_DEL_TAG )
    {
        if( buttonIndex == 0 )
        {
            [self deleteArray:nil];
        }
    }
}

- (void)deleteArray:(KNPhotoBrowser *)brower
{
    for (PicInfo * info in _eidtImgViewArray) {
        [GalleryManager deleteOnePic:info];
    }
    [_picInfoArray removeObjectsInArray:_eidtImgViewArray];
    [_eidtImgViewArray removeAllObjects];
    [brower removeImageOrVideoOnPhotoBrowser];
    [self doneClicked];
}


-(void)showEditView:(BOOL)show
{
    
    
    CGFloat pos;
    
    pos = show ? (0 - EDIT_VIEW_HEIGHT - SAFE_BOTTOM) : EDIT_VIEW_HEIGHT + SAFE_BOTTOM;
    
    if ((_editView.center.y + pos) > (SCREEN_HEIGHT + EDIT_VIEW_HEIGHT)) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^(void){
        
        _editView.center = CGPointMake(_editView.center.x, _editView.center.y + pos);
        
    }];
    
}

-(void)updateTitle:(NSInteger)count{
    if (_picInfoArray.count == 0) {
        return;
    }
    if (count ==_picInfoArray.count) {
        
        NSString *str = NSLocalizedString(@"删除", nil);
        str =  [str stringByAppendingString:[NSString stringWithFormat:@"删除(%lu)",(unsigned long)_eidtImgViewArray.count]];
        
        [_delBtn setTitle:str forState:UIControlStateNormal];

        [_allBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"取消全选",nil)] forState:UIControlStateNormal];

    }else{
        
        NSString *str = NSLocalizedString(@"删除", nil);
        str =  [str stringByAppendingString:[NSString stringWithFormat:@"删除(%lu)",(unsigned long)_eidtImgViewArray.count]];
        [_delBtn setTitle:str forState:UIControlStateNormal];
        [_allBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"全选",nil)] forState:UIControlStateNormal];

    }
}

//全选
-(void)allClcied
{

    if (_eidtImgViewArray.count !=_picInfoArray.count) {
        [_eidtImgViewArray removeAllObjects];
        [_eidtImgViewArray addObjectsFromArray:_picInfoArray];
        
        for (int i= 0; i<_picInfoArray.count; i++) {
            [_selectedIdx setValue:@"1" forKey:[NSString stringWithFormat:@"%d",i]];

        }
        
    }else{
        
        NSArray *arr =[NSArray arrayWithArray:_selectedIdx.allKeys];
        for (NSString *str in arr) {
            [_selectedIdx removeObjectForKey:str];
            
        }
        [_eidtImgViewArray removeAllObjects];
    }
    [_tcollectionView reloadData];

    [self updateTitle:_eidtImgViewArray.count];
}


//删除按钮
-(void)delClicked
{
    if (_eidtImgViewArray.count == 0) {
        return;
        
    }
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"警告",nil) message:NSLocalizedString(@"确定删除所选内容?",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:NSLocalizedString(@"取消",nil), nil];
    alert.tag = ALERT_DEL_TAG;
    [alert show];
}

-(void)refreshPics
{
        //
        if(!_picInfoArray)
        {
            _picInfoArray = [NSMutableArray new];
        }
        if( !_eidtImgViewArray )
        {
            _eidtImgViewArray = [NSMutableArray new];
        }
        
        [_picInfoArray removeAllObjects];
        [_eidtImgViewArray removeAllObjects];
        
        //
        NSArray * array  = [[GalleryManager getAllFileNames:_dirName] copy];
        
        for( int i = 0 ; i < array.count; ++ i )
        {
            PicInfo * info = [PicInfo new];
            info.picName = [array objectAtIndex:i];
            info.dirName = _dirName;
            info.bSelected = NO;
            info.url =[NSURL fileURLWithPath:[[GalleryManager createPath:info.dirName ] stringByAppendingPathComponent:info.picName]];

            NSString *st =[info.picName.pathExtension lowercaseString];
            if ([st.lowercaseString isEqualToString:@"jpg"]||[st.lowercaseString isEqualToString:@"png"]||[st.lowercaseString isEqualToString:@"gif"]||[st.lowercaseString isEqualToString:@"jpeg"]||[st.lowercaseString isEqualToString:@"heic"]) {
//                info.img = [GalleryManager getImageFileWithDir:_dirName withName:info.picName];
//                info.tmpImg = [GalleryManager getThumbnailImageFileWithDir:_dirName withName:info.picName];

            } else {
//                UIImage *thumbnail = [self generateThumbnailForVideo:[info.url path]];
//                info.img = thumbnail;
                info.isVideo = YES;
            }
            
            [_picInfoArray addObject:info];
            
       }
    
//    
//    if( array.count ==  0 )
//    {
//        [self refreshGallery:nil withCount:0];
//    }
//    
//    
//    
    //
}




-(void)refreshGallery
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
//    NSData * data;
//    
//    if( self.appDel.bPretendLogo )
//    {
//        data = [def objectForKey:STORE_PRETEND_GALLERY];
//    }
//    else
//    {
//        data = [def objectForKey:STORE_TRUE_GALLERY];
//    }
    
    //
    PicInfo *picinfo = nil;
    if (self.picInfoArray.count) {
        picinfo = [self.picInfoArray firstObject];
    }
    
    NSMutableArray *array = self.galleryArray;
    
    for( int i = 0;i < array.count; ++ i )
    {
        GalleryInfo * info = array[i];
        
        if( [info.name isEqualToString:_dirName] )
        {
            if (picinfo.tmpImg) {
                //info.imgShut = UIImageJPEGRepresentation(picinfo.tmpImg, 0.3);//[GalleryManager getDataFormUIImage:shutImg];
            } else {
                //info.imgShut = nil;
            }
            info.count = @(self.picInfoArray.count);
            
            [array replaceObjectAtIndex:i withObject:info];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array requiringSecureCoding:YES error:nil];
            if( self.appDel.bPretendLogo )
            {
                [def setObject:data forKey:STORE_PRETEND_GALLERY];
            }
            else
            {
                [def setObject:data forKey:STORE_TRUE_GALLERY];
            }
            [def synchronize];
            
            break;
        }
    }
}

-(void)backClicked
{
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTF_HIED_TABVIEW object:nil userInfo:@{NOTF_HIED_TABVIEW:@"1"}];

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editClicked
{
    [self showEditView:YES];
    
    _bEdit = YES;
    [self setEditNavBtn];
}

- (void)setEditNavBtn
{

    //
    UIBarButtonItem * leftBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked)];
    leftBtn.tintColor = navColor;

    [self.navigationItem setLeftBarButtonItem:leftBtn];
    
    //
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"完成",nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)];
    rightBtn.tintColor = navColor;
    [self.navigationItem setRightBarButtonItem:rightBtn];
    
}

-(void)doneClicked
{
    
    [self showEditView:NO];
    NSArray *arr =[NSArray arrayWithArray:_selectedIdx.allKeys];
    for (NSString *str in arr) {
        [_selectedIdx removeObjectForKey:str];
    }
    [_eidtImgViewArray removeAllObjects];
    [_tcollectionView reloadData];
    [self updateTitle:_eidtImgViewArray.count];
    _bEdit = NO;
    
    [self resetNavBtn];

    [self refreshGallery];
}

-(void)addClicked
{
    NSArray *arr = @[NSLocalizedString(@"相册",nil),NSLocalizedString(@"相机",nil)];
    if (self.isvideo) {
        arr = @[NSLocalizedString(@"相册",nil)];
    }
    KNActionSheet *sheet = [[KNActionSheet alloc]initWithTitle:@"" cancelTitle:NSLocalizedString(@"取消",nil) titleArray:arr actionSheetBlock:^(NSInteger buttonIndex) {
        [self actionSheetAtIndex:buttonIndex];
    }];
    
    [sheet showOnView:self.view];
}


- (void)actionSheetAtIndex:(NSInteger)buttonIndex
{
    if( 1 == buttonIndex )
    {
        [self takeCamera];
    }
    else if( 0 == buttonIndex )
    {
        ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
        picker.maximumNumberOfSelection = 20;
        if (self.isvideo) {
            picker.assetsFilter = ZYQAssetsFilterAllVideos;
            picker.maximumNumberOfSelection = 1;
        } else {
            picker.assetsFilter = ZYQAssetsFilterAllPhotos;
        }
        picker.showEmptyGroups=NO;
        picker.delegate=self;
//        picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//            if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
//                NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
//                return duration >= 5;
//            } else {
//                return YES;
//            }
//        }];
        picker.navigationBar.tintColor = navColor;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark - QBImagePickerControllerDelegate
-(void)postAction{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [SVProgressHUD dismiss];
        [self doneClicked];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_IMPORT_SUCC object:nil];
        });
}
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    if (assets == nil || assets.count <= 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            for (int i=0; i<assets.count; i++)
            {
                @autoreleasepool {
                    BOOL isv = NO;
                    ZYQAsset *oAsset = assets[i];
                    PHAsset *asset = oAsset.originAsset;
                    if (oAsset.mediaType == ZYQAssetMediaTypeVideo) {
                        isv =YES;
                    } else
                        isv = NO;
                    
                    __block UIImage *tempImg = nil;
                    __block UIImage *originImg = nil;
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                    
                    [oAsset setGetThumbnail:^(UIImage *result) {
                        tempImg = result;
                    }];
                    
//                    [oAsset setGetOriginImage:^(UIImage *result) {
//                        originImg = result;
//                        // 信号量通知已经执行完毕
//                        dispatch_semaphore_signal(semaphore);
//
//                    }];
//                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

                    PicInfo *info = [PicInfo new];
                    PHAssetResource *assetResource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
                    NSString *filename = assetResource.originalFilename;
                    info.picName = filename;
                    info.dirName = _dirName;
                    info.isVideo = isv;
                    info.url= [NSURL fileURLWithPath:[[GalleryManager createPath:_dirName]stringByAppendingPathComponent:info.picName] ];
                    info.img = tempImg;
                    info.tmpImg = tempImg;
//                    [_picInfoArray addObject:info];
                    [GalleryManager storeOnePic:oAsset withName:info compliteBlock:^(PicInfo *obj, NSString *errorMsg, BOOL isError) {
                        
                        if (isError) {
                            dispatch_async(dispatch_get_main_queue(), ^{
//                                [SVProgressHUD dismiss];
                                [SVProgressHUD showErrorWithStatus:errorMsg];
                            });
                        } else {
                            
//                            if (info.isVideo) {
//                                UIImage *videoImg = [GalleryManager generateThumbnailForVideo:[info.url path]];
//                                NSString *vImagePath = [[GalleryManager createPath:info.dirName] stringByAppendingPathComponent:[info.picName stringByAppendingString:@".png"]];
//                                [UIImagePNGRepresentation(videoImg) writeToFile:vImagePath atomically:YES];
//                            }
                            
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_picInfoArray addObject:info];
                                [self postAction];
                            });
                        }
                    }];
                }
             }
    });
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"导入中,请稍候",nil) maskType:SVProgressHUDMaskTypeClear];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.appDel.bPretendLogo) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma EditImgView
-(void)imageClicked:(NSInteger)tag selected:(BOOL)selected
{
    if( _bEdit )
    {
        PicInfo * info= [_picInfoArray objectAtIndex:tag];
        info.bSelected = selected;
        [_picInfoArray replaceObjectAtIndex:tag withObject:info];
    }
    else
    {
        PicInfo * info = [_picInfoArray objectAtIndex:tag];
        
    }
}

/***********************************************************************************************/

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)i
{
    UIImage* image = [i objectForKey:@"UIImagePickerControllerOriginalImage"];
    //
    PicInfo * info = [PicInfo new];
    info.picName=  [NSString stringWithFormat:@"%d.jpg",arc4random()];
    info.dirName = _dirName;
    
    info.img = image;
    info.tmpImg = image;
    [_picInfoArray addObject:info];
    
    NSString *file =[[GalleryManager createPath:info.dirName]stringByAppendingPathComponent:info.picName];
    [UIImagePNGRepresentation(image)writeToFile:file atomically:YES];
    
    //
    [self doneClicked];
    //
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize  withSource:(UIImage*)sourceImage
{
    /*
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    
    if ( CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
        {
            scaleFactor = widthFactor;
        }
        else
        {
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) ;
        }
        else if (widthFactor > heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) ;
        }
    }
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"could not scale image");
    }
    
    return newImage ;
     */
    
    return nil;
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//读取文件
-(UIImage*)getImageFromFile:(NSString*)strFile
{
    UIImage * image = [UIImage imageWithContentsOfFile:strFile];
    
    return image;
}

//删除文件
-(void)clearTempImage
{
    /*
     for( NSString * strPath in _filePathArray )
     {
     NSFileManager *defaultManager;
     defaultManager = [NSFileManager defaultManager];
     [defaultManager removeItemAtPath:strPath error:nil];
     }
     */
}

//写入文件
-(BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    @try
    {
        NSData *imageData = nil;
        
        NSString *ext = [aPath pathExtension];
        
        if ([ext isEqualToString:@"png"])
        {
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            imageData = UIImageJPEGRepresentation(image, 1);
        }
        
        if ((imageData == nil) || ([imageData length] <= 0))
        {
            return NO;
        }
        
        [imageData writeToFile:aPath atomically:YES];
        
        return YES;
    }
    
    @catch (NSException *e)
    {
        NSLog(@"create thumbnail exception.");
    }
    
    return NO;
}

-(void)takeCamera
{
    [self takeImageClcked:UIImagePickerControllerSourceTypeCamera];
}

- (void)takeImageClcked:(UIImagePickerControllerSourceType)type
{
   UIImagePickerController * imgPicker = [[UIImagePickerController alloc]init];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = NO;
    imgPicker.sourceType = type;//
    
    [self presentViewController:imgPicker animated:YES completion:nil];
    
}



#define selectedTag 100
#define cellSize 72
#define newCellSize ([UIScreen mainScreen].bounds.size.width - 30) / 2

#define textLabelHeight 20
#define cellAAcitve 1.0
#define cellADeactive 0.3
#define cellAHidden 0.0
#define defaultFontSize 10.0


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _picInfoArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (![cell viewWithTag:selectedTag])
    {
        UILabel *selected = [[UILabel alloc] initWithFrame:CGRectMake(0, newCellSize - textLabelHeight, newCellSize, textLabelHeight)];
        selected.backgroundColor = [UIColor darkGrayColor];
        selected.textColor = [UIColor whiteColor];
        selected.text = @"SELECTED";
        selected.textAlignment = NSTextAlignmentCenter;
        selected.font = [UIFont systemFontOfSize:defaultFontSize];
        selected.tag = selectedTag;
        selected.alpha = cellAHidden;
        
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, newCellSize, newCellSize)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = selectedTag * 2;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:selected];

    }
    
    PicInfo *picinfo = [_picInfoArray objectAtIndex:[indexPath row] ];
    NSString * strFile = [NSString stringWithFormat:@"%@/%@/%@",[GalleryManager getFilePath],_dirName,picinfo.picName];
    
    UIImageView *imageview = [cell viewWithTag:selectedTag*2];
    if (picinfo.isVideo) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *img = [GalleryManager generateThumbnailForVideo:strFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                [imageview setImage:img];
            });
        });
    } else {
        [imageview sd_setImageWithURL:[NSURL fileURLWithPath:strFile]];
    }

    [[cell viewWithTag:selectedTag] setAlpha:cellAHidden];
    cell.backgroundView.alpha = cellADeactive;
    
    // You supposed to highlight the selected cell in here; This is an example
    bool cellSelected = [_selectedIdx objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    [self setCellSelection:cell selected:cellSelected];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(newCellSize, newCellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if (_bEdit) {
        bool cellSelected = [_selectedIdx objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];

        [self setCellSelection:cell selected:!cellSelected];
        PicInfo *info =[_picInfoArray objectAtIndex:indexPath.row];
        if (cellSelected) {
            [_selectedIdx removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];

            [_eidtImgViewArray removeObject:info];
        }else{
            [_eidtImgViewArray addObject:info];
            [_selectedIdx setValue:[NSString stringWithFormat:@"1"] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    }

        [self updateTitle:_eidtImgViewArray.count];
        return;
    }
    PicInfo *info = [_picInfoArray objectAtIndex:indexPath.row];
    
    if (info.isVideo) {
        AVAudioSession *avAudioSession = [AVAudioSession sharedInstance];
        [avAudioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [avAudioSession setActive:YES error:nil];
        
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[info.url path]]];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        
        // 模态推出播放器视图控制器
        [self presentViewController:playerViewController animated:YES completion:^{
            [player play];
            [player setMuted:NO];
        }];
        return;
        
    }
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_picInfoArray.count];
    
    for (PicInfo *pic in _picInfoArray) {
        NSInteger i = 0;
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:i];
        UICollectionViewCell *celll = [collectionView cellForItemAtIndexPath:indexPath];
        KNPhotoItems *info = [[KNPhotoItems alloc]init];
        info.sourceView = celll.backgroundView;
        info.sourceImage = [GalleryManager getImageFileWithDir:pic.dirName withName:pic.picName];
        if (pic.isVideo) {
            info.isVideo = pic.isVideo;
            info.url = [pic.url path];
        }
        [arr addObject:info];
        i++;
    }
//    
//    MJPhotoBrowser *Browser =[[MJPhotoBrowser alloc]init];
//    Browser.currentPhotoIndex =indexPath.row;
//    Browser.photos = arr;
//    [Browser show];
    
    KNPhotoBrowser *browser = [[KNPhotoBrowser alloc] init];
    browser.itemsArr = [arr copy];
    browser.currentIndex = indexPath.row;
    browser.placeHolderColor = UIColor.lightTextColor;
    browser.delegate = self;
    browser.isNeedPageControl = YES;
    browser.isNeedPageNumView = YES;
    browser.isNeedLongPress = YES;
    browser.isNeedPanGesture = YES;
    browser.isNeedRightTopBtn  = YES;
    browser.isNeedPrefetch = YES;
    browser.isNeedAutoPlay = NO;
    browser.isNeedOnlinePlay = YES;
    browser.isNeedVideoDismissButton = YES;
    [browser presentOn:self];
    
    [browser.view addSubview:self.bBannerView1];
    [browser.view addSubview:self.bBannerView2];
    [self.bBannerView1 loadRequest:[GADRequest request]];
    [self.bBannerView2 loadRequest:[GADRequest request]];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    bool cellSelected = [_selectedIdx objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:!cellSelected];
    
    [_selectedIdx setValue:[NSString stringWithFormat:@"%d",!cellSelected] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    PicInfo *info = [_picInfoArray objectAtIndex:indexPath.row];
    if (cellSelected) {
        [_eidtImgViewArray removeObject:info];
        [_selectedIdx removeObjectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];

    }else{
        [_selectedIdx setValue:[NSString stringWithFormat:@"1"] forKey:[NSString stringWithFormat:@"%d", indexPath.row]];

        [_eidtImgViewArray removeObject:info];
}
    [self updateTitle:_eidtImgViewArray.count];
}

- (void) setCellSelection:(UICollectionViewCell *)cell selected:(bool)selected
{
    cell.backgroundView.alpha = selected ? cellAAcitve : cellAAcitve;
    [cell viewWithTag:selectedTag].alpha = selected ? cellAAcitve : cellAHidden;
}

- (void) resetSelectedCells
{
    for (UICollectionViewCell *cell in _tcollectionView.visibleCells) {
        [self deselectCellForCollectionView:_tcollectionView atIndexPath:[_tcollectionView indexPathForCell:cell]];
    }
}

- (void) handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!_bEdit) {
        return;
    }
    float pointerX = [gestureRecognizer locationInView:_tcollectionView].x;
    float pointerY = [gestureRecognizer locationInView:_tcollectionView].y;
    
    for (UICollectionViewCell *cell in _tcollectionView.visibleCells) {
        float cellSX = cell.frame.origin.x;
        float cellEX = cell.frame.origin.x + cell.frame.size.width;
        float cellSY = cell.frame.origin.y;
        float cellEY = cell.frame.origin.y + cell.frame.size.height;
        
        if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY)
        {
            NSIndexPath *touchOver = [_tcollectionView indexPathForCell:cell];
            
            if (_lastAccessed != touchOver)
            {
                if (cell.selected)
                    [self deselectCellForCollectionView:_tcollectionView atIndexPath:touchOver];
                else
                    [self selectCellForCollectionView:_tcollectionView atIndexPath:touchOver];
            }
            
            _lastAccessed = touchOver;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        _lastAccessed = nil;
        _tcollectionView.scrollEnabled = YES;
    }
    
    
}

- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void) deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}

- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser rightBtnOperationActionWithIndex:(NSInteger)index{
    KNActionSheet *actionSheet = [[KNActionSheet share] initWithTitle:@""
                                                          cancelTitle:@"CANCEL"
                                                           titleArray:@[@"SAVE",@"DELETE"].mutableCopy
                                                     destructiveArray:@[].mutableCopy
                                                     actionSheetBlock:^(NSInteger buttonIndex) {
        NSLog(@"buttonIndex:%zd",buttonIndex);
        
        if (buttonIndex == 1) {
            [_eidtImgViewArray addObject:[_picInfoArray objectAtIndex:photoBrowser.currentIndex]];
            [self deleteArray:photoBrowser];
        }
        
        if (buttonIndex == 0) {
            [UIDevice deviceAlbumAuth:^(BOOL isAuthor) {
                if (isAuthor == false) {
                    // do something -> for example : jump to setting
                }else {
                    [photoBrowser downloadImageOrVideoToAlbum];
                }
            }];
        }
        
        if (buttonIndex == -1) {
            [_eidtImgViewArray removeAllObjects];
        }
    }];
    [actionSheet showOnView:photoBrowser.view];
}


- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser imageLongPressWithIndex:(NSInteger)index{
    
    KNActionSheet *actionSheet = [[KNActionSheet share] initWithTitle:@""
                                                          cancelTitle:NSLocalizedString(@"CANCEL",nil)
                                                           titleArray:@[NSLocalizedString(@"保存",nil),NSLocalizedString(@"删除", nil)].mutableCopy
                                                     destructiveArray:@[].mutableCopy
                                                     actionSheetBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [UIDevice deviceAlbumAuth:^(BOOL isAuthor) {
                if (isAuthor == false) {
                    // do something -> for example : jump to setting
                }else {
                    [photoBrowser downloadImageOrVideoToAlbum];
                }
            }];
        }
        if (buttonIndex == 1) {
            [_eidtImgViewArray addObject: [_picInfoArray objectAtIndex:photoBrowser.currentIndex]];
            [self deleteArray:photoBrowser];
        }
        
        if (buttonIndex == -1) {
            [_eidtImgViewArray removeAllObjects];
        }
    }];
    [actionSheet showOnView:photoBrowser.view];
}

- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser willDismissWithIndex:(NSInteger)index
{
    
}

- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser videoLongPress:(UILongPressGestureRecognizer *)longPress index:(NSInteger)index{
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [UIDevice deviceShake];
        [photoBrowser setImmediatelyPlayerRate:2];
    }else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed || longPress.state == UIGestureRecognizerStateRecognized){
        [photoBrowser setImmediatelyPlayerRate:1];
    }
}


- (void)photoBrowser:(KNPhotoBrowser *)photoBrowser state:(KNPhotoDownloadState)state progress:(float)progress photoItemRelative:(KNPhotoItems *)photoItemRe photoItemAbsolute:(KNPhotoItems *)photoItemAb {
    if (state == KNPhotoDownloadStateSaveSuccess) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"保存成功",nil)];
    } else if (state == KNPhotoDownloadStateSaveFailure) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"保存失败",nil)];
    }
}

@end
