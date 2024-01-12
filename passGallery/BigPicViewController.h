//
//  BigPicViewController.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BigPicViewController : UIViewController
@property(strong) UIImage * image;
@property(copy) NSArray * picInfoArray;
@property(assign) NSInteger curIndex;
@end
