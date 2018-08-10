//
//  TeacherTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@interface TeacherTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;   //头像
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;           //姓名
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;          //等级
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;          //评分
@property (weak, nonatomic) IBOutlet UILabel *countLabel;          //辅导次数
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;          //辅导价格
@property (weak, nonatomic) IBOutlet UIButton *connectButton;      //连线老师


-(void)appleDataForCellWithTeacher:(TeacherModel *)model;

@end
