//
//  StructInfo.h
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-15.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
///////////////////////////////////////////////////

@interface StructInfo : NSObject

@end


@interface PicInfo : NSObject
@property(strong) NSString * picName;//图片名字
@property(strong) NSString * dirName;//相册名字
@property(strong) UIImage * img;//图片原始数据
@property(nonatomic, strong) UIImage *tmpImg;//缩略图
@property(assign) BOOL bSelected;//编辑的时候 是否选中
@property (nonatomic,assign)BOOL isVideo;
@property(nonatomic,strong)NSURL *url;
@property(nonatomic, strong)NSString *videoImagePath;
@property(nonatomic, strong)NSString *imagePath;

@end

//主页上的相册名字
@interface GalleryInfo : NSObject<NSSecureCoding>
@property(strong) NSString * name;
@property(strong) NSData * imgShut;//快照
@property(strong) NSNumber * count;//张数
@property(nonatomic ,assign) BOOL isVideo;
@end
























