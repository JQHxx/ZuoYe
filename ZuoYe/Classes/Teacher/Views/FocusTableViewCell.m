//
//  FocusTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "FocusTableViewCell.h"

@interface FocusTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectsLabel;


@end

@implementation FocusTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.stateLabel.hidden = YES;
}

-(void)displayCellWithModel:(TeacherModel *)model{
    UIImage *img = [UIImage imageNamed:model.head];
    self.headImageView.image = [img imageWithCornerRadius:40.0];
    self.nameLabel.text = model.name;
    self.scoreLabel.text = [NSString stringWithFormat:@"评分 %.1f",model.score];
    self.subjectsLabel.text = [NSString stringWithFormat:@"%@/%@",model.grade,model.subjects];
}

@end
