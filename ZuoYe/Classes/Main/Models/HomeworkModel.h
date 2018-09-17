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

@property (nonatomic ,assign) NSInteger      type;          //辅导类型
@property (nonatomic ,strong) NSMutableArray     *images;       //作业图片数组
@property (nonatomic , copy ) NSString    *grade;        //年级
@property (nonatomic , copy ) NSString    *subject;      //科目
@property (nonatomic ,assign) double      perPrice;      //作业辅导 （元/分钟）
@property (nonatomic ,assign) double      check_price;    //作业检查价格
@property (nonatomic , copy ) NSString    *create_time;   //发布时间
@property (nonatomic ,assign) NSInteger   time_type;      //0、实时 1、预约
@property (nonatomic , copy ) NSString    *order_time;    //预约时间
@property (nonatomic ,assign) NSInteger    state;           //0、待接单 1、已接单待辅导 2、辅导中
@property (nonatomic , copy ) NSString    *head_image;      //老师头像
@property (nonatomic , copy ) NSString    *name;            //老师姓名
@property (nonatomic , copy ) NSString    *coverImage;

@property (nonatomic ,strong) TeacherModel *teacher;

@end
