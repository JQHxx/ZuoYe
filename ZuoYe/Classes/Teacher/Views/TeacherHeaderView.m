//
//  TeacherHeaderView.m
//  ZuoYe
//
//  Created by vision on 2018/8/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherHeaderView.h"

@interface TeacherHeaderView (){
    UILabel    *introLabel;
    UILabel    *commentCountLabel;
}

@property (nonatomic, strong) UIImageView *headImageView;     //头像
@property (nonatomic, strong) UILabel     *nameLabel;         //姓名
@property (nonatomic, strong) UILabel     *gradeLabel;        //年级/科目
@property (nonatomic, strong) UILabel     *levelLabel;        //教师等级
@property (nonatomic, strong) UILabel     *experienceLabel;   //经验
@property (nonatomic, strong) UIButton    *foucusBtn;         //关注
@property (nonatomic, strong) UILabel     *scoreLabel;        //评分
@property (nonatomic, strong) UILabel     *studentLabel;      //学生人数
@property (nonatomic, strong) UILabel     *fansLabel;         //粉丝数
@property (nonatomic, strong) UILabel     *priceLabel;        //辅导价格
@property (nonatomic, strong) UILabel     *totalTimeLabel;         //辅导时长
@property (nonatomic, strong) UILabel     *checkCountLabel;   //检查次数
@property (nonatomic, strong) UIButton    *identityButton;    //身份认证
@property (nonatomic, strong) UIButton    *teacherButton;     //教师资质
@property (nonatomic, strong) UIButton    *educationButton;    //学历认证
@property (nonatomic, strong) UIButton    *technicalButton;    //专业技能
@property (nonatomic, strong) UIView      *introView;

@property (nonatomic, strong) UIView      *commentHeaderView;  //评论头部视图


@end

@implementation TeacherHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 270)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        [bgView addSubview:self.headImageView];
        [bgView addSubview:self.nameLabel];
        [bgView addSubview:self.gradeLabel];
        [bgView addSubview:self.levelLabel];
        [bgView addSubview:self.experienceLabel];
        [bgView addSubview:self.foucusBtn];
        [bgView addSubview:self.scoreLabel];
        [bgView addSubview:self.studentLabel];
        [bgView addSubview:self.fansLabel];
        
        UIView *line= [[UIView alloc] initWithFrame:CGRectMake(10, self.scoreLabel.bottom+10, kScreenWidth-20, 0.5)];
        line.backgroundColor  = kLineColor;
        [bgView addSubview:line];
        
        [bgView addSubview:self.priceLabel];
        [bgView addSubview:self.totalTimeLabel];
        [bgView addSubview:self.checkCountLabel];
        
        NSArray *titles = @[@"作业辅导价格",@"作业辅导时长",@"作业检查次数"];
        for (NSInteger i=0; i<3; i++) {
            UIView *lineView= [[UIView alloc] initWithFrame:CGRectMake((i+1)*kScreenWidth/3.0, self.scoreLabel.bottom+30,0.5, 40)];
            lineView.backgroundColor  = kLineColor;
            [bgView addSubview:lineView];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(i*(kScreenWidth/3.0), self.priceLabel.bottom, kScreenWidth/3.0, 30)];
            lab.text = titles[i];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = kFontWithSize(16);
            [bgView addSubview:lab];
        }
        
        [bgView addSubview:self.identityButton];
        [bgView addSubview:self.teacherButton];
        [bgView addSubview:self.educationButton];
        [bgView addSubview:self.technicalButton];
        
        [self addSubview:self.introView];
        [self addSubview:self.commentHeaderView];
        
        
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 更多评论
-(void)getMoreCommentAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(teacherHeaderViewGetMoreCommentAction)]) {
        [self.delegate teacherHeaderViewGetMoreCommentAction];
    }
}

#pragma mark 关注
-(void)concernTeacherForClickAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(teacherHeaderViewDidConcernAction)]) {
        [self.delegate teacherHeaderViewDidConcernAction];
    }
}

#pragma mark -- setters
-(void)setTeacher:(TeacherModel *)teacher{
    _teacher = teacher;
    self.headImageView.image = [UIImage imageNamed:teacher.head];
    self.nameLabel.text = teacher.name;
    self.gradeLabel.text = [NSString stringWithFormat:@"%@/%@",teacher.grade,teacher.subjects];
    self.levelLabel.text = teacher.level;
    self.experienceLabel.text = [NSString stringWithFormat:@"%ld年教龄，%@毕业",teacher.schoolAge,teacher.graduated_school];
    self.scoreLabel.text = [NSString stringWithFormat:@"好评 %.1f",teacher.score];
    self.studentLabel.text = [NSString stringWithFormat:@"学生人数 %ld",teacher.student_count];
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝 %ld",teacher.fans_count];
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",teacher.price];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%ld分钟",teacher.tutoring_time];
    self.checkCountLabel.text = [NSString stringWithFormat:@"%ld次",teacher.check_number];
    self.identityButton.selected = teacher.identity_authentication;
    self.teacherButton.selected = teacher.teacher_qualification;
    self.educationButton.selected = teacher.education_certification;
    self.technicalButton.selected = teacher.technical_skill;
    
    introLabel.text = teacher.intro;
    CGFloat introHeight = [teacher.intro boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:kFontWithSize(14)].height;
    introLabel.frame = CGRectMake(15, 40, kScreenWidth-30, introHeight+10);
    self.introView.frame = CGRectMake(0, 280, kScreenWidth, introHeight+60);
    
    commentCountLabel.text = [NSString stringWithFormat:@"评论（%ld）",teacher.comment_count];
    self.commentHeaderView.frame = CGRectMake(0, self.introView.bottom+10, kScreenWidth, 40);
}


#pragma mark -- Private methods
-(UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setImage:[UIImage imageNamed:@"ic_eqment_pick_un"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ic_eqment_pick_on"] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = kFontWithSize(14);
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return btn;
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 80, 80)];
        _headImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _headImageView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.headImageView.top, 120, 30)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}

#pragma mark 年级/科目
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.nameLabel.bottom, 100, 25)];
        _gradeLabel.font = kFontWithSize(13);
        _gradeLabel.textColor = [UIColor blackColor];
    }
    return _gradeLabel;
}

#pragma mark 教师等级
-(UILabel *)levelLabel{
    if (!_levelLabel) {
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.gradeLabel.right, self.nameLabel.bottom, 80, 25)];
        _levelLabel.font = kFontWithSize(13);
        _levelLabel.textColor = [UIColor blackColor];
    }
    return _levelLabel;
}

#pragma mark 教龄 毕业学校
-(UILabel *)experienceLabel{
    if (!_experienceLabel) {
        _experienceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.gradeLabel.bottom, 200, 25)];
        _experienceLabel.font = kFontWithSize(13);
        _experienceLabel.textColor = [UIColor darkGrayColor];
    }
    return _experienceLabel;
}

#pragma mark 关注
-(UIButton *)foucusBtn{
    if (!_foucusBtn) {
        _foucusBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-90, self.nameLabel.top+15, 70, 30)];
        [_foucusBtn setTitle:@"+关注" forState:UIControlStateNormal];
        [_foucusBtn setTitle:@"已关注" forState:UIControlStateSelected];
        _foucusBtn.titleLabel.font = kFontWithSize(14);
        _foucusBtn.layer.cornerRadius = 5;
        _foucusBtn.layer.borderColor = [UIColor blackColor].CGColor;
        _foucusBtn.layer.borderWidth = 1.0;
        [_foucusBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_foucusBtn addTarget:self action:@selector(concernTeacherForClickAction:) forControlEvents:UIControlEventTouchUpInside];
        _foucusBtn.backgroundColor = [UIColor whiteColor];
    }
    return _foucusBtn;
}

#pragma mark 评分
-(UILabel *)scoreLabel{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.headImageView.bottom+10, (kScreenWidth-20)/3.0, 30)];
        _scoreLabel.font = kFontWithSize(14);
    }
    return _scoreLabel;
}

#pragma mark 学生人数
-(UILabel *)studentLabel{
    if (!_studentLabel) {
        _studentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scoreLabel.right, self.headImageView.bottom+10, (kScreenWidth-20)/3.0, 30)];
        _studentLabel.font = kFontWithSize(14);
    }
    return _studentLabel;
}

#pragma mark 粉丝人数
-(UILabel *)fansLabel{
    if (!_fansLabel) {
        _fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.studentLabel.right, self.headImageView.bottom+10, (kScreenWidth-20)/3.0, 30)];
        _fansLabel.font = kFontWithSize(14);
        _fansLabel.textAlignment = NSTextAlignmentRight;
    }
    return _fansLabel;
}

#pragma mark 辅导价格
-(UILabel *)priceLabel{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.scoreLabel.bottom+20, kScreenWidth/3.0, 30)];
        _priceLabel.font = kFontWithSize(14);
        _priceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLabel;
}

#pragma mark 辅导时长
-(UILabel *)totalTimeLabel{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.priceLabel.right, self.scoreLabel.bottom+20, kScreenWidth/3.0, 30)];
        _totalTimeLabel.font = kFontWithSize(14);
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

#pragma mark 检查次数
-(UILabel *)checkCountLabel{
    if (!_checkCountLabel) {
        _checkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.totalTimeLabel.right, self.scoreLabel.bottom+20, kScreenWidth/3.0, 30)];
        _checkCountLabel.font = kFontWithSize(14);
        _checkCountLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _checkCountLabel;
}

#pragma mark 身份认证
-(UIButton *)identityButton{
    if (!_identityButton) {
        _identityButton = [self createButtonWithFrame:CGRectMake(0,self.priceLabel.bottom+40, kScreenWidth/4.0, 30) title:@"身份认证"];
    }
    return _identityButton;
}

#pragma mark 教师资质
-(UIButton *)teacherButton{
    if (!_teacherButton) {
        _teacherButton = [self createButtonWithFrame:CGRectMake(self.identityButton.right, self.priceLabel.bottom+40, kScreenWidth/4.0, 30) title:@"教师资质"];
    }
    return _teacherButton;
}

#pragma mark 学历认证
-(UIButton *)educationButton{
    if (!_educationButton) {
        _educationButton = [self createButtonWithFrame:CGRectMake(self.teacherButton.right, self.priceLabel.bottom+40, kScreenWidth/4.0, 30) title:@"学历认证"];
    }
    return _educationButton;
}

#pragma mark 专业技能
-(UIButton *)technicalButton{
    if (!_technicalButton) {
        _technicalButton = [self createButtonWithFrame:CGRectMake(self.educationButton.right, self.priceLabel.bottom+40, kScreenWidth/4.0, 30) title:@"专业技能"];
    }
    return _technicalButton;
}

#pragma mark 个人简介
-(UIView *)introView{
    if (!_introView) {
        _introView = [[UIView alloc] initWithFrame:CGRectMake(0, 310, kScreenWidth, 0)];
        _introView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth-30, 30)];
        titleLab.font = kFontWithSize(14);
        titleLab.text = @"个人简介";
        titleLab.textColor = [UIColor darkGrayColor];
        [_introView addSubview:titleLab];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        introLabel.numberOfLines = 0;
        introLabel.textColor = [UIColor blackColor];
        introLabel.font = kFontWithSize(14);
        [_introView addSubview:introLabel];
    }
    return _introView;
}

#pragma mark 评论头部视图
-(UIView *)commentHeaderView{
    if (!_commentHeaderView) {
        _commentHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentHeaderView.backgroundColor = [UIColor whiteColor];
        
        commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
        commentCountLabel.font = kFontWithSize(14);
        [_commentHeaderView addSubview:commentCountLabel];
        
        UIView *line= [[UIView alloc] initWithFrame:CGRectMake(10, commentCountLabel.bottom+10, kScreenWidth-20, 0.5)];
        line.backgroundColor  = kLineColor;
        [_commentHeaderView addSubview:line];
        
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 70, 30)];
        [moreBtn setTitle:@"更多 >>" forState:UIControlStateNormal];
        moreBtn.titleLabel.font = kFontWithSize(14);
        [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(getMoreCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [_commentHeaderView addSubview:moreBtn];
    }
    return _commentHeaderView;
}



@end
