//
//  TransactionTypeViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TransactionTypeViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"

#import "LabelsView.h"

#define kMyHeight 200

@interface TransactionTypeViewController (){
    NSArray   *typesArray;
}

@property (nonatomic, strong) UILabel      *titleLabel;              //标题
@property (nonatomic, strong) UIButton     *closeButton;             //关闭按钮
@property (nonatomic, strong) LabelsView   *typeLabelsView;          //交易类型
@property (nonatomic, strong) UIButton     *confirmButton;            //确定

@end

@implementation TransactionTypeViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, kMyHeight);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, kMyHeight);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    typesArray = @[@"全部",@"作业检查",@"作业辅导",@"充值"];
    
    self.view.topBoderRadius = 8.0;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0, kScreenWidth, 0.5)];
    line2.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:line2];
    
    [self.view addSubview:self.typeLabelsView];
    [self.view addSubview:self.confirmButton];
}

#pragma mark -- Event Response
#pragma mark 关闭
-(void)closeTansactionViewAction:(UIButton *)sender{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:nil];
    }
}

#pragma mark 确定选择交易类型
-(void)confirmSelectedTransactionTypeAction:(UIButton *)sender{
    MyLog(@"type：%ld",self.transationType);
    if (self.popupController) {
        [self.popupController dismissWithCompletion:^{
            self.backBlock([NSNumber numberWithInteger:self.transationType]);
        }];
    }
}


#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, kScreenWidth-120, 25)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.text = @"交易类型";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 15, 35,22)];
        [_closeButton setTitle:@"取消" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [_closeButton addTarget:self action:@selector(closeTansactionViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark 交易类型
-(LabelsView *)typeLabelsView{
    if (!_typeLabelsView) {
        _typeLabelsView = [[LabelsView alloc] initWithFrame:CGRectZero];
        _typeLabelsView.selectedIndex = self.transationType==4?0:self.transationType;
        _typeLabelsView.labelsArray = [NSMutableArray arrayWithArray:typesArray];
        
        kSelfWeak;
        __weak typeof(_typeLabelsView) weakLabelsView = _typeLabelsView;
        _typeLabelsView.viewHeightRecalc = ^(CGFloat height) {
            weakLabelsView.frame = CGRectMake(10, weakSelf.titleLabel.bottom+33.0, kScreenWidth-20, height);
        };
        _typeLabelsView.didClickItem = ^(NSInteger itemIndex) {
            weakSelf.transationType = itemIndex==0?4:itemIndex;
        };
    }
    return _typeLabelsView;
}

#pragma mark 确定
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(43.0,self.titleLabel.bottom+102.0,kScreenWidth-95.0,(kScreenWidth-95.0)*(128.0/588.0))];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_confirmButton addTarget:self action:@selector(confirmSelectedTransactionTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
