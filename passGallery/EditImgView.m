//
//  EditImgView.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "EditImgView.h"
#import "GalleryManager.h"


#define SELECT_IMG_W   30

@interface EditImgView()
{
    UIImageView * selImgView;
    UIImageView * shutImgView;
}

@end

@implementation EditImgView


-(void)setEditEd:(BOOL)editEd
{
    _editEd = editEd;
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if( _selected )
    {
        selImgView.image =[UIImage imageNamed:@"selected"];
    }
    else
    {
        selImgView.image =nil;
    }
}


-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)image
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        self.userInteractionEnabled = YES;
        
        NSLog(@"image:%@",image);
        
        //
        UITapGestureRecognizer * g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgClicked)];
        [self addGestureRecognizer:g];
        
        CGSize imgSize = [GalleryManager fitIMGToImgView:image withSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
        
        NSLog(@"size:%f %f",imgSize.width,imgSize.height);
        
        shutImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgSize.width, imgSize.height)];
        shutImgView.image = image;
        shutImgView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:shutImgView];
        //
        selImgView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width-SELECT_IMG_W, frame.size.height-SELECT_IMG_W, SELECT_IMG_W, SELECT_IMG_W)];
        
        [self addSubview:selImgView];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
    }
    
    return self;
}


-(void)imgClicked
{
    if( _editEd )
    {
        _selected = !_selected;
    }
    
    
    if( _selected )
    {
        selImgView.image =[UIImage imageNamed:@"selected"];
    }
    else
    {
        selImgView.image =nil;
    }
    
    if( [_imgViewDelegate respondsToSelector:@selector(imageClicked:selected:)])
    {
        [_imgViewDelegate imageClicked:self.tag selected:_selected];
    }
}

@end
