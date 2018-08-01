//
//  IAPManager.m
//  In-App Purchase
//
//  Created by YangJing on 2018/7/30.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import "IAPManager.h"
#import <StoreKit/StoreKit.h>
#define sandBox 1

@interface IAPManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPManager

+ (IAPManager *)manager {
    static IAPManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IAPManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

+ (void)checkIAPStatusAction {
    
}

- (void)addIAPObserver {
    
}

- (void)removeIAPObserver {
    
}

- (void)getProductInfo:(NSString *)productIndentifier {
    if (![SKPaymentQueue canMakePayments]) {
        [self log:@"不允许使用In-App Purchase"];

        if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:didFailedWithErrorInfo:)]) {
            [self.delegate IAPManager:self didFailedWithErrorInfo:@"不允许使用In-App Purchase"];
        }
        return;
    }

    if (productIndentifier && productIndentifier.length > 0) {
        [self log:@"根据商品id获取商品信息"];

        NSSet *set = [NSSet setWithArray:@[productIndentifier]];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        
    } else {
        [self log:@"商品id为空"];

        if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:didFailedWithErrorInfo:)]) {
            [self.delegate IAPManager:self didFailedWithErrorInfo:@"productIndentifier is nill"];
        }
    }
}

//MARK: - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    if (!products || products.count <= 0) {
        [self log:@"无法获取商品信息"];

        if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:didFailedWithErrorInfo:)]) {
            [self.delegate IAPManager:self didFailedWithErrorInfo:@"无法获取商品信息"];
        }
        return;
    }
    
    [self log:@"获取商品信息成功，发起交易"];
    
    SKPayment *payment = [SKPayment paymentWithProduct:products[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self log:@"获取商品信息失败"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:didFailedWithErrorInfo:)]) {
        [self.delegate IAPManager:self didFailedWithErrorInfo:@"购买失败"];
    }
}

- (void)requestDidFinish:(SKRequest *)request {
    [self log:@"获取商品信息完成"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:didSuccessWithResult:)]) {
        [self.delegate IAPManager:self didSuccessWithResult:@"购买完成"];
    }
}

//MARK: - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                //商品添加进列表
            case SKPaymentTransactionStatePurchasing:{
                NSLog(@"yangjing_%@: 商品添加进列表", NSStringFromClass([self class]));
                [self log:@"商品添加进列表"];
            }
                break;
                //交易完成
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"yangjing_%@: 交易完成", NSStringFromClass([self class]));
                [self log:@"交易完成"];

                [self completeTransaction:transaction];
            }
                break;
                //交易失败
            case SKPaymentTransactionStateFailed: {
                NSLog(@"yangjing_%@: 交易失败", NSStringFromClass([self class]));
                [self log:@"交易失败"];

                [self failedTransaction:transaction];
            }
                break;
                //已经购买过该商品
            case SKPaymentTransactionStateRestored:{
                NSLog(@"yangjing_%@: 已经购买过该商品", NSStringFromClass([self class]));
                [self log:@"已经购买过该商品"];
            }
                break;
                //交易等待中
            case SKPaymentTransactionStateDeferred:{
                NSLog(@"yangjing_%@: 交易等待中", NSStringFromClass([self class]));
                [self log:@"交易等待中"];
            }
                break;
                
            default:
                break;
        }
    }
}

//交易成功，与服务器比对传输货单号
- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    //目前苹果公司提倡的获取购买凭证的方法
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    //base64位的产品验证码单，base64是服务端和苹果进行校验所必须的，苹果的文档要求凭证经过Base64加密
    NSString * transactionReceiptString = [receiptData base64EncodedStringWithOptions:0];
    
    NSLog(@"yangjing_%@: receiptUrl=%@", NSStringFromClass([self class]), receiptUrl);
    [self log:[NSString stringWithFormat:@"交易凭证：%@", receiptUrl]];
    
    // 向自己的服务器验证购买凭证（此处应该考虑将凭证本地保存,对服务器有失败重发机制）
    /**
     服务器要做的事情:
     接收ios端发过来的购买凭证。
     判断凭证是否已经存在或验证过，然后存储该凭证。
     将该凭证发送到苹果的服务器验证，并将验证结果返回给客户端。
     如果需要，修改用户相应的会员权限
     */
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data":transactionReceiptString};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    NSString *serverString = @"https://buy.itunes.apple.com/verifyReceipt";
    if (sandBox) {
        serverString = @"https://sandbox.itunes.apple.com/verifyReceipt";
    }
    
    NSURL *storeURL = [NSURL URLWithString:serverString];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   // 无法连接服务器,购买校验失败
                                   [self log:@"无法连接服务器,购买校验失败"];
                                   
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   if (!jsonResponse) {
                                       // 苹果服务器校验数据返回为空校验失败
                                       [self log:@"苹果服务器校验数据返回为空校验失败"];

                                   } else {
                                       // 苹果服务器校验数据
                                       [self log:[NSString stringWithFormat:@"苹果服务器校验数据: %@", jsonResponse]];
                                   }
                               }
                           }];
    
    //完整结束此次在App Store的交易，没有这句代码的调用，下次购买会提示已经购买该商品
    [self log:@"结束交易"];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    if (transaction.error.code != SKErrorPaymentCancelled) {
    }
    
    [self log:@"结束交易"];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

- (void)log:(NSString *)logInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(IAPManager:logInfo:)]) {
        [self.delegate IAPManager:self logInfo:[NSString stringWithFormat:@"%@: %@", [NSDate date], logInfo]];
    }
}

@end