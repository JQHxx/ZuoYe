//
//  HomeworkCollectionViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkCollectionViewCell.h"

@interface HomeworkCollectionViewCell ()

@property (nonatomic, strong) UIImageView *coverImgView;
@property (nonatomic, strong) UILabel  *typelabel;
@property (nonatomic, strong) UILabel  *timeLabel;
@property (nonatomic, strong) UILabel  *stateLabel;

@end

@implementation HomeworkCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImgView.clipsToBounds = YES;
        [self.contentView addSubview:self.coverImgView];
        
        UIImageView *typeBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 52, 16)];
        typeBgImageView.image = [UIImage imageNamed:@"label"];
        [self.contentView addSubview:typeBgImageView];
        
        self.typelabel= [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 45, 13)];
        self.typelabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:9];
        self.typelabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.typelabel];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(1, 70, self.width-2, 20)];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.5;
        [self.contentView addSubview:bgView];
        
        self.timeLabel= [[UILabel alloc] initWithFrame:CGRectMake(6.0,bgView.top+2,100, 16)];
        self.timeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        self.timeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.timeLabel];
        
        self.stateLabel= [[UILabel alloc] initWithFrame:CGRectMake(105,bgView.top+2,40, 16)];
        self.stateLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        self.stateLabel.textColor = [UIColor whiteColor];
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.stateLabel];
        
    }
    return self;
}

#pragma mark
-(void)configCellWithHomework:(HomeworkModel *)model{
    if (kIsArray(model.images)&& model.images.count>0) {
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.images[0]] placeholderImage:[UIImage imageNamed:@"home_task_loading"]];
    }else{
        self.coverImgView.image = [UIImage imageNamed:@"home_task_loading"];
    }
    
    if ([model.label integerValue]==1) {
        self.typelabel.text = [NSString stringWithFormat:@"检查【%@】",[model.subject substringToIndex:1]];
        self.timeLabel.hidden = YES;
        self.stateLabel.text = [model.is_receive integerValue]>1?@"已检查":@"待检查";
    }else{
        self.typelabel.text = [NSString stringWithFormat:@"辅导【%@】",[model.subject substringToIndex:1]];
        self.timeLabel.hidden = ![model.yuyue boolValue];
        self.timeLabel.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:model.start_time format:@"MM/dd HH:mm"];
        self.stateLabel.text = [model.is_receive integerValue]>1?@"已接单":@"待接单";
    }
}

@end
