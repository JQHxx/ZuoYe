//
//  MainViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MainViewController.h"
#import "TakePicturesViewController.h"
#import "TeacherDetailsViewController.h"
#import "ConnectionSettingViewController.h"
#import "MessagesViewController.h"
#import "HomeworkViewController.h"
#import "HomeworkDetailsViewController.h"
#import "TeacherTableViewCell.h"
#import "TeacherModel.h"
#import "SlideMenuView.h"
#import "MyHomeworkView.h"
#import "HomeworkModel.h"

#import "STPopupController.h"
#import "CheckResultViewController.h"
#import "MyConnecttingViewController.h"
#import "TutorialViewController.h"

#define kCellHeight 85.0



@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,SlideMenuViewDelegate,UIScrollViewDelegate,MyHomeworkViewDelegate>{
    NSMutableArray   *teachersArray;
    NSArray          *titles;
    NSInteger        selectIndex;
}

@property (nonatomic , strong) UIImageView     *bgImageView;         //头部背景
@property (nonatomic , strong) UIView          *navBarView;          //导航栏
@property (nonatomic , strong) UIScrollView    *rootScrollView;
@property (nonatomic , strong) MyHomeworkView  *myHomeworkView;    //我的作业
@property (nonatomic , strong) UIView          *bannerView;            //广告位
@property (nonatomic , strong) UITableView     *teacherTableView;      //老师列表
@property (nonatomic , strong) SlideMenuView   *subjectsView;   //科目
@property (nonatomic , strong) SlideMenuView   *subjectsCoverView;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    
    teachersArray = [[NSMutableArray alloc] init];
//    titles = @[@"语文",@"数学",@"英语",@"物理",@"化学",@"生物",@"历史",@"地理",@"道德与法治"];
    titles = @[@"语文",@"数学",@"英语"];
    selectIndex = 0;
    
    [self initMainView];
    
    [self loadTeacherData];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TeacherModel *model = teachersArray[indexPath.row];
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.id = model.id;
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
    
    TakePicturesViewController *takePicturesVC = [[TakePicturesViewController alloc] init];
    takePicturesVC.isConnectionSetting = NO;
    takePicturesVC.hidesBottomBarWhenPushed = YES;
    takePicturesVC.type = sender.tag==0 ?TutoringTypeReview:TutoringTypeHelp;
    [self.navigationController pushViewController:takePicturesVC animated:YES];
}

#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectIndex = index;
    if (menuView == self.subjectsView) {
        self.subjectsCoverView.currentIndex = index;
    }else{
        self.subjectsView.currentIndex = index;
    }
}

#pragma mark MyHomeworkViewDelegate
#pragma mark 获取更多作业
-(void)myHomeworkViewDidShowMoreHomeworkAction{
    HomeworkViewController *homeworkVC = [[HomeworkViewController alloc] init];
    homeworkVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:homeworkVC animated:YES];
}

#pragma mark 选中作业
-(void)myHomeworkView:(MyHomeworkView *)homeworkView didSelectCellForHomework:(HomeworkModel *)model{
    HomeworkDetailsViewController *homeworkDetailsVC = [[HomeworkDetailsViewController alloc] init];
    homeworkDetailsVC.hidesBottomBarWhenPushed = YES;
    homeworkDetailsVC.homework = model;
    [self.navigationController pushViewController:homeworkDetailsVC animated:YES];
}

#pragma mark -- Event Response
#pragma mark 帮助
-(void)leftNavigationItemAction{
    /*
    CheckResultViewController *resultVC = [[CheckResultViewController alloc] init];
    
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:resultVC];
    popupVC.style = STPopupStyleFormSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
     
    
    
    MyConnecttingViewController *myConnecttingVC  = [[MyConnecttingViewController alloc] init];
    myConnecttingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myConnecttingVC animated:YES];
     
     */
    
    TutorialViewController *tutorialVC = [[TutorialViewController alloc] init];
    tutorialVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tutorialVC animated:YES];
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
    
    ConnectionSettingViewController  *connectionSettingVC = [[ConnectionSettingViewController alloc] init];
    connectionSettingVC.hidesBottomBarWhenPushed = YES;
    connectionSettingVC.teacherModel = model;
    [self.navigationController pushViewController:connectionSettingVC animated:YES];
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
    
}

#pragma mark -- Private Methods
#pragma mark LoadData
-(void)loadTeacherData{
    self.myHomeworkView.homeworkCount = 100;
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<10; i++) {
        HomeworkModel *model = [[HomeworkModel alloc] init];
        model.type = i%2;
        model.coverImage = @"zuoye";
        model.state = i%3;
        model.time_type = i%2;
        model.order_time = @"今天 12:30";
        model.grade = @"一年级";
        model.subject = @"数学";
        if (model.state>0) {
            TeacherModel *teacher = [[TeacherModel alloc] init];
            teacher.head = @"photo";
            teacher.name = @"小明老师";
            teacher.score = 4.0;
            teacher.grade = @"一年级";
            teacher.tech_stage = @"小学";
            teacher.subjects = @"数学";
            model.teacher = teacher;
        }
        [tempArr addObject:model];
    }
    self.myHomeworkView.homeworksArray  = tempArr;
    
    
    
    NSArray *names =@[@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小芳老师",@"王五老师",@"小芳老师",@"王五老师",@"小芳老师"];
    NSArray *levels = @[@"特级教师",@"高级教师",@"中级教师",@"初级教师",@"普通教师",@"初级教师",@"普通教师",@"初级教师",@"普通教师"];
    for (NSInteger i=0; i<names.count; i++) {
        TeacherModel *model = [[TeacherModel alloc] init];
        model.head = @"photo";
        model.name = names[i];
        model.level = levels[i];
        model.score = 5.0 - i*0.2;
        model.count = 1500 + i*50;
        model.price = 2.0 - 0.2*i;
        model.grade = @"一年级";
        model.subjects = @"数学";
        [teachersArray addObject:model];
    }
    [self.teacherTableView reloadData];
    self.teacherTableView.frame=CGRectMake(0, self.subjectsView.bottom, kScreenWidth, teachersArray.count*kCellHeight);
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherTableView.top+self.teacherTableView.height);
}

#pragma mark 初始化界面
-(void)initMainView{
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.navBarView];
    
    //作业检查和作业辅导
    NSArray *btnImages = @[@"home_coach",@"home_inspect"];
    NSArray *titles = @[@"作业检查",@"作业辅导"];
    CGFloat kCapWidth = kScreenWidth-2*102-2*56;
    for (NSInteger i=0; i<btnImages.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(56+(102+kCapWidth)*i,self.navBarView.bottom+24, 102, 133)];
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
    [self.rootScrollView addSubview:self.bannerView];
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
        [rightBtn setImage:[UIImage drawImageWithName:@"home_news" size:CGSizeMake(24, 24)] forState:UIControlStateNormal];
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
-(UIView *)bannerView{
    if (!_bannerView) {
        _bannerView = [[UIView alloc] initWithFrame:CGRectMake(13,0, kScreenWidth-26.0, (kScreenWidth-26.0)*(80.0/349.0))];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:_bannerView.bounds];
        imgView.image = [UIImage imageNamed:@"banner"];
        [_bannerView addSubview:imgView];
    }
    return _bannerView;
}

#pragma mark 我的作业
-(MyHomeworkView *)myHomeworkView{
    if (!_myHomeworkView) {
        _myHomeworkView = [[MyHomeworkView alloc] initWithFrame:CGRectMake(13, self.bannerView.bottom+10, kScreenWidth-26, 150)];
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
