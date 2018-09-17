//
//  MyTutorialViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyTutorialViewController.h"
#import "TutorialDetailsViewController.h"
#import "MyTutorialTableViewCell.h"
#import "TutorialPayViewController.h"
#import "ConnectionSettingViewController.h"
#import "KRVideoPlayerController.h"
#import "STPopupController.h"
#import "TutorialModel.h"
#import "SlideMenuView.h"

@interface MyTutorialViewController ()<UITableViewDataSource,UITableViewDelegate,SlideMenuViewDelegate,MyTutorialTableViewCellDelegate>{
    NSArray      *stateArray;
    NSInteger    selectedIndex;
}

@property (nonatomic, strong)SlideMenuView     *titleView;
@property (nonatomic, strong) SlideMenuView    *orderMenuView;
@property (nonatomic, strong) UITableView      *tutorialTableView;

@property (nonatomic, strong) NSMutableArray   *checkArray;
@property (nonatomic, strong) NSMutableArray   *tutorialArray;

@property (nonatomic, strong) KRVideoPlayerController *videoController;


@end

@implementation MyTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    stateArray = @[@"全部",@"待付款",@"已完成",@"已取消"];
    selectedIndex = 0;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.orderMenuView];
    [self.view addSubview:self.tutorialTableView];
    
    [self loadMyTutorialData];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return selectedIndex==0?self.checkArray.count:self.tutorialArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MyTutorialTableViewCell";
    MyTutorialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTutorialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    TutorialModel *model = nil;
    if (selectedIndex==0) {
        model = self.checkArray[indexPath.section];
    }else{
        model = self.tutorialArray[indexPath.section];
    }
    cell.tutorial = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 175;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TutorialModel *model = nil;
    if (selectedIndex==0) {
        model = self.checkArray[indexPath.section];
    }else{
        model = self.tutorialArray[indexPath.section];
    }
    TutorialDetailsViewController *detailsVC = [[TutorialDetailsViewController alloc] init];
    detailsVC.myTutorial = model;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectedIndex = index;
    [self loadMyTutorialData];
}

#pragma mark MyTutorialTableViewCellDelegate
#pragma mark 去付款或连线老师
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell payOrderOrConnectTeacherWithTutorial:(TutorialModel *)model{
    if (model.state==0) {
        TutorialPayViewController *payVC = [[TutorialPayViewController alloc] init];
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    }else{
        ConnectionSettingViewController *connectSettingVC = [[ConnectionSettingViewController alloc] init];
        connectSettingVC.teacherModel = model.teacher;
        [self.navigationController pushViewController:connectSettingVC animated:YES];
    }
}

#pragma mark 回放
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell replayVideoWithTutorial:(TutorialModel *)model{
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    [self playVideoWithURL:videoURL];
}

#pragma mark -- Event Response
-(void)swipOrderTableView:(UISwipeGestureRecognizer *)gesture{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            selectedIndex++;
            if (selectedIndex>stateArray.count-1) {
                selectedIndex=stateArray.count;
                return;
            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            selectedIndex--;
            if (selectedIndex<0) {
                selectedIndex=0;
                return;
            }
        }
        default:
            break;
    }
    
    self.orderMenuView.currentIndex = selectedIndex;
}


#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadMyTutorialData{
    NSArray *names = @[@"小美老师",@"小芳老师",@"张三老师",@"李四老师",@"王五老师",@"赵六老师"];
    NSMutableArray *tempCheckArr = [[NSMutableArray alloc] init];
    NSMutableArray *tempTutorialArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<names.count; i++) {
        TutorialModel *model = [[TutorialModel alloc] init];
        model.type = i%2;
        model.datetime = [NSString stringWithFormat:@"2018-08-%02ld %02ld:%02ld",15+i,10+i,i*5];
        model.state = i%3;
        model.head_image = @"photo";
        model.name = names[i];
        model.level = @"高级教师";
        model.grade = @"一年级";
        model.subject = @"数学";
        model.check_price = (double)i*5+10;
        model.per_price = 1.0 + i*0.1;
        model.duration = 85+i*10;
        model.pay_price = (double)(i*15+5);
        model.order_sn = @"201878906547812";
        model.payway = i%3;
        model.video_cover = @"zuoye";
        model.payTime = [NSString stringWithFormat:@"2018-08-%02ld %02ld:%02ld",15+i,10+i,i*5];
        
        model.teacher.name = names[i];
        model.teacher.level = @"高级教师";
        model.teacher.grade = @"一年级";
        model.teacher.subjects = @"数学";
        
        if (model.type==0) {
          [tempCheckArr addObject:model];
        }else{
            [tempTutorialArr addObject:model];
        }
        
    }
    self.checkArray = tempCheckArr;
    self.tutorialArray = tempTutorialArr;
    [self.tutorialTableView reloadData];
}

#pragma mark -- getters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -200)/2, KStatusHeight, 200, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"作业检查",@"作业辅导"];
        _titleView.currentIndex = selectedIndex;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark 订单状态栏
-(SlideMenuView *)orderMenuView{
    if (!_orderMenuView) {
        _orderMenuView = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, kNavHeight+5, kScreenWidth, 40) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13] color:[UIColor colorWithHexString:@"#9B9B9B "] selColor:nil showLine:NO];
        _orderMenuView.myTitleArray = stateArray;
        _orderMenuView.currentIndex = 0;
        _orderMenuView.delegate = self;
        _orderMenuView.backgroundColor = [UIColor whiteColor];
    }
    return _orderMenuView;
}

#pragma mark  辅导列表
-(UITableView *)tutorialTableView{
    if (!_tutorialTableView) {
        _tutorialTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.orderMenuView.bottom+5, kScreenWidth, kScreenHeight-kNavHeight-45) style:UITableViewStyleGrouped];
        _tutorialTableView.delegate = self;
        _tutorialTableView.dataSource = self;
        _tutorialTableView.showsVerticalScrollIndicator = NO;
        _tutorialTableView.estimatedSectionHeaderHeight=0;
        _tutorialTableView.estimatedSectionFooterHeight=0;
        
        UISwipeGestureRecognizer *leftSwipGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipOrderTableView:)];
        leftSwipGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        [_tutorialTableView addGestureRecognizer:leftSwipGesture];
        
        UISwipeGestureRecognizer *rightSwipGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipOrderTableView:)];
        rightSwipGesture.direction = UISwipeGestureRecognizerDirectionRight;
        [_tutorialTableView addGestureRecognizer:rightSwipGesture];
    }
    return _tutorialTableView;
}

#pragma mark 检查信息
-(NSMutableArray *)checkArray{
    if (!_checkArray) {
        _checkArray = [[NSMutableArray alloc] init];
    }
    return _checkArray;
}

#pragma mark 辅导信息
-(NSMutableArray *)tutorialArray{
    if (!_tutorialArray) {
        _tutorialArray = [[NSMutableArray alloc] init];
    }
    return _tutorialArray;
}

#pragma mark 视屏播放
- (void)playVideoWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0,(kScreenHeight - kScreenWidth*(9.0/16.0))/2.0, kScreenWidth, kScreenWidth*(9.0/16.0))];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = url;
}



@end
