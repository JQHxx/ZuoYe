//
//  PaywayView.h
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaywayView : UIView

-(instancetype)initWithFrame:(CGRect)frame payImage:(NSString *)payImage payway:(NSString *)payway;

@property (nonatomic, strong) UIButton *myButton;
@property (nonatomic, assign) BOOL     isSelected;

@end
