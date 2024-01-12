//
//  PayMent.m
//  alarm
//
//  Created by zhuang chaoxiao on 15-6-20.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "PayMent.h"
static BOOL ishas = NO;
@implementation PayMent

-(void)startBuy
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"正在请求,请稍候",nil)];
    
    NSString * strPId = [_PayDelegate getProdId];
    
    [self requestProductData:strPId];
}

-(void)restoreBuy
{
    [self initialStore];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

/////////////////////////////////////////////////

-(id)init
{
    self = [super init];
    
    if( self )
    {
        [self initialStore];
    }
    
    return  self;
}

-(void)initialStore
{
    if (ishas) {
        return;
        
    }
    ishas = YES;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

-(void)releaseStore
{
    NSLog(@"-releaseStore-");
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


-(BOOL)CanMakePay
{
    return [SKPaymentQueue canMakePayments];
}


-(void)requestProductData:(NSString*)prdTag
{
    NSLog(@"-requestProductData-");
    
    NSArray * product = [[NSArray alloc] initWithObjects:prdTag, nil];
    NSSet * nsset = [NSSet setWithArray:product];
    SKProductsRequest * req = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    req.delegate = self;
    
    [req start];
}


-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray * myprd = response.products;
    
    if (myprd.count ==0) {
        [SVProgressHUD showErrorWithStatus:@"获取shangp信息失败，请重试"];
        [_PayDelegate buyFailed];
        return;
    };
    NSLog(@"prod count:%d",[myprd count]);
    //
    
    for( SKProduct * product in myprd )
    {
        NSLog(@"SK desc:%@",[product description]);
        NSLog(@"title:%@",[product localizedTitle]);
        NSLog(@"desc :%@",[product localizedDescription]);
        NSLog(@"price:%@",[product price]);
        NSLog(@"id:%@",[product productIdentifier]);
    }
    
    SKPayment * payment = nil;
    payment = [SKPayment paymentWithProduct:[response.products objectAtIndex:0]];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


-(void)requestProUpgradeProductData:(NSString*)idTag
{
    NSLog(@"----requestProUpgradeProductData----");
    
    NSSet * prodId = [NSSet setWithObject:idTag];
    SKProductsRequest * prodReq = [[SKProductsRequest alloc] initWithProductIdentifiers:prodId];
    prodReq.delegate = self;
    
    [prodReq start];
}


-(void)purchasedTransaction:(SKPaymentTransaction*)tran
{
    NSLog(@"----purchasedTransaction----");
    
    NSArray * trans = [[NSArray alloc]initWithObjects:tran, nil];
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:trans];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    [SVProgressHUD dismiss];
    for( SKPaymentTransaction * tran in transactions )
    {
        switch (tran.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [self completeTransaction:tran];
                
                [self storeBuyFlag:YES];
                
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"付款成功,将在下次启动APP的时候生效!",nil)];
            }
                break;
                
            case SKPaymentTransactionStateFailed:
            {
                [self completeTransaction:tran];
                [self storeBuyFlag:NO];
                UIAlertView * alterView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"支付失败",nil) message:NSLocalizedString(@"支付失败",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定",nil) otherButtonTitles:nil, nil];
                
                [alterView show];
            }
                break;
                
                
            case SKPaymentTransactionStateRestored:
            {
                NSLog(@"SKPaymentTransactionStateRestored");
                
                [self storeBuyFlag:YES];
                
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"恢复购买成功,将在下次启动APP的时候生效!",nil)];
                
            }
                break;
                
            case SKPaymentTransactionStatePurchasing:
            {
                [self storeBuyFlag:NO];
                NSLog(@"SKPaymentTransactionStatePurchasing");
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)completeTransaction:(SKPaymentTransaction*)tran
{
    NSLog(@"completeTransaction");
    
    NSString * prod = tran.payment.productIdentifier;
    
    if( [prod length] > 0 )
    {
        NSArray * tt = [prod componentsSeparatedByString:@"."];
        
        NSString * bookId = [tt lastObject];
        
        NSLog(@"bookId:%@",bookId);
        
        if( [bookId length] > 0 )
        {
            [self recordTransaction:bookId];
            [self provideContent:bookId];
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:tran];
}

-(void)recordTransaction:(NSString *)product
{
    NSLog(@"-----Record transcation--------\n");
}

-(void)provideContent:(NSString *)product
{
    NSLog(@"-----Download product content--------\n");
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Failed\n");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) paymentQueueRestoreCompletedTransactionsFinished: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----paymentQueueRestoreCompletedTransactionsFinished-------\n");
    
    
    [SVProgressHUD showSuccessWithStatus:@"恢复购买成功"];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"-----Restore transaction--------\n");
}

-(void) paymentQueue:(SKPaymentQueue *) paymentQueue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"-------Payment Queue----\n");
}

////////////////////////////////////////////////////////////////////////////////////

-(void)dealloc
{
    [SVProgressHUD dismiss];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void)storeBuyFlag:(BOOL)flag
{
    if( [_PayDelegate respondsToSelector:@selector(buySuccess:)] )
    {
        if (flag) {
            [_PayDelegate buySuccess:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*365)]];

        }else
            [_PayDelegate buyFailed];
        
    }
}





@end
