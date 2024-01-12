//
//  PicListViewController.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicListViewController : UIViewController

@property(strong) NSString * dirName;
@property(assign) BOOL isvideo;
@property(nonatomic ,strong)NSMutableArray *galleryArray;
//
@property(assign) BOOL bEdit;//编辑模式
@property(nonatomic,strong)NSMutableDictionary *selectedIdx;
@end
