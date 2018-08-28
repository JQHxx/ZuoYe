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
#import "ItemGroupView.h"
#import "TutorialModel.h"

@interface MyTutorialViewController ()<UITableViewDataSource,UITableViewDelegate,ItemGroupViewDelegate,MyTutorialTableViewCellDelegate>{
    NSArray      *stateArray;
    NSInteger    selectedIndex;
}

@property (nonatomic, strong) ItemGroupView    *orderMenuView;

@property (nonatomic, strong) UITableView      *tutorialTableView;
@property (nonatomic, strong) NSMutableArray   *tutorialArray;

@property (nonatomic, strong) KRVideoPlayerController *videoController;


@end

@implementation MyTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的辅导";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    stateArray = @[@"全部",@"待付款",@"已完成",@"已取消"];
    selectedIndex = 0;
    
    [self.view addSubview:self.orderMenuView];
    [self.view addSubview:self.tutorialTableView];
    
    [self loadMyTutorialData];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.tutorialArray.count;
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
    
    TutorialModel *model = self.tutorialArray[indexPath.section];
    cell.tutorial = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 240;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TutorialModel *model = self.tutorialArray[indexPath.section];
    TutorialDetailsViewController *detailsVC = [[TutorialDetailsViewController alloc] init];
    detailsVC.myTutorial = model;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark ItemGroupViewDelegate
-(void)itemGroupView:(ItemGroupView *)groupView didClickActionWithIndex:(NSInteger)index{
    
}

#pragma mark MyTutorialTableViewCellDelegate
#pragma mark 去付款或连线老师
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell payOrderOrConnectTeacherWithTutorial:(TutorialModel *)model{
    
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
    
    UIButton *btn;
    for (UIView  *view in self.orderMenuView.subviews) {
        for (UIView *menuview in view.subviews) {
            if ([menuview isKindOfClass:[UIButton class]]&&(menuview.tag == selectedIndex+100)) {
                btn = (UIButton*)menuview;
            }
        }
    }
    [self.orderMenuView changeItemForSwipMenuAction:btn];
}

#pragma mark 去付款或连线老师
-(void)payOrderOrConnectTeacherAction:(UIButton *)sender{
    TutorialModel *model = self.tutorialArray[sender.tag];
    if (model.state==3) {
        TutorialPayViewController *payVC = [[TutorialPayViewController alloc] init];
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    }else{
        ConnectionSettingViewController *connectSettingVC = [[ConnectionSettingViewController alloc] init];
        [self.navigationController pushViewController:connectSettingVC animated:YES];
    }
    
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadMyTutorialData{
    NSArray *names = @[@"小美老师",@"小芳老师",@"张三老师",@"李四老师",@"王五老师",@"赵六老师"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<names.count; i++) {
        TutorialModel *model = [[TutorialModel alloc] init];
        model.type = i%2+1;
        model.datetime = [NSString stringWithFormat:@"2018-08-%02ld %02ld:%02ld",15+i,10+i,i*5];
        model.state = i%3+3;
        model.head_image = @"ic_m_head";
        model.name = names[i];
        model.level = @"高级教师";
        model.grade = @"一年级";
        model.subject = @"数学";
        model.check_price = (double)i*5+10;
        model.duration = 85+i*10;
        model.pay_price = (double)(i*15+5);
        [tempArr addObject:model];
    }
    self.tutorialArray = tempArr;
    [self.tutorialTableView reloadData];
}

#pragma mark -- getters
#pragma mark 订单状态栏
-(ItemGroupView *)orderMenuView{
    if (!_orderMenuView) {
        _orderMenuView = [[ItemGroupView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, 40) titles:stateArray];
        _orderMenuView.viewDelegate = self;
        _orderMenuView.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 39, kScreenWidth-10, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [_orderMenuView addSubview:lineView];
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

#pragma mark 我的辅导信息
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
