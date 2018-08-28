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
    NSString  *typeStr;
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
    typeStr = @"全部";
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
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
    MyLog(@"type：%@",typeStr);
    if (self.popupController) {
        [self.popupController dismissWithCompletion:^{
            self.backBlock(typeStr);
        }];
    }
}


#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        _titleLabel.font = kFontWithSize(18);
        _titleLabel.text = @"交易类型";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-30, 5, 30,30)];
        [_closeButton setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeTansactionViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark 交易类型
-(LabelsView *)typeLabelsView{
    if (!_typeLabelsView) {
        _typeLabelsView = [[LabelsView alloc] initWithFrame:CGRectZero];
        _typeLabelsView.labelsArray = [NSMutableArray arrayWithArray:typesArray];
        
        kSelfWeak;
        __weak typeof(_typeLabelsView) weakLabelsView = _typeLabelsView;
        _typeLabelsView.viewHeightRecalc = ^(CGFloat height) {
            weakLabelsView.frame = CGRectMake(10, weakSelf.titleLabel.bottom+20, kScreenWidth-20, height);
        };
        _typeLabelsView.didClickItem = ^(NSInteger itemIndex) {
            typeStr = typesArray[itemIndex];
        };
    }
    return _typeLabelsView;
}

#pragma mark 确定
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kMyHeight-50, kScreenWidth-40, 40)];
        _confirmButton.layer.cornerRadius = 5;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton addTarget:self action:@selector(confirmSelectedTransactionTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
