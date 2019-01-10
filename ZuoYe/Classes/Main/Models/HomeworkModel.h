//
//  HomeworkModel.h
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeacherModel.h"

@interface HomeworkModel : NSObject

@property (nonatomic , strong ) NSNumber    *job_id;        //作业编号
@property (nonatomic , strong ) NSNumber    *label;         //作业类型
@property (nonatomic , strong ) NSNumber    *create_time;   //发布时间
@property (nonatomic , strong ) NSString    *grade;         //年级
@property (nonatomic , strong ) NSString    *subject;      //科目
@property (nonatomic ,  copy  ) NSArray     *images;       //作业图片数组
@property (nonatomic , strong ) NSNumber    *price;         //价格
@property (nonatomic ,   copy ) NSNumber    *start_time;    //开始辅导时间
@property (nonatomic ,   copy ) NSString    *job_pic;       //
@property (nonatomic , strong ) NSNumber    *is_receive;    //接单状态
@property (nonatomic , strong ) NSNumber    *yuyue;         //是否预约
@property (nonatomic , strong ) NSNumber    *tch_id;        //老师姓名
@property (nonatomic ,   copy ) NSString    *tch_name;       //老师姓名
@property (nonatomic ,   copy ) NSString    *trait;       //头像
@property (nonatomic , strong ) NSNumber    *score;       //评分

@property (nonatomic , copy) NSString    *third_id;       //云ID

@end
