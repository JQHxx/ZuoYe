//
//  TeacherCollectionViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherCollectionViewCell.h"

@implementation TeacherCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.doubleSided = NO;
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0,64, 64)];
        [self.contentView addSubview:self.headImageView];
        
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.headImageView.bottom+7.0,80, 17)];
        self.levelLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        self.levelLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        self.levelLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.levelLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.levelLabel.bottom+2, 80, 24)];
        self.priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        self.priceLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        self.priceLabel.layer.cornerRadius = 12;
        self.priceLabel.layer.borderColor = [UIColor colorWithHexString:@"#808080"].CGColor;
        self.priceLabel.layer.borderWidth = 1.0;
        [self.contentView addSubview:self.priceLabel];
    }
    return self;
}

- (void)initialize {
    
    
}


@end
