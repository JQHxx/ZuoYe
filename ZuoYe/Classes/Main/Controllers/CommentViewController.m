//
//  CommentViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CommentViewController.h"
#import "XHStarRateView.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"
#import "UITextView+ZWPlaceHolder.h"
#import "UITextView+ZWLimitCounter.h"
#import "LoginButton.h"
#import "MyTutorialViewController.h"
#import "TutorialDetailsViewController.h"

#define kMyHeight 450

@interface CommentViewController ()<XHStarRateViewDelegate,UITextViewDelegate>{
    CGFloat       score;   //评分
    UITextView     *commentText;         //评价
}

@property (nonatomic, strong) UIView       *commentScoreView;        //打分
@property (nonatomic, strong) UIView       *commentTextView;         //文字评论
@property (nonatomic, strong) LoginButton  *commitButton;            //提交

@end

@implementation CommentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"评价";
    
    [self.view addSubview:self.commentScoreView];
    [self.view addSubview:self.commentTextView];
    [self.view addSubview:self.commitButton];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

#pragma mark -- Delegate
#pragma mark XHStarRateViewDelegate
-(void)starRateView:(XHStarRateView *)starRateView currentScore:(CGFloat)currentScore{
    score = currentScore;
    MyLog(@"评分,%.1f",score);
}

#pragma mark -- Event reponse
#pragma mark 提交评论
-(void)commitCommentInfoAction:(UIButton *)sender{
    if (score<0.5) {
        [self.view makeToast:@"请选择评分" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (kIsEmptyString(commentText.text)) {
        [self.view makeToast:@"请输入评价内容" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@&score=%.1f&tid=%@&comment=%@",kUserTokenValue,self.orderId,score,self.tid,commentText.text];
    [TCHttpRequest postMethodWithURL:kTeacherCommentAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [weakSelf.view makeToast:@"您的评价已提交" duration:1.0 position:CSToastPositionCenter];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf popToTargetPageAction];
        });
    }];
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    [self popToTargetPageAction];
}

#pragma mark 返回
-(void)popToTargetPageAction{
    BOOL isOrderIn = NO;
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[MyTutorialViewController class]]) {
            [ZYHelper sharedZYHelper].isUpdateOrder = YES;
            isOrderIn = YES;
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
    if (!isOrderIn) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -- getters and setters
#pragma mark 打分
-(UIView *)commentScoreView{
    if (!_commentScoreView) {
        _commentScoreView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavHeight+10, kScreenWidth,44)];
        
        UIView *badgeView = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 4, 16)];
        badgeView.backgroundColor = [UIColor colorWithHexString:@"#FF6161"];
        [_commentScoreView addSubview:badgeView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 50, 22)];
        titleLab.text = @"打分";
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_commentScoreView addSubview:titleLab];
        
        XHStarRateView *starRateView = [[XHStarRateView alloc] initWithFrame:CGRectMake(titleLab.right, 6,105, 22)];
        starRateView.isAnimation = NO;
        starRateView.rateStyle = HalfStar;
        starRateView.delegate = self;
        [_commentScoreView addSubview:starRateView];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_commentScoreView addSubview:line];
    }
    return _commentScoreView;
}


#pragma mark 文字评价
-(UIView *)commentTextView{
    if (!_commentTextView) {
        _commentTextView  = [[UIView alloc] initWithFrame:CGRectMake(0, self.commentScoreView.bottom+10, kScreenWidth, 179)];
        
        UIView *badgeView = [[UILabel alloc] initWithFrame:CGRectMake(0, 9, 4, 16)];
        badgeView.backgroundColor = [UIColor colorWithHexString:@"#FF6161"];
        [_commentTextView addSubview:badgeView];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 6, 40, 22)];
        titleLab.text = @"评价";
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        titleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_commentTextView addSubview:titleLab];
        
        commentText = [[UITextView alloc] initWithFrame:CGRectMake(titleLab.left, titleLab.bottom, kScreenWidth-titleLab.left-10, 140)];
        commentText.font=[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        commentText.textColor=[UIColor colorWithHexString:@"#4A4A4A"];
        commentText.delegate=self;
        commentText.zw_placeHolder = @"请对老师简单评价一下吧";
        commentText.zw_limitCount = 200;
        [_commentTextView addSubview:commentText];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 178.5, kScreenWidth, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [_commentTextView addSubview:line];
        
    }
    return _commentTextView;
}

#pragma mark 提交
-(LoginButton *)commitButton{
    if (!_commitButton) {
        _commitButton = [[LoginButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0,self.commentTextView.bottom+30,280,55) title:@"提交"];
        [_commitButton addTarget:self action:@selector(commitCommentInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitButton;
}


@end
