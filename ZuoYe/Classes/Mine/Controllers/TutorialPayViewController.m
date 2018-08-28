//
//  TutorialPayViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialPayViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "PaymentTableViewCell.h"
#import "PaymentModel.h"

#define kSelfHeight 450

@interface TutorialPayViewController ()<UITableViewDelegate,UITableViewDataSource>{
    double    payAmount;   //应付金额
}

@property (nonatomic, strong) UILabel           *titleLabel;            //标题
@property (nonatomic, strong) UIButton          *closeButton;             //关闭按钮
@property (nonatomic, strong) UITableView       *payInfoTableView;      //支付信息
@property (nonatomic, strong) UIButton          *confirmButton;         //确定

@property (nonatomic, strong) NSMutableArray    *paymentArray;

@end

@implementation TutorialPayViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, kSelfHeight);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, kSelfHeight);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.payInfoTableView];
    [self.view addSubview:self.confirmButton];
    
    [self loadPayInfo];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?1:self.paymentArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0?@"":@"选择支付方式";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"应付金额";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f元",payAmount];
        cell.detailTextLabel.textColor = [UIColor redColor];
        return cell;
    }else{
        PaymentTableViewCell *cell = [[PaymentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        PaymentModel *model = self.paymentArray[indexPath.row];
        cell.model = model;

        cell.myButton.tag = indexPath.row;
        [cell.myButton addTarget:self action:@selector(choosePaymentAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section==0?44:60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0?1:30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


#pragma mark -- event response
#pragma mark 确认支付
-(void)confirmPayAction{
    
}

#pragma mark 关闭（取消支付）
-(void)closeCommentViewAction{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:nil];
    }
}

-(void)choosePaymentAction:(UIButton *)sender{
    PaymentModel *model = self.paymentArray[sender.tag];
    for (PaymentModel *paymentModel in self.paymentArray) {
        if (model.payment==paymentModel.payment) {
            paymentModel.isSelected = YES;
        }else{
            paymentModel.isSelected = NO;
        }
    }
    [self.payInfoTableView reloadData];
}

#pragma mark -- private methods
#pragma mark 获取付款信息
-(void)loadPayInfo{
    payAmount = 5.5;
    
    double myBalance = 20.0;
    
    NSArray *images = @[@"weipay",@"weipay",@"alipay"];
    for (NSInteger i=0; i<images.count; i++) {
        PaymentModel *model = [[PaymentModel alloc] init];
        model.imageName = images[i];
        model.payment = i;
        if (i==0) {
            model.balance = myBalance;
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
        [self.paymentArray addObject:model];
    }
    [self.payInfoTableView reloadData];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        _titleLabel.font = kFontWithSize(18);
        _titleLabel.text = @"去付款";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-30, 5, 30,30)];
        [_closeButton setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeCommentViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark
-(UITableView *)payInfoTableView{
    if (!_payInfoTableView) {
        _payInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+10, kScreenWidth, kSelfHeight-self.titleLabel.bottom-80) style:UITableViewStyleGrouped];
        _payInfoTableView.delegate = self;
        _payInfoTableView.dataSource = self;
        _payInfoTableView.estimatedSectionHeaderHeight = 0;
        _payInfoTableView.estimatedSectionFooterHeight = 0;
        _payInfoTableView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _payInfoTableView;
}

#pragma mark 确定支付
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kSelfHeight-60, kScreenWidth-40, 45)];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确认支付" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.layer.cornerRadius =5;
        [_confirmButton addTarget:self action:@selector(confirmPayAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark 支付信息
-(NSMutableArray *)paymentArray{
    if (!_paymentArray) {
        _paymentArray = [[NSMutableArray alloc] init];
    }
    return _paymentArray;
}

@end
