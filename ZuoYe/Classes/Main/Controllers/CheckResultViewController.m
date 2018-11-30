//
//  CheckResultViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CheckResultViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "TutorialPayViewController.h"
#import "PaySuccessViewController.h"
#import "PhotosView.h"
#import "TutorialModel.h"

@interface CheckResultViewController (){
    UIImageView  *headImageView;
    UILabel      *nameLabel;
    UILabel      *gradeLabel;
    UILabel      *priceLabel;
    
    TutorialModel  *myTutorial;
}

@property (nonatomic, strong) UILabel       *titleLabel;            //标题
@property (nonatomic ,strong) PhotosView    *photosView;
@property (nonatomic ,strong) UIView        *teacherView;
@property (nonatomic ,strong) UILabel       *payAmountLab;
@property (nonatomic ,strong) UIButton      *payButton;

@end

@implementation CheckResultViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = 543.0;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth-38, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    myTutorial = [[TutorialModel alloc] init];
    
    [self initCheckResultView];
    [self loadCheckResultData];
}

#pragma mark 去付款
-(void)payCheckOrderAction:(UIButton *)sender{
    TutorialPayViewController *payVC = [[TutorialPayViewController alloc] initWithIsOrderIn:YES];
    payVC.orderId = self.oid;
    payVC.payAmount = [myTutorial.pay_money doubleValue];
    payVC.label = 1;
    kSelfWeak;
    payVC.backBlock = ^(id object) {
        if (weakSelf.popupController) {
            [weakSelf.popupController dismissWithCompletion:^{
                PaySuccessViewController *paySuccessVC = [[PaySuccessViewController alloc] init];
                paySuccessVC.pay_amount = [object doubleValue];
                [weakSelf.navigationController pushViewController:paySuccessVC animated:YES];
            }];
        }
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initCheckResultView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.photosView];
    [self.view addSubview:self.teacherView];
    [self.view addSubview:self.payAmountLab];
    [self.view addSubview:self.payButton];
}

#pragma mark 加载数据
-(void)loadCheckResultData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@",kUserTokenValue,self.oid];
    [TCHttpRequest postMethodWithURL:kOrderDetailsAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dict = [json objectForKey:@"data"];
            [myTutorial setValues:dict];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.photosView.photosArray = [NSMutableArray arrayWithArray:myTutorial.pics];
                [headImageView sd_setImageWithURL:[NSURL URLWithString:myTutorial.trait] placeholderImage:[UIImage imageNamed:@"head_image"]];
                nameLabel.text = myTutorial.name;
                gradeLabel.text = [NSString stringWithFormat:@"%@/%@",myTutorial.grade,myTutorial.subject];
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[myTutorial.price doubleValue]];
                NSString *priceStr = [NSString stringWithFormat:@"应付款：%.2f元",[myTutorial.pay_money doubleValue]];
                NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
                [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF6161"] range:NSMakeRange(4, priceStr.length-4)];
                weakSelf.payAmountLab.attributedText = attributeStr;
            });
        });
    }];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, kScreenWidth-36-40, 22)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.text = @"作业检查结果";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 图片
-(PhotosView *)photosView{
    if (!_photosView) {
        _photosView = [[PhotosView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+11, kScreenWidth-36, 360) bgColor:[UIColor whiteColor]];
    }
    return _photosView;
}

#pragma mark 老师信息
-(UIView *)teacherView{
    if(!_teacherView){
        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(0, self.photosView.bottom+10, kScreenWidth-36, 69)];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 0, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [_teacherView addSubview:bgHeadImageView];
        
        //头像
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 3, 52, 52)];
        headImageView.boderRadius = 26.0;
        [_teacherView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13.0, 11.0, 80, 20)];
        nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_teacherView addSubview:nameLabel];
        
        gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13, nameLabel.bottom+1.0, 90, 17)];
        gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        [_teacherView addSubview:gradeLabel];
        
        UILabel *priceTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-90.0, nameLabel.top,74, 20)];
        priceTitleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        priceTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        priceTitleLab.textAlignment = NSTextAlignmentCenter;
        priceTitleLab.text = @"检查价格";
        [_teacherView addSubview:priceTitleLab];
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-90.0,priceTitleLab.bottom+2.0, 74.0, 17.0)];
        priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        [_teacherView addSubview:priceLabel];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,68,kScreenWidth-36, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [_teacherView addSubview:lineView];
    }
    return _teacherView;
}

#pragma mark 付款金额
-(UILabel *)payAmountLab{
    if (!_payAmountLab) {
        _payAmountLab = [[UILabel alloc] initWithFrame:CGRectMake(23, self.teacherView.bottom+15, 180, 22)];
        _payAmountLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _payAmountLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    }
    return _payAmountLab;
}

#pragma mark 去付款
-(UIButton *)payButton{
    if (!_payButton) {
        _payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-128, self.teacherView.bottom+12, 80, 80*(76.0/172.0))];
        _payButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [_payButton setBackgroundImage:[UIImage imageNamed:@"button_2"] forState:UIControlStateNormal];
        [_payButton setTitle:@"去付款" forState:UIControlStateNormal];
        [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(payCheckOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}



@end
