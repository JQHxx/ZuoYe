//
//  SetPriceTool.h
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetPriceToolDelegate <NSObject>
//设置数量
-(void)setPriceToolDidSetPrice:(double)price;

@end

@interface SetPriceTool : UIView

@property (nonatomic,weak)id<SetPriceToolDelegate>delegate;


@end
