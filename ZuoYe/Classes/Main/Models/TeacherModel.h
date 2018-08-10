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
@property (nonatomic, copy )NSString    *grade;    //年级
@property (nonatomic, copy )NSString    *subjects;  //科目
@property (nonatomic, assign)double     score;     //评分
@property (nonatomic, assign)NSInteger  count;     //辅导次数
@property (nonatomic, assign)double     price;     //辅导价格

@end
