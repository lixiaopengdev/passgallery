//
//  PayMent.h
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-20.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "SVProgressHUD.h"


@protocol PayMentDelegate <NSObject>

@required
-(NSString*)getProdId;

@optional
-(void)buySuccess:(NSDate*)date;
-(void)buyFailed;

@end

@interface PayMent : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property(weak) id<PayMentDelegate> PayDelegate;
-(BOOL)CanMakePay;
-(void)startBuy;
-(void)restoreBuy;
@end
