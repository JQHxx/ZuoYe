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
        
        _imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height-3.0)];
        [self addSubview:_imgBtn];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.width - 23, 5, 18, 18);
        [_deleteBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self addSubview:_deleteBtn];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imgBtn.frame = CGRectMake(0, 0, self.width, self.height-3);
    _deleteBtn.frame = CGRectMake(self.width - 23, 5, 18, 18);
}


-(void)setRow:(NSInteger)row{
    _row = row;
    _deleteBtn.tag = row;
}


@end
