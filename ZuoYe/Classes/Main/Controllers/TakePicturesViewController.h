//
//  TakePicturesViewController.h
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//



#import "BaseViewController.h"

typedef void(^ReturnBackBLock)(NSMutableArray *photosArray);

@interface TakePicturesViewController : BaseViewController

@property (nonatomic, assign)TutoringType type; //辅导类型

@property (nonatomic,assign) BOOL  isConnectionSetting;

@property (nonatomic, copy ) ReturnBackBLock backBlock;

@end
