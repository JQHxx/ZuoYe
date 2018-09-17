//
//  SetValueModel.h
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetValueModel : NSObject

@property (nonatomic ,assign) NSInteger value_id;
@property (nonatomic , copy ) NSString *imgName;
@property (nonatomic , copy ) NSString *value;
@property (nonatomic , assign)BOOL     isSet;



@end
