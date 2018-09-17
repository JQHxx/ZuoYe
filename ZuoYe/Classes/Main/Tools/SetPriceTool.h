//
//  SetPriceTool.h
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetPriceToolDelegate <NSObject>
//设置数量（填写）
-(void)setPriceToolDidSetPrice:(NSInteger)price;

//设置数量（输入）
@optional
-(void)setPriceToolTextInPrice;

@end

@interface SetPriceTool : UIView

@property (nonatomic,weak)id<SetPriceToolDelegate>delegate;

@property (nonatomic,assign)NSInteger price;  //价格

@end
