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

@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  *billMonthArr;
}

@property (nonatomic, strong) UITableView     *billTableView;
@property (nonatomic, strong) NSMutableArray  *billData;

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"账单";
    
    self.rigthTitleName = @"筛选";
    
    billMonthArr = [NSDate getDatesForNumberMonth:12 WithFromDate:[NSDate date]];
    
    [self.view addSubview:self.billTableView];
    
    [self loadBillData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return billMonthArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.billData.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return billMonthArr[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BillTableViewCell";
    BillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BillTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    BillModel *model = self.billData[indexPath.row];
    cell.myBill = model;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BillModel *model = self.billData[indexPath.row];
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
    transactionTypeVC.backBlock = ^(id object) {
        NSString *typeStr = (NSString *)object;
        MyLog(@"bill -- type：%@",typeStr);
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:transactionTypeVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark 加载账单数据
-(void)loadBillData{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSArray *amounts = @[@"5.00",@"20.35",@"200.00",@"5.00",@"23.00",@"54.50",@"65.25"];
    for (NSInteger i=0; i<amounts.count; i++) {
        BillModel *model = [[BillModel alloc] init];
        model.bill_type = i%3;
        model.pay_type = i/2;
        model.create_time = [NSString stringWithFormat:@"8月%02ld %02ld:%02ld:%2ld",22-i,10+i%3,20+i,10+i*3];
        model.amount = [amounts[i] doubleValue];
        model.state = @"交易成功";
        model.order_sn = @"20180903823844";
        [tempArr addObject:model];
    }
    self.billData = tempArr;
    [self.billTableView reloadData];
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
    }
    return _billTableView;
}

#pragma mark 账单数据
-(NSMutableArray *)billData{
    if (!_billData) {
        _billData = [[NSMutableArray alloc] init];
    }
    return _billData;
}


@end
