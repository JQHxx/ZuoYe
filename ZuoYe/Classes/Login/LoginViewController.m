//
//  LoginViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "PhoneText.h"

@interface LoginViewController ()<UITextFieldDelegate>{
    PhoneText      *loginField;
    UITextField    *passWordField;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    [self initLoginView];
}

#pragma mark -- Event reponse
#pragma mark 登录
-(void)loginAction{
    
}

#pragma mark 去注册
-(void)toRegisterAction{
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

#pragma mark 忘记密码
-(void)forgetPwAction{
    
}


#pragma mark -- Pravite Methods
#pragma mark 初始化界面
-(void)initLoginView{
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tangshi_logo"];
    [self.view addSubview:imgView];
    
    loginField = [[PhoneText alloc] initWithFrame:CGRectMake(28 + 30, imgView.bottom+60, kScreenWidth-46 - 30, 38)];
    loginField.returnKeyType=UIReturnKeyDone;
    loginField.keyboardType = UIKeyboardTypeNumberPad;
    loginField.clearButtonMode = UITextFieldViewModeWhileEditing;
    loginField.delegate = self;
    loginField.tag = 100;
    loginField.font = [UIFont systemFontOfSize:16];
    loginField.placeholder = @"手机号码";
    [self.view addSubview:loginField];
    
    passWordField = [[UITextField alloc] initWithFrame:CGRectMake(28+30, loginField.bottom+15, kScreenWidth - 46 - 30 - 40, 38)];
    passWordField.clearsOnBeginEditing = YES;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.keyboardType = UIKeyboardTypeASCIICapable;
    passWordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordField.delegate = self;
    passWordField.tag = 101;
    passWordField.placeholder  = @"登录密码";
    passWordField.font = [UIFont systemFontOfSize:16];
    passWordField.secureTextEntry = YES;
    [self.view addSubview:passWordField];
    
    for (int i= 0; i<2; i++) {
        UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, loginField.top+ 53*i, 30, 30)];
        phoneImg.image = [UIImage imageNamed:i==0?@"ic_login_num":@"ic_login_code"];
        [self.view addSubview:phoneImg];
        
        UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, loginField.bottom+53*i, kScreenWidth- 36, 1)];
        loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
        [self.view addSubview:loginlbl];
    }
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(18, passWordField.bottom + 15, kScreenWidth-36, 48)];
    loginButton.layer.cornerRadius = 5;
    [loginButton setTitle:@" 登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
    loginButton.backgroundColor = [UIColor redColor];
    [loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    UIButton *registBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2-100,loginButton.bottom + 24, 80, 20)];
    [registBtn setTitle:@"立即注册" forState:UIControlStateNormal];
    registBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [registBtn setTitleColor:[UIColor colorWithHexString:@"#05d380"] forState:UIControlStateNormal];
    [registBtn addTarget:self action:@selector(toRegisterAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registBtn];
    
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(kScreenWidth/2+20, loginButton.bottom + 24, 80, 20);
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[UIColor colorWithHexString:@"#959595"] forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(forgetPwAction) forControlEvents:UIControlEventTouchUpInside];
    forgetBtn.titleLabel.font = kFontWithSize(15);
    [self.view addSubview:forgetBtn];
}




@end
