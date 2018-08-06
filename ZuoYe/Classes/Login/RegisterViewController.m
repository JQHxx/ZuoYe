//
//  RegisterViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/6.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RegisterViewController.h"
#import "PhoneText.h"

@interface RegisterViewController ()<UITextFieldDelegate>{
    PhoneText     *phoneField;
    UITextField   *passWordField;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"注册";
    
    [self initRegisterView];
}

#pragma mark -- Event response
#pragma mark 注册
-(void)registerAction{
    
}

#pragma mark -- Pravite Methods
#pragma mark 初始化界面
-(void)initRegisterView{
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-90)/2, 84, 90, 90)];
    imgView.image=[UIImage imageNamed:@"ic_tangshi_logo"];
    [self.view addSubview:imgView];
    
    phoneField = [[PhoneText alloc] initWithFrame:CGRectMake(28 + 30, imgView.bottom+60, kScreenWidth-46 - 30, 38)];
    phoneField.returnKeyType=UIReturnKeyDone;
    phoneField.keyboardType = UIKeyboardTypeNumberPad;
    phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneField.delegate = self;
    phoneField.tag = 100;
    phoneField.font = [UIFont systemFontOfSize:16];
    phoneField.placeholder = @"手机号码";
    [self.view addSubview:phoneField];
    
    passWordField = [[UITextField alloc] initWithFrame:CGRectMake(28+30, phoneField.bottom+15, kScreenWidth - 46 - 30 - 40, 38)];
    passWordField.clearsOnBeginEditing = YES;
    passWordField.returnKeyType=UIReturnKeyDone;
    passWordField.keyboardType = UIKeyboardTypeASCIICapable;
    passWordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passWordField.delegate = self;
    passWordField.tag = 101;
    passWordField.placeholder  = @"请输入验证码";
    passWordField.font = [UIFont systemFontOfSize:16];
    passWordField.secureTextEntry = YES;
    [self.view addSubview:passWordField];
    
    for (int i= 0; i<2; i++) {
        UIImageView *phoneImg = [[UIImageView alloc] initWithFrame:CGRectMake(18, phoneField.top+ 53*i, 30, 30)];
        phoneImg.image = [UIImage imageNamed:i==0?@"ic_login_num":@"ic_login_code"];
        [self.view addSubview:phoneImg];
        
        UILabel *loginlbl = [[UILabel alloc] initWithFrame:CGRectMake(18, phoneField.bottom+53*i, kScreenWidth- 36, 1)];
        loginlbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
        [self.view addSubview:loginlbl];
    }
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(18, passWordField.bottom + 15, kScreenWidth-36, 48)];
    loginButton.layer.cornerRadius = 5;
    [loginButton setTitle:@"注册" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:18];
    loginButton.backgroundColor = [UIColor redColor];
    [loginButton addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
}

@end
