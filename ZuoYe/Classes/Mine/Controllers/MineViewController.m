//
//  MineViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MineViewController.h"
#import "UserInfoViewController.h"

#define kImageViewHeight 120

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    NSArray               *titleArray;
    NSArray               *imagesArray;
    NSArray               *classesArray;
}

@property (nonatomic, strong) UITableView    *mineTableView;
@property (nonatomic, strong) UIImageView    *zoomImageView;    //背景图片
@property (nonatomic, strong) UIImageView    *headImageView;    //头像
@property (nonatomic, strong) UILabel        *nickNameLabel;    //昵称
@property (nonatomic, strong) UILabel        *gradeLabel;       //年级
@property (nonatomic, strong) UIImageView    *arrowImageView;   //箭头


@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    titleArray = @[@[@"我的订单",@"我的钱包"],@[@"使用帮助",@"分享邀请",@"联系客服"],@[@"设置"]];
    imagesArray = @[@[@"my_tutorship",@"my_wallet"],@[@"using_help",@"invitation",@"custom_service"],@[@"setup"]];
    classesArray = @[@[@"MyTutorial",@"MyWallet"],@[@"UseHelp",@"",@"ContactService"],@[@"Setup"]];
    
    [self initMineView];
    [self loadUserInfoData];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [titleArray[section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage drawImageWithName:imagesArray[indexPath.section][indexPath.row] size:CGSizeMake(22, 22)];
    cell.textLabel.text = titleArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *classStr = [NSString stringWithFormat:@"%@ViewController",classesArray[indexPath.section][indexPath.row]];
    Class aClass = NSClassFromString(classStr);
    BaseViewController *vc = (BaseViewController *)[[aClass alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y=scrollView.contentOffset.y;
    if (y < -kImageViewHeight) {
        CGRect frame=_zoomImageView.frame;
        frame.origin.y=y;
        frame.size.height=-y;
        _zoomImageView.frame=frame;
    }
}


#pragma mark -- Event response
#pragma mark 跳转到个人信息
-(void)gotoUserInfoVC{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark -- Private methods
#pragma mark 初始化界面
-(void)initMineView{
    [self.view addSubview:self.zoomImageView];
    
    UIImageView *headBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 46, 72.0, 72.0)];
    headBgImgView.image = [UIImage imageNamed:@"connection_head_image_white"];
    [self.zoomImageView addSubview:headBgImgView];
    
    [self.zoomImageView addSubview:self.headImageView];
    [self.zoomImageView addSubview:self.nickNameLabel];
    [self.zoomImageView addSubview:self.gradeLabel];
    [self.zoomImageView addSubview:self.arrowImageView];
    
    [self.view addSubview:self.mineTableView];
}

#pragma mark 加载数据
-(void)loadUserInfoData{
    UIImage *img = [UIImage imageNamed:@"head_image"];
    self.headImageView.image = [img imageWithCornerRadius:30.0];
    self.nickNameLabel.text = @"小明";
    self.gradeLabel.text = @"一年级/数学";
}


#pragma mark -- getters
#pragma mark 背景图片
-(UIImageView *)zoomImageView{
    if (!_zoomImageView) {
        _zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth*(296.0/750.0))];
        _zoomImageView.image = [UIImage imageNamed:@"my_background"];
        _zoomImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserInfoVC)];
        [_zoomImageView addGestureRecognizer:tap];
    }
    return _zoomImageView;
}

#pragma mark 我的主界面
-(UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.zoomImageView.bottom-10, kScreenWidth, kScreenHeight-kTabHeight-self.zoomImageView.bottom+10) style:UITableViewStyleGrouped];
        _mineTableView.dataSource = self;
        _mineTableView.delegate = self;
        _mineTableView.showsVerticalScrollIndicator=NO;
        _mineTableView.backgroundColor=[UIColor bgColor_Gray];
        _mineTableView.estimatedSectionHeaderHeight=0;
        _mineTableView.estimatedSectionFooterHeight=0;
        _mineTableView.scrollEnabled = NO;
        _mineTableView.topBoderRadius = 8.0;
    }
    return _mineTableView;
}

#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 49, 65.9, 65.9)];
    }
    return _headImageView;
}

#pragma mark 昵称
-(UILabel *)nickNameLabel{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+11.0,61.0, 100,25.0)];
        _nickNameLabel.textColor=[UIColor whiteColor];
        _nickNameLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
    }
    return _nickNameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+10, self.nickNameLabel.bottom, 80, 20)];
        _gradeLabel.textColor=[UIColor whiteColor];
        _gradeLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
    }
    return _gradeLabel;
}

#pragma mark 箭头
-(UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView= [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-28.0,67.0 ,9.0, 15.0)];
        _arrowImageView.image = [UIImage imageNamed:@"arrow_personal_information"];
    }
    return _arrowImageView;
}


@end
