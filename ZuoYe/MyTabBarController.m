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
#import "NSObject+Tool.h"
#import "BaseWebViewController.h"
#import "TutorialDetailsViewController.h"
#import "CheckResultViewController.h"
#import "STPopupController.h"
#import "HomeworkDetailsViewController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#B4B4B4"],NSFontAttributeName:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:10]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#FF7568"],NSFontAttributeName:[UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:10]} forState:UIControlStateSelected];
    
    [UITabBar appearance].translucent = NO;
    
    self.tabBar.barStyle = UIBarStyleDefault;
    [self setTabbarBackView];
    [self initMyTabBar];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrderCheckResult:) name:kOrderCheckSuccessNotification object:nil];
}



#pragma mark -- Private Methods
- (void)initMyTabBar{
    MainViewController *mainVC = [[MainViewController alloc] init];
    BaseNavigationController * nav1 = [[BaseNavigationController alloc] initWithRootViewController:mainVC];
    
    UITabBarItem * mainItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[[UIImage imageNamed:@"home_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"home"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav1 setTabBarItem:mainItem];
    
    TeacherViewController *teacherVC = [[TeacherViewController alloc] init];
    BaseNavigationController * nav2 = [[BaseNavigationController alloc] initWithRootViewController:teacherVC];
    UITabBarItem * teacherItem = [[UITabBarItem alloc] initWithTitle:@"老师" image:[[UIImage imageNamed:@"teacher_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"teacher"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav2 setTabBarItem:teacherItem];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    BaseNavigationController * nav3 = [[BaseNavigationController alloc] initWithRootViewController:mineVC];
    UITabBarItem * mineItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"my_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"my"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav3 setTabBarItem:mineItem];
    
    self.viewControllers = @[nav1,nav2,nav3];
}


-(void)setTabbarBackView{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kTabHeight)];
    backView.backgroundColor = [UIColor whiteColor];
    // 去除顶部横线
    [self.tabBar insertSubview:backView atIndex:0];
    self.tabBar.opaque = YES;
}

#pragma mark -- 作业检查结果推送
-(void)showOrderCheckResult:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];

    CheckResultViewController *checkResultVC = [[CheckResultViewController alloc] init];
    checkResultVC.oid = userInfo[@"oid"];
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:checkResultVC];
    popupVC.style = STPopupStyleFormSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}


#pragma mark - public methods
#pragma mark 处理消息推送
-(void)handerUserNotificationWithUserInfo:(NSDictionary *)userInfo{
    if (kIsDictionary(userInfo)&&userInfo.count>0) {
        BaseViewController *controller = (BaseViewController *)[self currentViewController];
        NSString *type = [userInfo valueForKey:@"cate"];
        if (!kIsEmptyString(type)) {
            if ([type isEqualToString:@"sys"]||[type isEqualToString:@"check"]) {
                NSNumber *mid = [userInfo valueForKey:@"mid"];
                [self setMessageReadWithMid:mid type:type];
            }
            
            if ([type isEqualToString:@"sys"]) {
                BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
                webVC.urlStr = userInfo[@"oid"];
                webVC.webTitle = @"系统消息详情";
                webVC.hidesBottomBarWhenPushed = YES;
                [controller.navigationController pushViewController:webVC animated:YES];
            }else if ([type isEqualToString:@"check"]){
                CheckResultViewController *checkResultVC = [[CheckResultViewController alloc] init];
                checkResultVC.oid = userInfo[@"oid"];
                STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:checkResultVC];
                popupVC.style = STPopupStyleFormSheet;
                popupVC.navigationBarHidden = YES;
                [popupVC presentInViewController:self];
            }else if ([type isEqualToString:@"checkAccept"]){ //作业检查接单或作业辅导实时接单或取消订单
                TutorialDetailsViewController *tutorialDetailsVC = [[TutorialDetailsViewController alloc] init];
                tutorialDetailsVC.orderId = userInfo[@"oid"];
                tutorialDetailsVC.hidesBottomBarWhenPushed = YES;
                [controller.navigationController pushViewController:tutorialDetailsVC animated:YES];
            }else if ([type isEqualToString:@"guidePreAccept"]){//作业辅导预约接单
                HomeworkDetailsViewController *tutorialDetailsVC = [[HomeworkDetailsViewController alloc] init];
                tutorialDetailsVC.jobId = userInfo[@"oid"];
                tutorialDetailsVC.label = [NSNumber numberWithInteger:2];
                tutorialDetailsVC.isReceived = YES;
                tutorialDetailsVC.hidesBottomBarWhenPushed = YES;
                [controller.navigationController pushViewController:tutorialDetailsVC animated:YES];
            }
        }
    }
}

#pragma mark  设置消息已读
-(void)setMessageReadWithMid:(NSNumber *)mid type:(NSString *)type{
    NSString *body = [NSString stringWithFormat:@"token=%@&cate=%@&mid=%@",kUserTokenValue,type,mid];
    [TCHttpRequest postMethodWithoutLoadingForURL:kMessageReadAPI body:body success:^(id json) {
        
    }];
}

-(void)dealloc{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kOrderCheckSuccessNotification object:nil];
}

@end
