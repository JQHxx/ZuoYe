//
//  MainViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MainViewController.h"
#import "TeacherDetailsViewController.h"
#import "ConnectionSettingViewController.h"
#import "MessagesViewController.h"
#import "HomeworkViewController.h"
#import "HomeworkDetailsViewController.h"
#import "STPopupController.h"
#import "CheckResultViewController.h"
#import "MessagesViewController.h"
#import "UserHelpViewController.h"
#import "BaseWebViewController.h"
#import "TakePhotoViewController.h"
#import "BaseNavigationController.h"
#import "SDCycleScrollView.h"
#import "SlideMenuView.h"
#import "MyHomeworkView.h"
#import "TeacherTableViewCell.h"
#import "TeacherModel.h"
#import "HomeworkModel.h"
#import "BannerModel.h"

#define kCellHeight 85.0

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,SlideMenuViewDelegate,UIScrollViewDelegate,MyHomeworkViewDelegate,SDCycleScrollViewDelegate,UITabBarControllerDelegate>{
    NSMutableArray   *bannersArray;   //广告位
    NSMutableArray   *teachersArray;  //老师信息
    
    NSArray          *titles;
    NSInteger        selectIndex;
}

@property (nonatomic , strong) UILabel         *badgeLabel;          //红点
@property (nonatomic , strong) UIImageView     *bgImageView;         //头部背景
@property (nonatomic , strong) UIView          *navBarView;          //导航栏
@property (nonatomic , strong) UIScrollView    *rootScrollView;
@property (nonatomic ,strong) SDCycleScrollView *bannerScrollView; //广告图
@property (nonatomic , strong) MyHomeworkView  *myHomeworkView;    //我的作业
@property (nonatomic , strong) UITableView     *teacherTableView;      //老师列表
@property (nonatomic , strong) SlideMenuView   *subjectsView;   //科目
@property (nonatomic , strong) SlideMenuView   *subjectsCoverView;



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    bannersArray = [[NSMutableArray alloc] init];
    teachersArray = [[NSMutableArray alloc] init];
    titles = @[@"语文",@"数学",@"英语"];
    selectIndex = 0;
    
    self.tabBarController.delegate = self;

    
    [self initMainView];
    
    [self loadHomeAllData];
    [self loadUnReadMessageData];
    [self loadMyWalletData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"首页"];
    
    if ([ZYHelper sharedZYHelper].isUpdateHome) {
        [self refreshHomeData];
        [ZYHelper sharedZYHelper].isUpdateHome = NO;
    }
    if ([ZYHelper sharedZYHelper].isUpdateMessageUnread) {
        [self loadUnReadMessageData];
        [ZYHelper sharedZYHelper].isUpdateMessageUnread = NO;
    }
    
    if ([ZYHelper sharedZYHelper].isRechargeSuccess) {
        [self loadMyWalletData];
        [ZYHelper sharedZYHelper].isRechargeSuccess = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeData) name:kHomeworkAcceptNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHomeData) name:kGuideCancelNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"首页"];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHomeworkAcceptNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGuideCancelNotification object:nil];
    
}

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
    TeacherModel *model = teachersArray[indexPath.row];
    [cell applyDataForCellWithTeacher:model];
    
    cell.connectButton.tag = indexPath.row;
    [cell.connectButton addTarget:self action:@selector(connectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 25, 0, 26)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TeacherModel *model = teachersArray[indexPath.row];
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.tch_id = model.tch_id;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.rootScrollView) {
        if (scrollView.contentOffset.y>self.myHomeworkView.bottom+10) {
            self.subjectsCoverView.hidden = NO;
            self.subjectsView.hidden = YES;
        }else{
            self.subjectsCoverView.hidden = YES;
            self.subjectsView.hidden = NO;
        }
    }
}


#pragma mark -- Custom Delegate
#pragma mark ReleaseViewDelegate
-(void)releaseZuoyeOrderAction:(UIButton *)sender{
    MyLog(@"辅导类型：%@",sender.tag==0?@"作业检查":@"作业辅导");
    
    TakePhotoViewController *takePhotosVC = [[TakePhotoViewController alloc] init];
    takePhotosVC.isConnectionSetting = NO;
    takePhotosVC.type = sender.tag==0 ?TutoringTypeReview:TutoringTypeHelp;
    takePhotosVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:takePhotosVC animated:YES];
}

#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectIndex = index;
    if (menuView == self.subjectsView) {
        self.subjectsCoverView.currentIndex = index;
    }else{
        self.subjectsView.currentIndex = index;
    }
    [self loadTeachersData];
}

#pragma mark MyHomeworkViewDelegate
#pragma mark 获取更多作业
-(void)myHomeworkViewDidShowMoreHomeworkAction{
    HomeworkViewController *homeworkVC = [[HomeworkViewController alloc] init];
    homeworkVC.hidesBottomBarWhenPushed =YES;
    [self.navigationController pushViewController:homeworkVC animated:YES];
}

#pragma mark 选中作业
-(void)myHomeworkView:(MyHomeworkView *)homeworkView didSelectCellForHomework:(HomeworkModel *)model{
    HomeworkDetailsViewController *homeworkDetailsVC = [[HomeworkDetailsViewController alloc] init];
    homeworkDetailsVC.jobId = model.job_id;
    homeworkDetailsVC.label = model.label;
    homeworkDetailsVC.isReceived = [model.is_receive integerValue]==2;
    homeworkDetailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:homeworkDetailsVC animated:YES];
}

#pragma mark SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    BannerModel *banner = bannersArray[index];
    NSInteger bannerCate = [banner.cate integerValue];
    if (bannerCate==1) {
        BaseWebViewController *webVC = [[BaseWebViewController alloc] init];
        webVC.urlStr = banner.url;
        webVC.webTitle = banner.name;
        webVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webVC animated:YES];
    }else if(bannerCate==2){
        NSString *url=banner.url;
        UIApplication *application = [UIApplication sharedApplication];
        NSURL *URL = [NSURL URLWithString:url];
        if (@available(iOS 10.0, *)) {
            [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                MyLog(@"iOS10 Open %@: %d",url,success);
            }];
        } else {
            // Fallback on earlier versions
            BOOL success = [application openURL:URL];
            MyLog(@"Open %@: %d",url,success);
        }
    }
}


#pragma mark - UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([tabBarController.selectedViewController isEqual:[tabBarController.viewControllers firstObject]]) {
        // 判断再次选中的是否为当前的控制器
        if ([viewController isEqual:tabBarController.selectedViewController]) {
            // 执行操作
            selectIndex = 0;
            self.subjectsView.currentIndex = selectIndex;
            self.subjectsCoverView.currentIndex = selectIndex;
            [self loadHomeAllData];
            return NO;
        }
    }
    return YES;
}

#pragma mark -- Event Response
#pragma mark 帮助
-(void)leftNavigationItemAction{
  
    UserHelpViewController *userHelpVC = [[UserHelpViewController alloc] init];
    userHelpVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userHelpVC animated:YES];
     
}

#pragma mark 消息
-(void)rightNavigationItemAction{
    MessagesViewController *messagesVC = [[MessagesViewController alloc] init];
    messagesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messagesVC animated:YES];
}

#pragma mark 连线老师
-(void)connectTeacherAction:(UIButton *)sender{
    TeacherModel *model = teachersArray[sender.tag];
    if ([model.online boolValue]) {
        ConnectionSettingViewController  *connectionSettingVC = [[ConnectionSettingViewController alloc] init];
        connectionSettingVC.hidesBottomBarWhenPushed = YES;
        connectionSettingVC.teacherModel = model;
        [self.navigationController pushViewController:connectionSettingVC animated:YES];
    }else{
        [self.view makeToast:@"老师当前不在线，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark 滑动切换菜单
-(void)swipTeacherTableView:(UISwipeGestureRecognizer *)gesture{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            selectIndex++;
            if (selectIndex>titles.count-1) {
                selectIndex=titles.count;
                return;
            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            selectIndex--;
            if (selectIndex<0) {
                selectIndex=0;
                return;
            }
        }
        default:
            break;
    }
    self.subjectsView.currentIndex = selectIndex;
    self.subjectsCoverView.currentIndex = selectIndex;
     [self loadTeachersData];
}

#pragma mark notification
#pragma mark 刷新首页
-(void)refreshHomeData{
    selectIndex = 0;
    self.subjectsView.currentIndex = selectIndex;
    self.subjectsCoverView.currentIndex = selectIndex;
    
    [self loadHomeAllData];
}

#pragma mark -- Private Methods
#pragma mark LoadData
-(void)loadHomeAllData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithURL:kHomeAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        
        //佣金百分比
        NSNumber  *tchPercent = [data valueForKey:@"tchPercent"];
        [NSUserDefaultsInfos putKey:kTchPercent andValue:tchPercent];
        
        NSNumber *highPercent = [data valueForKey:@"highPercent"];
        [NSUserDefaultsInfos putKey:kHighPercent andValue:highPercent];
        
        //广告图
        NSArray *bannerList = [data objectForKey:@"banner"];
         NSMutableArray *tempBannerImgArr  = [[NSMutableArray alloc] init];
        if (kIsArray(bannerList)&&bannerList.count>0) {
            NSMutableArray *tempBannerArr = [[NSMutableArray alloc] init];
            for (NSDictionary *bannerDict in bannerList) {
                BannerModel *banner = [[BannerModel alloc] init];
                [banner setValues:bannerDict];
                [tempBannerArr addObject:banner];
                [tempBannerImgArr addObject:banner.pic];
            }
            bannersArray = tempBannerArr;
            
         }
        
        //我的作业
        NSArray *homeworksArr = [data objectForKey:@"job"];
        NSMutableArray *homeworktTempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in homeworksArr) {
            HomeworkModel *homework = [[HomeworkModel alloc] init];
            [homework setValues:dict];
            [homeworktTempArr addObject:homework];
        }

        //老师
        NSArray *teachers = [data objectForKey:@"teacher"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in teachers) {
            TeacherModel *model = [[TeacherModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        teachersArray = tempArr;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.bannerScrollView.imageURLStringsGroup = tempBannerImgArr;
            if (bannersArray.count>0) {
                weakSelf.bannerScrollView.frame = CGRectMake(13, 0, kScreenWidth-26.0, (kScreenWidth-26.0)*(80.0/349.0));
            }else{
                weakSelf.bannerScrollView.frame = CGRectZero;
            }
            
            weakSelf.myHomeworkView.homeworkCount = [[data valueForKey:@"count"] integerValue];
            weakSelf.myHomeworkView.homeworksArray  = homeworktTempArr;
            CGFloat tempH = 0.0;
            if (homeworktTempArr.count>0) {
                weakSelf.myHomeworkView.hidden = NO;
                weakSelf.myHomeworkView.frame = CGRectMake(13, self.bannerScrollView.bottom+10, kScreenWidth-26, 150);
                tempH = self.bannerScrollView.bottom+20+150;
            }else{
                weakSelf.myHomeworkView.hidden = YES;
                weakSelf.myHomeworkView.frame = CGRectMake(13, self.bannerScrollView.bottom, kScreenWidth-26, 0);
                tempH =  self.bannerScrollView.bottom+10;
            }
            weakSelf.subjectsView.frame = CGRectMake(0, tempH, kScreenWidth, 45.0);
            weakSelf.subjectsCoverView.frame = CGRectMake(0, self.navBarView.bottom+196, kScreenWidth, 45.0);
            [weakSelf.teacherTableView reloadData];
            weakSelf.teacherTableView.frame=CGRectMake(0, self.subjectsView.bottom, kScreenWidth, teachersArray.count*kCellHeight);
            weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherTableView.top+self.teacherTableView.height);
            
        });
    }];
}

#pragma mark 获取老师信息
-(void)loadTeachersData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&subject=%ld",kUserTokenValue,selectIndex+1];
    [TCHttpRequest postMethodWithURL:kHomeTeachersAPI body:body success:^(id json) {
        NSArray *teachersData = [json objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in teachersData) {
            TeacherModel *model = [[TeacherModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        teachersArray = tempArr;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.teacherTableView reloadData];
            weakSelf.teacherTableView.frame=CGRectMake(0, self.subjectsView.bottom, kScreenWidth, teachersArray.count*kCellHeight);
            weakSelf.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherTableView.top+self.teacherTableView.height);
        });
    }];
}

#pragma mark 获取未读消息信息
-(void)loadUnReadMessageData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithoutLoadingForURL:kMessageUnreadAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        NSInteger count = [[data valueForKey:@"count"] integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.badgeLabel.hidden = count<1;
        });
    }];
}

#pragma mark 获取我的钱包信息
-(void)loadMyWalletData{
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithoutLoadingForURL:kWalletMineAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        NSNumber *credit = [data valueForKey:@"credit"];
        MyLog(@"mycredit:%.2f",[credit doubleValue]);
        if (!kIsEmptyObject(credit)) {
            [NSUserDefaultsInfos putKey:kUserCredit andValue:credit];
        }
    }];
}

#pragma mark 初始化界面
-(void)initMainView{
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.badgeLabel];
    self.badgeLabel.hidden = YES;
    
    //作业检查和作业辅导
    NSArray *btnImages = @[@"home_inspect",@"home_coach"];
    NSArray *titles = @[@"作业检查",@"作业辅导"];
    CGFloat kCapWidth = (kScreenWidth-2*102-60)/2.0;
    for (NSInteger i=0; i<btnImages.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kCapWidth+(102+60)*i,self.navBarView.bottom+24, 102, 133)];
        [btn setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:20];
        btn.imageEdgeInsets = UIEdgeInsetsMake(-(btn.height - btn.titleLabel.height- btn.titleLabel.frame.origin.y-31),0, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(btn.imageView.height+btn.imageView.frame.origin.y, -btn.imageView.width, 0, 0);
        
        btn.tag = i;
        [btn addTarget:self action:@selector(releaseZuoyeOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.bannerScrollView];
    [self.rootScrollView addSubview:self.myHomeworkView];
    [self.rootScrollView addSubview:self.subjectsView];
    [self.rootScrollView addSubview:self.teacherTableView];
    [self.view addSubview:self.subjectsCoverView];
    self.subjectsCoverView.hidden = YES;
}

#pragma mark -- Setters and Getters
#pragma mark 头部背景图
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.image = [UIImage imageNamed:@"background1"];
    }
    return _bgImageView;
}

#pragma mark 红色标记
-(UILabel *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-22, KStatusHeight+7, 8, 8)];
        _badgeLabel.boderRadius = 4.0;
        _badgeLabel.backgroundColor = [UIColor colorWithHexString:@"#F50000"];
    }
    return _badgeLabel;
}

#pragma mark 导航栏
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UIButton *leftBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [leftBtn setImage:[UIImage drawImageWithName:@"home_using_help"size:CGSizeMake(24, 24)] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:leftBtn];
        
        UILabel  *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, KStatusHeight, 180, 44)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text = @"作业101";
        [_navBarView addSubview:titleLabel];
        
        UIButton *rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, KStatusHeight+2, 40, 40)];
        [rightBtn setImage:[UIImage drawImageWithName:@"home_news" size:CGSizeMake(30, 24)] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:rightBtn];
    }
    return _navBarView;
}

#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navBarView.bottom+196, kScreenWidth, kScreenHeight-self.navBarView.bottom-196-kTabHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor = [UIColor clearColor];
        _rootScrollView.delegate = self;
    }
    return _rootScrollView;
}

#pragma mark 广告位
-(SDCycleScrollView *)bannerScrollView{
    if (!_bannerScrollView) {
        _bannerScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(13, 0, kScreenWidth-26.0, (kScreenWidth-26.0)*(80.0/349.0)) delegate:self placeholderImage:[UIImage imageNamed:@"banner_default"]];
        _bannerScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        _bannerScrollView.autoScrollTimeInterval = 4;
        _bannerScrollView.currentPageDotColor = kSystemColor;
        _bannerScrollView.boderRadius = 6.0;
        _bannerScrollView.pageDotColor = [UIColor lightGrayColor];
    }
    return _bannerScrollView;
}

#pragma mark 我的作业
-(MyHomeworkView *)myHomeworkView{
    if (!_myHomeworkView) {
        _myHomeworkView = [[MyHomeworkView alloc] initWithFrame:CGRectMake(13, self.bannerScrollView.bottom+10, kScreenWidth-26, 150)];
        _myHomeworkView.viewDelegete = self;
    }
    return _myHomeworkView;
}

#pragma mark 科目
-(SlideMenuView *)subjectsView{
    if (!_subjectsView) {
        _subjectsView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, self.myHomeworkView.bottom+10, kScreenWidth, 45.0) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:16] color:[UIColor colorWithHexString:@"#808080"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:YES];
        _subjectsView.isShowUnderLine = YES;
        _subjectsView.btnCapWidth = 30;
        _subjectsView.myTitleArray = titles;
        _subjectsView.currentIndex = 0;
        _subjectsView.delegate = self;
        _subjectsView.backgroundColor = [UIColor whiteColor];
        _subjectsView.topBoderRadius = 8.0;
    }
    return _subjectsView;
}

#pragma mark 科目悬浮层
-(SlideMenuView *)subjectsCoverView{
    if (!_subjectsCoverView) {
        _subjectsCoverView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, self.navBarView.bottom+196, kScreenWidth, 45.0) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:16] color:[UIColor colorWithHexString:@"#808080"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:YES];
        _subjectsCoverView.isShowUnderLine = YES;
        _subjectsCoverView.btnCapWidth = 30;
        _subjectsCoverView.delegate = self;
        _subjectsCoverView.myTitleArray = titles;
        _subjectsCoverView.currentIndex = 0;
        _subjectsCoverView.backgroundColor = [UIColor whiteColor];
        _subjectsCoverView.topBoderRadius = 8.0;
    }
    return _subjectsCoverView;
}

#pragma mark 老师列表
-(UITableView *)teacherTableView{
    if (!_teacherTableView) {
        _teacherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.subjectsView.bottom, kScreenWidth, self.rootScrollView.height-self.subjectsView.bottom) style:UITableViewStylePlain];
        _teacherTableView.delegate = self;
        _teacherTableView.dataSource = self;
        _teacherTableView.showsVerticalScrollIndicator = NO;
        _teacherTableView.scrollEnabled = NO;
        _teacherTableView.backgroundColor = [UIColor bgColor_Gray];
        
        UISwipeGestureRecognizer *swipGestureLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipTeacherTableView:)];
        swipGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [_teacherTableView addGestureRecognizer:swipGestureLeft];
        
        UISwipeGestureRecognizer *swipGestureRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipTeacherTableView:)];
        swipGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [_teacherTableView addGestureRecognizer:swipGestureRight];
    }
    return _teacherTableView;
}

@end
