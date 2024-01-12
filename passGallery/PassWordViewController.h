//
//  PassWordViewController.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PASSWORD_INIT_TUREPASS,//初始化真密码
    PASSWORD_INIT_PRETENDPASS,//初始化假密码
    PASSWORD_CHECK,//登录   登录的时候 通过密码来判断是真的还是假的
    PASSWORD_ANY_VIEW_CHECK,//后台再回来的时候的登录
    PASSOWRD_MODIFY_TRUEPASS,//修改真密码
    PASSOWRD_MODIFY_PRETENDPASS,//修改假密码
    
    PASSWORD_MAX
    
    
} PASSWORD_TYPE;


@interface PassWordViewController : UIViewController

@property(assign) PASSWORD_TYPE passType;//

@end
