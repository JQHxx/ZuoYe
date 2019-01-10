//
//  ComplaintViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ComplaintViewController.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"

@interface ComplaintViewController ()<UITextViewDelegate>{
    UIButton    *selectedBtn;
    NSInteger   type;   // 投诉类型1=对老师不满意2=对订单有疑问3=其他
    
    UITextView  *complaintTextView;
}

@property (nonatomic, strong) UIView  *complaintView;


@end

@implementation ComplaintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"投诉";
    
    type = 1;
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
  
    [self initComplaintView];
   
}

#pragma mark--UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView==complaintTextView) {
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
    if (kIsEmptyString(complaintTextView.text)) {
        [self.view makeToast:@"您的投诉内容不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@&comment=%@&label=%ld",kUserTokenValue,self.oid,complaintTextView.text,type];
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
    UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavHeight+10, kScreenWidth, 260)];
    rootView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rootView];
    
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
    
    [rootView addSubview:self.complaintView];
    
    
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
-(UIView *)complaintView{
    if (!_complaintView) {
        _complaintView  = [[UIView alloc] initWithFrame:CGRectMake(0, 72, kScreenWidth, 186)];
        _complaintView.backgroundColor = [UIColor whiteColor];
        
        complaintTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth-30, 186)];
        complaintTextView.delegate = self;
        complaintTextView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        complaintTextView.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        complaintTextView.returnKeyType = UIReturnKeyDone;
        complaintTextView.zw_placeHolder = @"请简要描述您要投诉的内容";
        complaintTextView.zw_limitCount = 200;
        [_complaintView addSubview:complaintTextView];
    
        
    }
    return _complaintView;
}




@end
