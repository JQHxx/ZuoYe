//
//  MainViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MainViewController.h"
#import "TakePicturesViewController.h"

#import "ReleaseView.h"
#import "TeacherTableViewCell.h"

@interface MainViewController ()<ReleaseViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *teachersArray;
}

@property (nonatomic , strong) UIScrollView *rootScrollView;
@property (nonatomic , strong) UIView       *bannerView;        //广告位
@property (nonatomic , strong) UITableView  *orderTableView;    //需求订单列表
@property (nonatomic , strong) ReleaseView  *releaseView;       //发布辅导需求
@property (nonatomic , strong) UITableView  *teacherTableView;  //老师列表

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenBackBtn = YES;
    self.baseTitle = @"作业1对1";
    
    teachersArray = [[NSMutableArray alloc] init];
    
    [self initMainView];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return teachersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TeacherTableViewCell";
    TeacherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TeacherTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    return cell;
}


#pragma mark -- Custom Delegate
#pragma mark ReleaseViewDelegate
-(void)releaseViewDidReleasedHomeworkRecomandWithTag:(NSInteger)tag{
    MyLog(@"辅导类型：%@",tag==0?@"作业检查":@"作业辅导");
    TakePicturesViewController *takePicturesVC = [[TakePicturesViewController alloc] init];
    takePicturesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:takePicturesVC animated:YES];
}


#pragma mark -- Private Methods
-(void)initMainView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.bannerView];
    [self.rootScrollView addSubview:self.releaseView];
}



#pragma mark -- Setters and Getters
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight)];
        _rootScrollView.showsHorizontalScrollIndicator=NO;
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark 广告位
-(UIView *)bannerView{
    if (!_bannerView) {
        _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        _bannerView.backgroundColor = [UIColor whiteColor];
    }
    return _bannerView;
}

#pragma mark 发布辅导需求
-(ReleaseView *)releaseView{
    if (!_releaseView) {
        _releaseView = [[ReleaseView alloc] initWithFrame:CGRectMake(0, self.bannerView.bottom+10, kScreenWidth, 150)];
        _releaseView.delegate = self;
    }
    return _releaseView;
}

#pragma mark 老师列表
-(UITableView *)teacherTableView{
    if (!_teacherTableView) {
        _teacherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.releaseView.bottom+10, kScreenWidth, kScreenHeight-self.releaseView.bottom-10) style:UITableViewStylePlain];
        _teacherTableView.delegate = self;
        _teacherTableView.dataSource = self;
    }
    return _teacherTableView;
}

@end
