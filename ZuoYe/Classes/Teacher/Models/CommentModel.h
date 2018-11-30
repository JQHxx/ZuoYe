//
//  CommentModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/18.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentModel : NSObject

@property (nonatomic , copy ) NSString  *trait;
@property (nonatomic , copy ) NSString  *username;
@property (nonatomic ,strong) NSNumber  *score;
@property (nonatomic ,strong) NSNumber  *create_time;
@property (nonatomic,  copy ) NSString  *comment;



@end
