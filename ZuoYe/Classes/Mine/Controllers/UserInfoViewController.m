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

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UserModel     *user;
    NSArray       *titlesArr;
}

@property (nonatomic, strong) UITableView *userTableView;

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"个人信息";
    
    titlesArr = @[@"头像",@"姓名",@"性别",@"年级",@"地区"];
    user = [[UserModel alloc] init];
    
    [self.view addSubview:self.userTableView];
    [self loadUserInfo];
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
        imgView.image = [user.headImage imageWithCornerRadius:30];
        [cell.contentView addSubview:imgView];
    }else if (indexPath.row==1){
        cell.detailTextLabel.text = user.name;
    }else if (indexPath.row==2){
        cell.detailTextLabel.text = user.sex == 1?@"男":@"女";
    }else if (indexPath.row==3){
        cell.detailTextLabel.text = user.grade;
    }else{
        cell.detailTextLabel.text = user.region;
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
    curImage=[curImage cropImageWithSize:CGSizeMake(160, 160)];
    user.headImage = curImage;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.userTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSData *imageData = UIImagePNGRepresentation(curImage);
    //将图片数据转化为64为加密字符串
    NSString *encodeResult = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *body=[NSString stringWithFormat:@"photo=%@",encodeResult];
    MyLog(@"body：%@",body);
}

#pragma mark -- Private Methods
-(void)loadUserInfo{
    user.head_image = @"ic_m_head";
    user.name = @"小明";
    user.sex = 1;
    user.grade = @"一年级";
    user.region = @"湖南长沙";
    [self.userTableView reloadData];
}

#pragma mark 上传图片
-(void)uploadUserHeadPhotos{
    [self addPhoto];
}

#pragma mark 昵称
-(void)setNickName{
    NSString *title = NSLocalizedString(@"设置昵称", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"取消", nil);
    NSString *okButtonTitle = NSLocalizedString(@"确定", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"请输入昵称"];
        [textField setTextAlignment:NSTextAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        textField.delegate=self;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    kSelfWeak;
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController.textFields.firstObject resignFirstResponder];
        alertController.textFields.firstObject.text = [alertController.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *toBeString=alertController.textFields.firstObject.text;
        if (toBeString.length<1) {
            [weakSelf.view makeToast:@"昵称不能为空" duration:1.0 position:CSToastPositionCenter];
        }else if (toBeString.length>8){
            [weakSelf.view makeToast:@"昵称仅支持1-8个字符" duration:1.0 position:CSToastPositionCenter];
        }else{
            user.name = toBeString;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [weakSelf.userTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    NSString *sexStr =user.sex>0?sexArr[user.sex-1]:@"男";
    kSelfWeak;
    [BRStringPickerView showStringPickerWithTitle:@"选择性别" dataSource:sexArr defaultSelValue:sexStr isAutoSelect:NO resultBlock:^(id selectValue) {
        user.sex = [sexArr indexOfObject:selectValue]+1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [weakSelf.userTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark 设置年级
-(void)setUserGrade{
    NSArray *grades = @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
    kSelfWeak;
    [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:user.grade isAutoSelect:NO resultBlock:^(id selectValue) {
        user.grade = selectValue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [weakSelf.userTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark 设置所在地区
-(void)setUserArea{
    kSelfWeak;
    [BRAddressPickerView showAddressPickerWithTitle:@"所在地区" defaultSelected:@[@0,@0,@0] isAutoSelect:NO resultBlock:^(NSArray *selectAddressArr) {
        user.region = [NSString stringWithFormat:@"%@%@%@",selectAddressArr[0],selectAddressArr[1],selectAddressArr[2]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
        [weakSelf.userTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

#pragma mark -- Getters
#pragma mark 用户信息
-(UITableView *)userTableView{
    if (!_userTableView) {
        _userTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _userTableView.dataSource = self;
        _userTableView.delegate = self;
        _userTableView.tableFooterView = [[UIView alloc] init];
    }
    return _userTableView;
}



@end
