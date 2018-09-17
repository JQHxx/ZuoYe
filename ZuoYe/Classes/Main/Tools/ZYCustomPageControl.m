//
//  ZYCustomPageControl.m
//  ZuoYe
//
//  Created by vision on 2018/9/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ZYCustomPageControl.h"

#define dotW 12 // 圆点宽
#define dotH 7  // 圆点高
#define magrin 8    // 圆点间距

@implementation ZYCustomPageControl

-(instancetype)init{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}


-(void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        size.height = dotH;
        if (subviewIndex==currentPage) {
            size.width = dotW;
        }else{
            size.width = dotH;
        }
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width,size.height)];
    }
}

@end
