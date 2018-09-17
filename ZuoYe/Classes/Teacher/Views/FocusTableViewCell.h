//
//  FocusTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@interface FocusTableViewCell : UITableViewCell


@property (strong, nonatomic) UIButton *connectButton;      //连线老师

-(void)displayCellWithModel:(TeacherModel *)model;

@end
