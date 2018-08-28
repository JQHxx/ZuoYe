//
//  CommentViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CommentViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "XHStarRateView.h"
#import "LabelsView.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

#define kMyHeight 450

@interface CommentViewController ()<XHStarRateViewDelegate,UITextViewDelegate>{
    CGFloat       score;   //评分
    NSString      *labelStr;   //标签
    
    NSArray        *commentLabelsArr;
    LabelsView     *labelView;
    UIButton       *refreshBtn;          //刷新
    UITextView     *commentText;         //评价
}

@property (nonatomic, strong) UILabel      *titleLabel;              //标题
@property (nonatomic, strong) UIButton     *closeButton;             //关闭按钮
@property (nonatomic, strong) UIView       *commentScoreView;        //打分
@property (nonatomic, strong) UIView       *commentLabelsView;       //标签
@property (nonatomic, strong) UIView       *commentTextView;         //文字评论
@property (nonatomic, strong) UIButton     *commitButton;            //提交

@end

@implementation CommentViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, kMyHeight);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight,kMyHeight);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    commentLabelsArr = @[@"完美解决了我的问题",@"口齿清晰",@"普通话标准",@"讲解通俗易懂",@"声音好听"];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.commentScoreView];
    [self.view addSubview:self.commentLabelsView];
    [self.view addSubview:self.commentTextView];
    [self.view addSubview:self.commitButton];
    
    [self loadLabelsData];
    
}

#pragma mark -- Delegate
#pragma mark XHStarRateViewDelegate
-(void)starRateView:(XHStarRateView *)starRateView currentScore:(CGFloat)currentScore{
    score = currentScore;
}

#pragma mark -- Event reponse
#pragma mark 关闭
-(void)closeCommentViewAction{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:^{
            self.backBlock(nil);
        }];
    }
}

#pragma mark 刷新标签词
-(void)refreshLabelsAction{
    [self loadLabelsData];
}

#pragma mark 提交评论
-(void)commitCommentInfoAction:(UIButton *)sender{
    MyLog(@"score：%.f,label:%@,comment:%@",score,labelStr,commentText.text);
}

#pragma mark -- Private Methods
-(void)loadLabelsData{
    NSMutableArray *arr =[NSMutableArray arrayWithArray:commentLabelsArr];
    NSInteger i = [arr count];
    while(--i > 0) {
        NSInteger j = rand() % (i+1);
        [arr exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
    labelStr = arr[0];
    labelView.labelsArray = arr;
    
    kSelfWeak;
    __weak typeof(labelView) weakView = labelView;
    __weak typeof(_commentLabelsView) weakCommentLabelView = _commentLabelsView;
    __weak typeof(refreshBtn) weakRefreshBtn = refreshBtn;
    __weak typeof(_commentTextView) weakCommentTextView = _commentTextView;
    labelView.viewHeightRecalc = ^(CGFloat height) {
        weakView.frame = CGRectMake(60, 10, kScreenWidth-60-20, height);
        weakRefreshBtn.frame = CGRectMake(kScreenWidth-80, weakView.bottom-5, 70, 30);
        weakCommentLabelView.frame = CGRectMake(0, weakSelf.commentScoreView.bottom, kScreenWidth, height + 30);
        weakCommentTextView.frame = CGRectMake(0, weakCommentLabelView.bottom, kScreenWidth, 120);
    };
    
    labelView.didClickItem = ^(NSInteger itemIndex) {
        MyLog(@"选择index（%ld）:%@",itemIndex,arr[itemIndex]);
        labelStr = arr[itemIndex];
    };
}

#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        _titleLabel.font = kFontWithSize(18);
        _titleLabel.text = @"评价";
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

#pragma mark 打分
-(UIView *)commentScoreView{
    if (!_commentScoreView) {
        _commentScoreView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+10, kScreenWidth, 50)];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 50, 30)];
        titleLab.text = @"打分";
        titleLab.font = kFontWithSize(16);
        titleLab.textColor = [UIColor blackColor];
        [_commentScoreView addSubview:titleLab];
        
        XHStarRateView *starRateView = [[XHStarRateView alloc] initWithFrame:CGRectMake(titleLab.right, 10, 200, 30)];
        starRateView.isAnimation = NO;
        starRateView.rateStyle = HalfStar;
        starRateView.delegate = self;
        [_commentScoreView addSubview:starRateView];
    }
    return _commentScoreView;
}

#pragma mark 标签
-(UIView  *)commentLabelsView{
    if (!_commentLabelsView) {
        _commentLabelsView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 40, 30)];
        titleLab.text = @"标签";
        titleLab.font = kFontWithSize(16);
        titleLab.textColor = [UIColor blackColor];
        [_commentLabelsView addSubview:titleLab];
        
        labelView = [[LabelsView alloc] init];
        [_commentLabelsView addSubview:labelView];
        
        refreshBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [refreshBtn setTitle:@"换一换" forState: UIControlStateNormal];
        refreshBtn.titleLabel.font = kFontWithSize(14);
        [refreshBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [refreshBtn addTarget:self action:@selector(refreshLabelsAction) forControlEvents:UIControlEventTouchUpInside];
        [_commentLabelsView addSubview:refreshBtn];
        
    }
    return _commentLabelsView;
}

#pragma mark 文字评价
-(UIView *)commentTextView{
    if (!_commentTextView) {
        _commentTextView  = [[UIView alloc] initWithFrame:CGRectZero];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 40, 30)];
        titleLab.text = @"评价";
        titleLab.font = kFontWithSize(16);
        titleLab.textColor = [UIColor blackColor];
        [_commentTextView addSubview:titleLab];
        
        commentText = [[UITextView alloc] initWithFrame:CGRectMake(titleLab.right+10, 10, kScreenWidth-titleLab.right-20, 80)];
        commentText.font=[UIFont systemFontOfSize:14.0];
        commentText.textColor=[UIColor blackColor];
        commentText.delegate=self;
        commentText.returnKeyType=UIReturnKeyDone;
        commentText.layer.cornerRadius = 3;
        commentText.layer.borderColor = [UIColor lightGrayColor].CGColor;
        commentText.layer.borderWidth = 1;
        [commentText setContentSize:CGSizeMake(kScreenWidth-20.0, 180.0)];
        [_commentTextView addSubview:commentText];
        
    }
    return _commentTextView;
}

#pragma mark 提交
-(UIButton *)commitButton{
    if (!_commitButton) {
        _commitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, kMyHeight-50, kScreenWidth-40, 40)];
        _commitButton.layer.cornerRadius = 5;
        [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _commitButton.backgroundColor = [UIColor redColor];
        [_commitButton addTarget:self action:@selector(commitCommentInfoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitButton;
}


@end
