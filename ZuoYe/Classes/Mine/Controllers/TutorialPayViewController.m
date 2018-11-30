//
//  TutorialPayViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialPayViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "PaymentTableViewCell.h"
#import "PaymentModel.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>

#define kSelfHeight 280

@interface TutorialPayViewController (){
    NSArray   *imagesArr;
    NSArray   *titlesArr;
    
    UILabel   *priceLabel;      //辅导金额
    UILabel   *durationLabel;    //辅导时长
    UILabel   *payLabel;      //应付金额
    UILabel   *balanceLabel;  //余额
    
    UIButton  *selectBtn;
    NSInteger payway;      //支付方式
    double    myBalance;  //账户余额
    double    payMoney;    //支付金额
    BOOL      _isOrderIn;
    CGFloat   viewHeight;
}

@property (nonatomic, strong) UILabel           *titleLabel;            //标题
@property (nonatomic, strong) UIButton          *closeButton;            //关闭按钮
@property (nonatomic, strong) UIView            *payView;               //付款金额
@property (nonatomic, strong) UIView            *paywayView;            //支付方式
@property (nonatomic, strong) UIButton          *confirmButton;         //确定


@end

@implementation TutorialPayViewController

-(instancetype)initWithIsOrderIn:(BOOL)isOrderIn{
    self = [super init];
    if (self) {
        _isOrderIn = isOrderIn;
        viewHeight = isOrderIn?280:384;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, viewHeight);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, viewHeight);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    imagesArr = _isOrderIn?@[@"release_price"]:@[@"release_price",@"release_time",@"release_price"];
    titlesArr = _isOrderIn?@[@"应付金额"]:@[@"辅导价格",@"本次辅导时长",@"应付金额"];
    
    [self initTutrialPayView];
    [self loadPayInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payOrderSuccessAction) name:kPayBackNotification object:nil];
}


#pragma mark -- event response
#pragma mark 确认支付
-(void)confirmPayAction{
    // 支付方式 cate 1支付宝，2微信 3余额
    kSelfWeak;
    if (payway==0) {  //余额支付
        if (payMoney>myBalance) {
            [self.view makeToast:@"余额不足" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        NSString *unSignStr = [NSString stringWithFormat:@"cate=3&label=%ld&oid=%@&pay_money=%.2f&token=%@",self.label,self.orderId,payMoney,kUserTokenValue];
        NSString *body = [NSString stringWithFormat:@"%@&sign=%@",unSignStr,[unSignStr MD5]];
        [TCHttpRequest postMethodWithURL:kOrderPayAPI body:body success:^(id json) {
            [weakSelf payOrderSuccessAction];
        }];
    }else if (payway==1){ //微信支付
        NSString *unSignStr = [NSString stringWithFormat:@"cate=2&label=%ld&oid=%@&pay_money=%.2f&token=%@",self.label,self.orderId,payMoney,kUserTokenValue];
        NSString *body = [NSString stringWithFormat:@"%@&sign=%@",unSignStr,[unSignStr MD5]];
        [TCHttpRequest postMethodWithURL:kOrderPayAPI body:body success:^(id json) {
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
        
    }else{  //支付宝支付
         NSString *unSignStr = [NSString stringWithFormat:@"cate=1&label=%ld&oid=%@&pay_money=%.2f&token=%@",self.label,self.orderId,payMoney,kUserTokenValue];
        NSString *body = [NSString stringWithFormat:@"%@&sign=%@",unSignStr,[unSignStr MD5]];
        [TCHttpRequest postMethodWithURL:kOrderPayAPI body:body success:^(id json) {
            NSString *payInfo =[json objectForKey:@"data"];
            [[AlipaySDK defaultService] payOrder:payInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [weakSelf payOrderSuccessAction];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"alipay--error:%@",memo);
                }
            }];
            
        }];
    }
}


#pragma mark 关闭（取消支付）
-(void)closeCommentViewAction{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:nil];
    }
}

#pragma mark 选择支付方式
-(void)choosePaymentAction:(UIButton *)sender{
    selectBtn.selected = NO;
    sender.selected = YES;
    selectBtn = sender;
    payway = sender.tag;
}

#pragma mark -- Notification
-(void)payOrderSuccessAction{
    kSelfWeak;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view makeToast:@"支付成功" duration:1.0 position:CSToastPositionCenter];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.popupController) {
            [weakSelf.popupController dismissWithCompletion:^{
                weakSelf.backBlock([NSNumber numberWithDouble:payMoney]);
            }];
        }
    });
    
}

#pragma mark -- private methods
#pragma mark 初始化
-(void)initTutrialPayView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    self.closeButton.hidden = !_isOrderIn;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0, kScreenWidth, 0.5)];
    line1.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:line1];
    
    [self.view addSubview:self.payView];
    [self.view addSubview:self.paywayView];
    [self.view addSubview:self.confirmButton];
}

#pragma mark 获取付款信息
-(void)loadPayInfo{
    if (_isOrderIn) {
        payMoney = self.payAmount;
    }else{
        priceLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",[self.guidePrice doubleValue]];
        if(self.duration>3600){
            durationLabel.text =[NSString stringWithFormat:@"%ld时%ld分%ld秒",self.duration/3600,self.duration/60,self.duration%60];
        }else{
            durationLabel.text =[NSString stringWithFormat:@"%ld分%ld秒",self.duration/60,self.duration%60];
        }
        payMoney = (self.duration/60.0)*[self.guidePrice doubleValue];
    }
    
    payLabel.text = [NSString stringWithFormat:@"%.2f元",payMoney];
    
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithURL:kWalletMineAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        myBalance = [[data valueForKey:@"money"] doubleValue];
        dispatch_sync(dispatch_get_main_queue(), ^{
            balanceLabel.text = [NSString stringWithFormat:@"（可用余额：%.2f元）",myBalance];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 12, kScreenWidth-120, 25)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.text = @"支付";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-34, 7.5, 30,30)];
        [_closeButton setImage:[UIImage drawImageWithName:@"delete" size:CGSizeMake(18, 18)] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeCommentViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark 应付金额
-(UIView *)payView{
    if (!_payView) {
        _payView = [[UIView alloc] initWithFrame:CGRectMake(0, 46, kScreenWidth, 42*titlesArr.count)];
        
        for (NSInteger i=0; i<titlesArr.count; i++) {
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 11+42*i, 20, 20)];
            iconImageView.image = [UIImage imageNamed:imagesArr[i]];
            [_payView addSubview:iconImageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+8.0, 10+42*i,120, 22)];
            label.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
            label.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            label.text = titlesArr[i];
            [_payView addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, 10+42*i,100, 22)];
            valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
            valueLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
            valueLabel.textAlignment = NSTextAlignmentRight;
            [_payView addSubview:valueLabel];
            
            if (_isOrderIn) {
                payLabel = valueLabel;
            }else{
                if (i==0) {
                    priceLabel = valueLabel;
                }else if (i==1){
                    durationLabel = valueLabel;
                }else{
                    payLabel = valueLabel;
                }
            }
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(26.0, 42.0*(i+1), kScreenWidth-51, 0.5)];
            line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
            [_payView addSubview:line];
        }
    }
    return _payView;
}

#pragma mark 支付方式
-(UIView *)paywayView{
    if (!_paywayView) {
        _paywayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.payView.bottom, kScreenWidth, 100)];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 11, 20, 20)];
        iconImageView.image = [UIImage imageNamed:@"payment_method"];
        [_paywayView addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+8.0, 10,80, 22)];
        label.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        label.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        label.text = @"支付方式";
        [_paywayView addSubview:label];
        
        NSArray *btnTitles = @[@"余额支付",@"微信支付",@"支付宝支付"];
        for (NSInteger i=0; i<btnTitles.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
            [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"pay_choose_gray"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"pay_choose"] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
            btn.tag = i;
            if (i==0) {
                btn.frame = CGRectMake(40, label.bottom+10, 105, 22);
                btn.selected = YES;
                selectBtn = btn;
            }else{
                btn.frame = CGRectMake(40+(105+50)*(i-1), label.bottom+42, 105, 22);
                btn.selected = NO;
            }
            btn.titleEdgeInsets = UIEdgeInsetsMake(0,5,0, 0);
            [btn addTarget:self action:@selector(choosePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
            [_paywayView addSubview:btn];
        }
        
        balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, label.bottom+10,180, 20)];
        balanceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        balanceLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [_paywayView addSubview:balanceLabel];
    }
    return _paywayView;
}


#pragma mark 确定支付
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0,self.paywayView.bottom+15,280,55)];
        [_confirmButton setTitle:@"确定支付" forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_confirmButton addTarget:self action:@selector(confirmPayAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayBackNotification object:nil];
}

@end
