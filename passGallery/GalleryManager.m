//
//  GalleryManager.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "GalleryManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CommData.h"
#import <PHASE/PHASE.h>
#import <Photos/Photos.h>
#import <SDWebImage/SDWebImage.h>
//NSString * filePath;


@interface GalleryManager()
{
    
}
@end



@implementation GalleryManager

+(GalleryManager*)shareManager
{
    static GalleryManager * mamager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^(void){
        
        mamager = [GalleryManager new];
        
        [self getFilePath];
    });
    
    return mamager;
}

+(NSString *)getFilePath
{
    NSArray * docts = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [docts objectAtIndex:0];
}


+(NSString *)getDataFormUIImage:(PicInfo *)image
{
    NSString * str =[NSString stringWithFormat:@"%@/%@/%@",[self getFilePath],image.dirName,image.picName] ;
    return str;
}

+(void)storeOnePic:(ZYQAsset*)asset withName:(PicInfo *)info compliteBlock:(AssetsCompliteBlock)compliteBlock
{
    if (asset.mediaType == ZYQAssetMediaTypeImage) {
        NSMutableData *accumulatedData = [NSMutableData data];

        [[PHAssetResourceManager defaultManager] requestDataForAssetResource:[[PHAssetResource assetResourcesForAsset:asset.originAsset] firstObject]
                                                               options:nil
                                                         dataReceivedHandler:^(NSData * _Nonnull data) {
            
            [accumulatedData appendData:data];

        } completionHandler:^(NSError * _Nullable error) {
            if (error) {
                // Handle error
                NSLog(@"Error: %@", error.localizedDescription);
                if (compliteBlock) {
                    compliteBlock(info, @"导入失败", YES);
                }
            } else {
                NSString *file = [[self createPath:info.dirName] stringByAppendingPathComponent:info.picName]; // Assuming 'filename' is the key for the file name
                info.imagePath = file;
                [accumulatedData writeToFile:file atomically:YES];
                if (compliteBlock) {
                    compliteBlock(info, nil, NO);
                }
            }
        }];

    } else {
                
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset.originAsset options:nil resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable dic) {
                
                NSURL *url = (NSURL *)[[(AVURLAsset *)avasset URL] fileReferenceURL];
                AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetExportSession *expor = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:AVAssetExportPresetHighestQuality];
                expor.outputFileType = AVFileTypeQuickTimeMovie;
                expor.outputURL= [NSURL fileURLWithPath:[[self createPath:info.dirName] stringByAppendingPathComponent:info.picName]];
                [expor exportAsynchronouslyWithCompletionHandler:^{
                    switch (expor.status) {
                        case AVAssetExportSessionStatusCompleted:
                            
                            if (compliteBlock) {
                                compliteBlock(info, nil, NO);
                            }
                            break;
                        case AVAssetExportSessionStatusFailed:
                            if (compliteBlock) {
                                compliteBlock(info, @"导入失败", YES);
                            }
                            break;
                        default:
                            
                            break;
                    }
                }];

            
        }];
        
    }
    
}

+ (UIImage *)generateThumbnailForVideo:(NSString *)videoFilePath {
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoFilePath];
    AVAsset *asset = [AVAsset assetWithURL:videoURL];

    // 创建 AVAssetImageGenerator
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;

    // 获取视频总时长
    CMTime duration = asset.duration;

    // 设置获取缩略图的时间点（这里设置为视频中点）
    CMTime midPoint = CMTimeMultiplyByFloat64(duration, 0.5);

    NSError *error = nil;
    CMTime actualTime;
    
    // 获取缩略图
    CGImageRef thumbnailImageRef = [imageGenerator copyCGImageAtTime:midPoint
                                                         actualTime:&actualTime
                                                              error:&error];

    if (thumbnailImageRef != NULL) {
        // 转换为 UIImage
        UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];

        // 释放 CGImageRef
        CGImageRelease(thumbnailImageRef);

        return thumbnailImage;
    } else {
        // 处理错误
        NSLog(@"Error generating thumbnail: %@", error.localizedDescription);
        return nil;
    }
}

+(UIImage*)getImageFileWithDir:(NSString*)dir withName:(NSString*)name
{
    NSString * strFile = [NSString stringWithFormat:@"%@/%@/%@",[self getFilePath],dir,name];
    UIImage * img = [UIImage imageWithContentsOfFile:strFile];
    
    return img;
}

+(UIImage*)getThumbnailImageFileWithDir:(NSString*)dir withName:(NSString*)name
{
    
    NSString *strFile = [NSString stringWithFormat:@"%@/%@/%@", [self getFilePath], dir, name];
    
    // 加载图片
    UIImage *originalImage = [UIImage imageWithContentsOfFile:strFile];
    
    // 获取缩略图大小
    CGSize thumbnailSize = CGSizeMake(300, 300);
    
    // 开始绘制缩略图
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0);
    [originalImage drawInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 在这里使用 thumbnailImage，它就是缩略图
    return thumbnailImage;
}

+(void)deleteOnePic:(PicInfo*)info
{
    NSFileManager * fileM = [NSFileManager defaultManager];
    NSString * strFile = [NSString stringWithFormat:@"%@/%@/%@",[self getFilePath],info.dirName,info.picName];
    
    [fileM removeItemAtPath:strFile error:nil];
}

+(NSArray*)getAllFileNames:(NSString*)dirName
{
    [self shareManager];
    //
    NSFileManager * fileM = [NSFileManager defaultManager];
    NSError * error = nil;
    
    NSString *strPath = [NSString stringWithFormat:@"%@/%@/",[self getFilePath],dirName];
    NSArray * fileArray = [fileM contentsOfDirectoryAtPath:strPath error:&error];
    
    return fileArray;
}

+(NSString *)createPath:(NSString*)dirName
{
    NSString* strPath= [NSString stringWithFormat:@"%@",[self getFilePath]];
    strPath =[strPath stringByAppendingPathComponent:dirName];

    if ([[NSFileManager defaultManager]fileExistsAtPath:strPath ]) {
        
    }else
    [[NSFileManager defaultManager] createDirectoryAtPath:strPath withIntermediateDirectories:YES attributes:nil error:nil];
    return strPath;
}

+(CGSize)fitIMGToImgView:(UIImage*)sourceImg withSize:(CGSize)targeSize
{
    CGSize imgSize = sourceImg.size;
    CGFloat scaleX = imgSize.width/targeSize.width;
    CGFloat scaleY = imgSize.height/targeSize.height;
    
    if( scaleX >= scaleY )
    {
        return CGSizeMake(targeSize.width, imgSize.height*targeSize.width/imgSize.width);
    }
    else
    {
        return CGSizeMake(imgSize.width*targeSize.height/imgSize.height, targeSize.height);
    }
    
    return CGSizeZero;
}

+(void)removeDir:(NSString*)dirName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* strPath= [NSString stringWithFormat:@"%@/%@",[self getFilePath],dirName];
    [fileManager removeItemAtPath:strPath error:nil];
}

//// 获取顶部安全区高度
//- (CGFloat)getSafeAreaTop {
//    if (@available(iOS 11.0, *)) {
//        return self.view.safeAreaInsets.top;//44
//    } else {
//        return 0.0;
//    }
//}
//
//// 获取底部安全区高度
//- (CGFloat)getSafeAreaBottom {
//    if (@available(iOS 11.0, *)) {
//        return self.view.safeAreaInsets.bottom;//34
//    } else {
//        return 0.0;
//    }
//}

// 获取window顶部安全区高度
- (CGFloat)getWindowSafeAreaTop {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top;//44
    }
    return 0.0;
}

// 获取window底部安全区高度
- (CGFloat)getWindowSafeAreaBottom {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;//34
    }
    return 0.0;
}
@end




































