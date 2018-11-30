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
#import "TutorialViewController.h"
#import "TutorialModel.h"
#import "SlideMenuView.h"
#import "PaySuccessViewController.h"
#import "ConnecttingViewController.h"
#import "MJRefresh.h"
#import "TeacherModel.h"
#import "CancelViewController.h"
#import "CommentViewController.h"
#import "RechargeViewController.h"

@interface MyTutorialViewController ()<UITableViewDataSource,UITableViewDelegate,SlideMenuViewDelegate,MyTutorialTableViewCellDelegate>{
    NSArray      *stateArray;
    NSArray      *cateArray;
    
    NSInteger    typeSelectIndex;
    NSInteger    orderSelectIndex;
    NSInteger    page;
}

@property (nonatomic, strong) SlideMenuView     *titleView;
@property (nonatomic, strong) SlideMenuView    *orderMenuView;
@property (nonatomic, strong) UITableView      *tutorialTableView;
@property (nonatomic ,strong) UIImageView       *blankView; //空白页

@property (nonatomic, strong) NSMutableArray   *orderListData;

@property (nonatomic, strong) KRVideoPlayerController *videoController;


@end

@implementation MyTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    stateArray = @[@"全部",@"进行中",@"待付款",@"已完成",@"已取消"];
    cateArray = @[@"all",@"doing",@"nopay",@"complete",@"cancel"];
    typeSelectIndex = 0;
    orderSelectIndex = 0;
    page = 1;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.orderMenuView];
    [self.view addSubview:self.tutorialTableView];
    [self.tutorialTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self loadMyTutorialData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZYHelper sharedZYHelper].isPayOrderSuccess) {
        [self loadMyTutorialData];
        [ZYHelper sharedZYHelper].isPayOrderSuccess = NO;
    }
    
    if ([ZYHelper sharedZYHelper].isUpdateOrder) {
        [self loadMyTutorialData];
        [ZYHelper sharedZYHelper].isUpdateOrder = NO;
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.orderListData.count;
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
    
    TutorialModel *model = self.orderListData[indexPath.section];
    cell.tutorial = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TutorialModel *model = self.orderListData[indexPath.section];
    if ([model.status integerValue]==0) {
        return 155;
    }else if ([model.status integerValue]==3){
        if ([model.label integerValue]<2) {
            return 125;
        }else{
            return 155;
        }
    }else{
       return  175;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TutorialModel *model = self.orderListData[indexPath.section];
    TutorialDetailsViewController *detailsVC = [[TutorialDetailsViewController alloc] init];
    detailsVC.orderId = model.oid;
    detailsVC.status = [model.status integerValue];
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    if (menuView == self.titleView) {
        typeSelectIndex = index;
        orderSelectIndex = 0;
        self.orderMenuView.currentIndex = orderSelectIndex;
    }else{
        orderSelectIndex = index;
    }
    [self loadNewOrderData];
}

#pragma mark MyTutorialTableViewCellDelegate
#pragma mark 去付款
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell payOrderActionWithTutorial:(TutorialModel *)model{
    TutorialPayViewController *payVC = [[TutorialPayViewController alloc] initWithIsOrderIn:YES];
    payVC.orderId = model.oid;
    payVC.duration = [model.job_time integerValue];
    payVC.guidePrice = model.price;
    payVC.label = [model.label integerValue]>1?2:1;
    payVC.payAmount = [model.pay_money doubleValue];
    kSelfWeak;
    payVC.backBlock = ^(id object) {
        if ([model.label integerValue]>1) {
            CommentViewController *commentVC = [[CommentViewController alloc] init];
            commentVC.orderId = model.oid;
            commentVC.tid = model.tch_id;
            [weakSelf.navigationController pushViewController:commentVC animated:YES];
        }else{
            PaySuccessViewController *paySuccessVC = [[PaySuccessViewController alloc] init];
            paySuccessVC.pay_amount = [object doubleValue];
            [weakSelf.navigationController pushViewController:paySuccessVC animated:YES];
        }
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark 重新连线
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell connectTeacherWithTutorial:(TutorialModel *)model{
    BOOL isOnline = [model.online boolValue];
    if (isOnline) {
        //老师信息
        TeacherModel *teacher = [[TeacherModel alloc] init];
        teacher.tch_id = model.tch_id;
        teacher.tch_name = model.name;
        teacher.trait = model.trait;
        teacher.grade = @[model.grade];
        teacher.subject = model.subject;
        teacher.third_id = model.third_id;
        
        kSelfWeak;
        if ([model.label integerValue]<2) { //作业检查连线老师
            teacher.guide_price = model.guide_price;
            NSString * imgJsonStr = [TCHttpRequest getValueWithParams:model.pics];
            NSString *body = [NSString stringWithFormat:@"token=%@&images=%@&tid=%@&price=%@",kUserTokenValue,imgJsonStr,model.tch_id,model.guide_price];
            [TCHttpRequest postMethodWithURL:kConnectSettingAPI body:body success:^(id json) {
                NSInteger status=[[json objectForKey:@"error"] integerValue];
                NSString *message=[json objectForKey:@"msg"];
                if (status==3) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        RechargeViewController *rechargeVC = [[RechargeViewController alloc] init];
                        [weakSelf.navigationController pushViewController:rechargeVC animated:YES];
                    });
                }else{
                    NSDictionary *data = [json objectForKey:@"data"];
                    teacher.job_pic = model.pics;
                    teacher.job_id = data[@"jobid"];
                    teacher.label = [NSNumber numberWithInteger:3];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:teacher.third_id];
                        connecttingVC.teacher = teacher;
                        connecttingVC.isOrderIn = NO;
                        [weakSelf.navigationController pushViewController:connecttingVC animated:YES];
                    });
                    
                }
            }];
        }else{ //作业辅导连线
            if ([model.status integerValue]==0) {
                teacher.guide_price = model.price;
                teacher.job_pic = model.job_pic;
                teacher.job_id = model.jobid;
                teacher.orderId = model.oid;
                teacher.label = model.label;
                ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:model.third_id];
                connecttingVC.teacher = teacher;
                connecttingVC.isOrderIn = YES;
                [self.navigationController pushViewController:connecttingVC animated:YES];
            }else{
                teacher.guide_price = model.guide_price;
                ConnectionSettingViewController  *connectionSettingVC = [[ConnectionSettingViewController alloc] init];
                connectionSettingVC.teacherModel = teacher;
                [self.navigationController pushViewController:connectionSettingVC animated:YES];
            }
        }
    }else{
        [self.view makeToast:@"老师当前不在线，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }
}


#pragma mark 取消订单
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell cancelOrderWithTutorial:(TutorialModel *)model{
    CancelViewController *cancelVC = [[CancelViewController alloc] init];
    cancelVC.jobid = model.jobid;
    cancelVC.myTitle = [model.label integerValue]<2?@"取消检查":@"取消辅导";
    cancelVC.type = [model.label integerValue]<2?CancelTypeOrderCheck:CancelTypeOrderCocah;
    [self.navigationController pushViewController:cancelVC animated:YES];
}

#pragma mark -- Event Response
-(void)swipOrderTableView:(UISwipeGestureRecognizer *)gesture{
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            orderSelectIndex++;
            if (orderSelectIndex>stateArray.count-1) {
                orderSelectIndex=stateArray.count;
                return;
            }
        }break;
        case UISwipeGestureRecognizerDirectionRight:
        {
            orderSelectIndex--;
            if (orderSelectIndex<0) {
                orderSelectIndex=0;
                return;
            }
        }
        default:
            break;
    }
    
    self.orderMenuView.currentIndex = orderSelectIndex;
    [self loadNewOrderData];
}


#pragma mark -- Private Methods
#pragma mark 加载最新数据
-(void)loadNewOrderData{
    page = 1;
    [self loadMyTutorialData];
}

#pragma mark 加载更多数据
-(void)loadMoreOrderData{
    page++;
    [self loadMyTutorialData];
}


#pragma mark 加载数据
-(void)loadMyTutorialData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&label=%ld&cate=%@&page=%ld",kUserTokenValue,typeSelectIndex+1,cateArray[orderSelectIndex],page];
    [TCHttpRequest postMethodWithURL:kOrderListAPI body:body success:^(id json) {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *ordersData = [json objectForKey:@"data"];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in ordersData) {
                TutorialModel *model = [[TutorialModel alloc] init];
                [model setValues:dict];
                [tempArr addObject:model];
            }
            if (page==1) {
                _orderListData = tempArr;
            }else{
                [_orderListData addObjectsFromArray:tempArr];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tutorialTableView.mj_footer.hidden = ordersData.count<20;
                weakSelf.blankView.hidden = _orderListData.count>0;
                [weakSelf.tutorialTableView reloadData];
                [weakSelf.tutorialTableView.mj_header  endRefreshing];
                [weakSelf.tutorialTableView.mj_footer endRefreshing];
            });
         });
    }];
}

#pragma mark -- getters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -200)/2, KStatusHeight, 200, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"作业检查",@"作业辅导"];
        _titleView.currentIndex = typeSelectIndex;
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
        _orderMenuView.currentIndex = orderSelectIndex;
        _orderMenuView.delegate = self;
        _orderMenuView.backgroundColor = [UIColor whiteColor];
    }
    return _orderMenuView;
}

#pragma mark  辅导列表
-(UITableView *)tutorialTableView{
    if (!_tutorialTableView) {
        _tutorialTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.orderMenuView.bottom+5, kScreenWidth, kScreenHeight-kNavHeight-55) style:UITableViewStyleGrouped];
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
        
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewOrderData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _tutorialTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreOrderData)];
        footer.automaticallyRefresh = NO;
        _tutorialTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _tutorialTableView;
}

#pragma mark 空白页
-(UIImageView *)blankView{
    if (!_blankView) {
        _blankView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2.0,70, 149, 127)];
        _blankView.image = [UIImage imageNamed:@"default_order"];
    }
    return _blankView;
}

#pragma mark 订单信息
-(NSMutableArray *)orderListData{
    if (!_orderListData) {
        _orderListData = [[NSMutableArray alloc] init];
    }
    return _orderListData;
}

#pragma mark 视屏播放
- (void)playVideoWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:self.view.bounds];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = url;
}



@end
