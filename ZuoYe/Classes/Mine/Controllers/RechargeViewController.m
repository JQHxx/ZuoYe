//
//  RechargeViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RechargeViewController.h"
#import "PhoneText.h"
#import "PaywayView.h"

@interface RechargeViewController ()<UITextFieldDelegate>{
    UIView         *amountTextView;
    
    NSArray        *amountArray;
    NSInteger      selectedIndex;
    UIButton       *selectItem;
    NSInteger      payway;
}

@property (nonatomic, strong) PhoneText     *amountTextField;
@property (nonatomic, strong) PaywayView    *wepaywayView;    //微信支付
@property (nonatomic, strong) PaywayView    *alipaywayView;   //支付宝支付
@property (nonatomic, strong) UIButton      *confirmButton;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"充值";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    amountArray = @[@"50",@"100",@"200",@"500",@"1000",@"2000"];
    payway = 0;
    
    [self initRechargeView];
}

#pragma mark -- UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
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
    NSInteger amount = 0;
    if (kIsEmptyString(self.amountTextField.text)) {
        amount = [amountArray[selectedIndex] integerValue];
    }else{
        amount = [self.amountTextField.text integerValue];
    }
    
    MyLog(@"amount:%ld,payway:%@",amount,payway==0?@"微信支付":@"支付宝支付");
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

#pragma mark -- private methods
#pragma mark 获取付款信息
-(void)loadPayInfo{
    
}

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
-(PhoneText *)amountTextField{
    if (!_amountTextField) {
        _amountTextField = [[PhoneText alloc] initWithFrame:CGRectMake(10,0, kScreenWidth-80, 38)];
        _amountTextField.placeholder = @"输入充值金额";
        _amountTextField.textColor = [UIColor blackColor];
        _amountTextField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
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



@end
