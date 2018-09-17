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

#define kSelfHeight 280

@interface TutorialPayViewController (){
    double    payAmount;   //应付金额
    UILabel   *payLabel;
    UILabel   *balanceLabel;
    
    UIButton  *selectBtn;
    NSInteger payway;
}

@property (nonatomic, strong) UILabel           *titleLabel;            //标题
@property (nonatomic, strong) UIButton          *closeButton;            //关闭按钮
@property (nonatomic, strong) UIView            *payView;               //付款金额
@property (nonatomic, strong) UIView            *paywayView;            //支付方式
@property (nonatomic, strong) UIButton          *confirmButton;         //确定


@end

@implementation TutorialPayViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, kSelfHeight);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, kSelfHeight);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    
    [self initTutrialPayView];
    [self loadPayInfo];
    
}


#pragma mark -- event response
#pragma mark 确认支付
-(void)confirmPayAction{
    MyLog(@"应付金额：%.2f，支付方式：%ld",payAmount,payway);
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

#pragma mark -- private methods
#pragma mark 初始化
-(void)initTutrialPayView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0, kScreenWidth, 0.5)];
    line1.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:line1];
    
    [self.view addSubview:self.payView];
    [self.view addSubview:self.paywayView];
    
    [self.view addSubview:self.confirmButton];
    
    
}

#pragma mark 获取付款信息
-(void)loadPayInfo{
    payAmount = 5.5;
    
    double myBalance = 20.0;
    payLabel.text = [NSString stringWithFormat:@"%.2f元",payAmount];
    balanceLabel.text = [NSString stringWithFormat:@"（可用余额：%.2f元）",myBalance];
    
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
        _payView = [[UIView alloc] initWithFrame:CGRectMake(0, 46, kScreenWidth, 42)];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 11, 20, 20)];
        iconImageView.image = [UIImage imageNamed:@"release_price"];
        [_payView addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconImageView.right+8.0, 10,80, 22)];
        label.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        label.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        label.text = @"应付金额";
        [_payView addSubview:label];
        
        payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 10,75, 22)];
        payLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        payLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        payLabel.textAlignment = NSTextAlignmentRight;
        [_payView addSubview:payLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(26.0, 42.0, kScreenWidth-51, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_payView addSubview:line];
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
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(48.0,self.paywayView.bottom+10,kScreenWidth-95.0,(kScreenWidth-95.0)*(128.0/588.0))];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_confirmButton addTarget:self action:@selector(confirmPayAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


@end
