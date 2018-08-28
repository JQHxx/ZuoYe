//
//  ComplaintViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ComplaintViewController.h"

@interface ComplaintViewController ()<UITextViewDelegate>{
    UIButton    *selectedBtn;
    UILabel     *promptLabel;
}

@property (nonatomic, strong) UIView      *typeView;
@property (nonatomic, strong) UITextView  *complaintTextView;
@property (nonatomic, strong) UIButton    *confirmButton;

@end

@implementation ComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"投诉";
    
    
    [self.view addSubview:self.typeView];
    [self.view addSubview:self.complaintTextView];
    [self.view addSubview:self.confirmButton];
}

#pragma mark 选择投诉类型
-(void)selectedComplaintTypeAction:(UIButton *)sender{
    if (selectedBtn) {
        selectedBtn.selected = NO;
        selectedBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    sender.selected = YES;
    sender.layer.borderColor = [UIColor redColor].CGColor;
    selectedBtn = sender;
}

#pragma mark
-(void)confirmComplaintAction:(UIButton *)sender{
    
}

#pragma mark -- Getters and Setters
#pragma mark 投诉类型
-(UIView *)typeView{
    if (!_typeView) {
        _typeView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth,90)];
        _typeView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 150, 30)];
        titleLab.font = kFontWithSize(14);
        titleLab.textColor = [UIColor blackColor];
        titleLab.text = @"选择投诉类型";
        [_typeView addSubview:titleLab];
        
        NSArray *btnTitles = @[@"对老师不满意",@"对订单有疑问",@"其他"];
        CGFloat tempWidth = 20;
        for (NSInteger i=0; i<3; i++) {
            NSString *btnTitle = btnTitles[i];
            CGFloat btnWidth = [btnTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30) withTextFont:kFontWithSize(14)].width+20;
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(tempWidth+i*20, titleLab.bottom+10, btnWidth, 30)];
            [btn setTitle:btnTitle forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor blackColor].CGColor;
            btn.layer.cornerRadius =3;
            btn.titleLabel.font = kFontWithSize(14);
            [btn addTarget:self action:@selector(selectedComplaintTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            [_typeView addSubview:btn];
            
            tempWidth += btnWidth;
        }
    }
    return _typeView;
}

#pragma mark 投诉内容
-(UITextView *)complaintTextView{
    if (!_complaintTextView) {
        _complaintTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, self.typeView.bottom+20, kScreenWidth-30, 80)];
        _complaintTextView.layer.borderColor = kLineColor.CGColor;
        _complaintTextView.layer.borderWidth = 1;
        _complaintTextView.layer.cornerRadius = 5.0;
        _complaintTextView.font = [UIFont systemFontOfSize:13];
        _complaintTextView.delegate = self;
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 250, 20)];
        promptLabel.text = @"请简要描述您要投诉的内容";
        promptLabel.font = [UIFont systemFontOfSize:14];
        promptLabel.textColor = [UIColor lightGrayColor];
        [_complaintTextView addSubview:promptLabel];
    }
    return _complaintTextView;
}

#pragma mark 确认
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(15, self.complaintTextView.bottom+20, kScreenWidth-30, 40)];
        [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor redColor];
        _confirmButton.layer.cornerRadius = 5.0;
        [_confirmButton addTarget:self action:@selector(confirmComplaintAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

@end
