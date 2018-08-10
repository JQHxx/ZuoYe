//
//  UserModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic, copy ) NSString  *head_image;
@property (nonatomic, copy ) NSString  *name;
@property (nonatomic,assign) NSInteger sex;
@property (nonatomic, copy ) NSString  *grade;
@property (nonatomic, copy ) NSString  *region;

@end
