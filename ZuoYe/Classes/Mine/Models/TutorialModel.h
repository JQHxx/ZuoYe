//
//  TutorialModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TutorialModel : NSObject

@property (nonatomic , copy )  NSString   *oid;             //订单号
@property (nonatomic , strong) NSNumber   *jobid;          //作业id
@property (nonatomic , strong) NSNumber  *label;            //辅导类型 1、作业检查 2、作业辅导预约 3、作业辅导实时
@property (nonatomic ,strong)  NSNumber   *price;          //价格
@property (nonatomic ,strong)  NSNumber   *create_time;    //下单时间
@property (nonatomic ,strong)  NSNumber   *status;          //订单状态 0检查中 1待付款 2已完成 3已取消 5已评价
@property (nonatomic , copy )  NSString   *cover;           //视频封面图片
@property (nonatomic , copy )  NSString   *video_url;      //视频地址
@property (nonatomic ,strong)  NSNumber   *job_time;        //辅导时长
@property (nonatomic ,strong)  NSNumber   *pay_time;        //支付时间
@property (nonatomic ,strong)  NSNumber   *cate;            //支付金额
@property (nonatomic ,strong)  NSNumber   *pay_money;       //支付金额
@property (nonatomic ,strong)  NSArray    *job_pic;         //作业原始图片数组
@property (nonatomic ,strong)  NSArray    *pics;            //作业检查结果图片数组

@property (nonatomic ,strong) NSNumber    *online;
@property (nonatomic ,strong) NSNumber    *temp_time;


//老师信息
@property (nonatomic ,strong)  NSNumber   *tch_id;         //老师id
@property (nonatomic , copy )  NSString   *name;           //老师姓名
@property (nonatomic , copy )  NSString   *trait;          //老师头像
@property (nonatomic ,strong)  NSNumber   *guide_price;     //辅导价格
@property (nonatomic , copy )  NSString   *grade;          //年级
@property (nonatomic , copy )  NSString   *subject;        //科目
@property (nonatomic , copy )  NSString   *level;          //老师等级
@property (nonatomic , copy )  NSString  *third_id;


@end

@interface ComplainModel :NSObject

@property (nonatomic,strong) NSNumber *label;
@property (nonatomic, copy ) NSString *complain;

@end

