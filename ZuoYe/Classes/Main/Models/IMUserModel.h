//
//  IMUserModel.h
//  ZuoYe
//
//  Created by vision on 2018/11/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMUserModel : NSObject

@property (nonatomic ,copy ) NSString *IMId;
@property (nonatomic ,copy ) NSString *nickname;
@property (nonatomic ,copy ) NSString *avatarUrl;

@end

NS_ASSUME_NONNULL_END
