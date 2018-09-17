//
//  PaywayView.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PaywayView.h"

@interface PaywayView ()

@property (nonatomic ,strong) UIButton *selectButton;

@end


@implementation PaywayView

-(instancetype)initWithFrame:(CGRect)frame payImage:(NSString *)payImage payway:(NSString *)payway{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *payImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 12, 30, 30)];
        payImageView.image = [UIImage imageNamed:payImage];
        [self addSubview:payImageView];
        
        UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectMake(payImageView.right+13, 18, 100, 20)];
        paymentLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        paymentLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        paymentLabel.text = payway;
        [self addSubview:paymentLabel];
        
        self.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 18, 19, 19)];
        [self.selectButton setImage:[UIImage imageNamed:@"payment_method_choose_gray"] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"payment_method_choose"] forState:UIControlStateSelected];
        [self addSubview:self.selectButton];
        
        self.myButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.myButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.myButton];
    }
    return self;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.selectButton.selected = isSelected;
}


@end
