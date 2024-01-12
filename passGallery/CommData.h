//
//  CommData.h
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-15.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#ifndef alarm_CommData_h
#define alarm_CommData_h

#import "SVProgressHUD.h"

#define COLORHEX(hexValue) ([UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1])

#define RGB(r,g,b) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])

#define navColor RGB(52, 51, 57)


//#define UM_SHARE_KEY  @"55b06037e0f55a4422004da7"



#define ADV_BUYED @"buyed_adv"//是否购买

#define STORE_TRUE_GALLERY    @"STORE_TRUE_GALLERY"   //真实相册信息
#define STORE_PRETEND_GALLERY    @"STORE_PRETEND_GALLERY"   //假相册信息

#define STORE_TURE_PASSWORD  @"STORE_TURE_PASSWORD"//真是密码
#define STORE_PRETEND_PASSWORD @"STORE_PRETEND_PASSWORD"//伪装密码


#define NOTF_HIED_TABVIEW   @"NOTF_HIED_TABVIEW"
#define NOTF_REFRESH_PIC_LIST  @"NOTF_REFRESH_PIC_LIST"
#define NOTF_IMPORT_SUCC  @"NOTF_IMPORT_SUCC"  //照片移动完成

#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SAFE_BOTTOM [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom
#define SAFE_TOP [UIApplication sharedApplication].delegate.window.safeAreaInsets.top
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define TAB_WIDTH   SCREEN_WIDTH
#define TAB_HEIGHT  50
#define TAB_NUM   3

#define TAB_ICON_W 45
#define TAB_ICON_H 45

#endif
