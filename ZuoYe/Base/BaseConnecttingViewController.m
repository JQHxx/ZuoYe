//
//  BaseConnecttingViewController.m
//  ZYForTeacher
//
//  Created by vision on 2018/10/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseConnecttingViewController.h"
#import "TutorialViewController.h"
#import <NIMSDK/NIMSDK.h>
#import "YYModel.h"

//十秒之后如果还是没有收到对方响应的control字段，则自己发起一个假的control，用来激活铃声并自己先进入房间
#define DelaySelfStartControlWarningTime 10
#define DelaySelfStartControlTime 30

@interface BaseConnecttingViewController ()<NIMNetCallManagerDelegate>{
    NSInteger   timeCount;
    NSTimer     *myTimer;
}

@end

@implementation BaseConnecttingViewController

#pragma mark 主叫方是自己，发起通话，初始化方法
-(instancetype)initWithCallee:(NSString *)callee{
    self =  [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo.callee = callee;
        self.callInfo.caller = [[NIMSDK sharedSDK].loginManager currentAccount];
    }
    return self;
}

#pragma mark 被叫方是自己，接听界面，初始化方法
-(instancetype)initWithCaller:(NSString *)caller callId:(uint64_t)callID{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo.caller = caller;
        self.callInfo.callee = [[NIMSDK sharedSDK].loginManager currentAccount];
        self.callInfo.callID = callID;
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        if (!self.callInfo) {
            _callInfo = [[NetCallChatInfo alloc] init];
        }
        [[NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:NIMAudioOutputDeviceSpeaker];//切换音频输出设备
        [[NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:NO]; //是否需要贴耳传感器监听
        //防止应用在后台状态，此时呼入，会走init但是不会走viewDidLoad,此时呼叫方挂断，导致被叫监听不到，界面无法消去的问题。
        id<NIMNetCallManager> manager = [NIMAVChatSDK sharedSDK].netCallManager;
        [manager addDelegate:self];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    kSelfWeak;
    [self checkServiceEnable:^(BOOL result) {
        if (result) {
            if (weakSelf.callInfo.callID) {   //被叫
                [weakSelf voiceCallStartByCallee];
            }else{ //主叫
                [weakSelf voiceCallStartByCaller];
            }
        }else{
            //用户禁用服务，干掉界面
            if (weakSelf.callInfo.callID) {
                //说明是被叫方
                [[NIMAVChatSDK sharedSDK].netCallManager response:weakSelf.callInfo.callID accept:NO option:nil completion:nil];
            }
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player stop];
    if (myTimer) {
        [myTimer invalidate];
        myTimer = nil;
    }
    [[NIMAVChatSDK sharedSDK].netCallManager removeDelegate:self];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark 发起语音通话请求
-(void)voiceCallStartByCaller{
    [self playConnnetRing];
    NSArray *callees = [NSArray arrayWithObjects:self.callInfo.callee, nil];
    //先初始化 option参数
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    //设置拓展信息
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.teacher.job_pic forKey:@"job_pic"];
    NSString *nickName = [NSUserDefaultsInfos getValueforKey:kUserNickname];
    NSString *headPic = [NSUserDefaultsInfos getValueforKey:kUserHeadPic];
    NSString *grade = [NSUserDefaultsInfos getValueforKey:kUserGrade];
    [dic setValue:headPic forKey:@"trait"];
    [dic setValue:nickName forKey:@"username"];
    [dic setValue:grade forKey:@"grade"];
    [dic setValue:self.teacher.subject forKey:@"subject"];
    [dic setValue:self.teacher.guide_price forKey:@"price"];
    [dic setValue:self.teacher.job_id forKey:@"job_id"];
    [dic setValue:kUserIDValue forKey:@"stu_id"];
    if (self.isOrderIn) {
        [dic setObject:self.teacher.label forKey:@"label"];
        [dic setObject:self.teacher.orderId forKey:@"oid"];
    }else{
      [dic setObject:[NSNumber numberWithInteger:3] forKey:@"label"];
    }
    NSString *cid = [[NIMSDK sharedSDK].loginManager currentAccount];
    [dic setValue:cid forKey:@"third_id"];
    
    NSString *jsonStr = [dic yy_modelToJSONString];
    
    option.extendMessage = jsonStr;
    
     MyLog(@"extendMessage:%@",jsonStr);
    
    option.apnsContent =  [NSString stringWithFormat:@"来自用户%@语音通话请求",kIsEmptyString(nickName)?@"":nickName];
    option.apnsSound = @"audio_connect.mp3";
    option.apnsWithPrefix = NO;
    
    kSelfWeak;
    [[NIMAVChatSDK sharedSDK].netCallManager start:callees type:NIMNetCallMediaTypeAudio option:option completion:^(NSError * _Nullable error, UInt64 callID) {
        if (!error) {
            weakSelf.callInfo.callID = callID;
            
            MyLog(@"你正在向 %@ 发起语音通话请求，callID:%lld",weakSelf.callInfo.callee,callID);
            
            if (!myTimer) {
                timeCount = 0;
                myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(connecttingForTimerAction:) userInfo:[NSNumber numberWithLongLong:callID] repeats:YES];
            }
        }else{
            MyLog(@"通话请求失败： %@",error.localizedDescription);
            [self hangUp];
        }
    }];
}

#pragma mark  接受或拒绝通话请求
-(void)responseFromCallWithAccept:(BOOL)accept{
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    kSelfWeak;
    [[NIMAVChatSDK sharedSDK].netCallManager response:self.callInfo.callID accept:accept option:option completion:^(NSError * _Nullable error, UInt64 callID) {
        if (!error) {
            [weakSelf.player stop];
            if (accept) {
                [ZYHelper sharedZYHelper].isUpdateHome = YES;
                TutorialViewController *tutorialVC = [[TutorialViewController alloc] init];
                tutorialVC.teacher = weakSelf.teacher;
                tutorialVC.callInfo = weakSelf.callInfo;
                [weakSelf.navigationController pushViewController:tutorialVC animated:YES];
            }else{
                [weakSelf.view makeToast:@"你拒绝了对方的语音通话请求" duration:1.0 position:CSToastPositionCenter];
                [weakSelf hangUp];
            }
        }else{
            MyLog(@"连接失败--error：%@",error.localizedDescription);
            [weakSelf hangUp];
        }
    }];
}

#pragma mark 挂断
-(void)hangUp{
    MyLog(@"hangup,callID:%lld",self.callInfo.callID);
    [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
    kSelfWeak;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf playHangUpRing];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark 收到语音通话请求
-(void)voiceCallStartByCallee{
    [self playReceiverRing];
}

#pragma mark 铃声 - 正在呼叫请稍后
-(void)playConnnetRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"audio_connect" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

#pragma mark 铃声 - 接收方铃声
- (void)playReceiverRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"audio_connect" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

#pragma mark 铃声 - 对方暂时无法接听
- (void)playHangUpRing{
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"audio_chat_tip_HangUp" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

#pragma mark 获取麦克风权限
- (void)checkServiceEnable:(void(^)(BOOL))result{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                if (result) {
                    result(YES);
                }
            }else {
                if (result) {
                    result(NO);
                }
                UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"麦克风权限受限,无法音视频聊天" message:@"如还想使用此功能，请在手机设置中打开麦克风"  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *act=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alert addAction:act];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark 计时操作
-(void)connecttingForTimerAction:(NSTimer *)aTimer{
    id userInfo = [aTimer userInfo];
    timeCount++;
    MyLog(@"callID:%lld,count:%ld",[userInfo longLongValue],timeCount);
    if (timeCount==DelaySelfStartControlWarningTime) { //10s
        [self.view makeToast:@"对方手机可能不在身边，请稍后再试" duration:1.0 position:CSToastPositionCenter];
    }else if (timeCount==DelaySelfStartControlTime){ //30s
        [self onControl:[userInfo longLongValue] from:self.callInfo.callee type:NIMNetCallControlTypeBusyLine];
    }
}

#pragma mark -- NIMNetCallManagerDelegate
#pragma mark 收到被叫响应回调
-(void)onResponse:(UInt64)callID from:(NSString *)callee accepted:(BOOL)accepted{
    if (self.callInfo.callID==callID) {
         [self.player stop];
        if (self.isHomeworkIn) {
            if (accepted) {
                kSelfWeak;
                NSString *body = [NSString stringWithFormat:@"token=%@&third_id=%@&jobid=%@",kUserTokenValue,self.teacher.third_id,self.teacher.job_id];
                [TCHttpRequest postMethodWithURL:kJobConncectAPI body:body success:^(id json) {
                    TutorialViewController *tutorialVC = [[TutorialViewController alloc] init];
                    tutorialVC.teacher = self.teacher;
                    tutorialVC.callInfo = self.callInfo;
                    [weakSelf.navigationController pushViewController:tutorialVC animated:YES];
                }];
            }else{
                [self.view makeToast:@"对方拒绝了你的语音通话请求" duration:1.0 position:CSToastPositionCenter];
                [self hangUp];
            }
        }else{
            if (self.isOrderIn) {
                if (accepted) {
                    TutorialViewController *tutorialVC = [[TutorialViewController alloc] init];
                    tutorialVC.teacher = self.teacher;
                    tutorialVC.callInfo = self.callInfo;
                    [self.navigationController pushViewController:tutorialVC animated:YES];
                }else{
                    [self.view makeToast:@"对方拒绝了你的语音通话请求" duration:1.0 position:CSToastPositionCenter];
                    [self hangUp];
                }
            }else{
                kSelfWeak;
                NSString *body = [NSString stringWithFormat:@"token=%@&third_id=%@&sure=%d&jobid=%@",kUserTokenValue,self.teacher.third_id,accepted?1:2,self.teacher.job_id];
                [TCHttpRequest postMethodWithURL:kConnectTeacherAPI body:body success:^(id json) {
                    [ZYHelper sharedZYHelper].isUpdateHome = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (accepted) {
                            TutorialViewController *tutorialVC = [[TutorialViewController alloc] init];
                            tutorialVC.teacher = weakSelf.teacher;
                            tutorialVC.callInfo = weakSelf.callInfo;
                            [weakSelf.navigationController pushViewController:tutorialVC animated:YES];
                        }else{
                            [weakSelf.view makeToast:@"对方拒绝了你的语音通话请求" duration:1.0 position:CSToastPositionCenter];
                            [weakSelf hangUp];
                        }
                    });
                }];
            }
        }
    }
}

#pragma mark 收到对方网络通话控制信息，用于方便通话双方沟通信息
-(void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control{
    MyLog(@"收到对方网络通话控制信息,control:%zd",control);
    
    if (user == [[NIMSDK sharedSDK].loginManager currentAccount]) {
        //多端登录时，自己会收到自己发出的控制指令，这里忽略他
        return;
    }
    
    if (callID != self.callInfo.callID) {
        return;
    }
    
    if (control == NIMNetCallControlTypeBusyLine) {
        if (self.isHomeworkIn||self.isOrderIn) {
            [self.view makeToast:@"暂时无人接听" duration:1.0 position:CSToastPositionCenter];
            [self hangUp];
        }else{
            NSString *body = [NSString stringWithFormat:@"token=%@&third_id=%@&sure=%d&jobid=%@",kUserTokenValue,self.teacher.third_id,2,self.teacher.job_id];
            [TCHttpRequest postMethodWithoutLoadingForURL:kConnectTeacherAPI body:body success:^(id json) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.view makeToast:@"暂时无人接听" duration:1.0 position:CSToastPositionCenter];
                    [self hangUp];
                });
            }];
        }
    }
}


#pragma mark 对方挂断电话
-(void)onHangup:(UInt64)callID by:(NSString *)user{
    MyLog(@"对方挂断电话--onHangup");
    [self.view makeToast:@"对方挂断电话" duration:1.0 position:CSToastPositionCenter];
    [self hangUp];
}

#pragma mark 通话异常断开
-(void)onCallDisconnected:(UInt64)callID withError:(NSError *)error{
    MyLog(@"通话异常断开--error:%@",error.localizedDescription);
    [self.view makeToast:@"连接异常断开，请重新连接" duration:1.0 position:CSToastPositionCenter];
    kSelfWeak;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf hangUp];
    });
}

@end
