//
//  RegisterViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/6.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RegisterViewController.h"
#import "SetUserInfoViewController.h"
#import "BaseWebViewController.h"
#import "LoginTextView.h"
#import "UserAgreementView.h"
#import "UIDevice+Extend.h"
#import "SSKeychain.h"
#import "UserModel.h"
#import <NIMSDK/NIMSDK.h>
#import <UMPush/UMessage.h>

@interface RegisterViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton           *backBtn;
@property (nonatomic, strong) UILabel            *titleLabel;
@property (nonatomic, strong) LoginTextView      *phoneTextView;              //手机号
@property (nonatomic, strong) UIButton           *getCodeButton;              //获取验证码
@property (nonatomic, strong) LoginTextView      *securityCodeTextView;       //验证码
@property (nonatomic, strong) LoginTextView      *passwordTextView;           //密码
@property (nonatomic, strong) LoginTextView      *confirmPwdTextView;         //确认密码
@property (nonatomic, strong) UserAgreementView  *agreementView;       //用户协议
@property (nonatomic, strong) UIButton           *selButton;
@property (nonatomic, strong) UIButton           *registerButton;             //注册



@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar= YES;
    
    [self initRegisterView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"注册"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"注册"];
}

#pragma mark -- Event response
#pragma mark 注册
-(void)registerAction{
    if (kIsEmptyString(self.phoneTextView.myText.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    BOOL isPhoneNumber = [self.phoneTextView.myText.text isPhoneNumber];
    if (!isPhoneNumber) {
        [self.view makeToast:@"您输入的手机号码有误,请重新输入" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (kIsEmptyString(self.securityCodeTextView.myText.text)) {
        [self.view makeToast:@"验证码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (kIsEmptyString(self.passwordTextView.myText.text)||kIsEmptyString(self.confirmPwdTextView.myText.text)) {
        [self.view makeToast:@"密码不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (self.passwordTextView.myText.text.length<6||self.confirmPwdTextView.myText.text.length<6) {
        [self.view makeToast:@"密码不能少于6位" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    if (![self.passwordTextView.myText.text isEqualToString:self.confirmPwdTextView.myText.text]) {
        [self.view makeToast:@"两次输入的密码不相同" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSString *phoneStr = self.phoneTextView.myText.text;
    NSString *passwordStr = [self.passwordTextView.myText.text MD5];
    NSString *codeStr = self.securityCodeTextView.myText.text;
    
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&password=%@&code=%@&platform=iOS&deviceId=%@",phoneStr,passwordStr,codeStr,uuid];
    [TCHttpRequest postMethodWithURL:kRegisterAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        UserModel *model = [[UserModel alloc] init];
        [model setValues:data];
        [NSUserDefaultsInfos putKey:kUserID andValue:data[@"userid"]];
        [NSUserDefaultsInfos putKey:kUserToken andValue:data[@"token"]];
        [NSUserDefaultsInfos putKey:kLogID anddict:model.logid];
        [NSUserDefaultsInfos putKey:kLoginPhone andValue:phoneStr];
        [NSUserDefaultsInfos putKey:kUserThirdID andValue:model.third_id];
        [NSUserDefaultsInfos putKey:kUserThirdToken andValue:model.third_token];
        
        //登录网易云
        [[[NIMSDK sharedSDK] loginManager] login:model.third_id token:model.third_token completion:^(NSError * _Nullable error) {
            if (error) {
                MyLog(@"NIMSDK login--error:%@",error.localizedDescription);
            }else{
                MyLog(@"网易云登录成功");
                NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:model.third_id];
                MyLog(@"user--nickName:%@,avatar:%@",user.userInfo.nickName,user.userInfo.thumbAvatarUrl);
            }
        }];
        
        //绑定友盟推送别名
        NSString *tempStr=isTrueEnvironment?@"zs":@"cs";
        NSString *aliasStr=[NSString stringWithFormat:@"%@%@",tempStr,data[@"userid"]];
        [UMessage addAlias:aliasStr type:kUMAlaisType response:^(id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                MyLog(@"绑定别名失败，error:%@",error.localizedDescription);
            }else{
                MyLog(@"绑定别名成功,result:%@",responseObject);
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"注册成功" duration:1.0 position:CSToastPositionCenter];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SetUserInfoViewController *setUserInfoVC = [[SetUserInfoViewController alloc] init];
            setUserInfoVC.token = data[@"token"];
            setUserInfoVC.user_id = [data[@"userid"] integerValue];
            [weakSelf.navigationController pushViewController:setUserInfoVC animated:YES];
        });
    }];
}

#pragma mark 获取验证码
-(void)getSecurityCodeAction:(UIButton *)sender{
    if (kIsEmptyString(self.phoneTextView.myText.text)) {
        [self.view makeToast:@"手机号不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    BOOL isPhoneNumber = [self.phoneTextView.myText.text isPhoneNumber];
    if (!isPhoneNumber) {
        [self.view makeToast:@"您输入的手机号码有误,请重新输入" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    kSelfWeak;
    NSString *phoneStr = self.phoneTextView.myText.text;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&cate=register",phoneStr];
    [TCHttpRequest postMethodWithURL:kGetCodeSign body:body success:^(id json) {
        __block int timeout=60; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if(timeout<=0){ //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [self.getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                    [self.getCodeButton setTitleColor:[UIColor colorWithHexString:@"#FF7568"] forState:UIControlStateNormal];
                    self.getCodeButton.userInteractionEnabled = YES;
                });
            }else{
                int seconds = timeout % 61;
                NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [self.getCodeButton setTitle:[NSString stringWithFormat:@"%@s",strTime] forState:UIControlStateNormal];
                    self.getCodeButton.userInteractionEnabled = NO;
                });
                timeout--;
            }
        });
        dispatch_resume(_timer);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.phoneTextView.myText resignFirstResponder];
            [weakSelf.securityCodeTextView.myText becomeFirstResponder];
            [weakSelf.view makeToast:[json objectForKey:@"msg"] duration:1.0 position:CSToastPositionCenter];
        });
    }];
}

#pragma mark 密码是否可见
-(void)setPasswordVisibleAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.tag==0) {
        self.passwordTextView.myText.secureTextEntry=!sender.selected;
    }else{
        self.confirmPwdTextView.myText.secureTextEntry=!sender.selected;
    }
}

#pragma mark 是否已阅读
-(void)chooseForDidReadUserAgreement:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if(sender.selected){
        [self.registerButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        self.registerButton.userInteractionEnabled = YES;
    }else{
        [self.registerButton setBackgroundImage:[UIImage imageNamed:@"button_gray"] forState:UIControlStateNormal];
        self.registerButton.userInteractionEnabled = NO;
    }
}

#pragma mark -- delegate
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.phoneTextView.myText resignFirstResponder];
    [self.securityCodeTextView.myText resignFirstResponder];
    [self.passwordTextView.myText resignFirstResponder];
    [self.confirmPwdTextView.myText resignFirstResponder];
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.phoneTextView.myText==textField) {
        if ([textField.text length]<11) {
            return YES;
        }
    }
    if (self.securityCodeTextView.myText==textField) {
        if ([textField.text length]<6) {
            return YES;
        }
    }
    
    if (self.passwordTextView.myText == textField || self.confirmPwdTextView.myText == textField) {
        if ([textField.text length]<14) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -- Pravite Methods
#pragma mark 初始化界面
-(void)initRegisterView{
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.phoneTextView];
    [self.view addSubview:self.securityCodeTextView];
    [self.view addSubview:self.getCodeButton];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.securityCodeTextView.right,self.securityCodeTextView.bottom,kScreenWidth-25.0-self.securityCodeTextView.right, 0.5)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:lineLbl];
    
    [self.view addSubview:self.passwordTextView];
    [self.view addSubview:self.confirmPwdTextView];
    
    for (NSInteger i=0; i<2; i++) {
        UIButton *visibleButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-52,self.passwordTextView.top+16+i*62, 27, 16)];
        [visibleButton setImage:[UIImage imageNamed:@"register_password_hide"] forState:UIControlStateNormal];
        [visibleButton setImage:[UIImage imageNamed:@"register_password_show"] forState:UIControlStateSelected];
        visibleButton.tag = i;
        [visibleButton addTarget:self action:@selector(setPasswordVisibleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:visibleButton];
    }
    [self.view addSubview:self.agreementView];
    [self.view addSubview:self.selButton];
    
    [self.view addSubview:self.registerButton];
}

#pragma mark -- Getters
#pragma mark 返回
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
        [_backBtn setImage:[UIImage drawImageWithName:@"return"size:CGSizeMake(10, 17)] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [_backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, kNavHeight+15, 120, 28)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:20];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.text = @"手机号注册";
    }
    return _titleLabel;
}

#pragma mark 手机号
-(LoginTextView *)phoneTextView{
    if (!_phoneTextView) {
        _phoneTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26.0,self.titleLabel.bottom+30.0, kScreenWidth-51.0, 52) placeholder:@"请输入手机号码" icon:@"register_phone" isNumber:YES];
        _phoneTextView.myText.delegate = self;
    }
    return _phoneTextView;
}

#pragma mark 验证码
-(LoginTextView *)securityCodeTextView{
    if (!_securityCodeTextView) {
        _securityCodeTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26.0, self.phoneTextView.bottom+10,kScreenWidth-155, 52.0) placeholder:@"请输入验证码" icon:@"register_message" isNumber:YES];
        _securityCodeTextView.myText.delegate = self;
    }
    return _securityCodeTextView;
}

#pragma mark 获取验证码
-(UIButton *)getCodeButton{
    if (!_getCodeButton) {
        _getCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-120.0, self.phoneTextView.bottom+20,100.0, 33)];
        [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        _getCodeButton.layer.cornerRadius = 4;
        _getCodeButton.layer.borderColor = [UIColor colorWithHexString:@"#FF7568"].CGColor;
        _getCodeButton.layer.borderWidth = 1.0;
        CGFloat fontSize = kScreenWidth<375.0?14:16;
        _getCodeButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:fontSize];
        [_getCodeButton setTitleColor:[UIColor colorWithHexString:@"#FF7568"] forState:UIControlStateNormal];
        [_getCodeButton addTarget:self action:@selector(getSecurityCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _getCodeButton;
}

#pragma mark 密码
-(LoginTextView *)passwordTextView{
    if (!_passwordTextView) {
        _passwordTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26.0, self.securityCodeTextView.bottom+10, kScreenWidth - 51.0, 52.0) placeholder:@"请输入密码" icon:@"register_password" isNumber:NO];
        _passwordTextView.myText.delegate = self;
        _passwordTextView.myText.secureTextEntry = YES;
        _passwordTextView.myText.keyboardType = UIKeyboardTypeASCIICapable;
    }
    return _passwordTextView;
}

#pragma mark 确认密码
-(LoginTextView *)confirmPwdTextView{
    if (!_confirmPwdTextView) {
        _confirmPwdTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26, self.passwordTextView.bottom+10, kScreenWidth - 51, 52) placeholder:@"请重新输入密码" icon:@"register_password" isNumber:NO];
        _confirmPwdTextView.myText.delegate = self;
        _confirmPwdTextView.myText.secureTextEntry = YES;
        _confirmPwdTextView.myText.keyboardType = UIKeyboardTypeASCIICapable;
    }
    return _confirmPwdTextView;
}

#pragma mark 选择是否同意
-(UIButton *)selButton{
    if (!_selButton) {
        _selButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-220)/2.0, self.confirmPwdTextView.bottom+40.0, 16, 16)];
        [_selButton setImage:[UIImage imageNamed:@"login_agreement"] forState:UIControlStateNormal];
        [_selButton setImage:[UIImage imageNamed:@"login_agreement_agree"] forState:UIControlStateSelected];
        [_selButton addTarget:self action:@selector(chooseForDidReadUserAgreement:) forControlEvents:UIControlEventTouchUpInside];
        _selButton.selected = YES;
    }
    return _selButton;
}

#pragma mark 用户协议
-(UserAgreementView *)agreementView{
    if (!_agreementView) {
        NSString * tempStr = @"我已阅读并同意《用户服务协议》";
        CGFloat labW = [tempStr boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:kFontWithSize(12)].width;
        _agreementView = [[UserAgreementView alloc] initWithFrame:CGRectMake(self.selButton.right+5,self.confirmPwdTextView.bottom +38, labW+40, 20) string:tempStr];
        kSelfWeak;
        _agreementView.clickAction = ^{
            BaseWebViewController *userAgreementVC = [[BaseWebViewController alloc] init];
            userAgreementVC.webTitle = @"用户服务协议";
            userAgreementVC.urlStr = kUserAgreementURL;
            [weakSelf.navigationController pushViewController:userAgreementVC animated:YES];
        };
    }
    return _agreementView;
}


#pragma mark 注册
-(UIButton *)registerButton{
    if (!_registerButton) {
        CGFloat originX = kScreenWidth<375?48:(kScreenWidth-280)/2.0;
        CGFloat btnW = kScreenWidth<375?kScreenWidth-95:280;
        _registerButton = [[UIButton alloc] initWithFrame:CGRectMake(originX, self.agreementView.bottom+13.0, btnW, 55)];
        [_registerButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_registerButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

@end
