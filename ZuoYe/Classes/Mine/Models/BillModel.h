//
//  BillModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillModel : NSObject

@property (nonatomic ,assign )  NSInteger  bill_type;      //0、充值 1、作业检查 2、作业辅导
@property (nonatomic ,assign )  NSInteger  pay_type;       //0、余额支付 1、微信支付 2、支付宝支付
@property (nonatomic , copy )   NSString   *create_time;   //支付时间
@property (nonatomic ,assign )  double     amount;         //金额
@property (nonatomic , copy )   NSString   *order_sn;      //交易单号
@property (nonatomic , copy )   NSString   *state;         //当前状态

@end
