//
//  TutorialPayViewController.h
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"

@interface TutorialPayViewController : BaseViewController

-(instancetype)initWithIsOrderIn:(BOOL)isOrderIn;

@property (nonatomic ,strong) NSString    *orderId;
@property (nonatomic ,strong) NSNumber    *guidePrice; //辅导价格
@property (nonatomic ,assign) NSInteger   duration; //辅导时长
@property (nonatomic ,assign) NSInteger   label;
@property (nonatomic ,assign) double      payAmount;  //应付金额

@end
