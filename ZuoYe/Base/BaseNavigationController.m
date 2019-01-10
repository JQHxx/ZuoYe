//
//  BaseNavigationController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.tintColor=[UIColor whiteColor];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7.0) {
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]];
    }
}


/*
#pragma mark 跳转
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //1. 取出分栏
    UITabBar *tabBar = self.tabBarController.tabBar;
    
    // 将frame下移分栏的宽度
    CGRect frame = tabBar.frame;
    frame.origin.y += tabBar.frame.size.height;
    
    // 动画影藏tabBar
    [UIView animateWithDuration:0.25 animations:^{
        tabBar.frame = frame;
    }];
    
    [super pushViewController:viewController animated:animated];
 
}


-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    //1. 取出分栏
    UITabBar *tabBar = self.tabBarController.tabBar;
    
    // 将frame上移分栏的宽度
    CGRect frame = tabBar.frame;
    frame.origin.y -= tabBar.frame.size.height;
    
    // 动画影藏tabBar
    [UIView animateWithDuration:0.25 animations:^{
        tabBar.frame = frame;
    }];
    
    return [super popViewControllerAnimated:animated];
}
*/



@end
