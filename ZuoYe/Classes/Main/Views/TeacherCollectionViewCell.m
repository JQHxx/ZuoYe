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
        
        self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 30)];
        self.levelLabel.textColor = [UIColor blackColor];
        self.levelLabel.font = kFontWithSize(16);
        self.levelLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.levelLabel];
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width -60)/2.0, self.levelLabel.bottom,60, 60)];
        self.headImageView.backgroundColor = [UIColor clearColor];
        self.headImageView.contentMode = UIViewContentModeCenter;
        self.headImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.headImageView];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.headImageView.bottom, frame.size.width, 30)];
        self.priceLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14];
        self.priceLabel.textColor = [UIColor redColor];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.priceLabel];
    }
    return self;
}

- (void)initialize {
    
    
}


@end
