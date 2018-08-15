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

@end

@implementation TeacherInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [self addSubview:lineView];
        
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        self.headImageView.image = [UIImage imageNamed:@"ic_m_head"];
        [self addSubview:self.headImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, 10, 100, 30)];
        self.nameLabel.font = kFontWithSize(16);
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.text = @"小美老师";
        [self addSubview:self.nameLabel];
        
        self.gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.nameLabel.bottom, 120, 20)];
        self.gradeLabel.font = kFontWithSize(14);
        self.gradeLabel.textColor = [UIColor lightGrayColor];
        self.gradeLabel.text = @"一年级/数学" ;
        [self addSubview:self.gradeLabel];
    }
    return self;
}



@end
