//
//  SetPasswordViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "MyTabBarController.h"
#import "AppDelegate.h"
#import "LoginTextView.h"
#import "LoginButton.h"

@interface SetPasswordViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton           *backBtn;
@property (nonatomic, strong) UILabel            *titleLabel;
@property (nonatomic, strong) LoginTextView      *passwordTextView;           //密码
@property (nonatomic, strong) LoginTextView      *confirmPwdTextView;         //确认密码
@property (nonatomic, strong) LoginButton        *completeButton;             //注册


@end

@implementation SetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar= YES;
    
    [self initRegisterSuccessView];
}

#pragma mark -- Event response
#pragma mark 完成设置
-(void)confirmSetPwdAction{
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
    
    NSString *passwordStr = [self.passwordTextView.myText.text MD5];
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"mobile=%@&code=%@&password=%@",self.phone,self.code,passwordStr];
    [TCHttpRequest postMethodWithURL:kSetPwdAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"密码设置成功" duration:1.0 position:CSToastPositionCenter];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark -- delegate
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.passwordTextView.myText resignFirstResponder];
    [self.confirmPwdTextView.myText resignFirstResponder];
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.passwordTextView.myText==textField) {
        if ([textField.text length]<14) {
            return YES;
        }
    }
    if (self.confirmPwdTextView.myText==textField) {
        if ([textField.text length]<14) {
            return YES;
        }
    }
    return NO;
}


#pragma mark -- private methods
#pragma mark 初始化界面
-(void)initRegisterSuccessView{
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.titleLabel];
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
    
    [self.view addSubview:self.completeButton];
}

#pragma mark -- Getters and Setters
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
        _titleLabel.text = @"设置新密码";
    }
    return _titleLabel;
}

#pragma mark 密码
-(LoginTextView *)passwordTextView{
    if (!_passwordTextView) {
        _passwordTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26.0, self.titleLabel.bottom+30, kScreenWidth - 51.0, 52.0) placeholder:@"请输入密码" icon:@"register_password" isNumber:NO];
        _passwordTextView.myText.delegate = self;
        _passwordTextView.myText.secureTextEntry = YES;
    }
    return _passwordTextView;
}

#pragma mark 确认密码
-(LoginTextView *)confirmPwdTextView{
    if (!_confirmPwdTextView) {
        _confirmPwdTextView = [[LoginTextView alloc] initWithFrame:CGRectMake(26, self.passwordTextView.bottom+10, kScreenWidth - 51, 52) placeholder:@"请重新输入密码" icon:@"register_password" isNumber:NO];
        _confirmPwdTextView.myText.delegate = self;
        _confirmPwdTextView.myText.secureTextEntry = YES;
    }
    return _confirmPwdTextView;
}


#pragma mark 确定
-(LoginButton *)completeButton{
    if (!_completeButton) {
        _completeButton = [[LoginButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0, self.confirmPwdTextView.bottom+37.0, 280,55) title:@"确定"];
        [_completeButton addTarget:self action:@selector(confirmSetPwdAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeButton;
}


@end
