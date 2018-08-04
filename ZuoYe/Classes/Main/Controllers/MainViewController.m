//
//  MainViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic , strong) UIScrollView *rootScrollView;
@property (nonatomic , strong) UIView       *bannerView;        //广告位
@property (nonatomic , strong) UITableView  *orderTableView;    //需求订单列表
@property (nonatomic , strong) UIView       *releaseView;       //发布辅导需求
@property (nonatomic , strong) UITableView  *teacherTableView;  //老师列表

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"作业1对1";
    
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.bannerView];
    [self.view addSubview:self.releaseView];
    
    
    
}

#pragma mark -- Private Methods



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
-(UIView *)releaseView{
    
}







@end
