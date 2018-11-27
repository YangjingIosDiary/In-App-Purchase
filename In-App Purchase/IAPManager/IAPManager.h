//
//  IAPManager.h
//  In-App Purchase
//
//  Created by YangJing on 2018/7/30.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAPManagerDelegate <NSObject>

@optional
- (void)IAPManager:(id)manager logInfo:(NSString *)logInfo;

- (void)IAPManager:(id)manager didFailedWithErrorInfo:(NSString *)errorMsg;

- (void)IAPManager:(id)manager didSuccessWithResult:(NSString *)result;

@end

@interface IAPManager : NSObject

@property (nonatomic, weak) id <IAPManagerDelegate> delegate;

+ (IAPManager *)manager;

/**
 *  检查本地是否具有未成功校验的IAP订单
 */
+ (void)checkIAPStatusAction;

/**
 *  添加IAP观察者
 */
- (void)addIAPObserver:(id <IAPManagerDelegate>)observer;

/**
 *  移除IAP观察者
 */
- (void)removeIAPObserver;

/**
 *  获取商品信息
 */
- (void)getProductInfo:(NSString *)productIndentifier;

@end
