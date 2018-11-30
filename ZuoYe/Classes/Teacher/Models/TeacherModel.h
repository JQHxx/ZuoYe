//
//  TeacherModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeacherModel : NSObject

@property (nonatomic,strong) NSNumber  *tch_id;          //老师编号
@property (nonatomic, copy ) NSString  *trait;           //头像
@property (nonatomic, copy ) NSString  *tch_name;        //老师姓名
@property (nonatomic, copy ) NSArray   *grade;           //年级
@property (nonatomic,strong) NSNumber  *guide_price;     //辅导价格
@property (nonatomic,strong) NSString  *tech_stage;      //教授阶段
@property (nonatomic, copy ) NSString  *level;       //等级
@property (nonatomic,strong) NSString  *subject;          //学科
@property (nonatomic,strong) NSNumber  *edu_exp;       //教龄
@property (nonatomic, copy ) NSString  *college;        //毕业学校
@property (nonatomic,strong) NSNumber  *score;           //评分
@property (nonatomic,strong) NSNumber  *online;          //是否在线
@property (nonatomic, copy ) NSString  *intro;           //简介
@property (nonatomic,strong) NSNumber  *stu_num;         //学生人数
@property (nonatomic,strong) NSNumber  *follower_num;    // 粉丝人数
@property (nonatomic,strong) NSNumber  *guide_num;       // 辅导次数
@property (nonatomic,strong) NSNumber  *check_num;       // 检查次数
@property (nonatomic,strong) NSNumber  *guide_time;       //辅导时长
@property (nonatomic,strong) NSNumber  *is_ID_auth;       //身份认证
@property (nonatomic,strong) NSNumber  *is_edu_auth;      //学历认证
@property (nonatomic,strong) NSNumber  *is_teach_auth;     //教师资质
@property (nonatomic,strong) NSNumber  *is_skill_auth;     //专业技能
@property (nonatomic,strong) NSNumber  *attention;         //是否关注 1 关注 0 未关注


@property (nonatomic, copy ) NSString  *third_id;
@property (nonatomic,strong) NSNumber  *job_id;
@property (nonatomic, copy ) NSArray   *job_pic;
@property (nonatomic,strong) NSNumber  *label;
@property (nonatomic, copy ) NSString  *orderId;

@end
