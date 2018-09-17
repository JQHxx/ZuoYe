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
        CGFloat labHeight=frame.size.height;
        
        self.layer.borderColor = [UIColor colorWithHexString:@"#FF6363"].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 4.0;
        
        //减
        subtractBtn = [[UIButton alloc] initWithFrame:CGRectMake(9.0, 0, 14.0, labHeight)];
        [subtractBtn setTitle:@"-" forState:UIControlStateNormal];
        [subtractBtn setTitleColor:[UIColor colorWithHexString:@"#FF6363"] forState:UIControlStateNormal];
        subtractBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:22];
        [subtractBtn addTarget:self action:@selector(handleQuantityAction:) forControlEvents:UIControlEventTouchUpInside];
        subtractBtn.tag=100;
        [self addSubview:subtractBtn];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(subtractBtn.right+9.0, 0, 1.0, labHeight)];
        line1.backgroundColor = [UIColor colorWithHexString:@"#FF6363"];
        [self addSubview:line1];
        
        quantityLab = [[UILabel alloc] initWithFrame:CGRectMake(subtractBtn.right+21.0,2.0, 39.0,25.0)];
        quantityLab.textAlignment = NSTextAlignmentCenter;
        quantityLab.text=@"10";
        quantityLab.userInteractionEnabled=YES;
        quantityLab.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        [self addSubview:quantityLab];
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quantityTapAction)];
        [self addGestureRecognizer:tapGesture];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(quantityLab.right+9.0, 0, 1.0, labHeight)];
        line2.backgroundColor = [UIColor colorWithHexString:@"#FF6363"];
        [self addSubview:line2];
        
        //加
        addBtn = [[UIButton alloc] initWithFrame:CGRectMake(quantityLab.right+21.0, 0, 14.0, labHeight)];
        [addBtn setTitle:@"+" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor colorWithHexString:@"#FF6363"] forState:UIControlStateNormal];
        addBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:22];
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
        self.price-=1;
        if (self.price<1) {
            self.price=1;
        }
    }else{
        self.price+=1;
    }
    subtractBtn.enabled=self.price>1;
    quantityLab.text=[NSString stringWithFormat:@"%ld",self.price];
    if ([self.delegate respondsToSelector:@selector(setPriceToolDidSetPrice:)]) {
        [self.delegate setPriceToolDidSetPrice:self.price];
    }
}

#pragma mark 点击数量
-(void)quantityTapAction{
    if ([self.delegate respondsToSelector:@selector(setPriceToolTextInPrice)]) {
        [self.delegate setPriceToolTextInPrice];
    }
}


#pragma mark -- Setters
-(void)setPrice:(NSInteger)price{
    _price=price;
    subtractBtn.enabled=price>1;
    quantityLab.text=[NSString stringWithFormat:@"%ld",price];
}

@end
