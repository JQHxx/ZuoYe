//
//  FeedbackViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UITextView+ZWLimitCounter.h"
#import "UITextView+ZWPlaceHolder.h"

@interface FeedbackViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *myTextView;
@property (nonatomic, strong) UIButton   *submitButton;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"意见反馈";
    
    [self.view addSubview:self.myTextView];
    [self.view addSubview:self.submitButton];
}

#pragma mark--UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView==self.myTextView) {
        if ([textView.text length]+text.length>200) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

#pragma mark -- Event Response
#pragma mark  提交
-(void)submitFeedbackAction:(UIButton *)sender{
    if (kIsEmptyString(self.myTextView.text)) {
        [self.view makeToast:@"您的意见内容不能为空" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&content=%@",kUserTokenValue,_myTextView.text];
    [TCHttpRequest postMethodWithURL:kFeedbackAPI body:body success:^(id json) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.view makeToast:@"您的意见已提交!" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    }];
}

#pragma mark -- Getters
#pragma mark 文字输入
-(UITextView *)myTextView{
    if (!_myTextView) {
        _myTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, kNavHeight+10, kScreenWidth-20, 200)];
        _myTextView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        _myTextView.delegate = self;
        _myTextView.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _myTextView.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _myTextView.boderRadius = 4.0;
        _myTextView.zw_limitCount = 200;
        _myTextView.zw_placeHolder = @"请简要描述您的问题和意见";
    }
    return _myTextView;
}



#pragma mark 提交
-(UIButton *)submitButton{
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0, self.myTextView.bottom+50, 280,60)];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_submitButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_submitButton addTarget:self action:@selector(submitFeedbackAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}


@end
