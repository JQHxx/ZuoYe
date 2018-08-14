//
//  CheckPriceView.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CheckPriceView.h"
#import "SetPriceTool.h"

@interface CheckPriceView ()<SetPriceToolDelegate>

@end

@implementation CheckPriceView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 90, 30)];
        titleLab.text = @"检查价格";
        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.textColor = [UIColor blackColor];
        [self addSubview:titleLab];
        
        SetPriceTool *priceTool = [[SetPriceTool alloc] initWithFrame:CGRectMake(frame.size.width-150, 10, 120,30)];
        priceTool.delegate = self;
        [self addSubview:priceTool];
        
        UILabel *unitLab = [[UILabel alloc] initWithFrame:CGRectMake(priceTool.right,10, 30, 30)];
        unitLab.textColor = [UIColor darkGrayColor];
        unitLab.text = @"元";
        unitLab.font = kFontWithSize(14);
        [self addSubview:unitLab];
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLab.bottom+10, kScreenWidth-20, 20)];
        tipsLab.text = @"请根据您的作业的题数及难易程度，设置一个合理的价格。";
        tipsLab.font = kFontWithSize(12);
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.textColor = [UIColor lightGrayColor];
        [self addSubview:tipsLab];
    }
    return self;
}

#pragma mark 输入价格
-(void)setPriceToolTextInPrice{
    
}

#pragma mark 加减获得价格
-(void)setPriceToolDidSetPrice:(double)price{
    self.getPriceBlock(price);
}

@end
