//
//  TutorialModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TutorialModel : NSObject

@property (nonatomic , assign) NSInteger type;
@property (nonatomic , copy )  NSString  *datetime;
@property (nonatomic , assign) NSInteger state;
@property (nonatomic , copy ) NSString   *head_image;
@property (nonatomic , copy ) NSString   *name;
@property (nonatomic , copy ) NSString   *level;
@property (nonatomic , copy ) NSString   *grade;
@property (nonatomic , copy ) NSString   *subject;
@property (nonatomic , copy ) NSString   *video_url;
@property (nonatomic , assign) double    check_price;
@property (nonatomic , assign) NSInteger    duration;
@property (nonatomic , assign) double    pay_price;

@end
