//
//  TeacherDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherDetailsViewController.h"
#import "CommentListViewController.h"
#import "ConnectionSettingViewController.h"
#import "TeacherHeaderView.h"
#import "CommentTableViewCell.h"
#import "CommentModel.h"

#define kBottomH kScreenWidth*(52.0/375.0)

@interface TeacherDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    TeacherModel   *teacher;
    NSMutableArray   *commentArray;
    
    UILabel    *introLabel;
    UILabel    *commentCountLabel;
    
    UIButton   *foucusBtn;
}

@property (nonatomic ,strong) UIScrollView          *rootScrollView;
@property (nonatomic ,strong) UIButton              *backBtn;
@property (nonatomic ,strong) TeacherHeaderView     *headerView;
@property (nonatomic, strong) UIView                *introView;
@property (nonatomic, strong) UIView                *commentHeaderView;  //评论头部视图
@property (nonatomic ,strong) UITableView           *teacherDetailsView;
@property (nonatomic ,strong) UIView                *bottomView;

@end

@implementation TeacherDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    teacher= [[TeacherModel alloc] init];
    commentArray = [[NSMutableArray alloc] init];
    
    [self initTeacherDetailsView];
    [self loadTeacherInfo];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count>5?5:commentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CommentTableViewCell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    CommentModel *model = commentArray[indexPath.row];
    cell.commentModel = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentModel *model = commentArray[indexPath.row];
    CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-97.0, CGFLOAT_MAX) withTextFont:[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12]].height;
    return commentH+60;
}

#pragma mark -- Delegate
#pragma mark TeacherHeaderViewDelegate
#pragma mark 更多评论
-(void)getMoreCommentAction:(UIButton *)sender{
    CommentListViewController *commentVC = [[CommentListViewController alloc] init];
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark 关注
-(void)concernTeacherForClickAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [foucusBtn setImage:nil forState:UIControlStateNormal];
    }else{
        [foucusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
    }
}

#pragma mark -- Event Response
#pragma mark 连线
-(void)connectTeacherAction{
    ConnectionSettingViewController *connectSetVC = [[ConnectionSettingViewController alloc] init];
    connectSetVC.teacherModel = teacher;
    [self.navigationController pushViewController:connectSetVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载老师数据
-(void)loadTeacherInfo{
    teacher.head = @"photo";
    teacher.name = @"小美老师";
    teacher.grade = @"一年级";
    teacher.subjects = @"英语";
    teacher.level = @"高级教师";
    teacher.schoolAge = 6;
    teacher.graduated_school = @"华中师范大学";
    teacher.score = 4.5;
    teacher.student_count = 2832;
    teacher.fans_count = 28233;
    teacher.price = 1.5;
    teacher.tutoring_time =12223;
    teacher.check_number =34424;
    teacher.identity_authentication = YES;
    teacher.teacher_qualification = YES;
    teacher.education_certification = NO;
    teacher.technical_skill = NO;
    teacher.intro = @"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。";
    teacher.comment_count = 1233;
    
    self.headerView.teacher = teacher;
    
    //个人简介
    introLabel.text = teacher.intro;
    CGFloat introHeight = [teacher.intro boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:introLabel.font].height;
    introLabel.frame = CGRectMake(16,36, kScreenWidth-26, introHeight);
    self.introView.frame = CGRectMake(0,self.headerView.bottom+10, kScreenWidth, introHeight+50);
    
    //评论头部
    commentCountLabel.text = [NSString stringWithFormat:@"评论（%ld）",teacher.comment_count];
    self.commentHeaderView.frame = CGRectMake(0, self.introView.bottom+10, kScreenWidth, 40);
    
    NSArray *names = @[@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小明老师"];
    NSArray *comments = @[@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。"];
    CGFloat commentHeight= 0.0;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<names.count; i++) {
        CommentModel *model = [[CommentModel alloc] init];
        model.head_image = @"photo";
        model.name = names[i];
        model.score = (double)(i+5)*0.5;
        model.create_time = [NSString stringWithFormat:@"2018-08-%ld %02ld:%02ld",i+12,i*3,i*5+3];
        model.comment = comments[i];
        CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-97.0, CGFLOAT_MAX) withTextFont:[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12]].height;
        commentHeight += commentH+60;
        [tempArr addObject:model];
    }
    commentArray = tempArr;
    [self.teacherDetailsView reloadData];
    self.teacherDetailsView.frame = CGRectMake(0, self.commentHeaderView.bottom, kScreenWidth, commentHeight);
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherDetailsView.top+self.teacherDetailsView.height);
    
}

#pragma mark 初始化
-(void)initTeacherDetailsView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.headerView];
    [self.rootScrollView addSubview:self.introView];
     [self.rootScrollView addSubview:self.commentHeaderView];
    [self.rootScrollView addSubview:self.teacherDetailsView];
   
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.bottomView];
    
}

#pragma mark -- Getters
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,-0, kScreenWidth, kScreenHeight-kBottomH)];
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _rootScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _rootScrollView;
}

#pragma mark 返回按钮
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [_backBtn setImage:[UIImage drawImageWithName:@"return_white" size:CGSizeMake(10, 17)] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [_backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark 老师头部视图
-(TeacherHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[TeacherHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,KStatusHeight+325)];
    }
    return _headerView;
}

#pragma mark 个人简介
-(UIView *)introView{
    if (!_introView) {
        _introView = [[UIView alloc] initWithFrame:CGRectZero];
        _introView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 80, 20)];
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        titleLab.text = @"个人简介";
        titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_introView addSubview:titleLab];
        
        introLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        introLabel.numberOfLines = 0;
        introLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        introLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_introView addSubview:introLabel];
    }
    return _introView;
}

#pragma mark 评论头部视图
-(UIView *)commentHeaderView{
    if (!_commentHeaderView) {
        _commentHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _commentHeaderView.backgroundColor = [UIColor whiteColor];
        
        commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 150, 20)];
        commentCountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        commentCountLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [_commentHeaderView addSubview:commentCountLabel];
        
        UIView *line= [[UIView alloc] initWithFrame:CGRectMake(15, commentCountLabel.bottom+8.0, kScreenWidth-18, 0.5)];
        line.backgroundColor  = [UIColor colorWithHexString:@"#D8D8D8"];
        [_commentHeaderView addSubview:line];
        
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 70, 30)];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [moreBtn setImage:[UIImage imageNamed:@"arrow2_personal_information"] forState:UIControlStateNormal];
        moreBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [moreBtn setTitleColor:[UIColor colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(5,60, 5, 0);
        [moreBtn addTarget:self action:@selector(getMoreCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [_commentHeaderView addSubview:moreBtn];
    }
    return _commentHeaderView;
}

#pragma mark
-(UITableView *)teacherDetailsView{
    if (!_teacherDetailsView) {
        _teacherDetailsView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.headerView.bottom+10, kScreenWidth, kScreenHeight-kBottomH-self.headerView.bottom) style:UITableViewStylePlain];
        _teacherDetailsView.dataSource = self;
        _teacherDetailsView.delegate = self;
        _teacherDetailsView.showsVerticalScrollIndicator = NO;
        _teacherDetailsView.tableFooterView = [[UIView alloc] init];
        _teacherDetailsView.scrollEnabled = NO;
    }
    return _teacherDetailsView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-kBottomH, kScreenWidth,kBottomH)];
        
        UIImageView *rootView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,kBottomH)];
        rootView.image = [UIImage imageNamed:@"white1"];
        [_bottomView addSubview:rootView];
        
        foucusBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth/2.0-70)/2.0, 10, 70, 30)];
        [foucusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
        [foucusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [foucusBtn setTitle:@"已关注" forState:UIControlStateSelected];
        foucusBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [foucusBtn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [foucusBtn setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateSelected];
        [foucusBtn addTarget:self action:@selector(concernTeacherForClickAction:) forControlEvents:UIControlEventTouchUpInside];
        foucusBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 0);
        [_bottomView addSubview:foucusBtn];
        
        UIButton *connectBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2.0+(kScreenWidth/2.0-70)/2.0, 10, 70, 30)];
        [connectBtn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [connectBtn setTitle:@"连线" forState:UIControlStateNormal];
        connectBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 0);
        [connectBtn setImage:[UIImage imageNamed:@"teacher_details_Connection"] forState:UIControlStateNormal];
        [connectBtn addTarget:self action:@selector(connectTeacherAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:connectBtn];
        
    }
    return _bottomView;
}

@end
