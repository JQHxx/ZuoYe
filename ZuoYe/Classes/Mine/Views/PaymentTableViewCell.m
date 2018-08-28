//
//  PaymentTableViewCell.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PaymentTableViewCell.h"

@interface PaymentTableViewCell ()

@property (nonatomic ,strong) UIImageView *payImageView;
@property (nonatomic ,strong) UILabel     *paymentLabel;    //支付方式
@property (nonatomic ,strong) UILabel     *balanceLabel;    //余额
@property (nonatomic ,strong) UIButton    *selectButton;    //选择



@end

@implementation PaymentTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.payImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:self.payImageView];
        
        self.paymentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.paymentLabel.font = [UIFont boldSystemFontOfSize:16];
        self.paymentLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.paymentLabel];
        
        self.balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.payImageView.right+10, 30, 150, 20)];
        self.balanceLabel.font = kFontWithSize(13);
        self.balanceLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.balanceLabel];
        
        self.selectButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, 20, 20, 20)];
        [self.selectButton setImage:[UIImage imageNamed:@"unChoose"] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"choose"] forState:UIControlStateSelected];
        [self.contentView addSubview:self.selectButton];
        
        self.myButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.myButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.myButton];
    }
    return self;
}

-(void)setModel:(PaymentModel *)model{
    _model = model;
    self.payImageView.image = [UIImage imageNamed:model.imageName];
    if (model.payment==0) {
        self.paymentLabel.text = @"余额支付";
        self.paymentLabel.frame = CGRectMake(self.payImageView.right+10, 10, 100, 20);
        self.balanceLabel.text = [NSString stringWithFormat:@"可用余额：%.2f元",model.balance];
        self.balanceLabel.hidden = NO;
    }else if(model.payment == 1){
        self.paymentLabel.text = @"微信支付";
        self.paymentLabel.frame = CGRectMake(self.payImageView.right+10, 15, 100, 30);
        self.balanceLabel.hidden = YES;
    }else{
        self.paymentLabel.text = @"支付宝支付";
        self.paymentLabel.frame = CGRectMake(self.payImageView.right+10, 15, 100, 30);
        self.balanceLabel.hidden = YES;
    }
    self.selectButton.selected = model.isSelected;
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
