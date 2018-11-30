//
//  HomeworkDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkDetailsViewController.h"
#import "HomeworkViewController.h"
#import "CancelViewController.h"
#import "PhotosView.h"
#import "TeacherModel.h"
#import "HomeworkModel.h"
#import "YBPopupMenu.h"
#import <NIMSDK/NIMSDK.h>
#import "NIMSessionViewController.h"
#import "ConnecttingViewController.h"
#import "NSDate+Extension.h"

@interface HomeworkDetailsViewController ()<YBPopupMenuDelegate,NIMConversationManagerDelegate>{
    UILabel     *typeLabel;
    UILabel     *gradeLabel;
    UIImageView *orderImgView;
    UILabel     *orderTimeLab;
    UILabel     *priceLabel;
    UILabel     *stateLabel;
    UIImageView *stateImageView;
    
    UIImageView *headImageView;
    UILabel     *nameLabel;
    
    NSMutableArray *scoreArray;
    HomeworkModel *model;
    
    BOOL       isShowMore;
    
    UILabel    *menuBadgeLbl;
    
    UIButton  *contactButton;
}

@property (nonatomic, strong) UIButton     *rightItem;
@property (nonatomic ,strong) UILabel      *badgeLabel;          //红点
@property (nonatomic ,strong) UIScrollView *rootScrollView;
@property (nonatomic ,strong) UIView     *homeworkView;
@property (nonatomic ,strong) PhotosView *photosView;
@property (nonatomic ,strong) UIView     *teacherView;

@end

@implementation HomeworkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"作业详情";
    
    isShowMore = [self.label integerValue]==2&&self.isReceived;
    self.rigthTitleName = isShowMore?@"":@"取消";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    
    model = [[HomeworkModel alloc] init];
    
    [self initHomeworkDetailsView];
    [self loadHomeworkDetailData];
}

#pragma mark -- Delegate
#pragma mark YBPopupMenuDelegate
-(void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    if(index==0){
        CancelViewController *cancelVC = [[CancelViewController alloc] init];
        cancelVC.jobid = self.jobId;
        cancelVC.type = 1;
        cancelVC.myTitle = [model.label integerValue]<2?@"取消检查":@"取消辅导";
        [self.navigationController pushViewController:cancelVC animated:YES];
    }else{
        NIMSession *session = [NIMSession session:model.third_id type:NIMSessionTypeP2P];
        NIMSessionViewController *sessionVC = [[NIMSessionViewController alloc] initWithSession:session];
        [self.navigationController pushViewController:sessionVC animated:YES];
    }
}

#pragma mark NIMConversationManagerDelegate
#pragma mark 增加最近会话的回调
-(void)didAddRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount{
    MyLog(@"TutorialViewController didAddRecentSession-- totalUnreadCount:%ld",totalUnreadCount);
    self.badgeLabel.hidden = totalUnreadCount<1;
}

#pragma mark 最近会话修改的回调
-(void)didUpdateRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount{
    MyLog(@"TutorialViewController 更新会话 didUpdateRecentSession -- totalUnreadCount:%ld",totalUnreadCount);
    self.badgeLabel.hidden = totalUnreadCount<1;
}

#pragma mark 已读回调
-(void)allMessagesRead{
    self.badgeLabel.hidden = YES;
}

#pragma mark -- Event Response
#pragma mark 取消
-(void)rightNavigationItemAction{
    if (isShowMore) {
        NSArray *titles = @[@"取消辅导",@"消息"];
        kSelfWeak;
        [YBPopupMenu showRelyOnView:self.rightItem titles:titles icons:@[@"",@"",@""] menuWidth:100 otherSettings:^(YBPopupMenu *popupMenu) {
            popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
            popupMenu.borderWidth = 0.5;
            popupMenu.borderColor = [UIColor colorWithHexString:@"0xeeeeeee"];
            popupMenu.delegate = self;
            popupMenu.textColor = [UIColor colorWithHexString:@"0x626262"];
            popupMenu.fontSize = 14;
            
            if (menuBadgeLbl==nil) {
                menuBadgeLbl=[[UILabel alloc] initWithFrame:CGRectMake(50,65, 8, 8)];
                menuBadgeLbl.backgroundColor=[UIColor redColor];
                menuBadgeLbl.boderRadius = 4;
                [popupMenu addSubview:menuBadgeLbl];
            }
            menuBadgeLbl.hidden=weakSelf.badgeLabel.hidden;
        }];
    }else{
        if ([model.is_receive integerValue]<2) {
            kSelfWeak;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"取消作业" message:@"确定要取消该作业吗？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@",kUserTokenValue,weakSelf.jobId];
                [TCHttpRequest postMethodWithURL:kJobCancelAPI body:body success:^(id json) {
                    [ZYHelper sharedZYHelper].isUpdateHome = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:@"作业已取消" duration:1.0 position:CSToastPositionCenter];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        BOOL isHomework = NO;
                        for (BaseViewController *controller in weakSelf.navigationController.viewControllers) {
                            if ([controller isKindOfClass:[HomeworkViewController class]]) {
                                [ZYHelper sharedZYHelper].isUpdateHomework = YES;
                                [weakSelf.navigationController popToViewController:controller animated:YES];
                                isHomework = YES;
                                break;
                            }
                        }
                        if (!isHomework) {
                            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                        }
                    });
                }];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            CancelViewController *cancelVC = [[CancelViewController alloc] init];
            cancelVC.jobid = self.jobId;
            cancelVC.type = CancelTypeHomework;
            cancelVC.myTitle = @"取消辅导";
            [self.navigationController pushViewController:cancelVC animated:YES];
        }
    }
}

#pragma mark 联系老师
-(void)contactTeacherAction:(UIButton *)sender{
    TeacherModel *teacher = [[TeacherModel alloc] init];
    teacher.tch_name = model.tch_name;
    teacher.trait = model.trait;
    teacher.guide_price = model.price;
    teacher.job_id = self.jobId;
    teacher.subject = model.subject;
    teacher.job_pic = model.images;
    teacher.grade = @[model.grade];
    teacher.third_id = model.third_id;
   
    ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:teacher.third_id];
    connecttingVC.isHomeworkIn = YES;
    connecttingVC.teacher = teacher;
    [self.navigationController pushViewController:connecttingVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadHomeworkDetailData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@",kUserTokenValue,self.jobId];
    [TCHttpRequest postMethodWithURL:kJobDetailsAPI body:body success:^(id json) {
        NSDictionary *dict = [json objectForKey:@"data"];
        [model setValues:dict];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.rootScrollView.hidden = NO;
            typeLabel.text = [model.label integerValue]==1?@"作业检查":@"作业辅导";
            gradeLabel.text = [NSString stringWithFormat:@"%@/%@",model.grade,model.subject];
            
            NSString *tempStr = nil;
            if ([model.label integerValue]==1) {
                tempStr = [NSString stringWithFormat:@"检查价格：%.2f元",[model.price doubleValue]];
                orderImgView.hidden = orderTimeLab.hidden = YES;
            }else{
                tempStr = [NSString stringWithFormat:@"辅导价格：%.2f元/分钟",[model.price doubleValue]];
                orderImgView.hidden = orderTimeLab.hidden = ![model.yuyue boolValue];
                orderTimeLab.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.start_time format:@"MM/dd hh:mm"];
            }
            NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
            [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
            priceLabel.attributedText = attributeStr;
            
            weakSelf.photosView.photosArray = [NSMutableArray arrayWithArray:model.images];
            
            if ([model.is_receive integerValue]==1) {
                stateLabel.text = @"待接单";
                stateImageView.image = [UIImage imageNamed:@"order_wait_receipt"];
                weakSelf.teacherView.hidden = YES;
                weakSelf.rootScrollView.contentSize =CGSizeMake(kScreenWidth, weakSelf.photosView.top+weakSelf.photosView.height);
            }else{
                stateLabel.text = @"已接单";
                stateImageView.image = [UIImage imageNamed:@"order_already_received"];
                
                if (kIsEmptyString(model.trait)) {
                    headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
                }else{
                    [headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
                }
                
                nameLabel.text = model.tch_name;
                
                //加星级
                CGSize scoreSize = CGSizeMake(13, 13);
                double scoreNum = [model.score doubleValue];
                NSInteger oneScroe=(NSInteger)scoreNum;
                NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
                for (int i = 0; i<scoreArray.count; i++) {
                    UIImageView *scoreImage = scoreArray[i];
                    [scoreImage setFrame:CGRectMake(headImageView.right+13.0+(scoreSize.width+4.0)*i,nameLabel.bottom+5.0, scoreSize.width, scoreSize.height)];
                    if (i<= num-1) {
                        if ((i==num-1)&&scoreNum>oneScroe) {
                            scoreImage.image=[UIImage imageNamed:@"score_half"];
                        }
                    }else{
                        scoreImage.image=[UIImage imageNamed:@"score_gray"];
                    }
                }
                
                weakSelf.teacherView.hidden = NO;
                weakSelf.rootScrollView.contentSize =CGSizeMake(kScreenWidth, weakSelf.teacherView.top+weakSelf.teacherView.height);
                
                NSNumber *currentTime =[[ZYHelper sharedZYHelper] timeSwitchTimestamp:[NSDate currentFullDate] format:@"yyyy年MM月dd日 HH:mm:ss"];
                if ([model.start_time integerValue]>[currentTime integerValue]) {
                    contactButton.hidden = YES;
                }else{
                    contactButton.hidden = NO;
                }
            }
        });
    }];
}

#pragma mark 初始化
-(void)initHomeworkDetailsView{
    if (isShowMore) {
        [self.view addSubview:self.rightItem];
        [self.view addSubview:self.badgeLabel];
        self.badgeLabel.hidden = YES;
    }
    
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.homeworkView];
    [self.rootScrollView addSubview:self.photosView];
    [self.rootScrollView addSubview:self.teacherView];
    self.teacherView.hidden = YES;
    self.rootScrollView.contentSize =CGSizeMake(kScreenWidth, self.photosView.top+self.photosView.height);
    self.rootScrollView.hidden = YES;
}

#pragma mark -- Getters and Setters
#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-20)];
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rootScrollView;
}

#pragma mark 导航栏右按钮
-(UIButton *)rightItem{
    if (!_rightItem) {
        _rightItem = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, KStatusHeight+2, 40, 40)];
        [_rightItem setImage:[UIImage drawImageWithName:@"more" size:CGSizeMake(30, 9)] forState:UIControlStateNormal];
        [_rightItem addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightItem;
}

#pragma mark 红色标记
-(UILabel *)badgeLabel{
    if (!_badgeLabel) {
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-16, KStatusHeight+14, 8, 8)];
        _badgeLabel.boderRadius = 4.0;
        _badgeLabel.backgroundColor = [UIColor colorWithHexString:@"#F50000"];
    }
    return _badgeLabel;
}

#pragma mark 作业信息
-(UIView *)homeworkView{
    if (!_homeworkView) {
        _homeworkView = [[UIView alloc] initWithFrame:CGRectMake(10,9, kScreenWidth-20, 102)];
        _homeworkView.boderRadius = 4;
        _homeworkView.backgroundColor = [UIColor whiteColor];
        
        //辅导类型
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,13, 68, 22)];
        typeLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        typeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        typeLabel.layer.cornerRadius = 2.0;
        typeLabel.layer.borderColor = [UIColor colorWithHexString:@"#FF6161"].CGColor;
        typeLabel.layer.borderWidth = 1.0;
        typeLabel.textAlignment = NSTextAlignmentCenter;
        [_homeworkView addSubview:typeLabel];
        
        orderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(typeLabel.right+10, 16.6, 14.7, 14.7)];
        orderImgView.image = [UIImage imageNamed:@"order_time"];
        [_homeworkView addSubview:orderImgView];
        orderImgView.hidden = YES;
        
        //预约时间
        orderTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(orderImgView.right+5, 14, 100, 20)];
        orderTimeLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        orderTimeLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_homeworkView addSubview:orderTimeLab];
        orderTimeLab.hidden = YES;
        
        //年级/科目
        gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, typeLabel.bottom+10.0, 100, 20)];
        gradeLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_homeworkView addSubview:gradeLabel];
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, gradeLabel.bottom+4.0, 167.0, 20.0)];
        priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_homeworkView addSubview:priceLabel];
        
        //接单状态
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-85, 8.0, 52, 20.0)];
        stateLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        stateLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        stateLabel.textAlignment = NSTextAlignmentRight;
        [_homeworkView addSubview:stateLabel];
        
        stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-20-77, 44, 77, 58)];
        [_homeworkView addSubview:stateImageView];
    }
    return _homeworkView;
}

#pragma mark 图片
-(PhotosView *)photosView{
    if (!_photosView) {
        _photosView = [[PhotosView alloc] initWithFrame:CGRectMake(0, self.homeworkView.bottom+15, kScreenWidth, 360) bgColor:[UIColor bgColor_Gray]];
    }
    return _photosView;
}

#pragma mark 老师信息
-(UIView *)teacherView{
    if (!_teacherView) {
        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(10, self.photosView.bottom+10, kScreenWidth-20, 80)];
        _teacherView.boderRadius=4.0;
        _teacherView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [_teacherView addSubview:bgHeadImageView];
        
        //头像
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 14, 52, 52)];
        headImageView.boderRadius = 26.0;
        [_teacherView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13.0, 22.0, 60, 20)];
        nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_teacherView addSubview:nameLabel];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"score"]];
            [scoreArray addObject:scoreImage];
            [_teacherView addSubview:scoreImage];
        }
        
        contactButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-76, 11.0, 44.0, 60.0)];
        [contactButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [contactButton setTitle:@"联系老师" forState:UIControlStateNormal];
        [contactButton setTitleColor:[UIColor colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        contactButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        contactButton.imageEdgeInsets = UIEdgeInsetsMake(-(contactButton.height - contactButton.titleLabel.height- contactButton.titleLabel.y-16),0, 0, 0);
        contactButton.titleEdgeInsets = UIEdgeInsetsMake(contactButton.imageView.height+contactButton.imageView.y, -contactButton.imageView.width, 0, 0);
        [contactButton addTarget:self action:@selector(contactTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        [_teacherView addSubview:contactButton];
    }
    return _teacherView;
}

-(void)dealloc{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

@end
