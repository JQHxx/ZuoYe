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

@interface TeacherDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    TeacherModel   *teacher;
    NSMutableArray   *commentArray;
    
    UILabel    *introLabel;
    UILabel    *commentCountLabel;
    UIButton   *moreBtn;   //更多评论
    UIButton   *focusBtn;
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"老师详情"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"老师详情"];
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
    commentVC.tch_id = teacher.tch_id;
    [self.navigationController pushViewController:commentVC animated:YES];
}

#pragma mark 关注
-(void)concernTeacherForClickAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSInteger attention =0;
    if (sender.selected) {
        attention = 1;
        [focusBtn setImage:nil forState:UIControlStateNormal];
    }else{
        attention = 2;
        [focusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
    }
    
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&tid=%@&attention=%ld",kUserTokenValue,self.tch_id,attention];
    [TCHttpRequest postMethodWithURL:kTeacherAttentionAPI body:body success:^(id json) {
        if (weakSelf.isFocusIn) {
            [ZYHelper sharedZYHelper].isUpdateFocusTeacher = YES;
        }
        [weakSelf loadTeacherInfo];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (attention==1) {
                [weakSelf.view makeToast:@"已成功关注" duration:1.0 position:CSToastPositionCenter];
                [focusBtn setImage:nil forState:UIControlStateNormal];
            }else{
                [weakSelf.view makeToast:@"已取消关注" duration:1.0 position:CSToastPositionCenter];
                [focusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
            }
        });
    }];
}

#pragma mark -- Event Response
#pragma mark 连线
-(void)connectTeacherAction{
    BOOL isOnline = [teacher.online boolValue];
    if (isOnline) {
        ConnectionSettingViewController *connectSetVC = [[ConnectionSettingViewController alloc] init];
        connectSetVC.teacherModel = teacher;
        [self.navigationController pushViewController:connectSetVC animated:YES];
    }else{
        [self.view makeToast:@"老师当前不在线，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark -- Private Methods
#pragma mark 加载老师数据
-(void)loadTeacherInfo{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&tid=%@",kUserTokenValue,self.tch_id];
    [TCHttpRequest postMethodWithURL:kGetTeacherDetailsAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        
        //老师信息
        NSDictionary *tchDict = [data valueForKey:@"teacher"];
        [teacher setValues:tchDict];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.rootScrollView.hidden = NO;
            weakSelf.headerView.teacher = teacher;
            
            if (!kIsEmptyString(teacher.intro)) {
                weakSelf.introView.hidden = NO;
                introLabel.text = teacher.intro;
                CGFloat introHeight = [teacher.intro boundingRectWithSize:CGSizeMake(kScreenWidth-30, CGFLOAT_MAX) withTextFont:introLabel.font].height;
                introLabel.frame = CGRectMake(16,36, kScreenWidth-26, introHeight);
                weakSelf.introView.frame = CGRectMake(0,self.headerView.bottom+10, kScreenWidth, introHeight+50);
            }else{
                weakSelf.introView.hidden = YES;
                weakSelf.introView.frame = CGRectMake(0,self.headerView.bottom, kScreenWidth, 0);
            }
            
            //评论信息
            weakSelf.commentHeaderView.hidden = NO;
            NSDictionary *commentDict = [data valueForKey:@"comment"];
            NSInteger commentCount = [[commentDict valueForKey:@"num"] integerValue];
            commentCountLabel.text = [NSString stringWithFormat:@"评论（%ld）",commentCount];
            weakSelf.commentHeaderView.frame = CGRectMake(0, self.introView.bottom+10, kScreenWidth, 40);
            moreBtn.hidden = commentCount<3;
            
            NSArray *commentsArr = [commentDict valueForKey:@"data"];
            CGFloat commentHeight= 0.0;
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in commentsArr) {
                CommentModel *model = [[CommentModel alloc] init];
                [model setValues:dict];
                CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-97.0, CGFLOAT_MAX) withTextFont:[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12]].height;
                commentHeight += commentH+60;
                [tempArr addObject:model];
            }
            commentArray = tempArr;
            
            [weakSelf.teacherDetailsView reloadData];
            weakSelf.teacherDetailsView.frame = CGRectMake(0, self.commentHeaderView.bottom, kScreenWidth, commentHeight);
            weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherDetailsView.top+self.teacherDetailsView.height);
            
            if ([teacher.attention integerValue]==1) {
                focusBtn.selected = YES;
                [focusBtn setImage:nil forState:UIControlStateNormal];
            }else{
                focusBtn.selected = NO;
                [focusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
            }
        });
    }];
   
}

#pragma mark 初始化
-(void)initTeacherDetailsView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.headerView];
    [self.rootScrollView addSubview:self.introView];
    [self.rootScrollView addSubview:self.commentHeaderView];
    self.introView.hidden = self.commentHeaderView.hidden = YES;
    [self.rootScrollView addSubview:self.teacherDetailsView];
   
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.bottomView];
    
    self.rootScrollView.hidden = YES;
    
}

#pragma mark -- Getters
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        CGFloat bottomH = isXDevice ?(50+ 24) : 50;
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-bottomH)];
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
        
        moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, 5, 70, 30)];
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
        CGFloat bottomH = isXDevice ?(50+ 24) : 50;
        _teacherDetailsView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.headerView.bottom+10, kScreenWidth, kScreenHeight-bottomH-self.headerView.bottom) style:UITableViewStylePlain];
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
        
        CGFloat bottomH = isXDevice ?(50+ 24) : 50;
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-bottomH, kScreenWidth,bottomH)];
        
        focusBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth/2.0-70)/2.0, 10, 70, 30)];
        [focusBtn setImage:[UIImage imageNamed:@"teacher_details_follow"] forState:UIControlStateNormal];
        [focusBtn setTitle:@"关注" forState:UIControlStateNormal];
        [focusBtn setTitle:@"已关注" forState:UIControlStateSelected];
        focusBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [focusBtn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [focusBtn setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateSelected];
        [focusBtn addTarget:self action:@selector(concernTeacherForClickAction:) forControlEvents:UIControlEventTouchUpInside];
        focusBtn.titleEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 0);
        [_bottomView addSubview:focusBtn];
        
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
