//
//  BillModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillModel : NSObject

@property (nonatomic ,strong )  NSNumber   *pay_cate;     //1支付宝支付 2微信支付 3余额支付
@property (nonatomic ,strong )  NSNumber   *label;        // 1、作业检查 2、作业辅导 3、充值
@property (nonatomic ,strong )  NSNumber   *pay_time;     //支付时间
@property (nonatomic , copy )   NSString   *pay_money;   //金额
@property (nonatomic , copy )   NSString   *pay_no;      //交易单号
@property (nonatomic ,strong)   NSNumber   *pay_status;   //当前状态  1支付失败 2支付成功

@end
