//
//  AmountView.h
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmountView : UIView

@property (nonatomic, strong) NSMutableArray *labelsArray;

@property (nonatomic, strong) void (^viewHeightRecalc) (CGFloat height);
@property (nonatomic, strong) void (^didClickItem) (NSInteger itemIndex);

-(void)cancelClickItemAction;

@end
