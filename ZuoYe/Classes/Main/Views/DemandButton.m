//
//  DemandButton.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "DemandButton.h"

@implementation DemandButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:kRGBColor(54, 54, 54) forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        self.titleLabel.textAlignment=NSTextAlignmentLeft;
    }
    return self;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(10,5, 20, 20);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(40,0, self.width -40, 30);
}

@end
