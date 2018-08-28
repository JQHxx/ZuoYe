//
//  RechargeViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "RechargeViewController.h"
#import "AmountView.h"
#import "PhoneText.h"
#import "PaymentTableViewCell.h"
#import "PaymentModel.h"

#define kBtnWidth 80

@interface RechargeViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSArray        *amountArray;
    NSInteger      selectedIndex;
    
}

@property (nonatomic, strong) UITableView   *rechargeTableView;
@property (nonatomic, strong) UIButton      *confirmButton;

@property (nonatomic, strong) PhoneText     *amountTextField;
@property (nonatomic, strong) AmountView    *amountView;

@property (nonatomic, strong) NSMutableArray *paymentArray;

@end

@implementation RechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"充值";
    
    amountArray = @[@"50",@"100",@"200",@"500",@"1000",@"2000"];
    
    [self.view addSubview:self.rechargeTableView];
    [self.view addSubview:self.confirmButton];
    
    [self loadPayInfo];
    
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section==0?1:self.paymentArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section==0?@"充值金额":@"选择支付方式";
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.amountTextField = [[PhoneText alloc] initWithFrame:CGRectMake(20, 10, 80, 30)];
        self.amountTextField.borderStyle = UITextBorderStyleLine;
        self.amountTextField.placeholder = @"0";
        self.amountTextField.textColor = [UIColor blackColor];
        self.amountTextField.textAlignment = NSTextAlignmentCenter;
        self.amountTextField.font = kFontWithSize(16);
        self.amountTextField.delegate = self;
        [cell.contentView addSubview:self.amountTextField];
        
        UILabel *yuanLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.amountTextField.right+10, 10, 20, 30)];
        yuanLabel.text = @"元";
        yuanLabel.textColor = [UIColor blackColor];
        yuanLabel.font = kFontWithSize(16);
        [cell.contentView addSubview:yuanLabel];
        
        [cell.contentView addSubview:self.amountView];
        
        kSelfWeak;
        __weak typeof(_amountView) weakAmountView = self.amountView;
        self.amountView.viewHeightRecalc = ^(CGFloat height) {
            weakAmountView.frame = CGRectMake(5, weakSelf.amountTextField.bottom+20, kScreenWidth-10, height);
        };
        self.amountView.didClickItem = ^(NSInteger itemIndex) {
            selectedIndex = itemIndex;
            [weakSelf.amountTextField resignFirstResponder];
            weakSelf.amountTextField.text = @"";
        };
        
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
    return indexPath.section==0?160:60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


#pragma mark -- UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.amountView cancelClickItemAction];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (1 == range.length) {//按下回格键
        return YES;
    }
   
    if (self.amountTextField==textField) {
        if ([textField.text length]<6) {
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event reponse
#pragma mark 选择支付方式
-(void)choosePaymentAction:(UIButton *)sender{
    PaymentModel *model = self.paymentArray[sender.tag];
    for (PaymentModel *paymentModel in self.paymentArray) {
        if (model.payment==paymentModel.payment) {
            paymentModel.isSelected = YES;
        }else{
            paymentModel.isSelected = NO;
        }
    }
    [self.rechargeTableView reloadData];
}

#pragma mark  确认充值
-(void)confirmRechargeAction:(UIButton *)sender{
    
}

#pragma mark -- private methods
#pragma mark 获取付款信息
-(void)loadPayInfo{
    NSArray *images = @[@"weipay",@"alipay"];
    for (NSInteger i=0; i<images.count; i++) {
        PaymentModel *model = [[PaymentModel alloc] init];
        model.imageName = images[i];
        model.payment = i+1;
        if (i==0) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
        [self.paymentArray addObject:model];
    }
    [self.rechargeTableView reloadData];
}


#pragma mark -- Getters
#pragma mark 充值视图
-(UITableView *)rechargeTableView{
    if (!_rechargeTableView) {
        _rechargeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStyleGrouped];
        _rechargeTableView.dataSource= self;
        _rechargeTableView.delegate = self;
        _rechargeTableView.estimatedSectionFooterHeight = 0;
        _rechargeTableView.estimatedSectionHeaderHeight = 0;
    }
    return _rechargeTableView;
}

#pragma mark 确定支付
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kScreenHeight-80, kScreenWidth-40, 45)];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.layer.cornerRadius =5;
        [_confirmButton addTarget:self action:@selector(confirmRechargeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark
-(AmountView *)amountView{
    if (!_amountView) {
        _amountView = [[AmountView alloc] init];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSInteger i=0; i<amountArray.count; i++) {
            NSString *tempStr = [NSString stringWithFormat:@"%@元",amountArray[i]];
            [tempArr addObject:tempStr];
        }
        _amountView.labelsArray = tempArr;
    }
    return _amountView;
}

#pragma mark 支付方式
-(NSMutableArray *)paymentArray{
    if (!_paymentArray) {
        _paymentArray = [[NSMutableArray alloc] init];
    }
    return _paymentArray;
}



@end
