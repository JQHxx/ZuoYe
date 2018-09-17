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

@interface MyWalletViewController ()

@property (nonatomic , strong) UIImageView  *bgImageView;     //头部背景
@property (nonatomic , strong) UIView       *navBarView;      //导航栏
@property (nonatomic , strong) UILabel      *totalAmountLabel;     //余额
@property (nonatomic , strong) UIButton     *rechargeButton;
@property (nonatomic ,strong ) UIView *precautionsView; //注意事项

@end

@implementation MyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMyWalletView];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initMyWalletView{
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.navBarView];
    
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.navBarView.bottom+18.0, kScreenWidth-100, 30)];
    accountLabel.text = @"账户余额（元）";
    accountLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    accountLabel.textColor = [UIColor whiteColor];
    accountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:accountLabel];
    
    [self.view addSubview:self.totalAmountLabel];
    [self.view addSubview:self.rechargeButton];
    [self.view addSubview:self.precautionsView];
}


#pragma mark -- Setters and Getters
#pragma mark 头部背景图
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*(243.0/375.0))];
        _bgImageView.image = [UIImage imageNamed:@"wallet_background"];
    }
    return _bgImageView;
}

#pragma mark 导航栏
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
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
        
        UIButton *rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, KStatusHeight+10, 32, 22)];
        [rightBtn setTitle:@"账单" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:rightBtn];
    }
    return _navBarView;
}

#pragma mark 余额
-(UILabel *)totalAmountLabel{
    if (!_totalAmountLabel) {
        _totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, self.navBarView.bottom+42.0,kScreenWidth-100, 48)];
        _totalAmountLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:34];
        _totalAmountLabel.textColor = [UIColor whiteColor];
        _totalAmountLabel.textAlignment = NSTextAlignmentCenter;
        _totalAmountLabel.text = @"1088.50";
    }
    return _totalAmountLabel;
}

#pragma mark 充值
-(UIButton *)rechargeButton{
    if (!_rechargeButton) {
        _rechargeButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth -103)/2.0,self.totalAmountLabel.bottom+19.0,103, 33)];
        [_rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [_rechargeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rechargeButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _rechargeButton.layer.cornerRadius = 2;
        _rechargeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _rechargeButton.layer.borderWidth = 1;
        [_rechargeButton addTarget:self action:@selector(rechargeForAccountAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rechargeButton;
}

#pragma mark 注意事项
-(UIView *)precautionsView{
    if (!_precautionsView) {
        _precautionsView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth-100, 30)];
        titleLab.text = @"注意事项";
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_precautionsView addSubview:titleLab];
        
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.numberOfLines = 0;
        descLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
        descLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        descLabel.text = @"1、如果你无法简洁的表达你的想法，那只说明你还不够了解它。\n2、如果你无法简洁的表达你的想法，那只说明你还不够了解它。";
        CGFloat height = [descLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-40, CGFLOAT_MAX) withTextFont:descLabel.font].height;
        descLabel.frame = CGRectMake(0, titleLab.bottom+10, kScreenWidth-40, height+10);
        [_precautionsView addSubview:descLabel];
        
        _precautionsView.frame = CGRectMake(20, self.bgImageView.bottom+22, kScreenWidth-40, height+60);
        
    }
    return _precautionsView;
}

@end
