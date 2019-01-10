//
//  FocusTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "FocusTableViewCell.h"

@interface FocusTableViewCell (){
    NSMutableArray  *scoreArray;
}

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
        _headImageView.boderRadius = 26.0;
        [bgView addSubview:_headImageView];
        
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [bgView addSubview:_nameLabel];
        
        //准备5个心桃 默认隐藏
        scoreArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<=4; i++) {
            UIImageView *scoreImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"score"]];
            [scoreArray addObject:scoreImage];
            [bgView addSubview:scoreImage];
        }
        
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
    if (kIsEmptyString(model.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    
    _nameLabel.text = model.tch_name;
    CGFloat nameW = [model.tch_name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:_nameLabel.font].width;
    _nameLabel.frame = CGRectMake(self.headImageView.right+14.0, 22.0, nameW, 20);
    
    //加星级
    CGSize scoreSize = CGSizeMake(13, 13);
    double scoreNum = [model.score doubleValue];
    NSInteger oneScroe=(NSInteger)scoreNum;
    NSInteger num=scoreNum>oneScroe?oneScroe+1:oneScroe;
    for (int i = 0; i<scoreArray.count; i++) {
        UIImageView *scoreImage = scoreArray[i];
        [scoreImage setFrame:CGRectMake(_nameLabel.right+10+(scoreSize.width+4.0)*i,25.0, scoreSize.width, scoreSize.height)];
        if (i<= num-1) {
            if ((i==num-1)&&scoreNum>oneScroe) {
                scoreImage.image=[UIImage imageNamed:@"score_half"];
            }
        }else{
            scoreImage.image=[UIImage imageNamed:@"score_gray"];
        }
    }
    
    if (kIsArray(model.grade)&&model.grade.count>0) {
        NSString *gradeStr = [[ZYHelper sharedZYHelper] parseToGradeStringForGrades:model.grade];
        _gradeLabel.text =  [NSString stringWithFormat:@"%@  %@",gradeStr,model.subject];
    }else{
        _gradeLabel.text =  [NSString stringWithFormat:@"%@",model.subject];
    }
    CGFloat gradeW = [_gradeLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth-200, 17.0) withTextFont:_gradeLabel.font].width;
    _gradeLabel.frame = CGRectMake(self.headImageView.right+14.0, _nameLabel.bottom, gradeW, 17.0);
    
    
    if ([model.online integerValue]==1) {
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
