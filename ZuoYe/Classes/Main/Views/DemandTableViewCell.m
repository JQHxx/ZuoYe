//
//  DemandTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "DemandTableViewCell.h"

@interface DemandTableViewCell ()

@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel     *valueLabel;


@end

@implementation DemandTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 12, 20, 20)];
        [self.contentView addSubview:_imgView];
        
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imgView.right+16, 11, 120, 22)];
        _valueLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        _valueLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [self.contentView addSubview:_valueLabel];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-34, 15, 9, 13.3)];
        arrowImageView.image = [UIImage imageNamed:@"triangle_choose"];
        [self.contentView addSubview:arrowImageView];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(26.0, 43.0, kScreenWidth-51.0, 1.0)];
        line2.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [self addSubview:line2];
    }
    return self;
}

-(void)setValueModel:(SetValueModel *)valueModel{
    _imgView.image = [UIImage imageNamed:valueModel.imgName];
    
    _valueLabel.textColor = valueModel.isSet?[UIColor colorWithHexString:@"#4A4A4A"]:[UIColor colorWithHexString:@"#9B9B9B"];
    _valueLabel.text = valueModel.value;
    
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
