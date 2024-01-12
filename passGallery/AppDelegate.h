//
//  AppDelegate.h
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign) BOOL bPretendLogo;//是否伪密码登录

-(void)changeRootVC;
-(BOOL)showAdv;

@end

