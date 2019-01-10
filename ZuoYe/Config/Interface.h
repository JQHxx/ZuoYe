//
//  Interface.h
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#ifndef Interface_h
#define Interface_h


#endif /* Interface_h */


#define isTrueEnvironment 0

#if isTrueEnvironment
//正式环境
#define kHostURL @"https://www.zuoye101.com"
#define kHostTempURL @"https://www.zuoye101.com%@"

#define kNIMApnsCername     @"zuoye101APS"


#else
//测试环境
#define kHostURL @"https://test.zuoye101.com"
#define kHostTempURL @"https://test.zuoye101.com%@"

#define kNIMApnsCername     @"zuoye101"

#endif


#define  kZySecret   @"fe90839782da56bbd27a34b5b8f93a70"

//用户协议
#define kUserAgreementURL   @"https://zy.zuoye101.com/agreement.html"

#define kUploadDeviceInfoAPI   @"/student/device"            //上传设备信息
#define kGetGradeAPI           @"/student/job/grade"         //获取年级
#define kGetSubjectAPI         @"/student/job/subject"       //获取科目
#define kUploadPicAPI          @"/student/upload"            //上传头像
#define kUploadVideoAPI        @"/student/upload/video"      //上传视频
#define kDataStatisticsAPI     @"/student/logs/count"        //数据统计

/**学生管理***/
#define kGetCodeSign           @"/admin/code/get"            //发送手机验证码
#define kRegisterAPI           @"/student/user/register"     //注册
#define kLoginAPI              @"/student/user/login"        //登录
#define kCheckCodeAPI          @"/admin/code/check"          //验证验证码
#define kSetPwdAPI             @"/student/user/setPwd"       //修改密码
#define kSetUserInfoAPI        @"/student/user/setinfo"      //设置用户信息
#define kGetUserInfoAPI        @"/student/user/userinfo"      //获取用户信息

/***作业管理***/
#define kHomeAPI               @"/student"                    //首页
#define kJobPublishAPI         @"/student/job/publish"        //作业发布
#define kJobGuideAPI           @"/student/job/guide"          //作业辅导
#define kJobCheckAPI           @"/student/job/check"          //作业检查
#define kJobMineAPI            @"/student/job/mine"           //我的作业
#define kJobConncectAPI        @"/student/online/guide"        //预约时间到 连线老师
#define kJobDetailsAPI         @"/student/job/detail"         //作业详情
#define kJobCancelAPI          @"/student/job/cancel"         //未接单（已接单）取消
#define kCancelReasonAPI       @"/student/reason"             //获取取消原因
#define kJobCheckedAPI         @"/student/job/checked"        //作业检查结果反馈
#define kJobGuideCompleteAPI   @"/student/job/guided"         //结束辅导
#define kJobGuideTemptimeAPI   @"/student/job/guide_temp"     //辅导临时时间提交


/**老师管理***/
#define kGetTeachersAPI         @"/student/teacher"
#define kGetMoreTeachersAPI     @"/student/teacher/more"           //获取老师列表
#define kGetTeacherDetailsAPI   @"/student/teacher/detail"          //获取老师详情
#define kGetTeacherCommentsAPI  @"/student/teacher/discuss"         //获取老师评价列表
#define kTeacherCommentAPI      @"/student/teacher/comment"         //评论
#define kTeacherAttentionAPI    @"/student/teacher/attention"       //关注
#define kHomeTeachersAPI        @"/student/teacher/search"          //根据科目选老师
#define kConnectSettingAPI      @"/student/online/setting"          //连线设置
#define kConnectTeacherAPI      @"/student/online/connect"          //连线


/**订单管理**/
#define kOrderListAPI           @"/student/order"                  //我的订单
#define kOrderDetailsAPI        @"/student/order/detail"           //订单详情
#define kOrderCancelAPI         @"/student/order/cancel"           //取消订单
#define kOrderPayAPI            @"/student/order/pay"              //订单支付
#define kOrderComplaintAPI      @"/student/order/complain"          //订单投诉

/**账户管理**/
#define kWalletMineAPI          @"/student/wallet/mine"           //我的钱包
#define kWalletBillAPI          @"/student/wallet/bill"           //账单
#define kWalletRechargeAPI      @"/student/wallet/pay"            //充值


/**消息管理**/
#define kMessageUnreadAPI      @"/student/message/unread"         //未读消息
#define kMessageLastAPI        @"/student/message/lastMessage"    //最新消息
#define kMessageListAPI        @"/student/message"                //消息列表
#define kMessageReadAPI        @"/student/message/read"           //消息设为已读

/**支付管理**/
#define kGetPrePayOrderAPI      @"/student/wxpay/getPrePayOrder"   //获取预支付订单（微信）
#define kAliPayOrderAPI         @"/student/alipay/pay"          //支付宝支付

#define kFeedbackAPI           @"/student/setting/feedback"     //意见反馈


