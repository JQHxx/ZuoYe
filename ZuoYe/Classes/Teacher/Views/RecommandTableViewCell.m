//
//  RecommandTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RecommandTableViewCell.h"

@interface RecommandTableViewCell (){
    
     NSMutableArray  *scoreArray;
}

@property (strong, nonatomic) UIImageView *headImageView;   //头像
@property (strong, nonatomic) UILabel *nameLabel;           //姓名
@property (strong, nonatomic) UILabel *gradeLabel;          //年级
@property (strong, nonatomic) UILabel *subjectLabel;        //科目
@property (strong, nonatomic) UILabel *priceLabel;          //辅导价格

@end

@implementation RecommandTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor bgColor_Gray];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20, 86.0)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.boderRadius = 4.0;
        [self.contentView addSubview:bgView];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0, 12.0, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [bgView addSubview:bgHeadImageView];
        
        //头像
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19.0, 15.0, 52, 52)];
        _headImageView.boderRadius = 26.0;
        [bgView addSubview:_headImageView];
        
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [bgView addSubview:_nameLabel];
        
        //年级
         _gradeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [bgView addSubview:_gradeLabel];
        
        //科目
        _subjectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subjectLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _subjectLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [bgView addSubview:_subjectLabel];
        
        //辅导价格
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.headImageView.right+13.0, 55.0, 140.0, 17.0)];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        [bgView addSubview:_priceLabel];
        
        _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(bgView.width-76, 13.0, 44.0, 60.0)];
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

-(void)displayCellWithTeacher:(TeacherModel *)model{
    if (kIsEmptyString(model.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:model.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    
    _nameLabel.text = model.tch_name;
    CGFloat nameW = [model.tch_name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:_nameLabel.font].width;
    _nameLabel.frame = CGRectMake(self.headImageView.right+13.0, 14.0, nameW, 20);
    
    if (kIsArray(model.grade)&&model.grade.count>0) {
        NSString *gradeStr = [[ZYHelper sharedZYHelper] parseToGradeStringForGrades:model.grade];
        _gradeLabel.text = gradeStr;
        CGFloat gradeW = [gradeStr boundingRectWithSize:CGSizeMake(kScreenWidth-200, 17.0) withTextFont:_gradeLabel.font].width;
        _gradeLabel.frame = CGRectMake(self.headImageView.right+13.0, _nameLabel.bottom, gradeW, 17.0);
        
        _subjectLabel.text = model.subject;
        _subjectLabel.frame = CGRectMake(_gradeLabel.right+10.0, _nameLabel.bottom, 60.0, 17.0);
    }else{
        _subjectLabel.text = model.subject;
        _subjectLabel.frame = CGRectMake(self.headImageView.right+10.0, _nameLabel.bottom, 60.0, 17.0);
    }
    
    
    NSString *priceStr = [NSString stringWithFormat:@"辅导价格：%.2f元/分钟",[model.guide_price doubleValue]];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5, priceStr.length-5)];
    _priceLabel.attributedText = attributeStr;
    
    [_connectButton setImage:[UIImage imageNamed:[model.online boolValue]?@"connection_teacher":@"connection_teacher_gray"] forState:UIControlStateNormal];
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
