//
//  MessageModel.h
//  ZYForTeacher
//
//  Created by vision on 2018/10/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (nonatomic,strong)NSNumber    *id;

@property (nonatomic, copy )NSNumber    *create_time; //创建时间
@property (nonatomic, copy )NSString    *myTitle;
@property (nonatomic, copy )NSString    *icon;
@property (nonatomic,strong)NSNumber    *count;


//系统消息
@property (nonatomic, copy )NSString    *title;
@property (nonatomic, copy )NSString    *desc;  //系统消息简介
@property (nonatomic, copy )NSString    *cover;  //系统消息简封面
@property (nonatomic, copy )NSString    *url;    //系统消息详情地址
@property (nonatomic, copy )NSString    *sys_msg_id;

//作业检查
@property (nonatomic, copy )NSString    *oid; //订单号
@property (nonatomic,strong)NSArray     *pics;
@property (nonatomic, copy )NSString    *tch_name;
@property (nonatomic, copy )NSString    *trait;
@property (nonatomic, copy )NSNumber    *checkded_time;

@end
