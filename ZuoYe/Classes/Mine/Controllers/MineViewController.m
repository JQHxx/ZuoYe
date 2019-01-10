//
//  MineViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MineViewController.h"
#import "UserInfoViewController.h"
#import <UShareUI/UShareUI.h>
#import "MJRefresh.h"
#import "MyWalletView.h"
#import "MyWalletViewController.h"
#import "RechargeViewController.h"

#define kImageViewHeight 196

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,MyWalletViewDelegate>{
    NSArray               *titleArray;
    NSArray               *imagesArray;
    NSArray               *classesArray;
    
    UserModel             *user;
}

@property (nonatomic, strong) UITableView    *mineTableView;
@property (nonatomic, strong) UIView         *headView;
@property (nonatomic, strong) UIImageView    *zoomImageView;    //背景图片
@property (nonatomic, strong) MyWalletView   *myWalletView;
@property (nonatomic, strong) UIImageView    *headBgImgView;    //头像背景
@property (nonatomic, strong) UIImageView    *headImageView;    //头像
@property (nonatomic, strong) UILabel        *nickNameLabel;    //昵称
@property (nonatomic, strong) UILabel        *gradeLabel;       //年级
@property (nonatomic, strong) UIImageView    *arrowImageView;   //箭头



@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    user = [[UserModel alloc] init];
    
    titleArray = @[@[@"我的订单",@"我的钱包"],@[@"使用帮助",@"分享好友",@"联系客服"],@[@"设置"]];
    imagesArray = @[@[@"my_tutorship",@"my_wallet"],@[@"using_help",@"invitation",@"custom_service"],@[@"setup"]];
    classesArray = @[@[@"MyTutorial",@"MyWallet"],@[@"UserHelp",@"",@"ContactService"],@[@"Setup"]];
    
    [self initMineView];
    [self loadUserInfoData];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的"];
    
    if ([ZYHelper sharedZYHelper].isUpdateUserInfo) {
        [self loadUserInfoData];
        [ZYHelper sharedZYHelper].isUpdateUserInfo = NO;
    }
    if ([ZYHelper sharedZYHelper].isRechargeSuccess) {
        [self loadUserInfoData];
        [ZYHelper sharedZYHelper].isRechargeSuccess = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的"];
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
    
    if (indexPath.section==1&&indexPath.row==1) { //分享好友
        kSelfWeak;
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone)]];
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            //创建网页内容对象
            UIImage *image = [UIImage imageNamed:@"logo180"];
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"下载作业101" descr:@"中小学作业1对1在线辅导" thumImage:image];
            shareObject.webpageUrl = @"https://www.zuoye101.com/";
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:@"分享成功" duration:1.0 position:CSToastPositionCenter];
                    });
                } else {
                    if (error.code == 2009) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.view makeToast:@"您已取消分享" duration:1.0 position:CSToastPositionCenter];
                        });
                    }
                    MyLog(@"分享失败， error:%@",error.localizedDescription);
                }
            }];
        }];
        
    }else{
        NSString *classStr = [NSString stringWithFormat:@"%@ViewController",classesArray[indexPath.section][indexPath.row]];
        Class aClass = NSClassFromString(classStr);
        BaseViewController *vc = (BaseViewController *)[[aClass alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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

#pragma mark MyWalletViewDelegate
#pragma mark 我的钱包
-(void)myWalletViewShow{
    MyWalletViewController *myWalletVC = [[MyWalletViewController alloc] init];
    myWalletVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myWalletVC animated:YES];
}

#pragma mark 充值
-(void)myWalletViewToRecharge{
    RechargeViewController *rechargeVC = [[RechargeViewController alloc] init];
    rechargeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rechargeVC animated:YES];
}

#pragma mark -- Event response
#pragma mark 跳转到个人信息
-(void)gotoUserInfoVC{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.userModel = user;
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark -- Private methods
#pragma mark 初始化界面
-(void)initMineView{
    
    [self.view addSubview:self.mineTableView];
    self.mineTableView.tableHeaderView = self.headView;
    
    [self.headView addSubview:self.zoomImageView];
    [self.headView addSubview:self.myWalletView];
    [self.headView addSubview:self.headBgImgView];
    [self.headView addSubview:self.headImageView];
    [self.headView addSubview:self.nickNameLabel];
    [self.headView addSubview:self.gradeLabel];
    [self.headView addSubview:self.arrowImageView];
}

#pragma mark 加载数据
-(void)loadUserInfoData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithURL:kGetUserInfoAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        [user setValues:data];
        
        if (!kIsEmptyObject(user.credit)) {
            [NSUserDefaultsInfos putKey:kUserCredit andValue:user.credit];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.mineTableView.mj_header endRefreshing];
            if (kIsEmptyString(user.trait)) {
                weakSelf.headImageView.image = [UIImage imageNamed:@"head_image"];
            }else{
                [weakSelf.headImageView sd_setImageWithURL:[NSURL URLWithString:user.trait] placeholderImage:[UIImage imageNamed:@"head_image"]];
            }
            weakSelf.nickNameLabel.text = user.username;
            weakSelf.gradeLabel.text = user.grade;
            weakSelf.myWalletView.balance = [user.money doubleValue];
            weakSelf.myWalletView.myCredit = [user.credit doubleValue];
        });
    }];
}


#pragma mark -- getters
#pragma mark 我的主界面
-(UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight-kTabHeight) style:UITableViewStylePlain];
        _mineTableView.dataSource = self;
        _mineTableView.delegate = self;
        _mineTableView.showsVerticalScrollIndicator=NO;
        _mineTableView.backgroundColor=[UIColor bgColor_Gray];
        _mineTableView.estimatedSectionHeaderHeight=0;
        _mineTableView.estimatedSectionFooterHeight=0;
        if (@available(iOS 11.0, *)) {
            _mineTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadUserInfoData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _mineTableView.mj_header=header;
    }
    return _mineTableView;
}

#pragma mark
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 256)];
        _headView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _headView;
}

#pragma mark 背景图片
-(UIImageView *)zoomImageView{
    if (!_zoomImageView) {
        _zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kImageViewHeight)];
        _zoomImageView.image = [UIImage imageNamed:@"my_background"];
        _zoomImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserInfoVC)];
        [_zoomImageView addGestureRecognizer:tap];
    }
    return _zoomImageView;
}

#pragma mark 账户
-(MyWalletView *)myWalletView{
    if (!_myWalletView) {
        _myWalletView = [[MyWalletView alloc] initWithFrame:CGRectMake(10, 144, kScreenWidth-20, 102)];
        _myWalletView.boderRadius = 7.0;
        _myWalletView.delegate = self;
        _myWalletView.backgroundColor = [UIColor whiteColor];
    }
    return _myWalletView;
}

#pragma mark 头像背景
-(UIImageView *)headBgImgView{
    if (!_headBgImgView) {
        _headBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 46, 72.0, 72.0)];
        _headBgImgView.backgroundColor = [UIColor whiteColor];
        _headBgImgView.boderRadius = 36.0;
        _headBgImgView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;  //自动布局，自使用顶部
    }
    return _headBgImgView;
}

#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 49, 66, 66)];
        _headImageView.boderRadius = 33;
        _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin ;  //自动布局，自使用顶部
    }
    return _headImageView;
}

#pragma mark 昵称
-(UILabel *)nickNameLabel{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+11.0,61.0, 100,25.0)];
        _nickNameLabel.textColor=[UIColor whiteColor];
        _nickNameLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        _nickNameLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    }
    return _nickNameLabel;
}

#pragma mark 年级
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+11, self.nickNameLabel.bottom, 80, 20)];
        _gradeLabel.textColor=[UIColor whiteColor];
        _gradeLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        _gradeLabel.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    }
    return _gradeLabel;
}

#pragma mark 箭头
-(UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView= [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-28.0,67.0 ,9.0, 15.0)];
        _arrowImageView.image = [UIImage imageNamed:@"arrow_personal_information"];
        _arrowImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    }
    return _arrowImageView;
}


@end
