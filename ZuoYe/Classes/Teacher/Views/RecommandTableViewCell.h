//
//  RecommandTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@interface RecommandTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *connectTeacherBtn;


- (void)appleDataForRecommandTeacher:(TeacherModel *)model;

@end
