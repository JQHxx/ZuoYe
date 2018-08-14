//
//  OrderTimePickerView.h
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseView.h"

typedef void(^OrderTimeResultBlock)(NSString *dayStr,NSString *hourStr,NSString *minuteStr);

@interface OrderTimePickerView : BaseView

+(void)showOrderTimePickerWithTitle:(NSString *)title defaultTime:(NSDictionary *)defaultTimeDic resultBlock:(OrderTimeResultBlock)resultBlock;


@end
