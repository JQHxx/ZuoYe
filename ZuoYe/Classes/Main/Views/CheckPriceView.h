//
//  CheckPriceView.h
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetpriceBlock)(double aPrice);

@interface CheckPriceView : UIView

@property (nonatomic, copy )GetpriceBlock getPriceBlock;

@end
