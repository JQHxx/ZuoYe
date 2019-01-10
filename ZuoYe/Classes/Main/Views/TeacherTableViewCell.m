//
//  TeacherTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherTableViewCell.h"

@interface TeacherTableViewCell ()

@property (strong, nonatomic) UIImageView *headImageView;   //头像
@property (strong, nonatomic) UILabel *nameLabel;           //姓名
@property (strong, nonatomic) UILabel *levelLabel;          //等级
@property (strong, nonatomic) UILabel *scoreLabel;          //评分
@property (strong, nonatomic) UILabel *countLabel;          //辅导次数
@property (strong, nonatomic) UILabel *priceLabel;          //辅导价格



@end

@implementation TeacherTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(31, 14, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [self.contentView addSubview:bgHeadImageView];
        
        //头像
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(34, 17, 52, 52)];
        _headImageView.boderRadius = 26;
        [self.contentView addSubview:_headImageView];
        
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [self.contentView addSubview:_nameLabel];
        
        //等级
        _levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _levelLabel.textColor = [UIColor colorWithHexString:@" #FF9E1F"];
        _levelLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        _levelLabel.layer.cornerRadius = 7.5;
        _levelLabel.layer.borderColor = [UIColor colorWithHexString:@" #FF9E1F"].CGColor;
        _levelLabel.layer.borderWidth = 0.5;
        _levelLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_levelLabel];
        
        //评分
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+8.0, 37.0, 50, 17.0)];
        _scoreLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _scoreLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [self.contentView addSubview:_scoreLabel];
        
        //辅导次数
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(_scoreLabel.right+13.0, 37.0, 120.0, 17)];
        _countLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _countLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [self.contentView addSubview:_countLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right+8.0, _scoreLabel.bottom, 140.0, 17.0)];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [self.contentView addSubview:_priceLabel];
        
        _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-76, 13.0, 44.0, 60.0)];
        [_connectButton setImage:[UIImage imageNamed:@"connection_teacher"] forState:UIControlStateNormal];
        [_connectButton setTitle:@"连线老师" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        _connectButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        _connectButton.imageEdgeInsets = UIEdgeInsetsMake(-(_connectButton.height - _connectButton.titleLabel.height- _connectButton.titleLabel.y-16),0, 0, 0);
        _connectButton.titleEdgeInsets = UIEdgeInsetsMake(_connectButton.imageView.height+_connectButton.imageView.y, -_connectButton.imageView.width, 0, 0);
        [self.contentView addSubview:_connectButton];
        
        
    }
    return self;
}


#pragma mark 数据展示
-(void)applyDataForCellWithTeacher:(TeacherModel *)model{
    if (kIsEmptyString(model.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    
    _nameLabel.text = model.tch_name;
    CGFloat nameW = [model.tch_name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:_nameLabel.font].width;
    _nameLabel.frame = CGRectMake(self.headImageView.right+8.0, 16.0, nameW, 20);
    
    if (kIsEmptyString(model.level)) {
        _levelLabel.hidden = YES;
    }else{
        _levelLabel.hidden = NO;
        _levelLabel.frame = CGRectMake(_nameLabel.right+6.0, 18.0, 54.0, 15.0);
        _levelLabel.text =[NSString stringWithFormat:@"%@",model.level];
    }
    
    
    _scoreLabel.text = [NSString stringWithFormat:@"评分 %.1f",[model.score doubleValue]];
    _countLabel.text = [NSString stringWithFormat:@"辅导次数 %@",model.guide_num];
    
    if (!kIsEmptyObject(model.guide_price)) {
        NSString *priceStr = [NSString stringWithFormat:@"辅导价格：%.2f元/分钟",[model.guide_price doubleValue]];
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
        [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, priceStr.length-5)];
        _priceLabel.attributedText = attributeStr;
    }
    
    [_connectButton setImage:[UIImage imageNamed:[model.online boolValue]?@"connection_teacher":@"connection_teacher_gray"] forState:UIControlStateNormal];
}



@end

