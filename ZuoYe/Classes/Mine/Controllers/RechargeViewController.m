//
//  RechargeViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RechargeViewController.h"
#import "PaywayView.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "NSDate+Extension.h"
#import "PaySuccessViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DecimalTextInput.h"

@interface RechargeViewController ()<UITextFieldDelegate>{
    UIView         *amountTextView;
    
    NSArray        *amountArray;
    NSInteger      selectedIndex;
    UIButton       *selectItem;
    NSInteger      payway;
    double         amount;
    
    BOOL           isEditing;
}

@property (nonatomic, strong) DecimalTextInput   *amountTextField;
@property (nonatomic, strong) PaywayView    *wepaywayView;    //微信支付
@property (nonatomic, strong) PaywayView    *alipaywayView;   //支付宝支付
@property (nonatomic, strong) UIButton      *confirmButton;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"充值";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    amountArray = @[@"10",@"20",@"50",@"100",@"150",@"200"];
    payway = 0;
    
    [self initRechargeView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rechargePaySuccessAction) name:kPayBackNotification object:nil];
}

#pragma mark -- UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    amount = 0;
    isEditing = YES;
    [self cancelClickItemAction];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
   
    if (self.amountTextField==textField) {
        if ([textField.text length]<6) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event reponse
#pragma mark 选择支付方式
-(void)choosePaymentAction:(UIButton *)sender{
    isEditing = NO;
    if (sender.tag==100) {
        self.wepaywayView.isSelected = YES;
        self.alipaywayView.isSelected = NO;
    }else{
        self.wepaywayView.isSelected = NO;
        self.alipaywayView.isSelected = YES;
    }
    payway = sender.tag-100;
}

#pragma mark  确认充值
-(void)confirmRechargeAction:(UIButton *)sender{
    if (!isEditing) {
        amount = [amountArray[selectedIndex] doubleValue];
    }else{
        amount = [self.amountTextField.text doubleValue];
    }
    
    if (amount<0.01) {
        [self.view makeToast:@"请设置充值金额" duration:1.0 position:CSToastPositionCenter];
    }
    
    if (payway==0) {   //微信支付
        NSString *body = [NSString stringWithFormat:@"token=%@&cate=2&from=iOS&money=%.2f",kUserTokenValue,amount];
        [TCHttpRequest postMethodWithURL:kWalletRechargeAPI body:body success:^(id json) {
            NSDictionary *payInfo =[json objectForKey:@"data"];
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [payInfo valueForKey:@"appid"];
            req.partnerId           = [payInfo valueForKey:@"partnerid"];
            req.prepayId            = [payInfo valueForKey:@"prepayid"];
            req.nonceStr            = [payInfo valueForKey:@"noncestr"];
            req.timeStamp           = [[payInfo valueForKey:@"timestamp"] intValue];
            req.package             = [payInfo valueForKey:@"package"];
            req.sign                = [payInfo valueForKey:@"sign"];
            
            [WXApi sendReq:req];
        }];
    }else{ //支付宝支付
        kSelfWeak;
        NSString *body = [NSString stringWithFormat:@"token=%@&cate=1&from=iOS&money=%.2f",kUserTokenValue,amount];
        [TCHttpRequest postMethodWithURL:kWalletRechargeAPI body:body success:^(id json) {
            NSString *payInfo =[json objectForKey:@"data"];
            [[AlipaySDK defaultService] payOrder:payInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [weakSelf rechargePaySuccessAction];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"alipay--error:%@",memo);
                }
            }];
        }];
    }
}

#pragma mark 选择充值金额
-(void)itemClickAction:(UIButton *)sender{
    self.amountTextField.text = @"";
    [self.amountTextField resignFirstResponder];
    
    if (selectItem) {
        selectItem.selected = NO;
        selectItem.layer.borderColor = [[UIColor colorWithHexString:@"#B4B4B4"] CGColor];
        selectItem.backgroundColor = [UIColor whiteColor];
    }
    
    sender.selected = YES;
    sender.layer.borderColor = [UIColor redColor].CGColor;
    sender.backgroundColor = [UIColor redColor];
    selectItem = sender;
    selectedIndex = sender.tag;
}

#pragma mark -- Notification
#pragma mark 充值成功
-(void)rechargePaySuccessAction{
    PaySuccessViewController *paySuccessVC = [[PaySuccessViewController alloc] init];
    paySuccessVC.isRechargeSuccess = YES;
    paySuccessVC.isMyWalletIn = self.isMyWalletIn;
    paySuccessVC.pay_amount = amount;
    [self.navigationController pushViewController:paySuccessVC animated:YES];
}

#pragma mark -- private methods
#pragma mark 初始化界面
-(void)initRechargeView{
    UIView *amountView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavHeight+5, kScreenWidth, 205)];
    amountView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:amountView];
    
    UILabel *amountTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(18, 12, 60, 20)];
    amountTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    amountTitleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    amountTitleLab.text = @"充值金额";
    [amountView addSubview:amountTitleLab];
    
    amountTextView = [[UIView alloc] initWithFrame:CGRectMake(18,44, kScreenWidth-36, 38)];
    amountTextView.layer.borderColor = [UIColor colorWithHexString:@"#B4B4B4"].CGColor;
    amountTextView.layer.borderWidth = 1.0;
    amountTextView.layer.cornerRadius = 4.0;
    [amountView addSubview:amountTextView];
    
    [amountTextView addSubview:self.amountTextField];
    
    UILabel *unitLab = [[UILabel alloc] initWithFrame:CGRectMake(self.amountTextField.right+10, 8, 16, 22)];
    unitLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    unitLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    unitLab.text = @"元";
    [amountTextView addSubview:unitLab];
    
    CGFloat itemW = (kScreenWidth-26-36)/3.0;
    for (int i = 0; i < amountArray.count; i ++) {
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(18+(itemW+13)*(i%3), amountTextView.bottom+14+(i/3)*(35+14), itemW, 35)];
        item.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [item setTitleColor:[UIColor colorWithHexString:@" #4A4A4A"] forState:UIControlStateNormal];
        [item setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [item setTitle:[NSString stringWithFormat:@"%ld元",[amountArray[i] integerValue]] forState:UIControlStateNormal];
        item.layer.cornerRadius = 4.0;
        item.clipsToBounds = YES;
        item.layer.borderWidth = 1;
        item.layer.borderColor = [[UIColor colorWithHexString:@"#B4B4B4"] CGColor] ;
        item.tag = i;
        if (i==0) {
            item.selected = YES;
            item.layer.borderColor = [UIColor redColor].CGColor;
            item.backgroundColor = [UIColor redColor];
            selectItem = item;
        }
        [item addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [amountView addSubview:item];
    }
    
    UIView *paywayView = [[UIView alloc] initWithFrame:CGRectMake(0, amountView.bottom+10, kScreenWidth, 142)];
    paywayView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:paywayView];
    
    UILabel *paywayTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 60, 20)];
    paywayTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    paywayTitleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    paywayTitleLab.text = @"支付方式";
    [paywayView addSubview:paywayTitleLab];
    
    [paywayView addSubview:self.wepaywayView];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(19.0,self.wepaywayView.bottom, kScreenWidth-37.0, 0.5)];
    line2.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [paywayView addSubview:line2];
    
    [paywayView addSubview:self.alipaywayView];
    
    [self.view addSubview:self.confirmButton];
}

#pragma mark 取消金额选择
-(void)cancelClickItemAction{
    for (UIView *view in amountTextView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
            btn.layer.borderColor = [[UIColor colorWithHexString:@"#B4B4B4"] CGColor];
            btn.backgroundColor = [UIColor whiteColor];
        }
    }
    
    selectItem.selected = NO;
    selectItem.layer.borderColor = [[UIColor colorWithHexString:@"#B4B4B4"] CGColor];
    selectItem.backgroundColor = [UIColor whiteColor];
}

#pragma mark -- Getters
#pragma mark 充值金额输入
-(DecimalTextInput *)amountTextField{
    if (!_amountTextField) {
        _amountTextField = [[DecimalTextInput alloc] initWithFrame:CGRectMake(10,0, kScreenWidth-80, 38)];
        _amountTextField.placeholder = @"输入充值金额";
        _amountTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _amountTextField.delegate = self;
    }
    return _amountTextField;
}

#pragma mark 微信支付
-(PaywayView *)wepaywayView{
    if (!_wepaywayView) {
        _wepaywayView = [[PaywayView alloc] initWithFrame:CGRectMake(0, 32, kScreenWidth, 54) payImage:@"WeChat" payway:@"微信支付"];
        _wepaywayView.isSelected = YES;
        _wepaywayView.myButton.tag = 100;
        [_wepaywayView.myButton addTarget:self action:@selector(choosePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wepaywayView;
}

#pragma mark 支付宝支付
-(PaywayView *)alipaywayView{
    if (!_alipaywayView) {
        _alipaywayView = [[PaywayView alloc] initWithFrame:CGRectMake(0, self.wepaywayView.bottom+1, kScreenWidth, 54) payImage:@"alipay" payway:@"支付宝支付"];
        _alipaywayView.isSelected = NO;
        _alipaywayView.myButton.tag = 101;
        [_alipaywayView.myButton addTarget:self action:@selector(choosePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alipaywayView;
}

#pragma mark 确定支付
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(43.0,kScreenHeight-(kScreenWidth-95.0)*(128.0/588.0)-45.0,kScreenWidth-95.0,(kScreenWidth-95.0)*(128.0/588.0))];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_confirmButton addTarget:self action:@selector(confirmRechargeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayBackNotification object:nil];
}


@end
