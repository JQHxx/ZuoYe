//
//  TutorialModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeacherModel.h"

@interface TutorialModel : NSObject

@property (nonatomic , assign) NSInteger  type;            //辅导类型 0、作业检查 1、作业辅导
@property (nonatomic , copy )  NSString   *datetime;       //下单时间
@property (nonatomic , assign) NSInteger  state;           //订单状态 0、待付款 1、已完成 2、已取消
@property (nonatomic , copy )  NSString   *head_image;     //老师头像
@property (nonatomic , copy )  NSString   *name;           //老师姓名
@property (nonatomic , copy )  NSString   *level;          //老师等级
@property (nonatomic , copy )  NSString   *grade;          //年级
@property (nonatomic , copy )  NSString   *subject;        //科目
@property (nonatomic , copy )  NSString   *video_cover;    //视频封面图片
@property (nonatomic , copy )  NSString   *video_url;      //视频地址
@property (nonatomic , assign) double     check_price;      //检查价格
@property (nonatomic , assign) double     per_price;        //辅导价格
@property (nonatomic , assign) NSInteger  duration;         //辅导时长
@property (nonatomic , assign) double     pay_price;        //支付金额

@property (nonatomic , copy ) NSString  *order_sn;   //订单号
@property (nonatomic ,assign) NSInteger payway;   //支付方式
@property (nonatomic , copy ) NSString  *payTime;   //支付时间
@property (nonatomic ,strong) NSArray   *images;    //作业图片数组

@property (nonatomic ,strong) TeacherModel *teacher;

@end

