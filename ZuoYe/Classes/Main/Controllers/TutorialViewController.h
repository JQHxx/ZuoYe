//
//  TutorialViewController.h
//  ZuoYe
//
//  Created by vision on 2018/9/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"
#import "TeacherModel.h"
#import "NetCallChatInfo.h"

@interface TutorialViewController : BaseViewController

@property (nonatomic, strong) TeacherModel  *teacher;
@property (nonatomic, strong)  NetCallChatInfo *callInfo;

@end
