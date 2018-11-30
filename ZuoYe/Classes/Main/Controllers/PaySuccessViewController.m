//
//  PaySuccessViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/26.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PaySuccessViewController.h"
#import "MyWalletViewController.h"
#import "MyTutorialViewController.h"

@interface PaySuccessViewController ()

@property (nonatomic,strong) UIView   *bottomView;

@end

@implementation PaySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.isRechargeSuccess?@"充值成功":@"付款成功";
    
    [self initPaySuccessView];
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    for (BaseViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MyWalletViewController class]]) {
            [ZYHelper sharedZYHelper].isRechargeSuccess = YES;
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
        if ([controller isKindOfClass:[MyTutorialViewController class]]) {
            [ZYHelper sharedZYHelper].isPayOrderSuccess = YES;
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

#pragma mark 初始化界面
-(void)initPaySuccessView{
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-149)/2, kNavHeight+66, 149, 120)];
    imgView.image = [UIImage imageNamed:@"images_payment"];
    [self.view addSubview:imgView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(100, imgView.bottom+20, kScreenWidth-200, 25)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = self.isRechargeSuccess?@"充值成功":@"付款成功";
    lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
    lab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    [self.view addSubview:lab];
    
    UILabel *payLab = [[UILabel alloc] initWithFrame:CGRectMake(30, lab.bottom+5, kScreenWidth-60, 21)];
    payLab.textAlignment = NSTextAlignmentCenter;
    payLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
    payLab.textColor = [UIColor colorWithHexString:@"#808080"];
    payLab.text = [NSString stringWithFormat:@"付款金额：¥%.2f",self.pay_amount];
    [self.view addSubview:payLab];
    
}





@end
