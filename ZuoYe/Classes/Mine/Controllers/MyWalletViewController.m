//
//  MyWalletViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyWalletViewController.h"
#import "BillViewController.h"
#import "RechargeViewController.h"
#import "BillDetailsViewController.h"
#import "TransactionTypeViewController.h"
#import "STPopupController.h"
#import "CustomDatePickerView.h"
#import "BillHeaderView.h"
#import "BillTableViewCell.h"
#import "MJRefresh.h"
#import "BillModel.h"
#import "NSDate+Extension.h"

@interface MyWalletViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,BillHeaderViewDelegate>{
    UILabel   *balanceLabel; //账户余额
    UILabel   *creditLabel; //可用余额
    
    NSInteger label; //1检查2辅导3充值4全部
    NSInteger page;
    NSString  *dateStr;
}

@property (nonatomic ,strong) UIScrollView   *rootScrollView;
@property (nonatomic ,strong) UIView         *navBarView;     //导航栏
@property (nonatomic ,strong) UIView         *balanceView;
@property (nonatomic ,strong) UITableView    *detailsTableView;  //明细
@property (nonatomic ,strong) BillHeaderView *headerView;
@property (nonatomic ,strong) BillHeaderView *headerCoverView;

@property (nonatomic ,strong) UIImageView       *blankView; //空白页

@property (nonatomic, strong) NSMutableArray  *detailsData;

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    page = 1;
    label = 4;
    
    self.isHiddenNavBar = YES;
    
    [self initMyWalletView];
    [self loadMyWalletInfo];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZYHelper sharedZYHelper].isRechargeSuccess) {
        [self loadMyWalletInfo];
        [ZYHelper sharedZYHelper].isRechargeSuccess = NO;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.detailsData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BillTableViewCell";
    BillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BillTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    BillModel *model = self.detailsData[indexPath.row];
    cell.myBill = model;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BillModel *model = self.detailsData[indexPath.row];
    
    BillDetailsViewController *billDetailsVC = [[BillDetailsViewController alloc] init];
    billDetailsVC.myBill = model;
    [self.navigationController pushViewController:billDetailsVC animated:YES];
}

#pragma mark -- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.rootScrollView) {
        if (self.rootScrollView.contentOffset.y > self.balanceView.bottom) {
            self.headerCoverView.hidden = NO;
        }else{
            self.headerCoverView.hidden = YES;
        }
    }
}

#pragma mark -- BillHeaderViewDelegate
-(void)billHeaderView:(BillHeaderView *)headerView didFilterForTag:(NSInteger)tag{
    if (tag==0) { //筛选
        TransactionTypeViewController *transactionTypeVC = [[TransactionTypeViewController alloc] init];
        transactionTypeVC.transationType = label;
        kSelfWeak;
        transactionTypeVC.backBlock = ^(id object) {
            dateStr = nil;
            label = [object integerValue];
            [weakSelf loadNewDetailsData];
        };
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:transactionTypeVC];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    }else{ // 时间
        kSelfWeak;
        NSString *currentMonth = kIsEmptyString(dateStr)?[NSDate currentYearMonth]:dateStr;
        [CustomDatePickerView showDatePickerWithTitle:@"选择时间" defauldValue:currentMonth minDateStr:@"2018-08" maxDateStr:[NSDate currentYearMonth] resultBlock:^(NSString *selectValue) {
            MyLog(@"selectValue:%@",selectValue);
            label = 4;
            dateStr = selectValue;
            [weakSelf loadNewDetailsData];
        }];
    }
}

#pragma mark -- Event Response
#pragma mark 充值
-(void)rechargeForAccountAction:(UIButton *)sender{
    RechargeViewController *rechargeVC = [[RechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initMyWalletView{
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.navBarView];
    [self.rootScrollView addSubview:self.balanceView];
    [self.rootScrollView addSubview:self.detailsTableView];
    self.detailsTableView.tableHeaderView = self.headerView;
    self.balanceView.hidden = self.detailsTableView.hidden = YES;
    
    [self.rootScrollView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    [self.view addSubview:self.headerCoverView];
    self.headerCoverView.hidden = YES;

}

#pragma mark 加载最新明细数据
-(void)loadNewDetailsData{
    page=1;
    [self loadMyWalletInfo];
}

-(void)loadMoreDetailsData{
    page++;
    [self loadMyWalletInfo];
}

#pragma mark 获取账户余额
-(void)loadMyWalletInfo{
    kSelfWeak;
    NSString *body = kIsEmptyString(dateStr)?[NSString stringWithFormat:@"token=%@&label=%ld&page=%ld",kUserTokenValue,label,page]:[NSString stringWithFormat:@"token=%@&label=%ld&page=%ld&date=%@",kUserTokenValue,label,page,dateStr];
    [TCHttpRequest postMethodWithURL:kWalletBillAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        
        //余额和可用余额
        NSDictionary *userInfo = [data valueForKey:@"userinfo"];
        NSNumber *balance = [userInfo valueForKey:@"money"];
        NSNumber *credit = [userInfo valueForKey:@"credit"];
        double amount = [balance doubleValue];
        if (!kIsEmptyObject(credit)) {
            [NSUserDefaultsInfos putKey:kUserCredit andValue:credit];
        }
        
        //明细
        NSArray *details = [data valueForKey:@"bill"];  //明细
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in details) {
            BillModel *model = [[BillModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        if (page==1) {
            weakSelf.detailsData = tempArr;
        }else{
            [weakSelf.detailsData addObjectsFromArray:tempArr];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.balanceView.hidden = weakSelf.detailsTableView.hidden = NO;
            
             balanceLabel.text = [NSString stringWithFormat:@"%.2f",amount];
            creditLabel.text = [NSString stringWithFormat:@"%.2f",[credit doubleValue]];
            weakSelf.rootScrollView.mj_footer.hidden = details.count<20;
            weakSelf.blankView.hidden = data.count>0&&details.count>0;
            [weakSelf.detailsTableView reloadData];
            weakSelf.detailsTableView.frame = CGRectMake(0, self.balanceView.bottom, kScreenWidth, tempArr.count*68+46);
            weakSelf.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.detailsTableView.top+self.detailsTableView.height);
            [weakSelf.rootScrollView.mj_header endRefreshing];
            [weakSelf.rootScrollView.mj_footer endRefreshing];
        });
    }];
}


#pragma mark -- Setters and Getters
#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.delegate = self;
        
        if (@available(iOS 11.0, *)) {
            _rootScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDetailsData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _rootScrollView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDetailsData)];
        footer.automaticallyRefresh = NO;
        _rootScrollView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _rootScrollView;
}

#pragma mark 账户信息
-(UIView *)balanceView{
    if (!_balanceView) {
        _balanceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 180)];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:_balanceView.bounds];
        bgImageView.image = [UIImage imageNamed:@"wallet_background"];
        [_balanceView addSubview:bgImageView];
        
        NSArray *titles = @[@"账户余额（元）",@"可用余额（元）"];
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(kScreenWidth/2.0)*i,20.0, kScreenWidth/2.0-20, 40)];
            valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:28];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.textAlignment = NSTextAlignmentCenter;
            [_balanceView addSubview:valueLabel];
            if (i==0) {
                balanceLabel = valueLabel;
            }else{
                creditLabel = valueLabel;
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+(kScreenWidth/2.0)*i,valueLabel.bottom, kScreenWidth/2.0-20, 20)];
            titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = titles[i];
            [_balanceView addSubview:titleLabel];
        }
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2.0, 30, 0.5, 50)];
        line.backgroundColor = [UIColor whiteColor];
        [_blankView addSubview:line];
        
        UIButton *rechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-185.0)/2.0, balanceLabel.bottom+60, 185, 33)];
        rechargeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        rechargeBtn.layer.borderWidth = 1.0;
        rechargeBtn.layer.cornerRadius = 2.0;
        [rechargeBtn setTitle:@"充值" forState:UIControlStateNormal];
        [rechargeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rechargeBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [rechargeBtn addTarget:self action:@selector(rechargeForAccountAction:) forControlEvents:UIControlEventTouchUpInside];
        [_balanceView addSubview:rechargeBtn];
    }
    return _balanceView;
}

#pragma mark 导航栏
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        _navBarView.backgroundColor = [UIColor colorWithHexString:@"#FF6161"];
        
        UIButton *leftBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [leftBtn setImage:[UIImage drawImageWithName:@"return_white"size:CGSizeMake(10, 17)] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:leftBtn];
        
        UILabel  *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, KStatusHeight, 180, 44)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text = @"我的钱包";
        [_navBarView addSubview:titleLabel];
        
    }
    return _navBarView;
}

#pragma mark 明细
-(UITableView *)detailsTableView{
    if (!_detailsTableView) {
        _detailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.balanceView.bottom, kScreenWidth, kScreenHeight-self.balanceView.bottom) style:UITableViewStylePlain];
        _detailsTableView.delegate = self;
        _detailsTableView.dataSource = self;
        _detailsTableView.showsVerticalScrollIndicator = NO;
        _detailsTableView.scrollEnabled = NO;
        _detailsTableView.estimatedSectionHeaderHeight = 0;
        _detailsTableView.estimatedSectionFooterHeight = 0;
        _detailsTableView.tableFooterView = [[UIView alloc] init];
        
    }
    return _detailsTableView;
}

#pragma mark 明细头部视图
-(BillHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[BillHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 46)];
        _headerView.delegate = self;
    }
    return _headerView;
}

#pragma mark 明细头部视图
-(BillHeaderView *)headerCoverView{
    if (!_headerCoverView) {
        _headerCoverView = [[BillHeaderView alloc] initWithFrame:CGRectMake(0,kNavHeight, kScreenWidth, 46)];
        _headerCoverView.delegate = self;
    }
    return _headerCoverView;
}

#pragma mark 空白页
-(UIImageView *)blankView{
    if (!_blankView) {
        _blankView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2.0,self.balanceView.bottom+90, 149, 127)];
        _blankView.image = [UIImage imageNamed:@"default_bill"];
    }
    return _blankView;
}

#pragma mark 账单数据
-(NSMutableArray *)detailsData{
    if (!_detailsData) {
        _detailsData = [[NSMutableArray alloc] init];
    }
    return _detailsData;
}


@end
