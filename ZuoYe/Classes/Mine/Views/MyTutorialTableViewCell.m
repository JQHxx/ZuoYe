//
//  MyTutorialTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyTutorialTableViewCell.h"

@interface MyTutorialTableViewCell (){
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
        dateTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(13, 11, 140, 20)];
        dateTimeLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        dateTimeLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [self.contentView addSubview:dateTimeLab];
        
        stateLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-80, 11, 62, 20)];
        stateLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        stateLab.textColor = [UIColor colorWithHexString:@"#FF6161"];
        stateLab.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:stateLab];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(12, 38.0, kScreenWidth-10, 0.5)];
        lineView.backgroundColor  = [UIColor colorWithHexString:@" #D8D8D8"];
        [self.contentView addSubview:lineView];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.0,lineView.bottom+9.0, 52, 52)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [self.contentView addSubview:bgHeadImageView];
        
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.9, lineView.bottom+11.9, 46, 46)];
        [self.contentView addSubview:headImageView];
        
        nameLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+16, dateTimeLab.bottom+27, 56, 20)];
        nameLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [self.contentView addSubview:nameLab];
        
        levelLab = [[UILabel alloc] initWithFrame:CGRectMake(nameLab.right+7.0, dateTimeLab.bottom+29, 54, 15)];
        levelLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        levelLab.textColor = [UIColor colorWithHexString:@"#FF9E1F"];
        levelLab.layer.cornerRadius = 7.5;
        levelLab.layer.borderWidth = 0.5;
        levelLab.textAlignment = NSTextAlignmentCenter;
        levelLab.layer.borderColor = [UIColor colorWithHexString:@"#FF9E1F"].CGColor;
        [self.contentView addSubview:levelLab];
        
        gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+16, nameLab.bottom, 90, 17)];
        gradeLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        gradeLab.textColor = [UIColor colorWithHexString:@"#808080"];
        [self.contentView addSubview:gradeLab];
        
        self.replayBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-98, lineView.bottom+13,79.6, 45)];
        [self.replayBtn setBackgroundImage:[UIImage imageNamed:@"zuoye"] forState:UIControlStateNormal];
        [self.replayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.replayBtn setTitle:@"回放" forState:UIControlStateNormal];
        self.replayBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [self.replayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.replayBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 13, 47.6);
        self.replayBtn.titleEdgeInsets = UIEdgeInsetsMake(13,14, 12, 15.6);
        [self.replayBtn addTarget:self action:@selector(replayTutorialVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.replayBtn];
        
        UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(12, bgHeadImageView.bottom+10, kScreenWidth-12, 0.5)];
        lineView2.backgroundColor  = [UIColor colorWithHexString:@" #D8D8D8"];
        [self.contentView addSubview:lineView2];
        
        checkPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(18, lineView2.bottom+10, 150, 18)];
        checkPriceLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:13];
        checkPriceLab.textColor = [UIColor colorWithHexString:@"#FF6161"];
        [self.contentView addSubview:checkPriceLab];
        
        payLab = [[UILabel alloc] initWithFrame:CGRectMake(18, checkPriceLab.bottom+3.0, 150, 18)];
        payLab.textColor = [UIColor colorWithHexString:@"#FF6161"];
        payLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
        [self.contentView addSubview:payLab];
        
        self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, lineView2.bottom+15, 80, 80*(76.0/172.0))];
        self.payButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [self.payButton setBackgroundImage:[UIImage imageNamed:@"button_2"] forState:UIControlStateNormal];
        [self.payButton setTitle:@"去付款" forState:UIControlStateNormal];
        [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.payButton addTarget:self action:@selector(payOrderOrConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.payButton];
        
        self.connectButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-106, lineView2.bottom+15, 88, 28)];
        self.connectButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        self.connectButton.layer.cornerRadius = 10;
        self.connectButton.layer.borderColor =[UIColor colorWithHexString:@"#FF6161"].CGColor;
        self.connectButton.layer.borderWidth = 1.0;
        [self.connectButton setTitle:@"再次连线" forState:UIControlStateNormal];
        [self.connectButton setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [self.connectButton addTarget:self action:@selector(payOrderOrConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.connectButton];
        
    }
    return self;
}

#pragma mark 我的辅导
-(void)setTutorial:(TutorialModel *)tutorial{
    _tutorial = tutorial;
    
    dateTimeLab.text = tutorial.datetime;
    
    headImageView.image = [UIImage imageNamed:tutorial.head_image];
    
    nameLab.text = tutorial.name;
    CGFloat nameW = [tutorial.name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:nameLab.font].width;
    nameLab.frame = CGRectMake(headImageView.right+16.0,dateTimeLab.bottom+27.0, nameW, 20);

    levelLab.text = tutorial.level;
    levelLab.frame = CGRectMake(nameLab.right+7.0, dateTimeLab.bottom+29, 54, 15);
    
    gradeLab.text = [NSString stringWithFormat:@"%@/%@",tutorial.grade,tutorial.subject];
    
    self.replayBtn.hidden = !tutorial.type;
    if (tutorial.type==1&&tutorial.state<2) {
        self.replayBtn.hidden = NO;
    }else{
        self.replayBtn.hidden = YES;
    }
    
    //价格
   
    NSString *tempPriceStr = nil;
    if (tutorial.type==0) {
        tempPriceStr = [NSString stringWithFormat:@"检查价格：%.2f元",tutorial.check_price];
    }else{
        tempPriceStr = [NSString stringWithFormat:@"辅导时长：%ld分%ld秒",tutorial.duration/60,tutorial.duration%60];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempPriceStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
    checkPriceLab.attributedText = attributeStr;
    
    
    if (tutorial.state==2) {
        stateLab.text = @"已取消";
        payLab.hidden = checkPriceLab.hidden = YES;
        self.payButton.hidden = YES;
        self.connectButton.hidden = NO;
    }else{
        NSString *tempStr = nil;
        if (tutorial.state==0) {
            self.payButton.hidden = NO;
            self.connectButton.hidden = YES;
            stateLab.text = @"待付款";
            tempStr = [NSString stringWithFormat:@"%@：¥%.2f",@"待付金额",tutorial.pay_price];
        }else if (tutorial.state==1){
            stateLab.text = @"已完成";
            tempStr = [NSString stringWithFormat:@"%@：¥%.2f",@"已付金额",tutorial.pay_price];
            self.payButton.hidden = YES;
            self.connectButton.hidden = NO;
        }
        NSMutableAttributedString *attributeStr2 = [[NSMutableAttributedString alloc] initWithString:tempStr];
        [attributeStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
        payLab.attributedText = attributeStr2;
        payLab.hidden = checkPriceLab.hidden = NO;
    }
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
