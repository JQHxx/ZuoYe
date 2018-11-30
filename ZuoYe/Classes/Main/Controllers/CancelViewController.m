//
//  CancelViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/14.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CancelViewController.h"
#import "HomeworkViewController.h"
#import "MyTutorialViewController.h"
#import "WhiteboardCmdHandler.h"
#import "UIButton+Touch.h"

@interface CancelViewController ()<WhiteboardCmdHandlerDelegate>{
    NSArray   *reasonsArr;
    UIButton  *selectBtn;
    NSInteger selectRid;
}

@property (nonatomic ,strong) UIButton *confirmButton;
@property (nonatomic , strong ) WhiteboardCmdHandler   *cmdHander;

@end

@implementation CancelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.myTitle;
    
    _cmdHander = [[WhiteboardCmdHandler alloc] initWithDelegate:self];
    
    [self initCancelView];
    [self loadCancelReasonsInfo];
}

#pragma mark -- event response
#pragma mark 选择取消原因
-(void)chooseCancelReaonsAction:(UIButton *)sender{
    if (selectBtn) {
        selectBtn.selected = NO;
    }
    sender.selected = YES;
    selectBtn = sender;
    selectRid = sender.tag;
}

#pragma mark 确定
-(void)confirmChooseCancelReasonAction{
    kSelfWeak;
    if (self.type==CancelTypeHomework) {  //作业取消
        NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@&rid=%ld",kUserTokenValue,self.jobid,selectRid];
        [TCHttpRequest postMethodWithURL:kJobCancelAPI body:body success:^(id json) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:@"您已取消作业"duration:1.0 position:CSToastPositionCenter];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ZYHelper sharedZYHelper].isUpdateHome = YES;
                BOOL isHomework = NO;
                for (BaseViewController *controller in weakSelf.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[HomeworkViewController class]]) {
                        [ZYHelper sharedZYHelper].isUpdateHomework = YES;
                        [weakSelf.navigationController popToViewController:controller animated:YES];
                        isHomework = YES;
                        break;
                    }
                }
                if (!isHomework) {
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
            });
        }];
    }else{ //订单取消
        NSString *body = [NSString stringWithFormat:@"token=%@&jobid=%@&rid=%ld",kUserTokenValue,self.jobid,selectRid];
        [TCHttpRequest postMethodWithURL:kOrderCancelAPI body:body success:^(id json) {
            if (weakSelf.type== CancelTypeOrderCocah) {
                [_cmdHander sendPureCmd:WhiteBoardCmdTypeCancelCoach];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf.view makeToast:@"您已取消订单"duration:1.0 position:CSToastPositionCenter];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL isOrder = NO;
                for (BaseViewController *controller in weakSelf.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[MyTutorialViewController class]]) {
                        [ZYHelper sharedZYHelper].isUpdateOrder = YES;
                        [weakSelf.navigationController popToViewController:controller animated:YES];
                        isOrder = YES;
                        break;
                    }
                }
                if (!isOrder) {
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                }
            });
        }];
    }
}


#pragma mark -- Private methods
#pragma mark 初始化
-(void)initCancelView{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30,kNavHeight+18, kScreenWidth-52, 22)];
    titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    titleLabel.text = [NSString stringWithFormat:@"请说明您的%@的原因",self.myTitle];
    [self.view addSubview:titleLabel];

    [self.view addSubview:self.confirmButton];
}

#pragma mark 获取取消原因
-(void)loadCancelReasonsInfo{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&label=%ld",kUserTokenValue,self.type];
    [TCHttpRequest postMethodWithURL:kCancelReasonAPI body:body success:^(id json) {
        reasonsArr = [json objectForKey:@"data"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf creatReasonsListViewWithReasons:reasonsArr];
            weakSelf.confirmButton.frame = CGRectMake((kScreenWidth-280)/2.0,kNavHeight+44+46*reasonsArr.count+30,280,55);
        });
    }];
}

#pragma mark
-(void)creatReasonsListViewWithReasons:(NSArray *)reasonsArr{
    for (NSInteger i=0; i<reasonsArr.count; i++) {
        NSDictionary *dict = reasonsArr[i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30,kNavHeight+54+(30+16)*i, kScreenWidth-40, 30)];
        [btn setTitle:dict[@"reason"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"pay_choose_gray"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"pay_choose"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#FF6161"] forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        btn.titleEdgeInsets = UIEdgeInsetsMake(5,5,5, 0);
        btn.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.tag = [dict[@"rid"] integerValue];
        [btn addTarget:self action:@selector(chooseCancelReaonsAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark 确定
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_confirmButton addTarget:self action:@selector(confirmChooseCancelReasonAction) forControlEvents:UIControlEventTouchUpInside];
         _confirmButton.timeInterval = 3.0;
    }
    return _confirmButton;
}





@end
