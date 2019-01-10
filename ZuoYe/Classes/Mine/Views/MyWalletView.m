//
//  MyWalletView.m
//  ZuoYe
//
//  Created by vision on 2018/12/6.
//  Copyright © 2018 vision. All rights reserved.
//

#import "MyWalletView.h"

@interface MyWalletView ()

@property (nonatomic,strong) UILabel *balanceLabel;  //账户余额
@property (nonatomic,strong) UILabel *creditLabel;   //可用余额

@end

@implementation MyWalletView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat viewWidth = frame.size.width/3.0;
        CGFloat viewHeight = frame.size.height;
        NSArray *imgs = @[@"account_balance",@"available_balance"];
        NSArray *descArr = @[@"账户余额（元）",@"可用余额（元）"];
        for (NSInteger i=0; i<2; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i*viewWidth, 0, viewWidth, viewHeight)];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth-25)/2.0, 17.6, 25, 25)];
            imgView.image = [UIImage imageNamed:imgs[i]];
            [btn addSubview:imgView];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, imgView.bottom+5, viewWidth-20, 22)];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
            lab.textColor = [UIColor colorWithHexString:@"#303030"];
            lab.text = @"--";
            [btn addSubview:lab];
            if (i==0) {
                self.balanceLabel = lab;
            }else{
                self.creditLabel = lab;
            }
            
            UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(10, lab.bottom, viewWidth-20, 20)];
            descLab.text = descArr[i];
            descLab.textAlignment = NSTextAlignmentCenter;
            descLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
            descLab.textColor = [UIColor colorWithHexString:@"#868C99"];
            [btn addSubview:descLab];
            
            [btn addTarget:self action:@selector(showMyWalletDetails) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake((i+1)*viewWidth, 30, 1, viewHeight-60)];
            line.backgroundColor = [UIColor colorWithHexString:@"#E2E4EC"];
            [self addSubview:line];
        }
        
        UIButton *rechargeBtn = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth*2, 0, viewWidth, viewHeight)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((viewWidth-25)/2.0, 17.6, 25, 25)];
        imgView.image = [UIImage imageNamed:@"recharge"];
        [rechargeBtn addSubview:imgView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, imgView.bottom+10, viewWidth-20, 22)];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        lab.textColor = [UIColor colorWithHexString:@"#303030"];
        lab.text = @"充值";
        [rechargeBtn addSubview:lab];
        
        [rechargeBtn addTarget:self action:@selector(toRechargeAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rechargeBtn];
        
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 显示我的钱包
-(void)showMyWalletDetails{
    if ([self.delegate respondsToSelector:@selector(myWalletViewShow)]) {
        [self.delegate myWalletViewShow];
    }
}

#pragma mark 充值
-(void)toRechargeAction{
    if ([self.delegate respondsToSelector:@selector(myWalletViewToRecharge)]) {
        [self.delegate myWalletViewToRecharge];
    }
}

#pragma mark 账户余额
-(void)setBalance:(double)balance{
    _balance = balance;
    self.balanceLabel.text = [NSString stringWithFormat:@"%.2f",balance];
}

#pragma mark 可用余额
-(void)setMyCredit:(double)myCredit{
    _myCredit = myCredit;
    self.creditLabel.text = [NSString stringWithFormat:@"%.2f",myCredit];
}

@end
