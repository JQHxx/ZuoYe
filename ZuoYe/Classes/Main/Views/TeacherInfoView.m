//
//  TeacherInfoView.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherInfoView.h"

@interface TeacherInfoView()

@property (nonatomic ,strong) UIImageView *headImageView;     //头像
@property (nonatomic ,strong) UILabel     *nameLabel;         //姓名
@property (nonatomic ,strong) UILabel     *gradeLabel;        //年级
@property (nonatomic ,strong) UILabel     *priceLabel;        //价格

@end

@implementation TeacherInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 14, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [self addSubview:bgHeadImageView];
        
        //头像
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 17, 52, 52)];
        self.headImageView.boderRadius = 26.0;
        [self addSubview:self.headImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+13.0, 21.0, 100, 22)];
        self.nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [self addSubview:self.nameLabel];
        
        self.gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+13, self.nameLabel.bottom+3.0, 200, 20)];
        self.gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        self.gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        [self addSubview:self.gradeLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-130.0,21.0, 95.0, 22.0)];
        self.priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        self.priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        self.priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.priceLabel];
    }
    return self;
}

-(void)setModel:(TeacherModel *)model{
    if (kIsEmptyString(model.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    
    
    self.nameLabel.text = model.tch_name;
    if (kIsArray(model.grade)&&model.grade.count>0) {
        NSString *gradeStr = [[ZYHelper sharedZYHelper] parseToGradeStringForGrades:model.grade];
        self.gradeLabel.text = [NSString stringWithFormat:@"%@  %@",gradeStr,model.subject];
    }else{
        self.gradeLabel.text = [NSString stringWithFormat:@"%@",model.subject];
    }
    
    if (!kIsEmptyObject(model.guide_price)) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",[model.guide_price doubleValue]];
    }
}

@end
