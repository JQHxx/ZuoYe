//
//  LevelModel.h
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelModel : NSObject


@property (nonatomic, strong) NSNumber   *level;
@property (nonatomic, strong) NSNumber   *price;
@property (nonatomic,  copy ) NSString   *name;
@property (nonatomic,  copy ) NSString   *icon;
@property (nonatomic, assign) BOOL       isSelected;

@end
