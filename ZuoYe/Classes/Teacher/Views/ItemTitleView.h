//
//  ItemTitleView.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemTitleViewDelegate <NSObject>

-(void)itemTitleViewDidClickWithIndex:(NSInteger)index;

@end

@interface ItemTitleView : UIView

@property (nonatomic ,weak )id<ItemTitleViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles;

@end
