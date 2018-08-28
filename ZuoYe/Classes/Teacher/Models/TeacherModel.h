//
//  TeacherModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeacherModel : NSObject

@property (nonatomic, assign)NSInteger  id;
@property (nonatomic, copy )NSString    *head;    //头像
@property (nonatomic, copy )NSString    *name;    //姓名
@property (nonatomic, copy )NSString    *level;   //等级
@property (nonatomic, assign)NSInteger  schoolAge;   //教龄
@property (nonatomic, copy )NSString    *graduated_school;   //毕业学校
@property (nonatomic, copy )NSString    *grade;    //年级
@property (nonatomic, copy )NSString    *subjects;  //科目
@property (nonatomic, assign)double     score;     //评分
@property (nonatomic, assign)NSInteger  count;     //辅导次数
@property (nonatomic, assign)double     price;     //辅导价格
@property (nonatomic, assign)NSInteger  student_count;  //学生人数
@property (nonatomic, assign)NSInteger  fans_count;     //粉丝人数
@property (nonatomic, assign)NSInteger  tutoring_time;      //辅导时长
@property (nonatomic, assign)NSInteger  check_number;       //检查次数
@property (nonatomic, assign)BOOL       identity_authentication;       //身份认证
@property (nonatomic, assign)BOOL       teacher_qualification;          //教师资质
@property (nonatomic, assign)BOOL       education_certification;        //学历认证
@property (nonatomic, assign)BOOL       technical_skill;                //专业技能
@property (nonatomic, copy )NSString    *intro;                //简介
@property (nonatomic, assign)NSInteger  comment_count;




@end
