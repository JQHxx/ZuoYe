//
//  BillDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BillDetailsViewController.h"
#import "ContactServiceViewController.h"

@interface BillDetailsViewController ()

@end

@implementation BillDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"账单详情";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initBillDetailsView];
}

#pragma mark -- Event response
#pragma mark 联系客服
-(void)contactServiceAction:(UITapGestureRecognizer *)gesture{
    ContactServiceViewController *contactVC = [[ContactServiceViewController alloc] init];
    [self.navigationController pushViewController:contactVC animated:YES];
}

#pragma mark -- private methods
#pragma mark 初始化
-(void)initBillDetailsView{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavHeight+3.0, kScreenWidth, 360)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-56)/2.0, 30, 56, 56)];
    [topView addSubview:imgView];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, imgView.bottom+10, kScreenWidth-120, 22)];
    typeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    typeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
    typeLabel.textAlignment =NSTextAlignmentCenter;
    [topView addSubview:typeLabel];
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,typeLabel.bottom+10.0,kScreenWidth-120, 42)];
    amountLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:30];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:amountLabel];
    
    NSString *tempStr = nil;
    if (self.myBill.bill_type==0) {
        imgView.image = [UIImage imageNamed:@"bill_recharge"];
        typeLabel.text = @"充值";
        amountLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        tempStr = @"+";
    }else if (self.myBill.bill_type==1){
        imgView.image = [UIImage imageNamed:@"bill_inspect"];
        typeLabel.text = @"作业检查";
        amountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        tempStr = @"-";
    }else{
        imgView.image = [UIImage imageNamed:@"bill_coach"];
        typeLabel.text = @"作业辅导";
        amountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        tempStr = @"-";
    }
    amountLabel.text = [tempStr stringByAppendingString:[NSString stringWithFormat:@"¥%.2f",self.myBill.amount]];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(19.0,amountLabel.bottom+40.0, kScreenWidth-37.0, 0.5)];
    line2.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [topView addSubview:line2];
    
    NSString *payway =nil;
    if (self.myBill.pay_type==0) {
        payway = @"余额支付";
    }else if (self.myBill.pay_type==1){
        payway = @"微信支付";
    }else{
        payway = @"支付宝支付";
    }
    
    NSArray *titles = @[@"当前状态",@"支付方式",@"创建时间",@"交易单号"];
    NSArray *detailValues = @[self.myBill.state,payway,self.myBill.create_time,self.myBill.order_sn];
    for (NSInteger i=0; i<titles.count; i++) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, line2.bottom+13+i*(20+13), 60, 20)];
        titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        titleLabel.text = titles[i];
        [topView addSubview:titleLabel];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180, line2.bottom+13+i*(20+13),158, 20)];
        valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        valueLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        valueLabel.textAlignment = NSTextAlignmentRight;
        valueLabel.text = detailValues[i];
        [topView addSubview:valueLabel];
    }
    
    UIView *serviceView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.bottom+10.0, kScreenWidth, 45)];
    serviceView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:serviceView];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(28, 13, 60, 20)];
    lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
    lab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    lab.text = @"联系客服";
    [serviceView addSubview:lab];
    
    UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-35, 14, 8.2, 15)];
    arrowImgView.image = [UIImage imageNamed:@"arrow2_personal_information"];
    [serviceView addSubview:arrowImgView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:serviceView.bounds];
    [btn addTarget:self action:@selector(contactServiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [serviceView addSubview:btn];
}


@end
