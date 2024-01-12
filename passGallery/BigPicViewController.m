//
//  BigPicViewController.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "BigPicViewController.h"
#import "GalleryManager.h"


@interface BigPicViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;


- (IBAction)leftClicked;
- (IBAction)rightClicked;


@end

@implementation BigPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _imgView.image = _image;
    
    //CGSize imgSize = [GalleryManager fitIMGToImgView:_image withSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)leftClicked
{
    _curIndex--;
    if( _curIndex < 0 )
    {
        _curIndex = _picInfoArray.count-1;
    }
    
    _imgView.image = ((PicInfo*)[_picInfoArray objectAtIndex:_curIndex]).img;
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (IBAction)rightClicked
{
    _curIndex++;
    if( _curIndex > _picInfoArray.count-1)
    {
        _curIndex = 0;
    }
    
    _imgView.image = ((PicInfo*)[_picInfoArray objectAtIndex:_curIndex]).img;
    _imgView.contentMode = UIViewContentModeScaleAspectFit;

}
@end
