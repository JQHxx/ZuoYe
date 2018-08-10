//
//  RecommandTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RecommandTableViewCell.h"

@interface RecommandTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectsLabel;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation RecommandTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)appleDataForRecommandTeacher:(TeacherModel *)model{
    UIImage *img = [UIImage imageNamed:model.head];
    self.headImageView.image = [img imageWithCornerRadius:40.0];
    self.nameLabel.text = model.name;
    self.subjectsLabel.text = [NSString stringWithFormat:@"%@/%@",model.grade,model.subjects];
    self.experienceLabel.text = [NSString stringWithFormat:@"教学经验：%ld年",model.schoolAge];
    self.countLabel.text = [NSString stringWithFormat:@"辅导次数 %ld",model.count];
    self.scoreLabel.text = [NSString stringWithFormat:@"评分 %.1f",model.score];
    NSString *tempStr = [NSString stringWithFormat:@"作业辅导价格：%.2f元/分钟",model.price];
    NSMutableAttributedString  *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(7, tempStr.length-11)];
    self.priceLabel.attributedText = attributeStr;
}


@end
