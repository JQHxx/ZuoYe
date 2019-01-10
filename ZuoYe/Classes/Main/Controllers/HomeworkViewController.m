//
//  HomeworkViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkViewController.h"
#import "HomeworkDetailsViewController.h"
#import "HomeworkTableViewCell.h"
#import "SlideMenuView.h"
#import "HomeworkModel.h"
#import "MJRefresh.h"

@interface HomeworkViewController ()<SlideMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger  selectIndex;
    NSInteger  page;
}

@property (nonatomic, strong) SlideMenuView     *titleView;
@property (nonatomic, strong) UITableView       *homeworkTableView;
@property (nonatomic ,strong) UIImageView       *blankView; //空白页
@property (nonatomic, strong) NSMutableArray    *homeworksArray;

@end

@implementation HomeworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectIndex = 0;
    page = 1;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.homeworkTableView];
    [self.homeworkTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self loadHomeworkData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的作业"];
    
    if ([ZYHelper sharedZYHelper].isUpdateHomework) {
        [self loadHomeworkData];
        [ZYHelper sharedZYHelper].isUpdateHomework = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"我的作业"];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.homeworksArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HomeworkTableViewCell";
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[HomeworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HomeworkModel *model = self.homeworksArray[indexPath.section];
    [cell displayCellWithHomework:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkModel *model = self.homeworksArray[indexPath.section];
    HomeworkDetailsViewController *detailsVC = [[HomeworkDetailsViewController alloc] init];
    detailsVC.jobId = model.job_id;
    detailsVC.label = model.label;
    detailsVC.isReceived =  [model.is_receive integerValue]==2;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectIndex = index;
    [self loadHomeworkData];
}

#pragma mark -- Private Methods
#pragma mark 加载最新数据
-(void)loadNewHomeworkListData{
    page=1;
    [self loadHomeworkData];
}

#pragma mark 加载更多数据
-(void)loadMoreHomeworkListData{
    page++;
    [self loadHomeworkData];
}

#pragma mark 获取数据
-(void)loadHomeworkData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&label=%ld&page=%ld",kUserTokenValue,selectIndex+1,page];
    [TCHttpRequest postMethodWithURL:kJobMineAPI body:body success:^(id json) {
        NSArray *data = [json objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            HomeworkModel *model = [[HomeworkModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        if (page==1) {
            weakSelf.homeworksArray = tempArr;
        }else{
            [weakSelf.homeworksArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.homeworkTableView.mj_footer.hidden = data.count<20;
            weakSelf.blankView.hidden = weakSelf.homeworksArray.count>0;
            [weakSelf.homeworkTableView reloadData];
            [weakSelf.homeworkTableView.mj_header endRefreshing];
            [weakSelf.homeworkTableView.mj_footer endRefreshing];
        });
    }];
}

#pragma mark -- Getters and Setters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -200)/2, KStatusHeight, 200, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"作业检查",@"作业辅导"];
        _titleView.currentIndex = selectIndex;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark  辅导列表
-(UITableView *)homeworkTableView{
    if (!_homeworkTableView) {
        _homeworkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, kScreenWidth, kScreenHeight-kNavHeight-10) style:UITableViewStyleGrouped];
        _homeworkTableView.delegate = self;
        _homeworkTableView.dataSource = self;
        _homeworkTableView.showsVerticalScrollIndicator = NO;
        _homeworkTableView.estimatedSectionHeaderHeight=0;
        _homeworkTableView.estimatedSectionFooterHeight=0;
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewHomeworkListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _homeworkTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreHomeworkListData)];
        footer.automaticallyRefresh = NO;
        _homeworkTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _homeworkTableView;
}

#pragma mark 空白页
-(UIImageView *)blankView{
    if (!_blankView) {
        _blankView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2.0,70, 149, 127)];
        _blankView.image = [UIImage imageNamed:@"default_news"];
    }
    return _blankView;
}

#pragma mark 作业
-(NSMutableArray *)homeworksArray{
    if (!_homeworksArray) {
        _homeworksArray  = [[NSMutableArray alloc] init];
    }
    return _homeworksArray;
}


@end
