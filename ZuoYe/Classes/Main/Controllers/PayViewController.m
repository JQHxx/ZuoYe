//
//  PayViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/14.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PayViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "CommentViewController.h"

@interface PayViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray   *titlesArr;
}

@property (nonatomic, strong) UILabel           *titleLabel;            //标题
@property (nonatomic, strong) UITableView       *payInfoTableView;      //支付信息
@property (nonatomic, strong) UIButton          *confirmButton;         //确定

@end

@implementation PayViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = kScreenHeight *0.5;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    titlesArr = self.tutoringType==TutoringTypeReview?@[@"检查价格",@"应付金额",@"支付方式"]:@[@"辅导价格",@"本次辅导时长",@"应付金额",@"支付方式"];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.payInfoTableView];
    [self.view addSubview:self.confirmButton];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titlesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = indexPath.row == titlesArr.count-1?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    cell.textLabel.text = titlesArr[indexPath.row];
    if (self.tutoringType==TutoringTypeReview) {
        if (indexPath.row==0) {
            cell.detailTextLabel.text =@"5.5元";
        }else if (indexPath.row==1){
            cell.detailTextLabel.text =@"5.5元";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }else{
            cell.detailTextLabel.text =@"余额";
        }
    }else{
        if (indexPath.row==0) {
            cell.detailTextLabel.text =@"1.00元/分钟";
        }else if (indexPath.row==1){
            cell.detailTextLabel.text =@"5分钟30秒";
        }else if (indexPath.row==2){
            cell.detailTextLabel.text =@"1.00*5.5=5.5元";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }else{
            cell.detailTextLabel.text =@"余额";
        }
    }
    return cell;
}

#pragma mark -- event response
#pragma mark 确认支付
-(void)confirmPayAction{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:^{
            self.backBlock(nil);
        }];
    }
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        _titleLabel.font = kFontWithSize(18);
        _titleLabel.text = @"支付";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark
-(UITableView *)payInfoTableView{
    if (!_payInfoTableView) {
        _payInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+10, kScreenWidth, kScreenHeight*0.5-self.titleLabel.bottom-80) style:UITableViewStylePlain];
        _payInfoTableView.delegate = self;
        _payInfoTableView.dataSource = self;
        _payInfoTableView.tableFooterView = [[UIView alloc] init];
    }
    return _payInfoTableView;
}

#pragma mark 确定支付
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kScreenHeight*0.5-60, kScreenWidth-40, 45)];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确认支付" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.layer.cornerRadius =5;
        [_confirmButton addTarget:self action:@selector(confirmPayAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


@end
