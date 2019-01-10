//
//  AppDelegate.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "IQKeyboardManager.h"
#import "UIDevice+Extend.h"
#import "SSKeychain.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>
#import "YYModel.h"
#import "MyConnecttingViewController.h"
#import "TeacherModel.h"
#import <AVFoundation/AVFoundation.h>
#import <UMCommon/UMCommon.h>
#import <UMCommonLog/UMCommonLogHeaders.h>
#import <UMShare/UMShare.h>
#import <UMPush/UMessage.h>
#import "GuidanceViewController.h"
#import "NTESAVNotifier.h"
#import <PhotosUI/PhotosUI.h>

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<WXApiDelegate,NIMNetCallManagerDelegate,UNUserNotificationCenterDelegate,NIMLoginManagerDelegate>

@property (nonatomic,strong) NTESAVNotifier *notifier;


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setAppSystemConfigWithOptions:launchOptions];
    [self replyPushNotificationAuthorization:application]; //申请通知权限
    [self loadInitializeData];
    
    _notifier = [[NTESAVNotifier alloc] init];
    
    [NSUserDefaultsInfos removeObjectForKey:kCallingForID];
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    
    BOOL hasShowGuidance=[[NSUserDefaultsInfos getValueforKey:kShowGuidance] boolValue];
    if (!hasShowGuidance) {
        GuidanceViewController *guidanceVC=[[GuidanceViewController alloc] init];
        self.window.rootViewController=guidanceVC;
    }else{
        BOOL isLogin=[[NSUserDefaultsInfos getValueforKey:kIsLogin] boolValue];
        NSString *account = [NSUserDefaultsInfos getValueforKey:kUserThirdID];
        NSString *token = [NSUserDefaultsInfos getValueforKey:kUserThirdToken];
        if ( isLogin&&!kIsEmptyString(account)&&!kIsEmptyString(token)) {
            NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
            loginData.account = account;
            loginData.token = token;
            [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
            
            self.myTabBarController = [[MyTabBarController alloc] init];
            self.window.rootViewController = self.myTabBarController;
        } else {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:loginVC];
            self.window.rootViewController = nav;
        }
    }
    
    //检查是否从通知启动
    if(launchOptions){
        NSDictionary* remoteNotification=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self handleRecerceNotificationData:remoteNotification];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    MyLog(@"applicationWillResignActive");
    [self loadDataStatisticsWithIndex:2]; //app退到后台
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    MyLog(@"applicationDidEnterBackground");
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    MyLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    MyLog(@"applicationDidBecomeActive");
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOrderCheckResultWithNotification:) name:kOrderCheckSuccessNotification object:nil];
    [self loadDataStatisticsWithIndex:1];//app打开
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    MyLog(@"applicationWillTerminate");
    [NSUserDefaultsInfos removeObjectForKey:kCallingForID];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - UIApplicationDelegate
#pragma mark 跳转应用回调
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL UMReturned = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!UMReturned) {
        NSString *hostStr=[[url host] stringByRemovingPercentEncoding];
        MyLog(@"ios9.0以下 host:%@",hostStr);
        
        if ([hostStr isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPayBackNotification object:nil];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"alipay--error:%@",memo);
                }
            }];
        }else if ([hostStr isEqualToString:@"pay"]){
            [WXApi handleOpenURL:url delegate:self];
        }
    }
    return UMReturned;
}

#pragma mark 跳转应用回调 （9.0以后使用新API接口）
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    if (!result) {
        NSString *hostStr=[[url host] stringByRemovingPercentEncoding];
        MyLog(@"iOS9.0以上 host:%@",hostStr);
        
        if ([hostStr isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSInteger resultStatus=[[resultDic valueForKey:@"resultStatus"] integerValue];
                if (resultStatus==9000) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPayBackNotification object:nil];
                }else{
                    NSString *memo=[resultDic valueForKey:@"memo"];
                    MyLog(@"alipay--error:%@",memo);
                }
            }];
            
        }else if ([hostStr isEqualToString:@"pay"]){
            [WXApi handleOpenURL:url delegate:self];
        }
    }
    return result;
}

#pragma mark -iOS 10之前收到通知
#pragma mark 接收通知
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
     MyLog(@"didReceiveRemoteNotification  ----------------------  后台收到通知:%@", userInfo);
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    
    [self handleRecerceNotificationData:userInfo];

    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark 获取设备的DeviceToken
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
    [UMessage registerDeviceToken:deviceToken];
    MyLog(@"didRegisterForRemoteNotificationsWithDeviceToken,deviceToken:%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""]);
}

#pragma mark - UNUserNotificationCenterDelegate
#pragma mark iOS10 App处于前台接收通知时
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(UNNotificationPresentationOptions))completionHandler{
    //收到推送的内容
    UNNotificationContent *content = notification.request.content;
    //收到用户的基本信息
    NSDictionary * userInfo = content.userInfo;
    

    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        MyLog(@"iOS10 前台收到远程通知:%@",userInfo);
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
        [self handleRecerceNotificationData:userInfo];
    }else{
        // 判断为本地通知
        MyLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",content.body,content.title,content.subtitle,content.badge,content.sound,userInfo);
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

#pragma mark iOS10 通知的点击事件的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler{
    //收到推送的内容
    UNNotificationContent *content = response.notification.request.content;
    //收到用户的基本信息
    NSDictionary * userInfo = content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        MyLog(@"iOS10 点击收到远程通知:%@",userInfo);
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
       
        [self.myTabBarController handerUserNotificationWithUserInfo:userInfo];
        
    }else{
        // 判断为本地通知
        MyLog(@"iOS10 点击本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",content.body,content.title,content.subtitle,content.badge,content.sound,userInfo);
    }
}

#pragma mark -- Delegate
#pragma mark WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass: [PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
            {
                //服务器端查询支付通知或查询API返回的结果再提示成功
                MyLog(@"微信支付成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:kPayBackNotification object:nil];
            }
                break;
            default:
                MyLog(@"支付失败，retcode=%d",resp.errCode);
                break;
        }
    }
}

#pragma mark Notification
#pragma mark 显示作业检查
-(void)showOrderCheckResultWithNotification:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];
    [self.myTabBarController handerUserNotificationWithUserInfo:userInfo];
}

#pragma mark -- NIMNetCallManagerDelegate
#pragma mark 被叫收到呼叫
-(void)onReceive:(UInt64)callID from:(NSString *)caller type:(NIMNetCallMediaType)type message:(NSString *)extendMessage{
    NSNumber *callingID = [NSUserDefaultsInfos getValueforKey:kCallingForID];
    if (!kIsEmptyObject(callingID)||[callingID unsignedLongLongValue]>0) {
        [[NIMAVChatSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
    }else{
        NSDictionary *dic =(NSDictionary*)extendMessage;
        TeacherModel *model = [TeacherModel yy_modelWithJSON:dic];
        
        //震动
        [_notifier startVibrate];
      
        
        MyLog(@"被叫收到呼叫---caller:%@,type:%zd,extendMessage--%@,",caller,type,dic);
        //拿到顶部控制器(用来判断当前用户是否在通话中)
        self.myTabBarController = (MyTabBarController *)self.window.rootViewController;
        BaseNavigationController *nav = self.myTabBarController.viewControllers[self.myTabBarController.selectedIndex];
        MyConnecttingViewController *connecttingVC = [[MyConnecttingViewController alloc] initWithCaller:caller callId:callID];
        connecttingVC.hidesBottomBarWhenPushed = YES;
        connecttingVC.teacher = model;
        
        [nav pushViewController:connecttingVC animated:YES];
    }
}

#pragma mark -- NIMLoginManagerDelegate
#pragma mark 登录网易云回调
-(void)onLogin:(NIMLoginStep)step{
    MyLog(@"登录成功");
}

-(void)onAutoLoginFailed:(NSError *)error{
    MyLog(@"自动登录失败 onAutoLoginFailed %zd,error:%@",error.code,error.localizedDescription);
}

#pragma mark -- Private Methods
#pragma mark app配置
-(void)setAppSystemConfigWithOptions:(NSDictionary *)launchOptions{
    //键盘工具配置
    IQKeyboardManager *keyboardManager= [IQKeyboardManager sharedManager];   // 获取类库的单例变量
    keyboardManager.enable = YES;   // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
    keyboardManager.enableAutoToolbar = NO; // 控制是否显示键盘上的工具条
    
    //注册微信APPID
    [WXApi registerApp:kWechatAppKey];
    
    //网易云
    //推荐在程序启动的时候初始化 NIMSDK
    NSString *appKey        = kNIMSDKAppKey;
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername      = kNIMApnsCername;
    option.pkCername        = kNIMApnsCername;
    [[NIMSDK sharedSDK] registerWithOption:option];
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
    MyLog(@"App Started SDK Version %@\n SDK Info: %@",[[NIMSDK sharedSDK] sdkVersion],[NIMSDKConfig sharedConfig]);
    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    
    //友盟
    //数据统计
    [UMCommonLogManager setUpUMCommonLogManager]; //开启日志系统
    [UMConfigure setEncryptEnabled:YES];//打开加密传输
    [UMConfigure setLogEnabled:YES];//设置打开日志
    [UMConfigure initWithAppkey:kUMAppKey channel:@"App Store"]; //初始化
    
    
    NSString* deviceID =  [UMConfigure deviceIDForIntegration];
    MyLog(@"集成测试的deviceID:%@",deviceID);
    
    
    //分享
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWechatAppKey appSecret:kWechatAppSecret redirectURL:nil];
    //设置分享到QQ互联的appID
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQAppKey appSecret:nil redirectURL:nil];
    //设置新浪的appKey和appSecret
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kSinaAppKey appSecret:kSinaAppSecret redirectURL:@""];
    
    //友盟推送
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            MyLog(@"友盟推送 --- 用户选择了接收push消息");
        }else{
            MyLog(@"友盟推送 --- 用户选择了拒绝接收push消息");
        }
    }];
}

#pragma mark - 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    if (IOS10_OR_LATER) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                MyLog(@"申请通知权限--注册成功");
            }else{
                //用户点击不允许
                MyLog(@"申请通知权限--注册失败");
            }
        }];
        
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            MyLog(@"获取推送权限设置 ========%@",settings);
        }];
    }else if (IOS8_OR_LATER){
        //iOS 8 - iOS 10系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        //iOS 8.0系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

#pragma mark 加载初始数据
-(void)loadInitializeData{
    //获取年级
    NSArray *grades = [ZYHelper sharedZYHelper].grades;
    if (!kIsArray(grades)||grades.count==0) {
        [TCHttpRequest postMethodWithoutLoadingForURL:kGetGradeAPI body:nil success:^(id json) {
            NSArray *data = [json objectForKey:@"data"];
            [ZYHelper sharedZYHelper].grades = data;
        }];
    }
    
    //获取科目
    NSArray *subjects = [ZYHelper sharedZYHelper].subjects;
    if (!kIsArray(subjects)||subjects.count==0) {
        [TCHttpRequest postMethodWithoutLoadingForURL:kGetSubjectAPI body:nil success:^(id json) {
            NSArray *data = [json objectForKey:@"data"];
            [ZYHelper sharedZYHelper].subjects = data;
        }];
    }
    
    //上传设备信息
    NSString *retrieveuuid=[SSKeychain passwordForService:kDeviceIDFV account:@"useridfv"];
    NSString *uuid=nil;
    if (kIsEmptyObject(retrieveuuid)) {
        uuid=[UIDevice getIDFV];
        [SSKeychain setPassword:uuid forService:kDeviceIDFV account:@"useridfv"];
    }else{
        uuid=retrieveuuid;
    }
    
    NSString *body = [NSString stringWithFormat:@"version=%@&channel=appstore&deviceType=%@&deviceId=%@&sysVer=%@&platform=iOS&nation=%@&language=%@&wifi=%@",[UIDevice getSoftwareVer],[UIDevice getSystemName],uuid,[UIDevice getSystemVersion],[UIDevice getCountry],[UIDevice getLanguage],[NSNumber numberWithBool:[UIDevice isWifi]]];
    [TCHttpRequest postMethodWithoutLoadingForURL:kUploadDeviceInfoAPI body:body success:^(id json) {
        
    }];
}

#pragma mark 数据统计
-(void)loadDataStatisticsWithIndex:(NSInteger)index{
    NSString *token = kUserTokenValue;
    if (!kIsEmptyString(token)) {
        NSNumber *logid = [NSUserDefaultsInfos getValueforKey:kLogID];
        NSString *body = [NSString stringWithFormat:@"token=%@&label=%ld&logid=%@",token,index,logid];
        [TCHttpRequest postMethodWithoutLoadingForURL:kDataStatisticsAPI body:body success:^(id json) {
            
        }];
    }
}

#pragma mark 处理收到推送
-(void)handleRecerceNotificationData:(NSDictionary *)userInfo{
    if (kIsDictionary(userInfo)&&userInfo.count>0) {
        NSString *type = [userInfo valueForKey:@"cate"];
        if (!kIsEmptyString(type)) {
            if ([type isEqualToString:@"check"]) { //作业检查结果
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrderCheckSuccessNotification object:nil userInfo:userInfo];
            }else if ([type isEqualToString:@"checkAccept"]||[type isEqualToString:@"guideNowAccept"]||[type isEqualToString:@"guidePreAccept"]){ //接单消息
                [[NSNotificationCenter defaultCenter] postNotificationName:kHomeworkAcceptNotification object:nil userInfo:userInfo];
            }else if([type isEqualToString:@"guideCancel"]){
                if (self.myTabBarController) {
                    self.myTabBarController.selectedIndex = 0;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kGuideCancelNotification object:nil userInfo:userInfo];
            }else if ([type isEqualToString:@"cancel"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrderCancelNotification object:nil userInfo:userInfo];
            }
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[[NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[NIMAVChatSDK sharedSDK].netCallManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOrderCheckSuccessNotification object:nil];
}

@end
