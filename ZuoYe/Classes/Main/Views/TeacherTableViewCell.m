//
//  TeacherTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherTableViewCell.h"


@implementation TeacherTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.levelLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.levelLabel.layer.borderWidth = 1;
    self.levelLabel.layer.cornerRadius = 5;
    
}

#pragma mark 渲染数据
-(void)appleDataForCellWithTeacher:(TeacherModel *)model{
    UIImage *img = [UIImage imageNamed:model.head];
    self.headImageView.image = [img imageWithCornerRadius:32.5];
    self.nameLabel.text = model.name;
    self.levelLabel.text = model.level;
    self.scoreLabel.text = [NSString stringWithFormat:@"评分 %.1f",model.score];
    self.countLabel.text = [NSString stringWithFormat:@"辅导次数 %ld",model.count];
    NSString *tempStr = [NSString stringWithFormat:@"作业辅导价格：%.2f元/分钟",model.price];
    NSMutableAttributedString  *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7, tempStr.length-11)];
    self.priceLabel.attributedText = attributeStr;
}


@end
