//
//  RecommandTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/9/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@interface RecommandTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *connectButton;      //连线老师

-(void)displayCellWithTeacher:(TeacherModel *)model;

@end
