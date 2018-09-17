//
//  FocusTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "FocusTableViewCell.h"

@interface FocusTableViewCell ()

@property (strong, nonatomic) UIImageView *headImageView;   //头像
@property (strong, nonatomic) UILabel *nameLabel;           //姓名
@property (strong, nonatomic) UILabel *gradeLabel;          //教授阶段/科目

@end

@implementation FocusTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor bgColor_Gray];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 80.0)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.boderRadius = 4.0;
        [self.contentView addSubview:bgView];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 11.0, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [bgView addSubview:bgHeadImageView];
        
        //头像
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 14.0, 52, 52)];
        [bgView addSubview:_headImageView];
        
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [bgView addSubview:_nameLabel];
        
        //教授阶段/科目
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [bgView addSubview:_gradeLabel];
        
        _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(bgView.width-76, 10.0, 44.0, 60.0)];
        [_connectButton setImage:[UIImage imageNamed:@"connection_teacher"] forState:UIControlStateNormal];
        [_connectButton setTitle:@"连线老师" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        _connectButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        _connectButton.imageEdgeInsets = UIEdgeInsetsMake(-(_connectButton.height - _connectButton.titleLabel.height- _connectButton.titleLabel.y-16),0, 0, 0);
        _connectButton.titleEdgeInsets = UIEdgeInsetsMake(_connectButton.imageView.height+_connectButton.imageView.y, -_connectButton.imageView.width, 0, 0);
        [bgView addSubview:_connectButton];
        
    }
    return self;
}

-(void)displayCellWithModel:(TeacherModel *)model{
    _headImageView.image = [UIImage imageNamed:model.head];
    
    _nameLabel.text = model.name;
    CGFloat nameW = [model.name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:_nameLabel.font].width;
    _nameLabel.frame = CGRectMake(self.headImageView.right+14.0, 22.0, nameW, 20);
    
    _gradeLabel.text = [NSString stringWithFormat:@"%@/%@",model.tech_stage,model.subjects];
    CGFloat gradeW = [_gradeLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth, 17.0) withTextFont:_gradeLabel.font].width;
    _gradeLabel.frame = CGRectMake(self.headImageView.right+14.0, _nameLabel.bottom, gradeW, 17.0);
    
    if (model.isOnline) {
        [_connectButton setImage:[UIImage imageNamed:@"connection_teacher"] forState:UIControlStateNormal];
    }else{
        [_connectButton setImage:[UIImage imageNamed:@"connection_teacher_gray"] forState:UIControlStateNormal];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
