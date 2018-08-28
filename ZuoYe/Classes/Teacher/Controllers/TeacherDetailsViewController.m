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

@interface TeacherDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,TeacherHeaderViewDelegate>{
    TeacherModel   *teacher;
    NSMutableArray   *commentArray;
}

@property (nonatomic ,strong) UITableView           *teacherDetailsView;
@property (nonatomic ,strong) TeacherHeaderView     *headerView;
@property (nonatomic ,strong) UIButton              *bottomBtn;

@end

@implementation TeacherDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"老师详情";
    
    teacher= [[TeacherModel alloc] init];
    commentArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.teacherDetailsView];
    [self.view addSubview:self.bottomBtn];
    
    [self loadTeacherInfo];
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
    CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-50-20, CGFLOAT_MAX) withTextFont:kFontWithSize(14)].height;
    return commentH+70;
}

#pragma mark -- Delegate
#pragma mark TeacherHeaderViewDelegate
#pragma mark 更多评论
-(void)teacherHeaderViewGetMoreCommentAction{
    CommentListViewController *commentVC = [[CommentListViewController alloc] init];
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark 关注
-(void)teacherHeaderViewDidConcernAction{
    
}

#pragma mark -- Event Response
#pragma mark 连线
-(void)connectTeacherAction{
    ConnectionSettingViewController *connectSetVC = [[ConnectionSettingViewController alloc] init];
    [self.navigationController pushViewController:connectSetVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载老师数据
-(void)loadTeacherInfo{
    teacher.head = @"ic_m_head";
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
    
    CGFloat introHeight = [teacher.intro boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:kFontWithSize(14)].height;
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth, introHeight+390);
    self.headerView.teacher = teacher;
    self.teacherDetailsView.tableHeaderView = self.headerView;
    
    
    NSArray *names = @[@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小明老师"];
    NSArray *comments = @[@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<names.count; i++) {
        CommentModel *model = [[CommentModel alloc] init];
        model.head_image = @"ic_m_head";
        model.name = names[i];
        model.score = (double)(i+5)*0.5;
        model.create_time = [NSString stringWithFormat:@"2018-08-%ld %02ld:%02ld",i+12,i*3,i*5+3];
        model.comment = comments[i];
        [tempArr addObject:model];
    }
    commentArray = tempArr;
    [self.teacherDetailsView reloadData];
}

#pragma mark -- Getters
#pragma mark
-(UITableView *)teacherDetailsView{
    if (!_teacherDetailsView) {
        _teacherDetailsView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-45) style:UITableViewStylePlain];
        _teacherDetailsView.dataSource = self;
        _teacherDetailsView.delegate = self;
        _teacherDetailsView.showsVerticalScrollIndicator = NO;
        _teacherDetailsView.tableFooterView = [[UIView alloc] init];
    }
    return _teacherDetailsView;
}

#pragma mark 老师头部视图
-(TeacherHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[TeacherHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 240)];
        _headerView.backgroundColor = [UIColor bgColor_Gray];
        _headerView.delegate = self;
    }
    return _headerView;
}

#pragma mark 底部连线
-(UIButton *)bottomBtn{
    if (!_bottomBtn) {
        _bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45)];
        _bottomBtn.backgroundColor = [UIColor redColor];
        [_bottomBtn setTitle:@"连线" forState:UIControlStateNormal];
        [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomBtn addTarget:self action:@selector(connectTeacherAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}


@end
