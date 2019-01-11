//
//  HomeworkTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkTableViewCell.h"

#define kImgW 99.5
#define kImgH 60

@interface HomeworkTableViewCell ()

@property (strong, nonatomic) UILabel      *gradeLabel;           //年级/科目
@property (strong, nonatomic) UILabel      *stateLabel;          //接单状态
@property (strong, nonatomic) UIScrollView *homeworkScrollView;  //作业图片数组
@property (strong, nonatomic) UIImageView  *orderImgView;          //预约图标
@property (strong, nonatomic) UILabel      *orderLabel;          //预约
@property (strong, nonatomic) UILabel      *priceLabel;          //检查价格或辅导价格

@end

@implementation HomeworkTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //年级/科目
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 8, 120, 20)];
        _gradeLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [self.contentView addSubview:_gradeLabel];
        
        //接单状态
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-75, 8.0, 52, 20.0)];
        _stateLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        _stateLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _stateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_stateLabel];
        
        //作业
        _homeworkScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _gradeLabel.bottom+7.0, kScreenWidth, 60)];
        _homeworkScrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:_homeworkScrollView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10.5,_homeworkScrollView.bottom+12,kScreenWidth-15.0, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [self.contentView addSubview:line];
        
        //预约
        _orderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.6, line.bottom+9.6, 14.7, 14.7)];
        _orderImgView.image = [UIImage imageNamed:@"order_time"];
        [self.contentView addSubview:_orderImgView];
        
        _orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(_orderImgView.right+4.7,line.bottom+7.0, 100.0, 20)];
        _orderLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _orderLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [self.contentView addSubview:_orderLabel];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-180, line.bottom+7.0, 167.0, 20.0)];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        _priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_priceLabel];
        
    }
    return self;
}

#pragma mark
-(void)displayCellWithHomework:(HomeworkModel *)model{
    self.gradeLabel.text = [NSString stringWithFormat:@"%@/%@",model.grade,model.subject];
    
    for (UIView *view in self.homeworkScrollView.subviews) {
        [view removeFromSuperview];
    }
    NSInteger num = model.images.count;
    if (num>0) {
        for (NSInteger i=0; i<num; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(17+(kImgW+10.5)*i, 0, kImgW, kImgH)];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds =YES;
            NSString *imgUrl = model.images[i];
            if (kIsEmptyString(imgUrl)) {
                imgView.image = [UIImage imageNamed:@"home_task_all_loading"];
            }else{
                [imgView sd_setImageWithURL:[NSURL URLWithString:model.images[i]] placeholderImage:[UIImage imageNamed:@"home_task_all_loading"]];
            }
            [self.homeworkScrollView addSubview:imgView];
        }
        self.homeworkScrollView.contentSize = CGSizeMake(17+(kImgW+10.5)*num+17, kImgH);
    }
    
    self.stateLabel.text = [model.is_receive integerValue]>1?@"已接单":@"待接单";

    NSString *tempStr = nil;
    if ([model.label integerValue]==1) {
        self.orderImgView.hidden = self.orderLabel.hidden = YES;
        tempStr = [NSString stringWithFormat:@"检查价格：%.2f元",[model.price doubleValue]];
    }else{
        self.orderImgView.hidden = self.orderLabel.hidden = NO;
        self.orderLabel.text = [model.label integerValue]==3?@"实时":[[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.start_time format:@"MM/dd HH:mm"];
        tempStr = [NSString stringWithFormat:@"辅导价格：%.2f元/分钟",[model.price doubleValue]];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
    self.priceLabel.attributedText = attributeStr;
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
