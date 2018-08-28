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

@interface MyWalletViewController (){
    UILabel   *totalAmountLabel;
}

@property (nonatomic ,strong ) UIView *headerView;
@property (nonatomic ,strong ) UIView *precautionsView; //注意事项

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的钱包";
    self.rigthTitleName = @"账单";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.precautionsView];
    
}

#pragma mark -- Event Response
#pragma mark 账单
-(void)rightNavigationItemAction{
    BillViewController *billVC = [[BillViewController alloc] init];
    [self.navigationController pushViewController:billVC animated:YES];
}

#pragma mark 充值
-(void)rechargeForAccountAction:(UIButton *)sender{
    RechargeViewController *rechargeVC = [[RechargeViewController alloc] init];
    [self.navigationController pushViewController:rechargeVC animated:YES];
}

#pragma mark -- Getters and Setters
#pragma mark 头部视图
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, 120)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 30)];
        accountLabel.text = @"账户余额（元）";
        accountLabel.font = kFontWithSize(16);
        accountLabel.textColor = [UIColor darkGrayColor];
        [_headerView addSubview:accountLabel];
        
        totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, accountLabel.bottom+10, 200, 40)];
        totalAmountLabel.font = [UIFont boldSystemFontOfSize:48];
        totalAmountLabel.textColor = [UIColor redColor];
        totalAmountLabel.text = @"1234.00";
        [_headerView addSubview:totalAmountLabel];
        
        UIButton *rechargeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-90, 60, 80, 35)];
        [rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [rechargeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        rechargeButton.layer.cornerRadius = 5;
        rechargeButton.layer.borderColor = [UIColor blackColor].CGColor;
        rechargeButton.layer.borderWidth = 1;
        [rechargeButton addTarget:self action:@selector(rechargeForAccountAction:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:rechargeButton];
    }
    return _headerView;
}

#pragma mark 注意事项
-(UIView *)precautionsView{
    if (!_precautionsView) {
        _precautionsView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, kScreenWidth-100, 30)];
        titleLab.text = @"注意事项";
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = kFontWithSize(16);
        [_precautionsView addSubview:titleLab];
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.numberOfLines = 0;
        descLabel.font = kFontWithSize(14);
        descLabel.text = @"1、如果你无法简洁的表达你的想法，那只说明你还不够了解它。\n2、如果你无法简洁的表达你的想法，那只说明你还不够了解它。";
        CGFloat height = [descLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) withTextFont:descLabel.font].height;
        descLabel.frame = CGRectMake(0, titleLab.bottom+10, kScreenWidth-40, height+10);
        [_precautionsView addSubview:descLabel];
        
        _precautionsView.frame = CGRectMake(20, self.headerView.bottom+30, kScreenWidth-40, height+60);
        
    }
    return _precautionsView;
}



@end
