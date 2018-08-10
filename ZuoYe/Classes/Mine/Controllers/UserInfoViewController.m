//
//  UserInfoViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "UserInfoViewController.h"

#import "UserModel.h"

@interface UserInfoViewController ()<UITableViewDelegate,UITableViewDataSource>{
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row==0) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 90, 10, 60,60)];
        UIImage *img = [UIImage imageNamed:user.head_image];
        imgView.image = [img imageWithCornerRadius:30];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row==0?80:44;
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
