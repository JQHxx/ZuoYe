//
//  TutorialViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialViewController.h"
#import "CancelViewController.h"
#import "ChatViewController.h"
#import "PayViewController.h"
#import "STPopupController.h"
#import "CommentViewController.h"
#import "YBPopupMenu.h"

@interface TutorialViewController ()<YBPopupMenuDelegate>

@property (nonatomic, strong ) UIScrollView  *rootScrollView;
@property (nonatomic, strong ) UIButton      *rightBtn;
@property (nonatomic, strong ) UILabel       *countLabel;
@property (nonatomic, strong ) UILabel       *tipsLabel;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [self initTutorialView];
}

#pragma mark -- Delegate
#pragma mark  YBPopupMenuDelegate
-(void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    if(index==0){
        CancelViewController *cancelVC = [[CancelViewController alloc] init];
        [self.navigationController pushViewController:cancelVC animated:YES];
    }else{
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark -- Event response
#pragma mark 查看更多（取消辅导和消息）
-(void)getMoreHandleListAction{
    [YBPopupMenu showRelyOnView:self.rightBtn titles:@[@"取消辅导",@"消息"] icons:@[@"",@"",@""] menuWidth:100 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.priorityDirection = YBPopupMenuPriorityDirectionTop;
        popupMenu.borderWidth = 0.5;
        popupMenu.borderColor = [UIColor colorWithHexString:@"0xeeeeeee"];
        popupMenu.delegate = self;
        popupMenu.textColor = [UIColor colorWithHexString:@"0x626262"];
        popupMenu.fontSize = 14;
    }];
}

#pragma mark 结束
-(void)endHomeworkCheckAction{
    PayViewController *payVC = [[PayViewController alloc] init];
    payVC.tutoringType = TutoringTypeReview;
    payVC.backBlock = ^(id object) {
        CommentViewController *commentVC = [[CommentViewController alloc] init];
        commentVC.backBlock = ^(id object) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        };
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:commentVC];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    };
    
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark -- Private Methods
#pragma mark 初始化
-(void)initTutorialView{
    [self.view addSubview:self.rootScrollView];
    [self.view addSubview:self.rightBtn];
    [self.view addSubview:self.countLabel];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5;
    [self.view addSubview:bgView];
    
    [self.view addSubview:self.tipsLabel];
}

#pragma mark -- Getters
#pragma mark 根视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _rootScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rootScrollView;
}

#pragma mark 更多
-(UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, KStatusHeight+10, 30, 30)];
        [_rightBtn setImage:[UIImage imageNamed:@"connection_more"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(getMoreHandleListAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

#pragma mark 数量
-(UILabel *)countLabel{
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-40, kScreenHeight-82, 30, 22)];
        _countLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _countLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _countLabel.text = @"1/4";
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

#pragma mark 数量
-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, kScreenHeight-37, kScreenWidth-30, 22)];
        _tipsLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        _tipsLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _tipsLabel.text = @"老师正在审题，审题阶段的时间不计费";
        _tipsLabel.textAlignment = NSTextAlignmentRight;
    }
    return _tipsLabel;
}



@end
