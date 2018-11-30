//
//  SetUserInfoViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "SetUserInfoViewController.h"
#import "MyTabBarController.h"
#import "LoginButton.h"
#import "AppDelegate.h"

@interface SetUserInfoViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    NSArray  *gradesArray;
}

@property (nonatomic, strong) UITextField  *nameTextField;
@property (nonatomic, strong) UIPickerView *pickerView ;


@end

@implementation SetUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    gradesArray = [ZYHelper sharedZYHelper].grades;
    
    [self initSetUserInfoView];
}

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return gradesArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return gradesArray[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *valueStr  = [gradesArray objectAtIndex:row];
    NSMutableAttributedString *AttributedString = [[NSMutableAttributedString alloc]initWithString:valueStr];
    [AttributedString addAttributes:@{NSFontAttributeName:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#4A4A4A"]} range:NSMakeRange(0, [AttributedString  length])];
    return AttributedString;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 35;
}

#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.nameTextField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (self.nameTextField==textField) {
        if ([textField.text length]<8) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event Response
-(void)confirmSetUserInfoAction{
    if (kIsEmptyString(self.nameTextField.text)) {
        [self.view makeToast:@"姓名不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    NSInteger selIndex = [self.pickerView selectedRowInComponent:0];
    NSString *grade = [gradesArray objectAtIndex:selIndex];
    MyLog(@"grade：%@",grade);
    NSString *nameStr = self.nameTextField.text;
    NSString *body = [NSString stringWithFormat:@"userid=%ld&token=%@&grade=%ld&username=%@",self.user_id,self.token,selIndex+1,nameStr];
    [TCHttpRequest postMethodWithURL:kSetUserInfoAPI body:body success:^(id json) {
        [NSUserDefaultsInfos putKey:kIsLogin andValue:[NSNumber numberWithBool:YES]];
        [NSUserDefaultsInfos putKey:kUserGrade andValue:grade];
        [NSUserDefaultsInfos putKey:kUserNickname andValue:nameStr];
        dispatch_sync(dispatch_get_main_queue(), ^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            MyTabBarController *myTabBar = [[MyTabBarController alloc] init];
            appDelegate.window.rootViewController = myTabBar;
        });
    }];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initSetUserInfoView{
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*(42.0/75.0))];
    bgImgView.image = [UIImage imageNamed:@"head_image_background"];
    [self.view addSubview:bgImgView];
    
    UIButton *backBtn=[[UIButton alloc] initWithFrame:CGRectMake(5,KStatusHeight + 2, 40, 40)];
    [backBtn setImage:[UIImage drawImageWithName:@"return_white" size:CGSizeMake(10, 17)] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, KStatusHeight, 180, 44)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text = @"个人信息";
    [self.view addSubview:titleLabel];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(55, bgImgView.bottom+20, 100, 22)];
    nameLab.text = @"你的姓名";
    nameLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    nameLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    [self.view addSubview:nameLab];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(55, nameLab.bottom+10, kScreenWidth-110, 22)];
    self.nameTextField.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    self.nameTextField.placeholder = @"请输入你的姓名";
    self.nameTextField.textColor = [UIColor blackColor];
    self.nameTextField.delegate = self;
    [self.view addSubview:self.nameTextField];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(26.0,self.nameTextField.bottom+12,kScreenWidth-51.0, 0.5)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:lineLbl];
    
    UILabel *gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(55, lineLbl.bottom+13, 100, 22)];
    gradeLab.text = @"选择年级";
    gradeLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    gradeLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    [self.view addSubview:gradeLab];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(55, gradeLab.bottom, kScreenWidth-110, 160)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.view addSubview:self.pickerView];
    
    UIButton *confirmButton = [[LoginButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0, self.pickerView.bottom+37.0,280, 55) title:@"确定"];
    [confirmButton addTarget:self action:@selector(confirmSetUserInfoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
}


@end
