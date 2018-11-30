//
//  TeacherCollectionViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherCollectionViewCell.h"

@interface TeacherCollectionViewCell ()

@property (nonatomic, strong) UIImageView  *bgHeadImageView;    //背景头像
@property (nonatomic, strong) UIImageView  *headImageView;    //头像
@property (nonatomic, strong) UIImageView  *arrowImageView;    //选择
@property (nonatomic, strong) UILabel      *levelLabel;       //等级
@property (nonatomic, strong) UILabel      *priceLabel;       //价格

@end

@implementation TeacherCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.doubleSided = NO;
        
        self.bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 0,66, 66)];
        self.bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FF7568"];
        self.bgHeadImageView.boderRadius = 33;
        [self.contentView addSubview:self.bgHeadImageView];
        self.bgHeadImageView.hidden = YES;
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 1,64, 64)];
        self.headImageView.boderRadius = 32;
        [self.contentView addSubview:self.headImageView];
        
        self.arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55, 47,18, 18)];
        self.arrowImageView.image = [UIImage imageNamed:@"teacher_grade_choose"];
        [self.contentView addSubview:self.arrowImageView];
        self.arrowImageView.hidden = YES;
        
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

-(void)updateCellWithLevel:(LevelModel *)model{
    if (model.isSelected) {
        self.bgHeadImageView.hidden = NO;
        self.arrowImageView.hidden = NO;
        self.levelLabel.textColor = [UIColor colorWithHexString:@"#FF6363"];
        self.priceLabel.layer.borderColor = [UIColor colorWithHexString:@"#FF6363"].CGColor;
         self.priceLabel.textColor = [UIColor colorWithHexString:@"#FF6363"];
    }else{
        self.bgHeadImageView.hidden = YES;
        self.arrowImageView.hidden = YES;
        self.levelLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        self.priceLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        self.priceLabel.layer.borderColor = [UIColor colorWithHexString:@"#808080"].CGColor;
    }
    
    self.levelLabel.text = model.name;
    if (kIsEmptyString(model.icon)) {
       self.headImageView.image = [UIImage imageNamed:@"teacher_grade_gray"];
    }else{
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"teacher_grade_gray"]];
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",[model.price doubleValue]];
    
}


@end
