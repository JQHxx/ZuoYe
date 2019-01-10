//
//  RechargeAlertViewController.m
//  ZuoYe
//
//  Created by vision on 2018/12/6.
//  Copyright © 2018 vision. All rights reserved.
//

#import "RechargeAlertViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "NSDate+Extension.h"
#import <AlipaySDK/AlipaySDK.h>

@interface RechargeAlertViewController (){
    NSArray  *amountArray;
    NSArray  *introArray;
    UIButton *selectItem;
    NSInteger selectedIndex;
    BOOL     showDot; //是否显示小数点
    
    double amount;
}

@property (nonatomic, strong) UILabel      *titleLabel;              //标题
@property (nonatomic, strong) UILabel      *descLabel;               //说明
@property (nonatomic, strong) UIButton     *closeButton;             //关闭按钮

@end

@implementation RechargeAlertViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = 295.0;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth-50, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.view.layer.cornerRadius = 5.0;
    self.view.layer.masksToBounds = YES;
    
    selectedIndex = 0;
    
    NSString *priceStr = nil;
    if (self.type==0) {
        NSInteger aPrice = (NSInteger) self.checkPrice;
        MyLog(@"aprice:%ld,checkPrice:%.2f",aPrice,self.checkPrice);
        if (self.checkPrice - (double)aPrice>0.00) {
            showDot = YES;
            priceStr = [NSString stringWithFormat:@"%.2f",self.checkPrice];
        }else{
            showDot = NO;
            priceStr = [NSString stringWithFormat:@"%ld",aPrice];
        }
        amountArray = @[priceStr,@"50"];
        introArray = @[@"本次作业检查金额",@"推荐充值金额"];
    }else{
      amountArray = @[@"10",@"50"];
      introArray = @[@"作业辅导预充值金额",@"推荐充值金额"];
    }
    
    [self initRechargeAlertView];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"充值提醒"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rechargeSuccessAction) name:kPayBackNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"充值提醒"];
}

#pragma mark - Event Response
#pragma mark 关闭
-(void)closeRechargeAlertViewAction:(UIButton *)sender{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:nil];
    }
}

#pragma mark 选择充值金额
-(void)rechargeItemClickAction:(UIButton *)sender{
    if (selectItem) {
        selectItem.selected = NO;
    }
    sender.selected = YES;
    selectItem = sender;
    selectedIndex = sender.tag;
}

#pragma mark 充值
-(void)confirmRechargeAction:(UITapGestureRecognizer *)sender{
    amount = [amountArray[selectedIndex] doubleValue];
    if (sender.view.tag==100) {   //微信支付
        NSString *body = [NSString stringWithFormat:@"token=%@&cate=2&money=%.2f",kUserTokenValue,amount];
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
        NSString *body = [NSString stringWithFormat:@"token=%@&cate=1&money=%.2f",kUserTokenValue,amount];
        [TCHttpRequest postMethodWithURL:kWalletRechargeAPI body:body success:^(id json) {
            NSString *payInfo =[json objectForKey:@"data"];
            [[AlipaySDK defaultService] payOrder:payInfo fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [weakSelf rechargeSuccessAction];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"alipay--error:%@",memo);
                }
            }];
        }];
    }
}

#pragma mark -- Notification
#pragma mark 充值成功
-(void)rechargeSuccessAction{
    double myCredit = [[NSUserDefaultsInfos getValueforKey:kUserCredit] doubleValue];
    myCredit += amount;
    MyLog(@"充值成功，myCredit：%.f",myCredit);
    [NSUserDefaultsInfos putKey:kUserCredit andValue:[NSNumber numberWithDouble:myCredit]];
    [ZYHelper sharedZYHelper].isRechargeSuccess = YES;
    [self.view makeToast:@"充值成功" duration:1.0 position:CSToastPositionCenter];
    kSelfWeak;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.popupController) {
            [weakSelf.popupController dismiss];
        }
    });
}

#pragma mark - Private methods
#pragma mark 初始化界面
-(void)initRechargeAlertView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.descLabel];
    
    CGFloat itemW = (kScreenWidth-27-28*2-50)/2.0;
    CGFloat labW = (kScreenWidth-50-10*2)/2.0;
    for (NSInteger i = 0; i < amountArray.count; i ++) {
        UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(28+(itemW+27)*i, self.descLabel.bottom+14, itemW, 36)];
        item.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:18];
        [item setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [item setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [item setBackgroundImage:[UIImage imageNamed:@"check_popup_button_white"] forState:UIControlStateNormal];
        [item setBackgroundImage:[UIImage imageNamed:@"check_popup_button"] forState:UIControlStateSelected];
        if (i==0) {
            if (showDot) {
                [item setTitle:[NSString stringWithFormat:@"%.2f元",[amountArray[i] doubleValue]] forState:UIControlStateNormal];
            }else{
                [item setTitle:[NSString stringWithFormat:@"%ld元",[amountArray[i] integerValue]] forState:UIControlStateNormal];
            }
        }else{
             [item setTitle:[NSString stringWithFormat:@"%ld元",[amountArray[i] integerValue]] forState:UIControlStateNormal];
        }
        item.tag = i;
        if (i==0) {
            item.selected = YES;
            selectItem = item;
        }
        [item addTarget:self action:@selector(rechargeItemClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:item];
        
        UILabel *introLab = [[UILabel alloc] initWithFrame:CGRectMake(10+labW*i, item.bottom+7, labW, 20)];
        introLab.text = introArray[i];
        introLab.textAlignment = NSTextAlignmentCenter;
        introLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        introLab.textColor = [UIColor colorWithHexString:@"#868C99"];
        [self.view addSubview:introLab];
    }
    
    UIImageView *dottedLineView = [[UIImageView alloc] initWithFrame:CGRectMake(16, self.descLabel.bottom+90, kScreenWidth-50-32, 2)];
    dottedLineView.image = [UIImage imageNamed:@"check_popup_line"];
    [self.view addSubview:dottedLineView];
    
    UIView *wepayView = [self makePaywayViewWithFrame:CGRectMake(0, dottedLineView.bottom, kScreenWidth-50, 60) Title:@"微信支付" image:@"WeChat"];
    [self.view addSubview:wepayView];
    wepayView.tag = 100;
    UITapGestureRecognizer *weTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confirmRechargeAction:)];
    [wepayView addGestureRecognizer:weTap];
    
    UIView *alipayView = [self makePaywayViewWithFrame:CGRectMake(0, wepayView.bottom, kScreenWidth-50, 44) Title:@"支付宝支付" image:@"alipay"];
    [self.view addSubview:alipayView];
    alipayView.tag =101;
    UITapGestureRecognizer *alipayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(confirmRechargeAction:)];
    [alipayView addGestureRecognizer:alipayTap];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(16, wepayView.bottom, kScreenWidth-50-32, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"#E2E4EC"];
    [self.view addSubview:line];
    
}

#pragma mark 创建支付方式视图
-(UIView *)makePaywayViewWithFrame:(CGRect)frame Title:(NSString *)title image:(NSString *)imgName{
    UIView *aView = [[UIView alloc] initWithFrame:frame];
    UIImageView *payImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 15, 30, 30)];
    payImageView.image = [UIImage imageNamed:imgName];
    [aView addSubview:payImageView];
    
    UILabel *paymentLabel = [[UILabel alloc] initWithFrame:CGRectMake(payImageView.right+13, 20, 100, 20)];
    paymentLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
    paymentLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    paymentLabel.text = title;
    [aView addSubview:paymentLabel];
    
    UIImageView *arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width-35, 25, 8, 12)];
    arrowImgView.image = [UIImage imageNamed:@"check_popup_arrow"];
    [aView addSubview:arrowImgView];
    
    aView.userInteractionEnabled = YES;
    
    return aView;
}

#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, kScreenWidth-120-50, 25)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.text = @"充值";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 描述
-(UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,self.titleLabel.bottom+10, kScreenWidth-40-50, 25)];
        _descLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _descLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _descLabel.text = @"您的余额不足，请先充值";
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40-50, 5, 35,35)];
        [_closeButton setImage:[UIImage imageNamed:@"check_popup_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeRechargeAlertViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPayBackNotification object:nil];
}


@end
