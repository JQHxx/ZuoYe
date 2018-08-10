//
//  FocusTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@interface FocusTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

-(void)displayCellWithModel:(TeacherModel *)model;

@end
