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
        [self.contentView addSubview:self.coverImgView];
        
        UIImageView *typeBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 50, 16)];
        typeBgImageView.image = [UIImage imageNamed:@"label"];
        [self.contentView addSubview:typeBgImageView];
        
        self.typelabel= [[UILabel alloc] initWithFrame:CGRectMake(5, 7, 40, 13)];
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
    self.coverImgView.image = [UIImage imageNamed:model.coverImage];
    self.typelabel.text = model.type ==0 ?@"作业检查":@"作业辅导";
    self.timeLabel.hidden = model.time_type;
    self.timeLabel.text = model.order_time;
    self.stateLabel.text = model.state == 0?@"待接单":@"已接单";
}

@end
