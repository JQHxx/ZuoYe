//
//  MyTabBarController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyTabBarController.h"
#import "MainViewController.h"
#import "TeacherViewController.h"
#import "MineViewController.h"
#import "BaseNavigationController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initMyTabBar];
    
}


#pragma mark -- Private Methods
- (void)initMyTabBar{
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavigationController * nav1 = [[BaseNavigationController alloc] initWithRootViewController:mainVC];
    UITabBarItem * mainItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[[UIImage imageNamed:@"ic_btn_h_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_h_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav1.tabBarItem = mainItem;
    
    TeacherViewController *teacherVC = [[TeacherViewController alloc] init];
    BaseNavigationController * nav2 = [[BaseNavigationController alloc] initWithRootViewController:teacherVC];
    UITabBarItem * teacherItem = [[UITabBarItem alloc] initWithTitle:@"老师" image:[[UIImage imageNamed:@"ic_btn_h_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_h_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav2.tabBarItem = teacherItem;
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    BaseNavigationController * nav3 = [[BaseNavigationController alloc] initWithRootViewController:mineVC];
    UITabBarItem * mineItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"ic_btn_h_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"ic_btn_h_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav3.tabBarItem = mineItem;
    
    self.viewControllers = @[nav1,nav2,nav3];
}



@end
