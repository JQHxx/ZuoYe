//
//  ComplaintViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ComplaintViewController.h"
#import "BackScrollView.h"

@interface ComplaintViewController ()<UITextViewDelegate>{
    UIButton    *selectedBtn;
    UILabel     *promptLabel;
    UILabel     *countLabel;
    NSInteger   type;   // 投诉类型1=对老师不满意2=对订单有疑问3=其他
}

@property (nonatomic, strong) UITextView  *complaintTextView;


@end

@implementation ComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"投诉";
    
    type = 1;
    
  
    [self initComplaintView];
   
}

#pragma mark--UITextViewDelegate
- (void)textViewDidChangeSelection:(UITextView *)textView{
    NSString *tString = [NSString stringWithFormat:@"%lu/200",(unsigned long)textView.text.length];
    countLabel.text = tString;
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]!= 0) {
        promptLabel.hidden = YES;
    }else{
        promptLabel.hidden = NO;
        NSString *tString = [NSString stringWithFormat:@"%lu/200",(unsigned long)textView.text.length];
        countLabel.text = tString;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView==self.complaintTextView) {
        if ([textView.text length]+text.length>200) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event response
#pragma mark 选择投诉类型
-(void)selectedComplaintTypeAction:(UIButton *)sender{
    if (selectedBtn) {
        selectedBtn.selected = NO;
        selectedBtn.layer.borderColor = [[UIColor blackColor] CGColor];
    }
    
    sender.selected = YES;
    sender.layer.borderColor = [UIColor redColor].CGColor;
    selectedBtn = sender;
    type = sender.tag + 1;
}

#pragma mark 确认
-(void)confirmComplaintAction:(UIButton *)sender{
    if (kIsEmptyString(self.complaintTextView.text)) {
        [self.view makeToast:@"您的投诉内容不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@&comment=%@&label=%ld",kUserTokenValue,self.oid,self.complaintTextView.text,type];
    [TCHttpRequest postMethodWithURL:kOrderComplaintAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.view makeToast:@"您的投诉已提交" duration:1.0 position:CSToastPositionCenter];
        });
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark -- Private methods
-(void)initComplaintView{
    BackScrollView *rootScrollView = [[BackScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
    rootScrollView.backgroundColor = [UIColor bgColor_Gray];
    [self.view addSubview:rootScrollView];
    
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 260)];
    rootView.backgroundColor = [UIColor whiteColor];
    [rootScrollView addSubview:rootView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(18, 10, 80, 22)];
    titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    titleLab.text = @"投诉类型";
    [rootView addSubview:titleLab];
    
    NSArray *btnTitles = @[@"对老师不满意",@"对订单有疑问",@"其他"];
    for (NSInteger i=0; i<btnTitles.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"pay_choose_gray"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"pay_choose"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        btn.tag = i;
        if (i==0) {
            btn.selected = YES;
            selectedBtn = btn;
        }
        
        if (i==2) {
            btn.frame = CGRectMake(18+120*i, titleLab.bottom+5, 55, 30);
        }else{
            btn.frame = CGRectMake(18+120*i, titleLab.bottom+5, 107, 30);
        }
        
        btn.titleEdgeInsets = UIEdgeInsetsMake(5,5,5, 0);
        [btn addTarget:self action:@selector(selectedComplaintTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [rootView addSubview:btn];
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0,71, kScreenWidth, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [rootView addSubview:line];
    
    [rootView addSubview:self.complaintTextView];
    
    
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0,rootView.bottom+35+kNavHeight,280.0,60)];
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    [confirmButton addTarget:self action:@selector(confirmComplaintAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    
}

#pragma mark -- Getters and Setters
#pragma mark 投诉内容
-(UITextView *)complaintTextView{
    if (!_complaintTextView) {
        _complaintTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 72, kScreenWidth-30, 186)];
        _complaintTextView.delegate = self;
        _complaintTextView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _complaintTextView.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _complaintTextView.returnKeyType = UIReturnKeyDone;
        
        promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 250, 20)];
        promptLabel.text = @"请简要描述您要投诉的内容";
        promptLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        promptLabel.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [_complaintTextView addSubview:promptLabel];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120, 155, 80, 20)];
        countLabel.text = @"0/500";
        countLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        countLabel.textAlignment = NSTextAlignmentRight;
        countLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_complaintTextView addSubview:countLabel];
    }
    return _complaintTextView;
}



@end
