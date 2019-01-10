//
//  RechargeAlertViewController.h
//  ZuoYe
//
//  Created by vision on 2018/12/6.
//  Copyright © 2018 vision. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RechargeAlertViewController : BaseViewController

@property (nonatomic,assign) NSInteger type; //0、作业检查 1、作业辅导
@property (nonatomic,assign) double    checkPrice;


@end

NS_ASSUME_NONNULL_END
