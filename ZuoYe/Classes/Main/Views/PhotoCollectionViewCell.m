//
//  PhotoCollectionViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.doubleSided = NO;
        
        self.coverImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 227, 340)];
        [self.contentView addSubview:self.coverImgView];

    }
    return self;
}

@end
