//
//  CommentModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/18.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic , copy ) NSString  *head_image;
@property (nonatomic , copy ) NSString  *name;
@property (nonatomic ,assign) double    score;
@property (nonatomic , copy ) NSString  *create_time;
@property (nonatomic, strong) NSArray   *labels;
@property (nonatomic,  copy ) NSString  *comment;



@end
