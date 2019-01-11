//
//  TeacherHeaderView.m
//  ZuoYe
//
//  Created by vision on 2018/8/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherHeaderView.h"

#define kItemW 75
#define kCapW (kScreenWidth-30-4*kItemW)/3.0

@interface TeacherHeaderView ()

@property (nonatomic, strong) UIImageView *headImageView;     //头像
@property (nonatomic, strong) UILabel     *nameLabel;         //姓名
@property (nonatomic, strong) UILabel     *gradeLabel;        //年级/科目
@property (nonatomic, strong) UILabel     *levelLabel;        //教师等级
@property (nonatomic, strong) UILabel     *experienceLabel;   //经验
@property (nonatomic, strong) UILabel     *scoreLabel;        //评分
@property (nonatomic, strong) UILabel     *studentLabel;      //学生人数
@property (nonatomic, strong) UILabel     *fansLabel;         //粉丝数

@property (nonatomic, strong) UILabel     *priceLabel;        //辅导价格
@property (nonatomic, strong) UILabel     *totalTimeLabel;    //辅导时长
@property (nonatomic, strong) UILabel     *checkCountLabel;   //检查次数
@property (nonatomic, strong) UIButton    *identityButton;    //身份认证
@property (nonatomic, strong) UIButton    *teacherButton;     //教师资质
@property (nonatomic, strong) UIButton    *educationButton;    //学历认证
@property (nonatomic, strong) UIButton    *technicalButton;    //专业技能


@end

@implementation TeacherHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //背景图片
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,KStatusHeight+180)];
        bgImageView.image = [UIImage imageNamed:@"teacher_details_background"];
        bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        bgImageView.clipsToBounds =YES;
        [self addSubview:bgImageView];
        
        //头像
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(28,KStatusHeight+40, 72, 72)];
        bgHeadImageView.backgroundColor = [UIColor whiteColor];
        bgHeadImageView.boderRadius = 36.0;
        [self addSubview:bgHeadImageView];
        [self addSubview:self.headImageView];
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.gradeLabel];
        [self addSubview:self.levelLabel];
        [self addSubview:self.experienceLabel];
        [self addSubview:self.scoreLabel];
        [self addSubview:self.studentLabel];
        [self addSubview:self.fansLabel];
        
        for (NSInteger i=0; i<2; i++) {
            UIView *line= [[UIView alloc] initWithFrame:CGRectMake((i+1)*kScreenWidth/3.0, self.headImageView.bottom+22,1, 19)];
            line.backgroundColor  = [UIColor whiteColor];
            [self addSubview:line];
        }
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,KStatusHeight+165, kScreenWidth, 160)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.topBoderRadius = 8.0;
        [self addSubview:bgView];
        
        // 作业辅导价格 作业辅导时长 作业检查次数
        NSArray *images = @[@"tutor_price",@"tutor_time",@"tutor_frequency"];
        NSArray *titles = @[@"作业辅导价格",@"作业辅导时长",@"作业检查次数"];
        for (NSInteger i=0; i<3; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth/3.0)*i+(kScreenWidth/3.0-28)/2.0, 17, 28, 28)];
            imgView.image = [UIImage imageNamed:images[i]];
            [bgView addSubview:imgView];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(i*(kScreenWidth/3.0), imgView.bottom+5.0, kScreenWidth/3.0, 20)];
            lab.text = titles[i];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
            lab.textColor = [UIColor colorWithHexString:@" #4A4A4A"];
            [bgView addSubview:lab];
            if (i==0) {
                self.priceLabel = lab;
            }else if (i==1){
                self.totalTimeLabel = lab;
            }else{
                self.checkCountLabel = lab;
            }
            
            UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(i*(kScreenWidth/3.0), lab.bottom+2.0, kScreenWidth/3.0, 20)];
            titleLab.text = titles[i];
            titleLab.textAlignment = NSTextAlignmentCenter;
            titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            titleLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
            [bgView addSubview:titleLab];
        }
        
        UIView *line2= [[UIView alloc] initWithFrame:CGRectMake(26,109.0,kScreenWidth-51, 0.5)];
        line2.backgroundColor  = [UIColor colorWithHexString:@"#D8D8D8"];
        [bgView addSubview:line2];
        
        //认证
        [bgView addSubview:self.identityButton];
        [bgView addSubview:self.teacherButton];
        [bgView addSubview:self.educationButton];
        [bgView addSubview:self.technicalButton];
    }
    return self;
}

#pragma mark -- setters
-(void)setTeacher:(TeacherModel *)teacher{
    _teacher = teacher;
    
    if (kIsEmptyString(teacher.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:teacher.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    
    self.nameLabel.text = teacher.tch_name;
    CGFloat nameW = [teacher.tch_name boundingRectWithSize:CGSizeMake(120, 25) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImageView.right+14,KStatusHeight+45, nameW, 25);
    if (!kIsEmptyString(teacher.level)) {
        self.levelLabel.hidden = NO;
        self.levelLabel.text = [NSString stringWithFormat:@"%@",teacher.level];
        self.levelLabel.frame = CGRectMake(self.nameLabel.right+5,KStatusHeight+49,65, 18);
    }else{
        self.levelLabel.hidden = YES;
    }
    
    if (kIsArray(teacher.grade)&&teacher.grade.count>0) {
        NSString *gradeStr = [[ZYHelper sharedZYHelper] parseToGradeStringForGrades:teacher.grade];
        _gradeLabel.text = [NSString stringWithFormat:@"%@  %@",gradeStr,teacher.subject];
    }else{
        _gradeLabel.text = [NSString stringWithFormat:@"%@",teacher.subject];
    }
    
    self.experienceLabel.text = [NSString stringWithFormat:@"%ld年教龄，%@毕业",[teacher.edu_exp integerValue],kIsEmptyString(teacher.college)?@"":teacher.college];
    self.scoreLabel.text = [NSString stringWithFormat:@"好评 %.1f",[teacher.score doubleValue]];
    self.studentLabel.text = [NSString stringWithFormat:@"学生人数 %@",teacher.stu_num];
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝 %@",teacher.follower_num];
    if (!kIsEmptyObject(teacher.guide_price)) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",[teacher.guide_price doubleValue]];
    }
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld分钟",[teacher.guide_time integerValue]/60];
    self.checkCountLabel.text = [NSString stringWithFormat:@"%ld次",[teacher.check_num integerValue]];
    
    self.identityButton.selected = [teacher.is_ID_auth integerValue]==2;
    self.teacherButton.selected = [teacher.is_teach_auth integerValue]==2;
    self.educationButton.selected = [teacher.is_edu_auth integerValue]==2;
    self.technicalButton.selected = [teacher.is_skill_auth integerValue]==2;
}

#pragma mark -- Private methods
#pragma mark 自定义按钮
-(UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)imgName selImage:(NSString *)selImage{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:selImage] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor colorWithHexString:@"#D8D8D8"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:12];
    btn.titleEdgeInsets = UIEdgeInsetsMake(4, 5, 4, 0);
    btn.userInteractionEnabled = NO;
    return btn;
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31,KStatusHeight+43, 66, 66)];
        _headImageView.boderRadius = 33.0;
    }
    return _headImageView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+14,KStatusHeight+45, 75, 25)];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        _nameLabel.textColor = [UIColor whiteColor];
    }
    return _nameLabel;
}

#pragma mark 年级/科目
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+14, self.nameLabel.bottom+4, 180, 17)];
        _gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        _gradeLabel.textColor = [UIColor whiteColor];
    }
    return _gradeLabel;
}

#pragma mark 教师等级
-(UILabel *)levelLabel{
    if (!_levelLabel) {
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.right+5,KStatusHeight+49,65, 18)];
        _levelLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:12];
        _levelLabel.backgroundColor = [UIColor colorWithHexString:@"#FFB842"];
        _levelLabel.textColor = [UIColor whiteColor];
        _levelLabel.textAlignment = NSTextAlignmentCenter;
        _levelLabel.layer.cornerRadius = 9.0;
        _levelLabel.clipsToBounds = YES;
    }
    return _levelLabel;
}

#pragma mark 教龄 毕业学校
-(UILabel *)experienceLabel{
    if (!_experienceLabel) {
        _experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+14, self.gradeLabel.bottom+2.0, 200, 17)];
        _experienceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        _experienceLabel.textColor = [UIColor whiteColor];
    }
    return _experienceLabel;
}

#pragma mark 评分
-(UILabel *)scoreLabel{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/3.0-80, self.headImageView.bottom+21, 60, 20)];
        _scoreLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        _scoreLabel.textColor = [UIColor whiteColor];
    }
    return _scoreLabel;
}

#pragma mark 学生人数
-(UILabel *)studentLabel{
    if (!_studentLabel) {
        _studentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/3.0+5, self.headImageView.bottom+21,kScreenWidth/3.0-10, 20)];
        _studentLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        _studentLabel.textColor = [UIColor whiteColor];
        _studentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _studentLabel;
}

#pragma mark 粉丝人数
-(UILabel *)fansLabel{
    if (!_fansLabel) {
        _fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth*(2.0/3.0)+5, self.headImageView.bottom+21, kScreenWidth/3.0-10, 20)];
        _fansLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        _fansLabel.textColor = [UIColor whiteColor];
        _fansLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _fansLabel;
}

#pragma mark 身份认证
-(UIButton *)identityButton{
    if (!_identityButton) {
        _identityButton = [self createButtonWithFrame:CGRectMake(16,123, kItemW, 25) title:@"身份认证" image:@"authentication_identity_gray" selImage:@"authentication_identity"];
    }
    return _identityButton;
}

#pragma mark 学历认证
-(UIButton *)educationButton{
    if (!_educationButton) {
        _educationButton = [self createButtonWithFrame:CGRectMake(self.identityButton.right+kCapW, 123,kItemW, 25) title:@"学历认证" image:@"authentication_education_gray" selImage:@"authentication_education"];
    }
    return _educationButton;
}

#pragma mark 教师资质
-(UIButton *)teacherButton{
    if (!_teacherButton) {
        _teacherButton = [self createButtonWithFrame:CGRectMake(self.educationButton.right+kCapW,123, kItemW, 25) title:@"教师资质" image:@"authentication_teacher_gray" selImage:@"authentication_teacher"];
    }
    return _teacherButton;
}

#pragma mark 专业技能
-(UIButton *)technicalButton{
    if (!_technicalButton) {
        _technicalButton = [self createButtonWithFrame:CGRectMake(self.teacherButton.right+kCapW,123,kItemW, 25) title:@"专业技能" image:@"authentication_skill_gray" selImage:@"authentication_skill"];
    }
    return _technicalButton;
}


@end
