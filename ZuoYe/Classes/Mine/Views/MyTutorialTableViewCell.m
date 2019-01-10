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
    
    UIView       *lineView2;
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
        headImageView.boderRadius = 23.0;
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
        
        
        lineView2 = [[UIView alloc]initWithFrame:CGRectMake(12, bgHeadImageView.bottom+10, kScreenWidth-12, 0.5)];
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
        
        
        self.payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-100, lineView2.bottom+15, 80, 35)];
        self.payButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [self.payButton setBackgroundImage:[UIImage imageNamed:@"button_2"] forState:UIControlStateNormal];
        [self.payButton setTitle:@"去付款" forState:UIControlStateNormal];
        [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.payButton addTarget:self action:@selector(payOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.payButton];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-106, lineView2.bottom+8, 88, 28)];
        [self.cancelButton setTitleColor:[UIColor colorWithHexString:@"#9B9B9B"] forState:UIControlStateNormal];
        self.cancelButton.layer.cornerRadius = 14;
        self.cancelButton.layer.borderColor = [UIColor colorWithHexString:@"#9B9B9B"].CGColor;
        self.cancelButton.layer.borderWidth = 1;
        self.cancelButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [self.cancelButton setTitle:@"结束辅导" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        self.cancelButton.hidden = YES;
        
        self.connectButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-106, lineView2.bottom+8, 88, 28)];
        self.connectButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        self.connectButton.layer.cornerRadius = 10;
        self.connectButton.layer.borderColor =[UIColor colorWithHexString:@"#FF6161"].CGColor;
        self.connectButton.layer.borderWidth = 1.0;
        [self.connectButton setTitle:@"再次连线" forState:UIControlStateNormal];
        [self.connectButton setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateNormal];
        [self.connectButton addTarget:self action:@selector(connectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.connectButton];
        
    }
    return self;
}

#pragma mark 我的辅导
-(void)setTutorial:(TutorialModel *)tutorial{
    _tutorial = tutorial;
    
    //时间
    dateTimeLab.text = [[ZYHelper sharedZYHelper] timeWithTimeIntervalNumber:tutorial.create_time format:@"yyyy-MM-dd HH:mm"];
    //头像
    if (kIsEmptyString(tutorial.trait)) {
        headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [headImageView sd_setImageWithURL:[NSURL URLWithString:tutorial.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    //姓名
    nameLab.text = tutorial.name;
    CGFloat nameW = [tutorial.name boundingRectWithSize:CGSizeMake(kScreenWidth, 20) withTextFont:nameLab.font].width;
    nameLab.frame = CGRectMake(headImageView.right+16.0,dateTimeLab.bottom+27.0, nameW, 20);
    //等级啊
    levelLab.text = tutorial.level;
    levelLab.frame = CGRectMake(nameLab.right+7.0, dateTimeLab.bottom+29, 54, 15);
    //年级/科目
    gradeLab.text = kIsEmptyString(tutorial.grade)?@"":[NSString stringWithFormat:@"%@/%@",tutorial.grade,tutorial.subject];
    
    //价格
    NSString *tempPriceStr = nil;
    if ([tutorial.label integerValue]==1) {
        tempPriceStr = [NSString stringWithFormat:@"检查价格：%.2f元",[tutorial.price doubleValue]];
    }else{
        NSInteger jobTime = [tutorial.job_time integerValue];
        tempPriceStr = [NSString stringWithFormat:@"辅导时长：%ld分%ld秒",jobTime/60,jobTime%60];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempPriceStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
    checkPriceLab.attributedText = attributeStr;
    
    lineView2.hidden = NO;
    
    if ([tutorial.status integerValue]==0) {  //进行中
        
        self.payButton.hidden = payLab.hidden = YES;
        if ([tutorial.label integerValue]==1) {
            checkPriceLab.hidden = NO;
            self.connectButton.hidden = self.cancelButton.hidden = YES;
            stateLab.text = @"检查中";
            self.cancelButton.frame = CGRectMake(kScreenWidth-106, lineView2.bottom+8, 88, 28);
        }else{
            checkPriceLab.hidden = YES;
            self.connectButton.hidden = self.cancelButton.hidden = NO;
            [self.connectButton setTitle:@"再次连线" forState:UIControlStateNormal];
            self.connectButton.frame =CGRectMake(kScreenWidth-106, lineView2.bottom+8, 88, 28);
            stateLab.text = @"辅导中";
            self.cancelButton.frame = CGRectMake(kScreenWidth-212, lineView2.bottom+8, 88, 28);
        }
        stateLab.textColor = [UIColor colorWithHexString:@"#FF6161"];
    }else if ([tutorial.status integerValue]==1||[tutorial.status integerValue]==2) {
        self.cancelButton.hidden = YES;
        NSString *tempStr = nil;
        if ([tutorial.status integerValue]==1) {  //待付款
            self.payButton.hidden = NO;
            self.connectButton.hidden = YES;
            stateLab.text = @"待付款";
            tempStr = [NSString stringWithFormat:@"%@：¥%.2f",@"待付金额",[tutorial.pay_money doubleValue]];
        }else if ([tutorial.status integerValue]==2){ //已完成
            stateLab.text = @"已完成";
            tempStr = [NSString stringWithFormat:@"%@：¥%.2f",@"已付金额",[tutorial.pay_money doubleValue]];
            self.payButton.hidden = YES;
            self.connectButton.hidden = NO;
            [self.connectButton setTitle:[tutorial.label integerValue]<2?@"连线老师":@"再次连线" forState:UIControlStateNormal];
            self.connectButton.frame =CGRectMake(kScreenWidth-106, lineView2.bottom+15, 88, 28);
        }
        NSMutableAttributedString *attributeStr2 = [[NSMutableAttributedString alloc] initWithString:tempStr];
        [attributeStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
        payLab.attributedText = attributeStr2;
        payLab.hidden = checkPriceLab.hidden = NO;
    }else{ //已取消
        self.cancelButton.hidden = YES;
        stateLab.text = @"已取消";
        payLab.hidden = checkPriceLab.hidden = YES;
        self.payButton.hidden = YES;
        if ([tutorial.label integerValue]>1) {
            self.connectButton.hidden = lineView2.hidden = NO;
            [self.connectButton setTitle:@"再次连线" forState:UIControlStateNormal];
            self.connectButton.frame =CGRectMake(kScreenWidth-106, lineView2.bottom+8, 88, 28);
        }else{
            self.connectButton.hidden = lineView2.hidden = YES;
        }
    }
}

#pragma mark 付款
-(void)payOrderAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(myTutorialTableViewCell:payOrderActionWithTutorial:)]) {
        [self.delegate myTutorialTableViewCell:self payOrderActionWithTutorial:self.tutorial];
    }
}

#pragma mark 重新连线
-(void)connectTeacherAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(myTutorialTableViewCell:connectTeacherWithTutorial:)]) {
        [self.delegate myTutorialTableViewCell:self connectTeacherWithTutorial: self.tutorial];
    }
}

#pragma mark 取消订单
-(void)cancelOrderAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(myTutorialTableViewCell:cancelOrderWithTutorial:)]) {
        [self.delegate myTutorialTableViewCell:self cancelOrderWithTutorial:self.tutorial];
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
