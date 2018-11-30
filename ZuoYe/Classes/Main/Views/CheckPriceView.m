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
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 11, 20, 20)];
        imgView.image = [UIImage imageNamed:@"release_price"];
        [self addSubview:imgView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(imgView.right+17.0, 11, 90, 22)];
        titleLab.text = @"检查价格";
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        titleLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [self addSubview:titleLab];
        
        SetPriceTool *priceTool = [[SetPriceTool alloc] initWithFrame:CGRectMake(frame.size.width-155, 7.0, 130.0,32.0)];
        priceTool.delegate = self;
        [self addSubview:priceTool];
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(10, titleLab.bottom+32.0, kScreenWidth-20, 16.0)];
        tipsLab.text = @"请根据您的作业的题数及难易程度，设置一个合理的价格。";
        tipsLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.textColor = [UIColor colorWithHexString:@"#808080"];
        [self addSubview:tipsLab];
    }
    return self;
}

#pragma mark 加减获得价格
-(void)setPriceToolDidSetPrice:(double)price{
    self.getPriceBlock(price);
}

@end
