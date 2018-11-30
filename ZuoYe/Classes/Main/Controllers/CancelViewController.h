//
//  CancelViewController.h
//  ZuoYe
//
//  Created by vision on 2018/8/14.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    CancelTypeHomework = 1,
    CancelTypeOrderCheck = 3,
    CancelTypeOrderCocah = 5,
} CancelType;

@interface CancelViewController : BaseViewController

@property (nonatomic, copy )NSString   *myTitle;
@property (nonatomic,strong)NSNumber   *jobid;       //作业id
@property (nonatomic,assign)CancelType  type;         //1作业辅导已接单 取消原因 3.取消作业检查订单原因 5.取消作业辅导订单原因


@end
