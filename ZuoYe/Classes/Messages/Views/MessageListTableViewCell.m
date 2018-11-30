//
//  MessageListTableViewCell.m
//  ZYForTeacher
//
//  Created by vision on 2018/10/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MessageListTableViewCell.h"

#define kRootViewWidth kScreenWidth-30
#define kImgW 99.5
#define kImgH 60

@interface MessageListTableViewCell (){
    NSMutableArray  *scoreArray;  //评分
    
    
}

@property (nonatomic,strong)UIView      *rootView;
@property (nonatomic,strong)UIImageView *headImgView;
@property (nonatomic,strong)UILabel     *nicknameLab;
@property (nonatomic,strong)UILabel     *timeLabel;
@property (nonatomic,strong)UILabel     *lineLabel;
@property (nonatomic,strong)UIScrollView *homeworkScrollView;  //作业检查图片数组
@property (nonatomic,strong)UILabel   *orderSnLab;



@end


@implementation MessageListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    
        
        self.contentView.backgroundColor = [UIColor bgColor_Gray];
        
        self.rootView = [[UIView alloc] initWithFrame:CGRectMake(15, 10, kScreenWidth, 146)];
        self.rootView.backgroundColor = [UIColor whiteColor];
        self.rootView.layer.cornerRadius =4.0;
        [self.contentView addSubview:self.rootView];
        
        //头像
        self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(12+15, 18, 32, 32)];
        self.headImgView.boderRadius = 16;
        [self.contentView addSubview:self.headImgView];
        
        //昵称
        self.nicknameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.headImgView.right+10, 20, 100, 25)];
        self.nicknameLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        self.nicknameLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
        [self.contentView addSubview:self.nicknameLab];
        
        //日期
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kRootViewWidth-120, 20, 120, 25)];
        self.timeLabel.textColor = [UIColor colorWithHexString:@"#A2A2A2"];
        self.timeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLabel];
        
        //线条
        self.lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, self.headImgView.bottom+7, kRootViewWidth-30, 0.5)];
        self.lineLabel.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [self.contentView addSubview:self.lineLabel];
        
        _homeworkScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, self.lineLabel.bottom+5.0, kRootViewWidth, 60)];
        _homeworkScrollView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:_homeworkScrollView];
        
        //订单号
        self.orderSnLab = [[UILabel alloc] initWithFrame:CGRectMake(12+15, self.homeworkScrollView.bottom+5.0, 220, 20)];
        self.orderSnLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        self.orderSnLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [self.contentView addSubview:self.orderSnLab];
        
        if (kScreenWidth>=375.0) {
            self.checkDetailsBtn = [[UIButton alloc] initWithFrame:CGRectMake(kRootViewWidth-90, self.orderSnLab.top, 95, 20)];
            [self.checkDetailsBtn setTitle:@"查看订单详情>" forState:UIControlStateNormal];
            [self.checkDetailsBtn setTitleColor:[UIColor colorWithHexString:@"#648FFE"] forState:UIControlStateNormal];
            self.checkDetailsBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
            [self.contentView addSubview:self.checkDetailsBtn];
        }
        
    }
    return self;
}

#pragma mark 设置信息
-(void)setMessageModel:(MessageModel *)messageModel{
    if (kIsEmptyString(messageModel.trait)) {
        self.headImgView.image = [UIImage imageNamed:@"default_head_image"];
    }else{
        [self.headImgView sd_setImageWithURL:[NSURL URLWithString:messageModel.trait] placeholderImage:[UIImage imageNamed:@"default_head_image"]];
    }
    self.nicknameLab.text = messageModel.tch_name;
    
    self.timeLabel.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:messageModel.checkded_time format:@"yyyy-MM-dd HH:mm"];
    
    for (UIView *view in self.homeworkScrollView.subviews) {
        [view removeFromSuperview];
    }
    NSInteger num = messageModel.pics.count;
    if (num>0) {
        for (NSInteger i=0; i<num; i++) {
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(17+(kImgW+10.5)*i, 0, kImgW, kImgH)];
            NSString *imgUrl = messageModel.pics[i];
            if (kIsEmptyString(imgUrl)) {
                imgView.image = [UIImage imageNamed:@"home_task_all_loading"];
            }else{
                [imgView sd_setImageWithURL:[NSURL URLWithString:messageModel.pics[i]] placeholderImage:[UIImage imageNamed:@"home_task_all_loading"]];
            }
            [self.homeworkScrollView addSubview:imgView];
        }
        self.homeworkScrollView.contentSize = CGSizeMake(17+(kImgW+10.5)*num+17, kImgH);
    }
    self.orderSnLab.text = [NSString stringWithFormat:@"订单号：%@",messageModel.oid];
    
}


@end
