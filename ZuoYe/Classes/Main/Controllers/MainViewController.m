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

#import "ReleaseView.h"
#import "TeacherTableViewCell.h"
#import "ItemGroupView.h"
#import "TeacherModel.h"

@interface MainViewController ()<ReleaseViewDelegate,UITableViewDelegate,UITableViewDataSource,ItemGroupViewDelegate,UIScrollViewDelegate>{
    NSMutableArray   *teachersArray;
    NSArray          *titles;
    NSInteger        selectIndex;
}

@property (nonatomic , strong) UIScrollView *rootScrollView;
@property (nonatomic , strong) UIView       *bannerView;        //广告位
@property (nonatomic , strong) UITableView  *orderTableView;    //需求订单列表
@property (nonatomic , strong) ReleaseView  *releaseView;       //发布辅导需求
@property (nonatomic , strong) UITableView  *teacherTableView;  //老师列表

@property (nonatomic , strong) ItemGroupView *subjectsView;   //科目
@property (nonatomic , strong) ItemGroupView *subjectsCoverView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenBackBtn = YES;
    self.baseTitle = @"作业101";
    self.rightImageName=@"h_ic_top_msg_nor";
    
    teachersArray = [[NSMutableArray alloc] init];
//    titles = @[@"语文",@"数学",@"英语",@"物理",@"化学",@"生物"];
    titles = @[@"语文",@"数学",@"英语"];
    selectIndex = 0;
    
    [self initMainView];
    
    [self loadTeacherData];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return teachersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TeacherTableViewCell";
    TeacherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TeacherTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TeacherModel *model = teachersArray[indexPath.row];
    [cell appleDataForCellWithTeacher:model];
    
    cell.connectButton.tag = indexPath.row;
    [cell.connectButton addTarget:self action:@selector(connectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0;
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
        self.subjectsCoverView.hidden = scrollView.contentOffset.y<self.releaseView.bottom;
    }
}


#pragma mark -- Custom Delegate
#pragma mark ReleaseViewDelegate
-(void)releaseViewDidReleasedHomeworkRecomandWithTag:(NSInteger)tag{
    MyLog(@"辅导类型：%@",tag==0?@"作业检查":@"作业辅导");
    
    TakePicturesViewController *takePicturesVC = [[TakePicturesViewController alloc] init];
    takePicturesVC.isConnectionSetting = NO;
    takePicturesVC.hidesBottomBarWhenPushed = YES;
    takePicturesVC.type = tag==0 ?TutoringTypeReview:TutoringTypeHelp;
    [self.navigationController pushViewController:takePicturesVC animated:YES];
}

#pragma mark ItemGroupViewDelegate
-(void)itemGroupView:(ItemGroupView *)groupView didClickActionWithIndex:(NSInteger)index{
    MyLog(@"didClickActionWithIndex");
    
    selectIndex = index -100;
    
    UIButton *btn;
    if (groupView == self.subjectsView) {
        for (UIView  *view in self.subjectsCoverView.subviews) {
            for (UIView *menuview in view.subviews) {
                if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == index)) {
                    btn = (UIButton*)menuview;
                }
            }
        }
        [self.subjectsCoverView changeItemForSwipMenuAction:btn];
    }else{
        for (UIView  *view in self.subjectsView.subviews) {
            for (UIView *menuview in view.subviews) {
                if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == index)) {
                    btn = (UIButton*)menuview;
                }
            }
        }
        [self.subjectsView changeItemForSwipMenuAction:btn];
    }
}

#pragma mark -- Event Response
#pragma mark 消息
-(void)rightNavigationItemAction{
    MessagesViewController *messagesVC = [[MessagesViewController alloc] init];
    messagesVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messagesVC animated:YES];
}

#pragma mark 连线老师
-(void)connectTeacherAction:(UIButton *)sender{
    ConnectionSettingViewController  *connectionSettingVC = [[ConnectionSettingViewController alloc] init];
    connectionSettingVC.hidesBottomBarWhenPushed = YES;
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
    
    UIButton *btn;
    for (UIView  *view in self.subjectsView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.subjectsView changeItemForSwipMenuAction:btn];
    
    for (UIView  *view in self.subjectsCoverView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == selectIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.subjectsCoverView changeItemForSwipMenuAction:btn];
    
}


#pragma mark -- Private Methods
#pragma mark LoadData
-(void)loadTeacherData{
    NSArray *names =@[@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小芳老师",@"王五老师",@"小芳老师",@"王五老师",@"小芳老师"];
    NSArray *levels = @[@"特级教师",@"高级教师",@"中级教师",@"初级教师",@"普通教师",@"初级教师",@"普通教师",@"初级教师",@"普通教师"];
    for (NSInteger i=0; i<names.count; i++) {
        TeacherModel *model = [[TeacherModel alloc] init];
        model.head = @"ic_m_head";
        model.name = names[i];
        model.level = levels[i];
        model.score = 5.0 - i*0.2;
        model.count = 1500 + i*50;
        model.price = 2.0 - 0.2*i;
        [teachersArray addObject:model];
    }
    [self.teacherTableView reloadData];
    self.teacherTableView.frame=CGRectMake(0, self.subjectsView.bottom+1, kScreenWidth, teachersArray.count*95);
    self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.teacherTableView.top+self.teacherTableView.height+kTabHeight+kNavHeight);
}

-(void)initMainView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.bannerView];
    [self.rootScrollView addSubview:self.releaseView];
    [self.rootScrollView addSubview:self.subjectsView];
    [self.rootScrollView addSubview:self.teacherTableView];
    
    [self.view addSubview:self.subjectsCoverView];
    self.subjectsCoverView.hidden = YES;
}

#pragma mark -- Setters and Getters
#pragma mark 根滚动视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight)];
        _rootScrollView.showsVerticalScrollIndicator=NO;
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        _rootScrollView.delegate = self;
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

#pragma mark 科目
-(ItemGroupView *)subjectsView{
    if (!_subjectsView) {
        _subjectsView = [[ItemGroupView alloc] initWithFrame:CGRectMake(0, self.releaseView.bottom+10, kScreenWidth, 40) titles:titles];
        _subjectsView.viewDelegate = self;
        _subjectsView.backgroundColor = [UIColor whiteColor];
    }
    return _subjectsView;
}

#pragma mark 科目悬浮层
-(ItemGroupView *)subjectsCoverView{
    if (!_subjectsCoverView) {
        _subjectsCoverView = [[ItemGroupView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, 40) titles:titles];
        _subjectsCoverView.viewDelegate = self;
        _subjectsCoverView.backgroundColor = [UIColor whiteColor];
    }
    return _subjectsCoverView;
}

#pragma mark 老师列表
-(UITableView *)teacherTableView{
    if (!_teacherTableView) {
        _teacherTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.subjectsView.bottom+1, kScreenWidth, kScreenHeight-self.subjectsView.bottom-1-kTabHeight) style:UITableViewStylePlain];
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
