//
//  TutorialDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialDetailsViewController.h"
#import "ComplaintViewController.h"
#import "TutorialPayViewController.h"
#import "ConnectionSettingViewController.h"
#import "KRVideoPlayerController.h"
#import "STPopupController.h"
#import "TutorialViewController.h"
#import "PaySuccessViewController.h"
#import "ConnecttingViewController.h"
#import "JobPicsView.h"
#import "ComplainInfoViewController.h"
#import "ContactServiceViewController.h"
#import "CancelViewController.h"
#import "MyTutorialViewController.h"
#import "CommentViewController.h"

@interface TutorialDetailsViewController (){
    UILabel       *typeLabel;    //作业类型
    UILabel       *stateLabel;   //订单状态
    UIImageView   *headImageView;        //头像
    UILabel       *nameLab;              //姓名
    UILabel       *levelLab;             //教师等级 高级 中级
    UILabel       *gradeLab;             //年级/科目
    
    UILabel       *durationTitleLabel;   //辅导时长标题
    UILabel       *durationLabel;        //辅导时长
    
    UIImageView  *videoCoverImageView;
    
    UILabel       *amountTitleLabel;
    UILabel       *amountLabel;      //检查价格或辅导金额
    UILabel       *payAmountLabel;   //付款金额
    
    UILabel       *orderSnLabel;     //订单号
    UILabel       *orderTimeLabel;     //下单时间
    UILabel       *paywayLabel;        //支付方式
    UILabel       *payTimeLabel;       //支付时间
    
    UIButton      *connectServiceBtn;  //联系客服
    UIButton      *handleBtn;
    UIButton      *payButton;  //去付款
    UIButton      *cancelButton; //取消订单
    
    TutorialModel *model;
    ComplainModel *complainModel;
}

@property (nonatomic ,strong) UIScrollView *rootScrollView;
@property (nonatomic ,strong) UIView     *headView;
@property (nonatomic ,strong) JobPicsView  *jobPicsView;      //作业检查结果
@property (nonatomic ,strong) UIView     *videoView; //作业辅导视频封面图片
@property (nonatomic ,strong) UIView     *homeworkView;
@property (nonatomic ,strong) UIView     *amountView;
@property (nonatomic ,strong) UIView     *orderView;
@property (nonatomic ,strong) UIView     *payView;
@property (nonatomic ,strong) UIView      *bottomView;

@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation TutorialDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.baseTitle = @"订单详情";
    
    self.rigthTitleName = self.status>0&&self.status<3?@"投诉":@"";
    model = [[TutorialModel alloc] init];
    complainModel = [[ComplainModel alloc] init];
    
    [self initTutorialDetailsView];
    [self loadTutorialDetailsData];
}


#pragma mark -- Event Response
#pragma mark 投诉
-(void)rightNavigationItemAction{
    if (!kIsEmptyObject(complainModel)&&!kIsEmptyString(complainModel.complain)) {
        ComplainInfoViewController *complainInfoVC = [[ComplainInfoViewController alloc] init];
        complainInfoVC.myComplain = complainModel;
        [self.navigationController pushViewController:complainInfoVC animated:YES];
    }else{
        ComplaintViewController *complaintVC = [[ComplaintViewController alloc] init];
        complaintVC.oid = self.orderId;
        [self.navigationController pushViewController:complaintVC animated:YES];
    }
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    BOOL isMyTutorialIn = NO;
    for (BaseViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MyTutorialViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            isMyTutorialIn = YES;
            break;
        }
    }
    if (!isMyTutorialIn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark 回放
-(void)replayTutorialVideoAction:(UIButton *)sender{
    if (!kIsEmptyString(model.video_url)) {
      [self playVideoWithURL:[NSURL URLWithString:model.video_url]];
    }
}

#pragma mark 联系客服
-(void)connectSeriveAction:(UIButton *)sender{
    ContactServiceViewController *contactServiceVC = [[ContactServiceViewController alloc] init];
    [self.navigationController pushViewController:contactServiceVC animated:YES];
}

#pragma mark 按钮事件
-(void)handleAction:(UIButton *)sender{
    BOOL isOnline = [model.online boolValue];
    if (isOnline) {
        TeacherModel *teacher = [[TeacherModel alloc] init];
        teacher.tch_id = model.tch_id;
        teacher.tch_name = model.name;
        teacher.trait = model.trait;
        teacher.grade = @[model.grade];
        teacher.subject = model.subject;
        teacher.third_id = model.third_id;
        
        if ([model.label integerValue]<2) { //作业检查连线老师
            teacher.guide_price = model.guide_price;
            kSelfWeak;
            NSString * imgJsonStr = [TCHttpRequest getValueWithParams:model.pics];
            NSString *body = [NSString stringWithFormat:@"token=%@&images=%@&tid=%@&price=%@",kUserTokenValue,imgJsonStr,model.tch_id,model.guide_price];
            [TCHttpRequest postMethodWithURL:kConnectSettingAPI body:body success:^(id json) {
                NSDictionary *data = [json objectForKey:@"data"];
                teacher.job_pic = model.pics;
                teacher.job_id = data[@"jobid"];
                teacher.label = [NSNumber numberWithInteger:3];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:teacher.third_id];
                    connecttingVC.teacher = teacher;
                    connecttingVC.isOrderIn = NO;
                    [weakSelf.navigationController pushViewController:connecttingVC animated:YES];
                });
            }];
        }else{ //作业辅导
            if ([model.status integerValue]==0) {
                teacher.guide_price = model.price;
                teacher.job_pic = model.job_pic;
                teacher.job_id = model.jobid;
                teacher.orderId = model.oid;
                teacher.label = model.label;
                ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:model.third_id];
                connecttingVC.teacher = teacher;
                connecttingVC.isOrderIn = YES;
                [self.navigationController pushViewController:connecttingVC animated:YES];
            }else{
                teacher.guide_price = model.guide_price;
                ConnectionSettingViewController  *connectionSettingVC = [[ConnectionSettingViewController alloc] init];
                connectionSettingVC.teacherModel = teacher;
                [self.navigationController pushViewController:connectionSettingVC animated:YES];
            }
        }
    }else{
        [self.view makeToast:@"老师当前不在线，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }
}

#pragma mark
-(void)payOrderAction:(UIButton *)sender{
    TutorialPayViewController *payVC = [[TutorialPayViewController alloc] initWithIsOrderIn:YES];
    payVC.orderId = model.oid;
    payVC.duration = [model.job_time integerValue];
    payVC.guidePrice = model.price;
    payVC.payAmount = [model.pay_money doubleValue];
    payVC.label = [model.label integerValue]>1?2:1;
    kSelfWeak;
    payVC.backBlock = ^(id object) {
        if ([model.label integerValue]>1) {
            CommentViewController *commentVC = [[CommentViewController alloc] init];
            commentVC.orderId = model.oid;
            commentVC.tid = model.tch_id;
            [weakSelf.navigationController pushViewController:commentVC animated:YES];
        }else{
            PaySuccessViewController *paySuccessVC = [[PaySuccessViewController alloc] init];
            paySuccessVC.pay_amount = [object doubleValue];
            [weakSelf.navigationController pushViewController:paySuccessVC animated:YES];
        }
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark   取消订单
-(void)cancelCurrentOrderAction{
    CancelViewController *cancelVC = [[CancelViewController alloc] init];
    cancelVC.jobid = model.jobid;
    cancelVC.myTitle = [model.label integerValue]>1?@"取消辅导":@"取消检查";
    cancelVC.type = [model.label integerValue]>1?CancelTypeOrderCocah:CancelTypeOrderCheck;
    [self.navigationController pushViewController:cancelVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initTutorialDetailsView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.headView];
    [self.rootScrollView addSubview:self.jobPicsView];
    [self.rootScrollView addSubview:self.videoView];
    [self.rootScrollView addSubview:self.homeworkView];
    [self.rootScrollView addSubview:self.amountView];
    [self.rootScrollView addSubview:self.orderView];
    [self.rootScrollView addSubview:self.payView];
    [self.view addSubview:self.bottomView];
    
    self.rootScrollView.hidden = YES;
    self.bottomView.hidden = YES;
}

#pragma mark 加载数据
-(void)loadTutorialDetailsData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@",kUserTokenValue,self.orderId];
    [TCHttpRequest postMethodWithURL:kOrderDetailsAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dict = [json objectForKey:@"data"];
            [model setValues:dict];
            
            NSDictionary *complainDict = [dict valueForKey:@"complain"];
            [complainModel setValues:complainDict];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakSelf.rootScrollView.hidden = NO;
                weakSelf.bottomView.hidden = NO;
                //类型
                typeLabel.text = [model.label integerValue]==1?@"作业检查":@"作业辅导";
                //头像
                if (kIsEmptyString(model.trait)) {
                    headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
                }else{
                    [headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
                }
                //姓名
                nameLab.text = model.name;
                CGFloat nameW = [model.name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:nameLab.font].width;
                nameLab.frame = CGRectMake(headImageView.right+16.0,typeLabel.bottom+28.0, nameW, 20);
                //等级
                if (kIsEmptyString(model.level)) {
                    levelLab.hidden = YES;
                }else{
                    levelLab.hidden = NO;
                    levelLab.text = model.level;
                    levelLab.frame = CGRectMake(nameLab.right+7.0, typeLabel.bottom+30, 54, 15);
                }
                //年级/科目
                gradeLab.text = [NSString stringWithFormat:@"%@/%@",model.grade,model.subject];
                
                 if ([model.status integerValue]==0||[model.status integerValue]==3) {  //进行中或已取消
                    weakSelf.homeworkView.hidden = weakSelf.videoView.hidden = weakSelf.amountView.hidden =  weakSelf.payView.hidden =  connectServiceBtn.hidden = YES;
                     if ([model.status integerValue]==0) {
                         cancelButton.hidden = weakSelf.jobPicsView.hidden =  NO;
                         if ([model.label integerValue]>1) {
                             stateLabel.text = @"辅导中";
                             handleBtn.hidden = NO;
                             cancelButton.frame = CGRectMake(kScreenWidth-190, 11, 80,30);
                         }else{
                             stateLabel.text = @"检查中";
                             handleBtn.hidden = YES;
                             cancelButton.frame = CGRectMake(kScreenWidth-100, 11, 88, 30);
                         }
                     }else{
                         stateLabel.text =  @"已取消";
                         if ([model.label integerValue]<2) {
                             handleBtn.hidden = YES;
                             weakSelf.bottomView.hidden = YES;
                         }else{
                             handleBtn.hidden = NO;
                         }
                         cancelButton.hidden = YES;
                     }
                     if (kIsArray(model.job_pic)&&model.job_pic.count>0) {
                         CGFloat imgW = (kScreenWidth-45)/3.0; //图片宽高
                         NSInteger allNum = model.job_pic.count;
                         [weakSelf.jobPicsView updateCollectViewWithPhotosArr:[NSMutableArray arrayWithArray:model.job_pic]];
                         weakSelf.jobPicsView.frame = CGRectMake(0,self.headView.bottom, kScreenWidth, (imgW+5)*(1+(allNum-1)/3)+10);
                     }else{
                         weakSelf.jobPicsView.frame = CGRectZero;
                     }
                    [handleBtn setTitle:@"再次连线" forState:UIControlStateNormal];
                     payButton.hidden = YES;
                    weakSelf.orderView.frame = CGRectMake(0, self.jobPicsView.bottom+10, kScreenWidth, 72);
                }else if([model.status integerValue]==1||[model.status integerValue]==2){ //待付款或已完成
                    cancelButton.hidden = YES;
                     weakSelf.amountView.hidden = connectServiceBtn.hidden = NO;
                    if ([model.label integerValue]==1) { //作业检查
                        weakSelf.homeworkView.hidden = weakSelf.videoView.hidden = durationTitleLabel.hidden = durationLabel.hidden = YES;
                        weakSelf.jobPicsView.hidden = NO;
                        //设置检查图片
                        if (kIsArray(model.pics)&&model.pics.count>0) {
                            CGFloat imgW = (kScreenWidth-45)/3.0; //图片宽高
                            NSInteger allNum = model.pics.count;
                            [weakSelf.jobPicsView updateCollectViewWithPhotosArr:[NSMutableArray arrayWithArray:model.pics]];
                            weakSelf.jobPicsView.frame = CGRectMake(0,self.headView.bottom, kScreenWidth, (imgW+5)*(1+(allNum-1)/3)+10);
                        }else{
                            weakSelf.jobPicsView.frame = CGRectZero;
                        }
                        //检查价格
                        amountTitleLabel.text = @"检查价格：";
                        amountLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.pay_money doubleValue]]; //检查价格
                        
                        weakSelf.amountView.frame = CGRectMake(0, weakSelf.jobPicsView.bottom+10, kScreenWidth, 80);
                    }else{ //作业辅导
                        weakSelf.homeworkView.hidden = durationTitleLabel.hidden = durationLabel.hidden = NO;
                        
                        
                        //显示辅导视频封面
                        if (kIsEmptyString(model.video_url)) {
                            weakSelf.videoView.hidden =  YES;
                            weakSelf.jobPicsView.hidden = NO;
                            CGFloat imgW = (kScreenWidth-45)/3.0; //图片宽高
                            NSInteger allNum = model.job_pic.count;
                            [weakSelf.jobPicsView updateCollectViewWithPhotosArr:[NSMutableArray arrayWithArray:model.job_pic]];
                            weakSelf.jobPicsView.frame = CGRectMake(0,weakSelf.headView.bottom, kScreenWidth, (imgW+5)*(1+(allNum-1)/3)+10);
                            
                            weakSelf.homeworkView.frame = CGRectMake(0, weakSelf.jobPicsView.bottom, kScreenWidth, 30);
                        }else{
                            weakSelf.jobPicsView.hidden = YES;
                            weakSelf.videoView.hidden =  NO;
                            NSString *imgeUrl = [NSString stringWithFormat:@"%@?x-oss-process=video/snapshot,t_3,f_jpg",model.video_url];
                            [videoCoverImageView sd_setImageWithURL:[NSURL URLWithString:imgeUrl] placeholderImage:[UIImage imageNamed:@"video_playback"]];
                            weakSelf.homeworkView.frame = CGRectMake(0, weakSelf.videoView.bottom, kScreenWidth, 30);
                        }
                        
                        //辅导金额和辅导时长
                        amountTitleLabel.text = @"辅导金额：";
                        NSInteger jobTime = [model.job_time integerValue];
                        durationLabel.text = [NSString stringWithFormat:@"%ld分%ld秒",jobTime/60,jobTime%60];
                        amountLabel.text = [NSString stringWithFormat:@"%.2f元/分钟",[model.price doubleValue]]; //辅导价格
                        weakSelf.amountView.frame = CGRectMake(0, weakSelf.homeworkView.bottom+10, kScreenWidth, 80);
                    }
                    
                    //支付信息
                    if (!kIsEmptyObject(model.pay_money)) {
                        payAmountLabel.text = [NSString stringWithFormat:@"¥%.2f",[model.pay_money doubleValue]]; //付款金额
                    }
                    
                    if ([model.status integerValue]==1) {
                        stateLabel.text = @"待付款";
                        weakSelf.orderView.frame = CGRectMake(0, weakSelf.amountView.bottom, kScreenWidth, 72);
                        weakSelf.payView.hidden = YES;
                        weakSelf.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.orderView.top+self.orderView.height+10);
                        payButton.hidden = NO;
                        handleBtn.hidden = YES;
                    }else{
                        stateLabel.text = @"已完成";
                        if ([model.cate integerValue]==1) {
                            paywayLabel.text = @"支付宝支付";
                        }else if ([model.cate integerValue]==2){
                            paywayLabel.text = @"微信支付";
                        }else{
                            paywayLabel.text = @"余额支付";
                        }
                        payTimeLabel.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.pay_time format:@"yyyy-MM-dd HH:mm"];
                        
                        weakSelf.orderView.frame = CGRectMake(0, self.amountView.bottom, kScreenWidth, 62);
                        weakSelf.payView.hidden = NO;
                        weakSelf.payView.frame = CGRectMake(0, self.orderView.bottom, kScreenWidth, 62);
                        weakSelf.rootScrollView.contentSize = CGSizeMake(kScreenWidth, self.payView.top+self.payView.height+10);
                        
                        [handleBtn setTitle:[model.label integerValue]<2?@"连线老师":@"再次连线" forState:UIControlStateNormal];
                        payButton.hidden = YES;
                        handleBtn.hidden = NO;
                    }
                }
                //订单信息
                orderSnLabel.text = model.oid;
                orderTimeLabel.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.create_time format:@"yyyy-MM-dd HH:mm"];
                
            });
            
        });
    }];
}

#pragma mark -- Getters
#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-60)];
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _rootScrollView;
}

#pragma mark 老师信息
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 115)];
        _headView.backgroundColor = [UIColor whiteColor];
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 11,75, 20)];
        typeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        typeLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [_headView addSubview:typeLabel];
        
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100, 10,75, 20)];
        stateLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        stateLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        stateLabel.textAlignment = NSTextAlignmentRight;
        [_headView addSubview:stateLabel];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12.0, 38.0, kScreenWidth-12, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_headView addSubview:line];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.0,line.bottom+9.0, 52, 52)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [_headView addSubview:bgHeadImageView];
        
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.7, line.bottom+12.9, 46.6, 46.6)];
        headImageView.boderRadius = 23.3;
        [_headView addSubview:headImageView];
        
        nameLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+16.0,typeLabel.bottom+28.0, 65, 20)];
        nameLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_headView addSubview:nameLab];
        
        levelLab = [[UILabel alloc] initWithFrame:CGRectZero];
        levelLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        levelLab.textColor = [UIColor colorWithHexString:@"#FF9E1F"];
        levelLab.layer.cornerRadius = 7.5;
        levelLab.layer.borderWidth = 0.5;
        levelLab.textAlignment = NSTextAlignmentCenter;
        levelLab.layer.borderColor = [UIColor colorWithHexString:@"#FF9E1F"].CGColor;
        [_headView addSubview:levelLab];
        
        gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+16, nameLab.bottom, 90, 17)];
        gradeLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        gradeLab.textColor = [UIColor colorWithHexString:@"#808080"];
        [_headView addSubview:gradeLab];
    }
    return _headView;
}

#pragma mark 作业检查图片
-(JobPicsView *)jobPicsView{
    if (!_jobPicsView) {
        _jobPicsView = [[JobPicsView alloc] initWithFrame:CGRectZero];
    }
    return _jobPicsView;
}

#pragma mark 作业辅导视频封面
-(UIView *)videoView{
    if (!_videoView) {
        _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headView.bottom+10, kScreenWidth, 200)];
        _videoView.backgroundColor = [UIColor whiteColor];
        
        videoCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(28, 10, kScreenWidth-56, 180)];
        videoCoverImageView.image = [UIImage imageNamed:@"video_playback"];
        videoCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
        videoCoverImageView.clipsToBounds = YES;
        [_videoView addSubview:videoCoverImageView];
        
        UIButton *videoPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-40)/2.0,(200-40)/2.0,40, 40)];
        [videoPlayBtn setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateNormal];
        [videoPlayBtn addTarget:self action:@selector(replayTutorialVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [_videoView addSubview:videoPlayBtn];
    }
    return _videoView;
}

#pragma mark 作业辅导信息
-(UIView *)homeworkView{
    if (!_homeworkView) {
        _homeworkView = [[UIView alloc] initWithFrame:CGRectZero];
        _homeworkView.backgroundColor = [UIColor whiteColor];
        
        durationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18,5,80, 20)];
        durationTitleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        durationTitleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        durationTitleLabel.text = @"辅导时长：";
        [_homeworkView addSubview:durationTitleLabel];
        
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-100,5,83, 20)];
        durationLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        durationLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        durationLabel.textAlignment = NSTextAlignmentRight;
        [_homeworkView addSubview:durationLabel];
    }
    return _homeworkView;
}

#pragma mark 支付信息
-(UIView *)amountView{
    if (!_amountView) {
        _amountView = [[UIView alloc] initWithFrame:CGRectZero];
        _amountView.backgroundColor = [UIColor whiteColor];
        
        for (NSInteger i=0; i<2; i++) {
            UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18,12+(20+10)*i,80, 20)];
            titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            [_amountView addSubview:titleLabel];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180,titleLabel.top,162, 20)];
            valueLabel.textAlignment = NSTextAlignmentRight;
            [_amountView addSubview:valueLabel];
            
            if (i==0) {
                titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
                amountTitleLabel = titleLabel;
                valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
                valueLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
                amountLabel = valueLabel;
            }else{
                titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
                titleLabel.text = @"付款金额：";
                valueLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
                payAmountLabel = valueLabel;
            }
        }
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12.0, 79.0, kScreenWidth-12, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_amountView addSubview:line];
    }
    return _amountView;
}

#pragma mark 订单信息
-(UIView *)orderView{
    if (!_orderView) {
        _orderView = [[UIView alloc] initWithFrame:CGRectZero];
        _orderView.backgroundColor = [UIColor whiteColor];
        
        NSArray *titles = @[@"订单号",@"接单时间"];
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18,12+(20+6)*i,80, 20)];
            label.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            label.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            label.text = titles[i];
            [_orderView addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180,label.top,162, 20)];
            valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            valueLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            valueLabel.textAlignment = NSTextAlignmentRight;
            [_orderView addSubview:valueLabel];
            
            if (i==0) {
                orderSnLabel = valueLabel;
            }else{
                orderTimeLabel = valueLabel;
            }
        }
    }
    return _orderView;
}

#pragma mark 支付信息
-(UIView *)payView{
    if (!_payView) {
        _payView = [[UIView alloc] initWithFrame:CGRectZero];
        _payView.backgroundColor = [UIColor whiteColor];
        
        NSArray *titles = @[@"支付方式",@"支付时间"];
        for (NSInteger i=0; i<titles.count; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18,(20+6)*i,80, 20)];
            label.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            label.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            label.text = titles[i];
            [_payView addSubview:label];
            
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180,label.top,162, 20)];
            valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            valueLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
            valueLabel.textAlignment = NSTextAlignmentRight;
            [_payView addSubview:valueLabel];
            
            if (i==0) {
                paywayLabel = valueLabel;
            }else{
                payTimeLabel = valueLabel;
            }
        }
        
    }
    return _payView;
}


#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        connectServiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-200, 11, 88, 30)];
        [connectServiceBtn setTitle:@"联系客服" forState:UIControlStateNormal];
        [connectServiceBtn setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        connectServiceBtn.layer.cornerRadius = 14;
        connectServiceBtn.layer.borderColor = [UIColor colorWithHexString:@"#9B9B9B"].CGColor;
        connectServiceBtn.layer.borderWidth = 1.0;
        connectServiceBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [connectServiceBtn addTarget:self action:@selector(connectSeriveAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:connectServiceBtn];
        
        payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 5, 88, 40)];
        payButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [payButton setBackgroundImage:[UIImage imageNamed:@"button_2"] forState:UIControlStateNormal];
        [payButton setTitle:@"去付款" forState:UIControlStateNormal];
        [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [payButton addTarget:self action:@selector(payOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:payButton];
        payButton.hidden = YES;
        
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-190, 11, 80,30)];
        [cancelButton setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        cancelButton.layer.cornerRadius = 14;
        cancelButton.layer.borderColor = [UIColor colorWithHexString:@"#9B9B9B"].CGColor;
        cancelButton.layer.borderWidth = 1;
        cancelButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [cancelButton setTitle:@"取消订单" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelCurrentOrderAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:cancelButton];
        
        
        handleBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, 11, 88, 30)];
        [handleBtn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        handleBtn.layer.cornerRadius=14;
        handleBtn.layer.borderColor = [UIColor colorWithHexString:@"#FF6161"].CGColor;
        handleBtn.layer.borderWidth = 1;
        handleBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [handleBtn addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:handleBtn];
    }
    return _bottomView;
}

#pragma mark 视屏播放
- (void)playVideoWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:self.view.bounds];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = url;
}



@end
