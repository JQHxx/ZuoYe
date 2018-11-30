//
//  HomeworkDetailsViewController.h
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeworkDetailsViewController : BaseViewController

@property (nonatomic ,strong) NSNumber *jobId;
@property (nonatomic ,strong) NSNumber *label;
@property (nonatomic ,assign) BOOL     isReceived; //是否接单

@end
