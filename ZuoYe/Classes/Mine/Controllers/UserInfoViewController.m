//
//  UserInfoViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "UserInfoViewController.h"
#import "BRPickerView.h"
#import "UserModel.h"
#import <NIMSDK/NIMSDK.h>

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSArray       *titlesArr;
    NSArray       *grades ;
    
    UITextField  *nameTextField;
    BOOL isSettingNickname;
    BOOL isSettingTrait;
}

@property (nonatomic, strong) UITableView *userTableView;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"个人信息";
    
    titlesArr = @[@"头像",@"姓名",@"性别",@"年级",@"地区"];
    grades = [ZYHelper sharedZYHelper].grades;
    
    [self.view addSubview:self.userTableView];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = titlesArr[indexPath.row];
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    
    cell.detailTextLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row==0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 90, 10, 60,60)];
        imgView.boderRadius = 30.0;
        if (kIsEmptyString(self.userModel.trait)) {
            imgView.image = [UIImage imageNamed:@"head_image"];
        }else{
            [imgView sd_setImageWithURL:[NSURL URLWithString:self.userModel.trait] placeholderImage:[UIImage imageNamed:@"head_image"]];
        }
        [cell.contentView addSubview:imgView];
    }else if (indexPath.row==1){
        cell.detailTextLabel.text = self.userModel.username;
    }else if (indexPath.row==2){
        cell.detailTextLabel.text = [self.userModel.sex integerValue]<2?@"男":@"女";
    }else if (indexPath.row==3){
        cell.detailTextLabel.text = self.userModel.grade;
    }else{
        cell.detailTextLabel.text = kIsEmptyString(self.userModel.province)?@"":[NSString stringWithFormat:@"%@ %@ %@",self.userModel.province,self.userModel.city,self.userModel.country];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self uploadUserHeadPhotos];
    }else if (indexPath.row == 1){
        [self setNickName];
    }else if (indexPath.row == 2){
        [self setUserSex];
    }else if (indexPath.row == 3){
        [self setUserGrade];
    }else if (indexPath.row == 4){
        [self setUserArea];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row==0?80:44;
}

#pragma mark--Delegate
#pragma mark UIImagePickerController
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage* curImage=[info objectForKey:UIImagePickerControllerEditedImage];
    curImage=[curImage cropImageWithSize:CGSizeMake(80, 80)];
    self.userModel.head_image = curImage;
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:curImage, nil];
    
    NSMutableArray *encodeImageArr = [[ZYHelper sharedZYHelper] imageDataProcessingWithImgArray:arr];
    NSString *encodeResult = [TCHttpRequest getValueWithParams:encodeImageArr];
    
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"pic=%@&dir=1",encodeResult];
    [TCHttpRequest postMethodWithURL:kUploadPicAPI body:body success:^(id json) {
        [ZYHelper sharedZYHelper].isUpdateUserInfo = YES;
        weakSelf.userModel.trait = [[json objectForKey:@"data"] objectAtIndex:0];
        [NSUserDefaultsInfos putKey:kUserHeadPic andValue:weakSelf.userModel.trait];
        isSettingTrait = YES;
        NSString *body = [NSString stringWithFormat:@"token=%@&trait=%@",kUserTokenValue,weakSelf.userModel.trait];
        [weakSelf modifyUserInfoWithParams:body];
    }];
}

#pragma mmark UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
    if (nameTextField==textField) {
        if ([textField.text length]<8) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark -- Private Methods
#pragma mark 修改个人信息
-(void)modifyUserInfoWithParams:(NSString *)params{
    kSelfWeak;
    [TCHttpRequest postMethodWithURL:kSetUserInfoAPI body:params success:^(id json) {
        if (isSettingNickname) {
            isSettingNickname = NO;
            [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(NIMUserInfoUpdateTagNick):weakSelf.userModel.username} completion:^(NSError * _Nullable error) {
                if (error) {
                    MyLog(@"用户信息托管失败,error:%@",error.localizedDescription);
                }else{
                    MyLog(@"用户信息托管成功");
                }
            }];
        }else if (isSettingTrait){
            isSettingTrait = NO;
            [[NIMSDK sharedSDK].userManager updateMyUserInfo:@{@(NIMUserInfoUpdateTagAvatar):weakSelf.userModel.trait} completion:^(NSError * _Nullable error) {
                if (error) {
                    MyLog(@"用户信息托管失败,error:%@",error.localizedDescription);
                }else{
                    MyLog(@"用户信息托管成功");
                }
            }];
        }
        [ZYHelper sharedZYHelper].isUpdateUserInfo = YES;
        [weakSelf.userTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
}


#pragma mark 上传图片
-(void)uploadUserHeadPhotos{
    [self addPhoto];
}

#pragma mark 昵称
-(void)setNickName{
    NSString *title = NSLocalizedString(@"设置姓名", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入姓名"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
        nameTextField = textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    kSelfWeak;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"姓名不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8){
            [weakSelf.view makeToast:@"姓名仅支持1-8个字符" duration:1.0 position:CSToastPositionCenter];
        }else{
            weakSelf.userModel.username = toBeString;
            isSettingNickname = YES;
            [NSUserDefaultsInfos putKey:kUserNickname andValue:weakSelf.userModel.username];
            NSString *body = [NSString stringWithFormat:@"token=%@&username=%@",kUserTokenValue,toBeString];
            [weakSelf modifyUserInfoWithParams:body];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    alertController.view.layer.cornerRadius = 20;
    alertController.view.layer.masksToBounds = YES;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 设置性别
-(void)setUserSex{
    NSArray *sexArr = @[@"男",@"女"];
    NSString *sexStr =[self.userModel.sex integerValue]<2?@"男":sexArr[[self.userModel.sex integerValue]-1];
    kSelfWeak;
    [BRStringPickerView showStringPickerWithTitle:@"选择性别" dataSource:sexArr defaultSelValue:sexStr isAutoSelect:NO resultBlock:^(id selectValue) {
        NSInteger sex = [sexArr indexOfObject:selectValue]+1;
        weakSelf.userModel.sex = [NSNumber numberWithInteger:sex];
        NSString *body = [NSString stringWithFormat:@"token=%@&sex=%ld",kUserTokenValue,sex];
        [weakSelf modifyUserInfoWithParams:body];
    }];
}

#pragma mark 设置年级
-(void)setUserGrade{
    kSelfWeak;
    [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:self.userModel.grade isAutoSelect:NO resultBlock:^(id selectValue) {
        NSInteger gradeInt = [grades indexOfObject:selectValue]+1;
        weakSelf.userModel.grade = selectValue;
        [NSUserDefaultsInfos putKey:kUserGrade andValue:weakSelf.userModel.grade];
        NSString *body = [NSString stringWithFormat:@"token=%@&grade=%ld",kUserTokenValue,gradeInt];
        [weakSelf modifyUserInfoWithParams:body];
    }];
}

#pragma mark 设置所在地区
-(void)setUserArea{
    kSelfWeak;
    [BRAddressPickerView showAddressPickerWithTitle:@"所在地区" defaultSelected:@[@0,@0,@0] isAutoSelect:NO resultBlock:^(NSArray *selectAddressArr) {
        weakSelf.userModel.province = selectAddressArr[0];
        weakSelf.userModel.city = selectAddressArr[1];
        weakSelf.userModel.country = selectAddressArr[2];
        NSString *body = [NSString stringWithFormat:@"token=%@&province=%@&city=%@&country=%@",kUserTokenValue,weakSelf.userModel.province,weakSelf.userModel.city,weakSelf.userModel.country];
        [weakSelf modifyUserInfoWithParams:body];
    }];
}

#pragma mark -- Getters
#pragma mark 用户信息
-(UITableView *)userTableView{
    if (!_userTableView) {
        _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight+10, kScreenWidth, kScreenHeight-kNavHeight-10) style:UITableViewStylePlain];
        _userTableView.dataSource = self;
        _userTableView.delegate = self;
        _userTableView.tableFooterView = [[UIView alloc] init];
    }
    return _userTableView;
}
@end
