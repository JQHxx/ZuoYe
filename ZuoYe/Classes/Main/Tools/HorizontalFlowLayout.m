//
//  HorizontalFlowLayout.m
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HorizontalFlowLayout.h"


@implementation HorizontalFlowLayout

-(instancetype)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
