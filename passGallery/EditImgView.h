//
//  EditImgView.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/7.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditImgViewDelegate <NSObject>

-(void)imageClicked:(NSInteger)tag selected:(BOOL)selected;

@end

///
@interface EditImgView : UIView
{
    
}
@property(weak) id<EditImgViewDelegate> imgViewDelegate;
@property(nonatomic, assign) BOOL editEd;
@property(nonatomic,assign) BOOL selected;


-(id)initWithFrame:(CGRect)frame withImage:(UIImage*)image;


@end
