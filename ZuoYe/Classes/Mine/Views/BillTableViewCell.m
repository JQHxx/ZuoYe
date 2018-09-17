//
//  BillTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BillTableViewCell.h"

@interface BillTableViewCell (){
    UIImageView    *billImageView;
    UILabel        *typeLabel;        //交易类型
    UILabel        *paywayLabel;      //支付方式
    UILabel        *timeLabel;        //创建时间
    UILabel        *amountLabel;      //金额
}



@end

@implementation BillTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        billImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 17,34, 34)];
        [self.contentView addSubview:billImageView];
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(billImageView.right+13, 13, 100, 21)];
        typeLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        typeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:15];
        [self.contentView addSubview:typeLabel];
        
        paywayLabel = [[UILabel alloc] initWithFrame:CGRectMake(billImageView.right+13, typeLabel.bottom+3.0, 100, 18)];
        paywayLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        paywayLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
        [self.contentView addSubview:paywayLabel];
        
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-160, 11.0, 142, 25)];
        amountLabel.textAlignment = NSTextAlignmentRight;
        amountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        amountLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        [self.contentView addSubview:amountLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120,amountLabel.bottom+1.0, 102, 25)];
        timeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:13];
        timeLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:timeLabel];
        
        
    }
    return self;
}

-(void)setMyBill:(BillModel *)myBill{
    
    
    NSString *tempStr = nil;
    if (myBill.bill_type==0) {
        billImageView.image = [UIImage imageNamed:@"bill_recharge"];
        typeLabel.text = @"充值";
        amountLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        tempStr = @"+";
    }else if (myBill.bill_type==1){
        billImageView.image = [UIImage imageNamed:@"bill_inspect"];
        typeLabel.text = @"作业检查";
        amountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        tempStr = @"-";
    }else{
        billImageView.image = [UIImage imageNamed:@"bill_coach"];
        typeLabel.text = @"作业辅导";
        amountLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        tempStr = @"-";
    }
    
    if (myBill.pay_type==0) {
        paywayLabel.text = @"余额支付";
    }else if (myBill.pay_type==1){
        paywayLabel.text = @"微信支付";
    }else{
        paywayLabel.text = @"支付宝支付";
    }
    
    timeLabel.text = myBill.create_time;
    amountLabel.text = [tempStr stringByAppendingString:[NSString stringWithFormat:@"¥%.2f",myBill.amount]];
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
