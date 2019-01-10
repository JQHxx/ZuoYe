//
//  TutorialViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialViewController.h"
#import "TutorialPayViewController.h"
#import "STPopupController.h"
#import "CommentViewController.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>
#import "SVProgressHUD.h"
#import "WhiteboardManager.h"
#import "WhiteboardLines.h"
#import "WhiteboardPoint.h"
#import "WhiteboardDrawView.h"
#import "WhiteboardCmdHandler.h"
#import "MyTutorialViewController.h"
#import "SDPhotoBrowser.h"

@interface TutorialViewController ()<UIScrollViewDelegate,NIMNetCallManagerDelegate,WhiteboardCmdHandlerDelegate,WhiteboardManagerDelegate,NIMLoginManagerDelegate,SDPhotoBrowserDelegate>{
    NSInteger     allNum;
    NSInteger     timeCount;
    UILabel       *timeLabel;
    
    BOOL          isOtherEnd;  //对方结束辅导
    BOOL          isEndCoach;
    BOOL          isRecordingStop;  //录制停止

    NSInteger     currentWhiteboardIndex; //当前白板页码
    UILabel       *menuBadgeLbl;
}

@property (nonatomic, strong ) UIScrollView  *rootScrollView;
@property (nonatomic, strong ) UILabel       *countLabel;
@property (nonatomic, strong ) UIView        *callView;     //通话确认
@property (nonatomic, strong ) UIView        *examView;     //审题
@property (nonatomic, strong ) UIView        *toolBarView;  //底部工具栏
@property (nonatomic, strong ) WhiteboardCmdHandler  *cmdHander;
@property (nonatomic,  copy  ) NSString  *myUid;      //通信ID

@property (nonatomic, strong ) NSMutableArray  *whiteboardLinesArray; //
@property (nonatomic, strong ) NSMutableArray  *drawViewsArray;

@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    isOtherEnd = NO;
    
    _whiteboardLinesArray = [[NSMutableArray alloc] init];
    _drawViewsArray = [[NSMutableArray alloc] init];
    
    //设置扬声器
    BOOL setSpeakerSuccess = [[NIMAVChatSDK sharedSDK].netCallManager setSpeaker:YES];
    if (setSpeakerSuccess) {
        MyLog(@"设置扬声器成功");
    }else{
        MyLog(@"设置扬声器失败");
    }
    //切换成音频模式
    [[NIMAVChatSDK sharedSDK].netCallManager switchType:NIMNetCallMediaTypeAudio];
    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    
    _cmdHander = [[WhiteboardCmdHandler alloc] initWithDelegate:self];
    [[WhiteboardManager sharedWhiteboardManager] setDataHandler:_cmdHander];
    [[WhiteboardManager sharedWhiteboardManager] setDelegate:self];
    
    //获取通信ID
    _myUid = [[NIMSDK sharedSDK].loginManager currentAccount];
    MyLog(@"通信ID：%@",_myUid);
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    [self initTutorialView];
    [self createWhiteBoard];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"作业辅导"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelCurrentCoach) name:kOrderCancelNotification object:nil];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"作业辅导"];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOrderCancelNotification object:nil];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark -- Delegate
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView==self.rootScrollView) {
        NSInteger currentIndex = scrollView.contentOffset.x/kScreenWidth;
        self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld",currentIndex+1,allNum];
    }
}

#pragma mark NIMNetCallManagerDelegate
#pragma mark 点对点通话建立成功
-(void)onCallEstablished:(UInt64)callID{
    MyLog(@"点对点通话建立成功--onCallEstablished:%lld",callID);
    [NSUserDefaultsInfos putKey:kCallingForID andValue:[NSNumber numberWithUnsignedLongLong:callID]];
}

#pragma mark 通话异常断开
-(void)onCallDisconnected:(UInt64)callID withError:(NSError *)error{
    MyLog(@"通话异常断开--error:%@,callID:%lld",error.localizedDescription,callID);
    if (!isEndCoach) {
        if (callID==self.callInfo.callID) {
            [NSUserDefaultsInfos removeObjectForKey:kCallingForID];
            [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
            [self.view makeToast:@"通话异常断开，请重新连接" duration:1.0 position:CSToastPositionCenter];
            kSelfWeak;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf backAction];
            });
        }
    }
}

#pragma mark 收到对方网络通话控制信息，用于方便通话双方沟通信息
-(void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control{
    MyLog(@"收到对方网络通话控制信息,callID:%lld,user:%@,type:%zd",callID,user,control);
    if (callID==self.callInfo.callID) {
        if (control== NIMNetCallControlTypeBackground) {
            [self.timer setFireDate:[NSDate distantFuture]]; //关闭计时器
            [self.view makeToast:@"对方退到后台" duration:1.0 position:CSToastPositionCenter];
        }else if (control == NIMNetCallControlTypeFeedabck){
            [self.timer setFireDate:[NSDate distantPast]]; //开启计时器
            [self.view makeToast:@"对方回到前台" duration:1.0 position:CSToastPositionCenter];
        }
    }
}

#pragma mark 对方挂断电话
-(void)onHangup:(UInt64)callID by:(NSString *)user{
    MyLog(@"对方挂断电话--onHangup,callID:%lld",callID);
}


#pragma mark - WhiteboardManagerDelegate
#pragma mark 创建互动白板
-(void)onReserve:(NSString *)name result:(NSError *)result{
    if (result == nil) {
        NSError *result = [[WhiteboardManager sharedWhiteboardManager] joinConference:name];
        MyLog(@"join rts conference: %@ result %zd", name, result.code);
    }else {
        [self.view makeToast:[NSString stringWithFormat:@"创建互动白板出错:%zd", result.code]];
    }
}

#pragma mark 加入互动白板结果回调
-(void)onJoin:(NSString *)name result:(NSError *)result{
    
}

#pragma mark - NIMLoginManagerDelegate
-(void)onLogin:(NIMLoginStep)step{
    MyLog(@"NIMLoginManagerDelegate -- onLogin:%ld",step);
}

#pragma mark - WhiteboardCmdHandlerDelegate
#pragma mark 收到白板绘制指令
-(void)onReceivePoint:(WhiteboardPoint *)point from:(NSString *)sender{
    MyLog(@"onReceivePoint:%zd",point.type);
    WhiteboardLines *lines = _whiteboardLinesArray[currentWhiteboardIndex];
    [lines addPoint:point uid:sender];
    
    WhiteboardDrawView *drawView = _drawViewsArray[currentWhiteboardIndex];
    [drawView setNeedsDisplay];
}

#pragma mark 收到操作指令
- (void)onReceiveCmd:(WhiteBoardCmdType)type from:(NSString *)sender{
    MyLog(@"onReceiveCmd:%zd",type);
    
    if (type == WhiteBoardCmdTypeCancelLine||type==WhiteBoardCmdTypeClearLines) {  //撤销
        WhiteboardLines *lines = _whiteboardLinesArray[currentWhiteboardIndex];
        if (type==WhiteBoardCmdTypeCancelLine) {
            [lines cancelLastLine:sender];
        }else{
           [lines clear];
        }
        
    } else if (type == WhiteBoardCmdTypeExam) { //审题
        [self startExam];
    }else if (type == WhiteBoardCmdTypeStartCoach) { //开始辅导
        [self startCoach];
    }else if (type == WhiteBoardCmdTypeEndCoach){ //结束辅导
        isOtherEnd = YES;
        [self endHomeworkTutoringAction];
    }else if (type == WhiteBoardCmdTypeCancelCoach){ //取消辅导或退出app
        [self.view makeToast:@"对方取消当前辅导" duration:1.0 position:CSToastPositionCenter];
        [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
        kSelfWeak;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf backAction];
        });
    }
}

#pragma mark 收到白板操作
-(void)onReceiveBoardCmd:(WhiteBoardCmdType)type index:(NSInteger)index from:(NSString *)sender{
    MyLog(@"onReceiveBoardCmd:%zd,index:%ld",type,index);
    if (type==WhiteBoardCmdTypeAddWhiteboard) { //添加白板
        [self addWhiteboard];
        currentWhiteboardIndex = index;
    }else if (type==WhiteBoardCmdTypeChooseWhiteboard){ //选择白板
        WhiteboardDrawView *drawView = _drawViewsArray[index];
        [self.view bringSubviewToFront:drawView];
        currentWhiteboardIndex = index;
    }else if (type==WhiteBoardCmdTypeDeleteWhiteboard){//删除白板
        WhiteboardDrawView *drawView = _drawViewsArray[index];
        [drawView removeFromSuperview];
        drawView = nil;
        [_drawViewsArray removeObjectAtIndex:index];
        [_whiteboardLinesArray removeObjectAtIndex:index];
        
        if (index<currentWhiteboardIndex) {
            currentWhiteboardIndex--;
        }else if (index==currentWhiteboardIndex){
            if (currentWhiteboardIndex>0) {
                WhiteboardDrawView *drawView = _drawViewsArray[index-1];
                [self.view bringSubviewToFront:drawView];
                currentWhiteboardIndex--;
            }
        }
    }
}

#pragma mark - SDPhotoBrowserDelegate
#pragma mark 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    return [UIImage imageNamed:@"task_details_loading"];
}

#pragma mark
-(NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSString *imgUrl = self.teacher.job_pic[index];
    return [NSURL URLWithString:imgUrl];
}

#pragma mark -- NSNotification
#pragma mark APP回到前台
-(void)appEnterForeground:(UIApplication *)application{
    MyLog(@"APP回到前台 语音发送指令，control:%lld,type:%zd",self.callInfo.callID,NIMNetCallControlTypeFeedabck);
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeFeedabck];
    [self.timer setFireDate:[NSDate distantPast]]; //开启计时器
}

#pragma mark APP退到后台
-(void)appEnterBackground:(UIApplication *)application{
    MyLog(@"退出后台 语音发送指令，control:%lld,type:%zd",self.callInfo.callID,NIMNetCallControlTypeBackground);
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeBackground];
    [self.timer setFireDate:[NSDate distantFuture]]; //关闭计时器
    
    NSString *unSignStr = [NSString stringWithFormat:@"jobid=%@&temp_time=%ld&token=%@&key=%@",self.teacher.job_id,timeCount,kUserTokenValue,kZySecret];
    NSString *body = [NSString stringWithFormat:@"jobid=%@&temp_time=%ld&token=%@&sign=%@",self.teacher.job_id,timeCount,kUserTokenValue,[unSignStr MD5]];
    [TCHttpRequest postMethodWithoutLoadingForURL:kJobGuideTemptimeAPI body:body success:^(id json) {
        
    }];
}

#pragma mark 取消当前辅导
-(void)cancelCurrentCoach{
    [self.view makeToast:@"对方取消当前辅导" duration:1.0 position:CSToastPositionCenter];
    [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
    kSelfWeak;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf backAction];
    });
}

#pragma mark -- Private Methods
#pragma mark 创建白板房间
-(void)createWhiteBoard{
    NSString *conferenceName = [NSString stringWithFormat:@"%@-%@",@"tutorial",self.teacher.job_id];
    NSError *error = [[WhiteboardManager sharedWhiteboardManager] reserveConference:conferenceName];
    if (error) {
        MyLog(@"reserve rts conference:%@ error -- code:%ld,desc:%@",conferenceName,error.code,error.localizedDescription);
    }
}

#pragma mark 添加白板
-(void)addWhiteboard{
    WhiteboardDrawView *drawView = [[WhiteboardDrawView alloc] initWithFrame:CGRectMake(0, KStatusHeight+100, kScreenWidth, kScreenHeight-KStatusHeight-150)];
    drawView.backgroundColor = [UIColor whiteColor];
    
    WhiteboardLines *lines = [[WhiteboardLines alloc] init];
    drawView.dataSource = lines;
    
    [self.view addSubview:drawView];
    [_whiteboardLinesArray addObject:lines];
    [_drawViewsArray addObject:drawView];
}

#pragma mark 返回
-(void)backAction{
    [NSUserDefaultsInfos removeObjectForKey:kCallingForID];
    BOOL isOrderIn = NO;
    for (BaseViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MyTutorialViewController class]]) {
            isOrderIn = YES;
            [ZYHelper sharedZYHelper].isUpdateOrder = YES;
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
    if (!isOrderIn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark 点击作业图片
-(void)homeworkPicTapAction:(UITapGestureRecognizer *)gesture{
    NSInteger index = gesture.view.tag;
    
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = index;
    photoBrowser.imageCount = self.teacher.job_pic.count;
    photoBrowser.sourceImagesContainerView = self.rootScrollView;
    [photoBrowser show];
}

#pragma mark Public Methods
#pragma mark 开始审题
-(void)startExam{
    self.countLabel.frame = CGRectMake(kScreenWidth-40, kScreenHeight-86, 30, 22);
    [self.callView removeFromSuperview];
    self.callView = nil;
    [self.view addSubview:self.examView];
}

#pragma mark 开始辅导
-(void)startCoach{
    self.countLabel.frame = CGRectMake(kScreenWidth-50, KStatusHeight+60, 34, 22);
    [self.examView removeFromSuperview];
    self.examView = nil;
    
    [self.view addSubview:self.toolBarView];
    [self startCountTime];
}

#pragma mark -- Event Reponse
#pragma mark 结束辅导
-(void)endHomeworkTutoringAction{
    MyLog(@"结束辅导");
    isEndCoach = YES;
    if (isOtherEnd) {  //对方结束辅导
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@&job_time=%ld",kUserTokenValue,self.teacher.job_id,timeCount+[self.teacher.temp_time integerValue]];
        [self finishGuideRequestForBody:body];
    }else{
        kSelfWeak;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"结束辅导" message:@"确定要结束作业辅导吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (weakSelf.timer) {
                [weakSelf.timer invalidate];
                weakSelf.timer = nil;
            }
            NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@&job_time=%ld",kUserTokenValue,self.teacher.job_id,timeCount+[self.teacher.temp_time integerValue]];
            [weakSelf finishGuideRequestForBody:body];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initTutorialView{
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.countLabel];
    [self.view addSubview:self.callView];
}

#pragma mark 开始计时
-(void)startCountTime{
    timeCount = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(repeatShowTime:) userInfo:nil repeats:YES];
}

-(void)repeatShowTime:(NSTimer *)timer{
    timeCount++;
    timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",timeCount/3600,timeCount/60,timeCount%60];
}

#pragma mark 结束辅导
-(void)finishGuideRequestForBody:(NSString *)body{
    kSelfWeak;
    [TCHttpRequest postMethodWithURL:kJobGuideCompleteAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        [[NIMAVChatSDK sharedSDK].netCallManager hangup:weakSelf.callInfo.callID];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (!isOtherEnd) {
                [kKeyWindow makeToast:@"已结束当前作业辅导" duration:1.0 position:CSToastPositionCenter];
                [_cmdHander sendPureCmd:WhiteBoardCmdTypeEndCoach]; //发送结束辅导指令
            }else{
                [kKeyWindow makeToast:@"对方已结束当前作业辅导" duration:1.0 position:CSToastPositionCenter];
            }
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            TutorialPayViewController *payVC = [[TutorialPayViewController alloc] initWithIsOrderIn:NO];
            payVC.guidePrice = weakSelf.teacher.guide_price;
            payVC.duration = timeCount+[self.teacher.temp_time integerValue];
            payVC.orderId = data[@"oid"];
            payVC.label = 2;
            payVC.backBlock = ^(id object) {
                CommentViewController *commentVC = [[CommentViewController alloc] init];
                commentVC.orderId = data[@"oid"];
                commentVC.tid = weakSelf.teacher.tch_id;
                [weakSelf.navigationController pushViewController:commentVC animated:YES];
            };
            
            STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
            popupVC.style = STPopupStyleBottomSheet;
            popupVC.navigationBarHidden = YES;
            [popupVC presentInViewController:weakSelf];
        });

    }];
}

#pragma mark -- Getters
#pragma mark 根视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _rootScrollView.showsVerticalScrollIndicator = NO;
        _rootScrollView.delegate = self;
        _rootScrollView.pagingEnabled = YES;
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        
        allNum = self.teacher.job_pic.count;
        for (NSInteger i=0; i<self.teacher.job_pic.count; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight)];
            [imgView sd_setImageWithURL:[NSURL URLWithString:self.teacher.job_pic[i]] placeholderImage:[UIImage imageNamed:@"task_details_loading"]];
            [_rootScrollView addSubview:imgView];
            
            imgView.userInteractionEnabled = YES;
            imgView.tag = i;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeworkPicTapAction:)];
            [imgView addGestureRecognizer:tap];
        }
        _rootScrollView.contentSize = CGSizeMake(kScreenWidth*allNum, kScreenHeight);
    }
    return _rootScrollView;
}

#pragma mark 数量
-(UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-40, kScreenHeight-86, 30, 22)];
        _countLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _countLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _countLabel.text = [NSString stringWithFormat:@"1/%ld",allNum];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

#pragma mark 通话
-(UIView *)callView{
    if (!_callView) {
        _callView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-156, kScreenWidth, 156)];
        _callView.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 23, kScreenWidth, 133)];
        bgView.backgroundColor = [UIColor whiteColor];
        [_callView addSubview:bgView];
        
        UIImageView *callImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-72.0)/2.0,0.0,72, 72)];
        callImageView.image = [UIImage imageNamed:@"coach_call"];
        [_callView addSubview:callImageView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, kScreenWidth-60, 17)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        lab.textColor = [UIColor colorWithHexString:@"#808080"];
        lab.text = @"语音通话中...";
        [_callView addSubview:lab];
        
    }
    return _callView;
}

#pragma mark 审题
-(UIView *)examView{
    if (!_examView) {
        _examView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _examView.backgroundColor = [UIColor blackColor];
        _examView.alpha = 0.5;
        
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, kScreenWidth-30, 22)];
        tipsLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        tipsLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        tipsLabel.text = @"老师正在审题，审题阶段的时间不计费";
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_examView addSubview:tipsLabel];
    }
    return _examView;
}

#pragma mark 底部工具
-(UIView *)toolBarView{
    if (!_toolBarView) {
        _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
        _toolBarView.backgroundColor = [UIColor colorWithHexString:@"#F7F7F7"];
        
        UIImageView *timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(26, 15, 20, 20)];
        timeImageView.image = [UIImage imageNamed:@"coach_time"];
        [_toolBarView addSubview:timeImageView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.right+10, 10, 80, 30)];
        timeLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        timeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16.0];
        timeLabel.text = @"00:00:00";
        [_toolBarView addSubview:timeLabel];
        
        UIButton *endBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-95, 6, 85, 38)];
        [endBtn setImage:[UIImage imageNamed:@"coach_finish_button"] forState:UIControlStateNormal];
        [endBtn addTarget:self action:@selector(endHomeworkTutoringAction) forControlEvents:UIControlEventTouchUpInside];
        [_toolBarView addSubview:endBtn];
    }
    return _toolBarView;
}

-(void)dealloc{
    MyLog(@"dealloc--%@",NSStringFromClass([self class]));
    [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
    [NSUserDefaultsInfos removeObjectForKey:kCallingForID];
    [[WhiteboardManager sharedWhiteboardManager] leaveCurrentConference];
    [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


@end
