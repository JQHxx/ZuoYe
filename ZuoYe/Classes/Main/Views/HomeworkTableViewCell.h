//
//  HomeworkTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeworkModel.h"

@interface HomeworkTableViewCell : UITableViewCell

-(void)displayCellWithHomework:(HomeworkModel *)model;


@end
