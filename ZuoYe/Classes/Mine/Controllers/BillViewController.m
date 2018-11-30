//
//  BillViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BillViewController.h"
#import "TransactionTypeViewController.h"
#import "BillDetailsViewController.h"
#import "STPopupController.h"
#import "BillTableViewCell.h"
#import "BillModel.h"
#import "NSDate+Extension.h"
#import "MJRefresh.h"

@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger       page;
    NSInteger       label; //1 作业检查 2 作业辅导 3充值 4全部
    
    NSMutableArray  *billArray;
    NSMutableArray  *monthsArray;
}

@property (nonatomic, strong) UITableView          *billTableView;
@property (nonatomic, strong) NSMutableDictionary  *billData;

@property (nonatomic ,strong) UIImageView       *blankView; //空白页

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"账单";
    
    self.rigthTitleName = @"筛选";
    page = 1;
    
    billArray = [[NSMutableArray alloc] init];
    monthsArray = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.billTableView];
    [self.billTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    
    label = 4;
    
    [self loadBillData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return monthsArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *values =[self.billData valueForKey:monthsArray[section]];
    return values.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return monthsArray[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BillTableViewCell";
    BillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BillTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    NSArray *values =[self.billData valueForKey:monthsArray[indexPath.section]];
    BillModel *model = values[indexPath.row];
    cell.myBill = model;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSArray *values =[self.billData valueForKey:monthsArray[indexPath.section]];
    BillModel *model = values[indexPath.row];
    BillDetailsViewController *billDetailsVC = [[BillDetailsViewController alloc] init];
    billDetailsVC.myBill = model;
    [self.navigationController pushViewController:billDetailsVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

#pragma mark -- Event Response
#pragma mark 筛选
-(void)rightNavigationItemAction{
    TransactionTypeViewController *transactionTypeVC = [[TransactionTypeViewController alloc] init];
    transactionTypeVC.transationType = label;
    kSelfWeak;
    transactionTypeVC.backBlock = ^(id object) {
        label = [object integerValue];
        [weakSelf loadNewBillData];
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:transactionTypeVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark 加载最新数据
-(void)loadNewBillData{
    page = 1;
    [self loadBillData];
}

#pragma mark 加载更多数据
-(void)loadMoreBillData{
    page++;
    [self loadBillData];
}

#pragma mark 加载账单数据
-(void)loadBillData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&page=%ld&label=%ld",kUserTokenValue,page,label];
    [TCHttpRequest postMethodWithURL:kWalletBillAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        NSArray *billArr = [data valueForKey:@"bill"];
        
        MyLog(@"bill-- count:%ld",billArr.count);
        
        NSArray *monthArr = [data valueForKey:@"month"];
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO];
        NSArray *descriptors = [NSArray arrayWithObject:descriptor];
        NSArray *sortedMonthArray = [monthArr sortedArrayUsingDescriptors:descriptors];
        
        if (page==1) {
            billArray = [NSMutableArray arrayWithArray:billArr];
            monthsArray = [NSMutableArray arrayWithArray:sortedMonthArray];
        }else{
            [billArray addObjectsFromArray:billArr];
            for (NSString *monthStr in sortedMonthArray) {  //去重
                if (![monthsArray containsObject:monthStr]) {
                    [monthsArray addObject:monthStr];
                }
            }
        }
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        for (NSString *monthStr in monthsArray) {
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in billArray) {
                BillModel *model = [[BillModel alloc] init];
                [model setValues:dict];
                NSString *payTime = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.pay_time format:@"yyyy年MM月"];
                if ([payTime isEqualToString:monthStr]) {
                    [tempArr addObject:model];
                }
            }
            [tempDict setObject:tempArr forKey:monthStr];
        }
        self.billData = tempDict;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.billTableView.mj_footer.hidden = billArr.count<20;
            weakSelf.blankView.hidden = self.billData.count>0;
            [weakSelf.billTableView reloadData];
            [weakSelf.billTableView.mj_header endRefreshing];
            [weakSelf.billTableView.mj_header endRefreshing];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 账单列表
-(UITableView *)billTableView{
    if (!_billTableView) {
        _billTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStyleGrouped];
        _billTableView.delegate = self;
        _billTableView.dataSource = self;
        _billTableView.estimatedSectionHeaderHeight = 0;
        _billTableView.estimatedSectionFooterHeight = 0;
        _billTableView.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewBillData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _billTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreBillData)];
        footer.automaticallyRefresh = NO;
        _billTableView.mj_footer = footer;
        footer.hidden=YES;
    }
    return _billTableView;
}

#pragma mark 空白页
-(UIImageView *)blankView{
    if (!_blankView) {
        _blankView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2.0,70, 149, 127)];
        _blankView.image = [UIImage imageNamed:@"default_bill"];
    }
    return _blankView;
}

#pragma mark 账单数据
-(NSMutableDictionary *)billData{
    if (!_billData) {
        _billData = [[NSMutableDictionary alloc] init];
    }
    return _billData;
}


@end
