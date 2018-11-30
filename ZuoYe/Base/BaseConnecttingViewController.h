//
//  BaseConnecttingViewController.h
//  ZYForTeacher
//
//  Created by vision on 2018/10/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <NIMAVChat/NIMAVChat.h>
#import "NetCallChatInfo.h"
#import "HomeworkModel.h"
#import "TeacherModel.h"

@interface BaseConnecttingViewController : BaseViewController

@property (nonatomic ,assign) BOOL   isOrderIn;

@property (nonatomic ,assign) BOOL   isHomeworkIn;

@property (nonatomic ,strong) TeacherModel *teacher;

@property (nonatomic ,strong)  NSNumber  *label;

@property (nonatomic,strong) NetCallChatInfo *callInfo;

@property (nonatomic,strong) AVAudioPlayer *player; //播放提示音

//主叫方是自己，发起通话，初始化方法
- (instancetype)initWithCallee:(NSString *)callee;
//被叫方是自己，接听界面，初始化方法
- (instancetype)initWithCaller:(NSString *)caller callId:(uint64_t)callID;

//接受或拒绝通话请求
-(void)responseFromCallWithAccept:(BOOL)accept;
//挂断
-(void)hangUp;

@end
