//
//  ZYHelper.h
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface ZYHelper : NSObject

singleton_interface(ZYHelper)

@property (nonatomic, assign) BOOL    isUpdateHome;   //是否刷新首页
@property (nonatomic, assign) BOOL    isUpdateMessageInfo;  //刷新消息
@property (nonatomic, assign) BOOL    isUpdateMessageUnread; //刷新未读消息
@property (nonatomic, assign) BOOL    isUpdateHomework; //刷新作业
@property (nonatomic, assign) BOOL    isUpdateUserInfo; //刷新用户信息
@property (nonatomic, assign) BOOL    isRechargeSuccess;   //充值成功
@property (nonatomic, assign) BOOL    isPayOrderSuccess;  //支付成功
@property (nonatomic, assign) BOOL    isUpdateOrder;   //刷新订单
@property (nonatomic, assign) BOOL    isUpdateFocusTeacher;
@property (nonatomic, assign) BOOL    isEndTutorial; //结束辅导

@property (nonatomic ,strong) NSArray *daysArray;
@property (nonatomic ,strong) NSArray *hoursArray;       //小时
@property (nonatomic ,strong) NSArray *minutesArray;     //分钟

@property (nonatomic , copy ) NSArray  *grades;  //年级
@property (nonatomic , copy ) NSArray  *subjects;  //科目

/*
 *根据年级获取科目
 *
 * @param grade 年级
 * @return 科目数组
 *
 */
-(NSArray *)getCourseForGrade:(NSString *)grade;

/*
 *
 *解析年级
 * @param grade 年级
 */
-(NSString *)parseToGradeStringForGrades:(NSArray *)gradesArr;


/**
 *@bref 时间戳转化为时间
 */
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format;

/**
 *@bref 将某个时间转化成 时间戳
 */
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format;

/**
 *@bref 其他数据转json数据
 */
-(NSString *)getValueWithParams:(id)params;

/*
 *@bref 对图片base64加密
 */
- (NSMutableArray *)imageDataProcessingWithImgArray:(NSMutableArray *)imgArray;

/*
 *获取视频第一帧图片
 */
-(UIImage *)getVideoPreViewImageWithUrl:(NSURL *)videoUrl;

@end

