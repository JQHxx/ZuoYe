//
//  SetPriceTool.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "SetPriceTool.h"

@interface SetPriceTool (){
    UIButton  *subtractBtn;
    UILabel   *quantityLab;
    UIButton  *addBtn;
}
@end

@implementation SetPriceTool

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat labWidth=frame.size.width/3.0;
        CGFloat labHeight=frame.size.height;
        //减
        subtractBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, labWidth, labHeight)];
        [subtractBtn setImage:[UIImage imageNamed:@"pd_ic_num_minus"] forState:UIControlStateNormal];
        [subtractBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        subtractBtn.tag=100;
        [self addSubview:subtractBtn];
        
        quantityLab = [[UILabel alloc] initWithFrame:CGRectMake(subtractBtn.right - 1, 0, labWidth,labHeight)];
        quantityLab.textAlignment = NSTextAlignmentCenter;
        quantityLab.text=@"1";
        quantityLab.userInteractionEnabled=YES;
        quantityLab.font=[UIFont systemFontOfSize:14];
        [self addSubview:quantityLab];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quantityTapAction)];
        [self addGestureRecognizer:tapGesture];
        
        //加
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(quantityLab.right, 0, labWidth, labHeight)];
        [addBtn setImage:[UIImage imageNamed:@"pd_ic_num_add"] forState:UIControlStateNormal];
        [addBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        addBtn.tag=101;
        [self addSubview:addBtn];
        
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 数量加减
-(void)handleQuantityAction:(UIButton *)sender{
    if (sender.tag==100) {
        self.price-=0.1;
        if (self.price<0.1) {
            self.price=1;
        }
        addBtn.enabled=YES;
    }else{
        addBtn.enabled=YES;
        self.price+=0.1;
    }
    subtractBtn.enabled=self.price>0.1;
    
    if (addBtn.enabled) {
        if ([self.delegate respondsToSelector:@selector(setPriceToolDidSetPrice:)]) {
            [self.delegate setPriceToolDidSetPrice:self.price];
        }
    }
    quantityLab.text=[NSString stringWithFormat:@"%.1f",self.price];
    
}

#pragma mark 点击数量
-(void)quantityTapAction{
    if ([self.delegate respondsToSelector:@selector(setPriceToolTextInPrice)]) {
        [self.delegate setPriceToolTextInPrice];
    }
}


#pragma mark -- Setters
-(void)setPrice:(double)price{
    _price=price;
    subtractBtn.enabled=price>0.1;
    quantityLab.text=[NSString stringWithFormat:@"%.1f",price];
}

@end
