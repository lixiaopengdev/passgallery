//
//  GalleryManager.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "StructInfo.h"
#import <Photos/Photos.h>
#import <ZYQAssetPickerController/ZYQAssetPickerController.h>

typedef void (^AssetsCompliteBlock)(PicInfo *obj, NSString* errorMsg, BOOL isError);

@interface GalleryManager : NSObject
+(GalleryManager*)shareManager;

+(NSString *)getFilePath;
+(void)deleteOnePic:(PicInfo*)info;
+(UIImage*)getImageFileWithDir:(NSString*)dir withName:(NSString*)name;
+(UIImage*)getThumbnailImageFileWithDir:(NSString*)dir withName:(NSString*)name;
+(void)storeOnePic:(ZYQAsset*)asset withName:(PicInfo *)info compliteBlock:(AssetsCompliteBlock)compliteBlock;
+(NSArray*)getAllFileNames:(NSString*)dirName;
+(NSString *)getDataFormUIImage:(PicInfo*)image;
+(CGSize)fitIMGToImgView:(UIImage*)sourceImg withSize:(CGSize)targeSize;
+(void)removeDir:(NSString*)dirName;
+(NSString *)createPath:(NSString*)dirName;
+ (UIImage *)generateThumbnailForVideo:(NSString *)videoFilePath;
@end
