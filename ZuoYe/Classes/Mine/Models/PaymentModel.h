//
//  PaymentModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentModel : NSObject

@property (nonatomic , copy ) NSString  *imageName;
@property (nonatomic ,assign) NSInteger  payment;    //0、余额 1、微信支付 2、支付宝支付
@property (nonatomic, assign) double     balance;
@property (nonatomic, assign) BOOL       isSelected;

@end
