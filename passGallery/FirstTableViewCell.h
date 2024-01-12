//
//  FirstTableViewCell.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StructInfo.h"
#import "CommData.h"

@interface FirstTableViewCell : UITableViewCell

-(void)refreshCell:(GalleryInfo*)info;

@end
