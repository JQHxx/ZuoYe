//
//  BannerModel.h
//  ZuoYe
//
//  Created by vision on 2018/11/5.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerModel : NSObject

@property (nonatomic ,strong )NSNumber *id;
@property (nonatomic ,copy )NSString *url;
@property (nonatomic ,copy )NSString *pic;
@property (nonatomic ,strong )NSNumber *cate;
@property (nonatomic ,copy )NSString *name;


@end

NS_ASSUME_NONNULL_END
