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

#define kImageViewHeight 120

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITabBarControllerDelegate>{
    NSArray               *titleArray;
    NSArray               *imagesArray;
    NSArray               *classesArray;
    
    UserModel             *user;
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
    
    user = [[UserModel alloc] init];
    
    titleArray = @[@[@"我的订单",@"我的钱包"],@[@"使用帮助",@"分享好友",@"联系客服"],@[@"设置"]];
    imagesArray = @[@[@"my_tutorship",@"my_wallet"],@[@"using_help",@"invitation",@"custom_service"],@[@"setup"]];
    classesArray = @[@[@"MyTutorial",@"MyWallet"],@[@"UserHelp",@"",@"ContactService"],@[@"Setup"]];
    
    self.tabBarController.delegate = self;
    
    [self initMineView];
    [self loadUserInfoData];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZYHelper sharedZYHelper].isUpdateUserInfo) {
        [self loadUserInfoData];
        [ZYHelper sharedZYHelper].isUpdateUserInfo = NO;
    }
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
            shareObject.webpageUrl = @"http://zuoye101.com/";
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

#pragma mark - UITabBarControllerDelegate
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([tabBarController.selectedViewController isEqual:[tabBarController.viewControllers firstObject]]) {
        // 判断再次选中的是否为当前的控制器
        if ([viewController isEqual:tabBarController.selectedViewController]) {
            [self loadUserInfoData];
            return NO;
        }
    }
    return YES;
}


#pragma mark -- Event response
#pragma mark 跳转到个人信息
-(void)gotoUserInfoVC{
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    userInfoVC.userModel = user;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

#pragma mark -- Private methods
#pragma mark 初始化界面
-(void)initMineView{
    [self.view addSubview:self.zoomImageView];
    
    UIImageView *headBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 46, 72.0, 72.0)];
    headBgImgView.backgroundColor = [UIColor whiteColor];
    headBgImgView.boderRadius = 36.0;
    [self.zoomImageView addSubview:headBgImgView];
    
    [self.zoomImageView addSubview:self.headImageView];
    [self.zoomImageView addSubview:self.nickNameLabel];
    [self.zoomImageView addSubview:self.gradeLabel];
    [self.zoomImageView addSubview:self.arrowImageView];
    
    [self.view addSubview:self.mineTableView];
}

#pragma mark 加载数据
-(void)loadUserInfoData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithURL:kGetUserInfoAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        [user setValues:data];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (kIsEmptyString(user.trait)) {
                weakSelf.headImageView.image = [UIImage imageNamed:@"head_image"];
            }else{
                [weakSelf.headImageView sd_setImageWithURL:[NSURL URLWithString:user.trait] placeholderImage:[UIImage imageNamed:@"head_image"]];
            }
            weakSelf.nickNameLabel.text = user.username;
            weakSelf.gradeLabel.text = user.grade;
        });
    }];
}


#pragma mark -- getters
#pragma mark 背景图片
-(UIImageView *)zoomImageView{
    if (!_zoomImageView) {
        _zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 138.0)];
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
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 49, 66, 66)];
        _headImageView.boderRadius = 33;
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
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+11, self.nickNameLabel.bottom, 80, 20)];
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
