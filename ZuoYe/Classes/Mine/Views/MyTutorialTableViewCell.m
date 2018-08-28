//
//  MyTutorialTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyTutorialTableViewCell.h"

@interface MyTutorialTableViewCell (){
    UILabel      *titleLab;             //作业检查 或 作业辅导
    UILabel      *dateTimeLab;          //日期
    UILabel      *stateLab;             //状态
    UIImageView  *headImageView;        //头像
    UILabel      *nameLab;              //姓名
    UILabel      *levelLab;             //教师等级 高级 中级
    UILabel      *gradeLab;             //年级/科目
    UILabel      *checkPriceLab;        //检查价格 或 辅导时长
    UILabel      *payLab;               //付款金额
}


@end

@implementation MyTutorialTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 120, 30)];
        titleLab.font = kFontWithSize(16);
        titleLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:titleLab];
        
        dateTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLab.bottom, 180, 20)];
        dateTimeLab.font = kFontWithSize(14);
        dateTimeLab.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:dateTimeLab];
        
        stateLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, 20, 70, 30)];
        stateLab.font = kFontWithSize(16);
        stateLab.textColor = [UIColor blackColor];
        stateLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:stateLab];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, dateTimeLab.bottom+10, kScreenWidth-10, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [self.contentView addSubview:lineView];
        
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, lineView.bottom+10, 80, 80)];
        [self.contentView addSubview:headImageView];
        
        nameLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, lineView.bottom+10, 90, 30)];
        nameLab.font = kFontWithSize(14);
        nameLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLab];
        
        levelLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, nameLab.bottom, 90, 20)];
        levelLab.font = kFontWithSize(13);
        levelLab.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:levelLab];
        
        gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, levelLab.bottom, 90, 20)];
        gradeLab.font = kFontWithSize(13);
        gradeLab.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:gradeLab];
        
        self.replayBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-80, lineView.bottom+20, 60, 80)];
        [self.replayBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.replayBtn setTitle:@"回放" forState:UIControlStateNormal];
        [self.replayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.replayBtn addTarget:self action:@selector(replayTutorialVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.replayBtn];
        
        UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(10, headImageView.bottom+10, kScreenWidth-10, 0.5)];
        lineView2.backgroundColor  = kLineColor;
        [self.contentView addSubview:lineView2];
        
        checkPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(15, lineView2.bottom+10, 150, 30)];
        checkPriceLab.font = kFontWithSize(14);
        checkPriceLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:checkPriceLab];
        
        payLab = [[UILabel alloc] initWithFrame:CGRectMake(15, checkPriceLab.bottom, 150, 20)];
        payLab.textColor = [UIColor blackColor];
        payLab.font = kFontWithSize(14);
        [self.contentView addSubview:payLab];
        
        self.myButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-110, lineView2.bottom+15, 100, 35)];
        [self.myButton setTitle:@"重新连线" forState:UIControlStateNormal];
        [self.myButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.myButton.backgroundColor = [UIColor redColor];
        self.myButton.layer.cornerRadius = 5;
        [self.myButton addTarget:self action:@selector(payOrderOrConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        self.myButton.titleLabel.font = kFontWithSize(14);
        [self.contentView addSubview:self.myButton];
        
    }
    return self;
}

#pragma mark 我的辅导
-(void)setTutorial:(TutorialModel *)tutorial{
    _tutorial = tutorial;
    titleLab.text = tutorial.type==1?@"作业检查":@"作业辅导";
    dateTimeLab.text = tutorial.datetime;
    stateLab.text = [[ZYHelper sharedZYHelper] getStateStringWithIndex:tutorial.state];
    headImageView.image = [UIImage imageNamed:tutorial.head_image];
    nameLab.text = tutorial.name;
    levelLab.text = tutorial.level;
    gradeLab.text = [NSString stringWithFormat:@"%@/%@",tutorial.grade,tutorial.subject];
    checkPriceLab.text = tutorial.type == 1?[NSString stringWithFormat:@"检查价格：%.2f元",tutorial.check_price]:[NSString stringWithFormat:@"辅导时长：%ld分%ld秒",tutorial.duration/60,tutorial.duration%60];
    payLab.text = [NSString stringWithFormat:@"%@：¥%.2f",tutorial.state==3?@"待付金额":@"已付金额",tutorial.pay_price];
    
    payLab.hidden = checkPriceLab.hidden = tutorial.state==5;
    [self.myButton setTitle:tutorial.state==3?@"去付款":@"重新连线" forState:UIControlStateNormal];
    
}

#pragma mark 付款或重新连线
-(void)payOrderOrConnectTeacherAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(myTutorialTableViewCell:payOrderOrConnectTeacherWithTutorial:)]) {
        [self.delegate myTutorialTableViewCell:self payOrderOrConnectTeacherWithTutorial:self.tutorial];
    }
}

#pragma mark  辅导视频回放
-(void)replayTutorialVideoAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(myTutorialTableViewCell:payOrderOrConnectTeacherWithTutorial:)]) {
        [self.delegate myTutorialTableViewCell:self replayVideoWithTutorial:self.tutorial];
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
