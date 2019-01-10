//
//  TeacherViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherViewController.h"
#import "TeacherDetailsViewController.h"
#import "ConnectionSettingViewController.h"
#import "SlideMenuView.h"
#import "RecommandTableViewCell.h"
#import "FocusTableViewCell.h"
#import "TeacherModel.h"
#import "MJRefresh.h"

@interface TeacherViewController ()<UITableViewDelegate,UITableViewDataSource,SlideMenuViewDelegate>{
    NSInteger   selectIndex;
    NSInteger   page;
}


@property (nonatomic, strong)SlideMenuView   *titleView;
@property (nonatomic, strong)UITableView     *myTableView;
@property (nonatomic ,strong) UIImageView       *blankView; //空白页

@property (nonatomic, strong)NSMutableArray  *teachersArray;  //老师列表

@end

@implementation TeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn = YES;
    
    selectIndex = 1;
    page = 1;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.myTableView];
    [self.myTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    [self requestForTeachersData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"老师"];
    
    if ([ZYHelper sharedZYHelper].isUpdateFocusTeacher) {
        [self requestForTeachersData];
        [ZYHelper sharedZYHelper].isUpdateFocusTeacher = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"老师"];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.teachersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (selectIndex==2) {
        static NSString *cellIdentifier = @"FocusTableViewCell";
        FocusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FocusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TeacherModel *model = self.teachersArray[indexPath.row];
        [cell displayCellWithModel:model];
        
        cell.connectButton.userInteractionEnabled = [model.online boolValue];
        cell.connectButton.tag = indexPath.row;
        [cell.connectButton addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"RecommandTableViewCell";
        RecommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[RecommandTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TeacherModel *model = self.teachersArray[indexPath.row];
        [cell displayCellWithTeacher:model];
        
        cell.connectButton.tag = indexPath.row;
        [cell.connectButton addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return selectIndex==2?90:96.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeacherModel *model = self.teachersArray[indexPath.row];
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.tch_id = model.tch_id;
    detailsVC.isFocusIn = selectIndex==2;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Custom Delegate
#pragma mark ItemTitleViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectIndex = index+1;
    page=1;
    [self loadNewTeacherListData];
}

#pragma mark -- Event response
-(void)toConnectTeacherAction:(UIButton *)sender{
    TeacherModel *model = self.teachersArray[sender.tag];
    BOOL isOnline = [model.online boolValue];
    if (isOnline) {
        ConnectionSettingViewController *settingVC = [[ConnectionSettingViewController alloc] init];
        settingVC.teacherModel = model;
        settingVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:settingVC animated:YES];
    }else{
        [self.view makeToast:@"老师当前不在线，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark -- Private Methods
#pragma mark 加载最新老师列表
-(void)loadNewTeacherListData{
    page=1;
    [self requestForTeachersData];
}

#pragma mark 加载更多老师列表
-(void)loadMoreTeacherListData{
    page++;
    [self requestForTeachersData];
}

#pragma mark load Data
-(void)requestForTeachersData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&label=%ld&page=%ld",kUserTokenValue,selectIndex,page];
    [TCHttpRequest postMethodWithURL:kGetMoreTeachersAPI body:body success:^(id json) {
        NSArray *data = [json objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            TeacherModel *model = [[TeacherModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        if (page==1) {
            weakSelf.teachersArray = tempArr;
        }else{
            [weakSelf.teachersArray addObjectsFromArray:tempArr];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.myTableView.mj_footer.hidden = data.count<20;
            if (selectIndex==1) {
                weakSelf.blankView.hidden = YES;
            }else{
                weakSelf.blankView.hidden = weakSelf.teachersArray.count>0;
            }
            [weakSelf.myTableView reloadData];
            [weakSelf.myTableView.mj_header endRefreshing];
            [weakSelf.myTableView.mj_footer endRefreshing];
        });
    }];
}


#pragma mark -- Setters and Getters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -120)/2, KStatusHeight, 120, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"推荐",@"关注"];
         _titleView.currentIndex = 0;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark 老师列表
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-kTabHeight) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.estimatedSectionHeaderHeight=0;
        _myTableView.estimatedSectionFooterHeight=0;
        _myTableView.tableFooterView = [[UIView alloc] init];
        _myTableView.backgroundColor = selectIndex==2 ? [UIColor whiteColor]:[UIColor bgColor_Gray];
        _myTableView.separatorStyle = selectIndex==2?UITableViewCellSeparatorStyleSingleLine:UITableViewCellSeparatorStyleNone;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewTeacherListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _myTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTeacherListData)];
        footer.automaticallyRefresh = NO;
        _myTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _myTableView;
}

#pragma mark 空白页
-(UIImageView *)blankView{
    if (!_blankView) {
        _blankView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2.0,70, 149, 127)];
        _blankView.image = [UIImage imageNamed:@"default_follow"];
    }
    return _blankView;
}

#pragma mark 推荐老师数组
-(NSMutableArray *)teachersArray{
    if (!_teachersArray) {
        _teachersArray = [[NSMutableArray alloc] init];
    }
    return _teachersArray;
}


@end
