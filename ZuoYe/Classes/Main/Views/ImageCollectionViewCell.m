//
//  ImageCollectionViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-10)];
        [self addSubview:_imgView];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.width - 16, 0, 16, 16);
        [_deleteBtn setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self addSubview:_deleteBtn];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imgView.frame = CGRectMake(0, 0, self.width, self.height-10);
    _deleteBtn.frame = CGRectMake(self.width - 16, 0, 16, 16);
}


-(void)setRow:(NSInteger)row{
    _row = row;
    _deleteBtn.tag = row;
}


@end
