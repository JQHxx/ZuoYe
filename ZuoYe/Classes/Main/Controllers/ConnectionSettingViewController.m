//
//  ConnectionSettingViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ConnectionSettingViewController.h"
#import "TakePhotoViewController.h"
#import "ConnecttingViewController.h"
#import "PhotoFrameView.h"
#import "TeacherInfoView.h"
#import "UIButton+Touch.h"
#import "RechargeAlertViewController.h"
#import "STPopupController.h"
#import "UIViewController+STPopup.h"
#import <UMAnalytics/MobClick.h>

@interface ConnectionSettingViewController ()<PhotoFrameViewDelegate,TakePhotoViewControllerDelegate>{
    double         checkPrice;
}

@property (nonatomic, strong) UIView              *bgView;   //根视图
@property (nonatomic, strong) TeacherInfoView     *infoView;
@property (nonatomic, strong) UIView              *addPhotoView;      //上传图片
@property (nonatomic, strong) PhotoFrameView      *photosFramView;   //作业相册
@property (nonatomic, strong) UIButton            *connenctBtn;
@property (nonatomic, strong) NSMutableArray      *photosArray;

@end

@implementation ConnectionSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"连线设置";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initSettingVew];
}

#pragma mark -- Delegate
#pragma mark PhotoFrameViewDelegate
#pragma mark 删除图片
-(void)photoFrameViewDidDeleteImageWithIndex:(NSInteger)index{
    [self.photosArray removeObjectAtIndex:index];
    [self.photosFramView updateCollectViewWithPhotosArr:self.photosArray];
}

#pragma mark 添加图片
-(void)photoFrameViewAddImage{
    [self addHomeworkPhotosAction];
}

#pragma mark  AddPhotoViewDelegate
#pragma mark 上传图片
-(void)addHomeworkPhotosAction{
    TakePhotoViewController *takePicturesVC = [[TakePhotoViewController alloc] init];
    takePicturesVC.isConnectionSetting = YES;
    takePicturesVC.controllerDelegate = self;
    [self.navigationController pushViewController:takePicturesVC animated:YES];
}

#pragma mark TakePhotoViewControllerDelegate
-(void)takePhotoViewContriller:(TakePhotoViewController *)controller didGotPhotos:(NSMutableArray *)photos{
    self.addPhotoView.hidden = YES;
    self.photosFramView.hidden = NO;
    
    [self.photosArray addObjectsFromArray:photos];
    if (self.photosArray.count>kMaxPhotosCount) {
        NSString *message = [NSString stringWithFormat:@"最多只能上传%ld张图片",kMaxPhotosCount];
        [self.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        [self.photosArray removeObjectsInArray:photos];
        return;
    }
    [self.photosFramView updateCollectViewWithPhotosArr:self.photosArray];
}

#pragma mark 连线老师
-(void)callTeacherForHelpAction{
    if (self.photosArray.count==0) {
        [self.view makeToast:@"请先上传您要辅导的作业图片" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    
    [MobClick event:@"10003"];
    
    kSelfWeak;
    NSMutableArray *imgArr = [[ZYHelper sharedZYHelper] imageDataProcessingWithImgArray:self.photosArray];
    NSString *imageArrJsonStr = [TCHttpRequest getValueWithParams:imgArr];
    NSString *body = [NSString stringWithFormat:@"pic=%@&dir=2",imageArrJsonStr];
    [TCHttpRequest postMethodWithURL:kUploadPicAPI body:body success:^(id json) {
        NSArray *imagesUrl = [json objectForKey:@"data"];
        NSString * imgJsonStr = [TCHttpRequest getValueWithParams:imagesUrl];
        
        NSString *body2 = [NSString stringWithFormat:@"token=%@&images=%@&tid=%@",kUserTokenValue,imgJsonStr,weakSelf.teacherModel.tch_id];
        [TCHttpRequest postMethodWithURL:kConnectSettingAPI body:body2 success:^(id json) {
            NSInteger status=[[json objectForKey:@"error"] integerValue];
            NSString *message=[json objectForKey:@"msg"];
            if (status==3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    RechargeAlertViewController *rechargeVC = [[RechargeAlertViewController alloc] init];
                    rechargeVC.type = 1;
                    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:rechargeVC];
                    popupVC.style = STPopupStyleFormSheet;
                    popupVC.navigationBarHidden = YES;
                    [popupVC presentInViewController:self];
                });
            }else{
                [ZYHelper sharedZYHelper].isUpdateHome = YES;
                [ZYHelper sharedZYHelper].isUpdateUserInfo = YES;
                NSDictionary *data = [json objectForKey:@"data"];
                TeacherModel *model = [[TeacherModel alloc] init];
                model = weakSelf.teacherModel;
                model.job_pic = imagesUrl;
                model.job_id = data[@"jobid"];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] initWithCallee:weakSelf.teacherModel.third_id];
                    connecttingVC.teacher = model;
                    [weakSelf.navigationController pushViewController:connecttingVC animated:YES];
                });
            }
        }];
    }];
}

#pragma mark -- private Methods
#pragma mark 初始化界面
-(void)initSettingVew{
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.infoView];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(11.0,self.infoView.bottom, kScreenWidth-42.0, 0.5)];
    line2.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.bgView addSubview:line2];
    
    [self.bgView addSubview:self.addPhotoView];
    [self.view addSubview:self.photosFramView];
    self.photosFramView.hidden = YES;
    [self.view addSubview:self.connenctBtn];
}

#pragma mark -- Getters
#pragma mark 根视图
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0, kNavHeight+10.0, kScreenWidth-20.0,260)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.boderRadius = 4.0;
    }
    return _bgView;
}

#pragma mark 底部老师视图
-(TeacherInfoView *)infoView{
    if (!_infoView) {
        _infoView = [[TeacherInfoView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
        _infoView.model = self.teacherModel;
    }
    return _infoView;
}

#pragma mark 上传图片
-(UIView *)addPhotoView{
    if (!_addPhotoView) {
        _addPhotoView = [[UIView alloc] initWithFrame:CGRectMake(0, self.infoView.bottom+1.0, kScreenWidth-20, 199.0)];
        
        UIButton *addPhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-20-105)/2.0, 20.0, 105, 105)];
        addPhotoBtn.backgroundColor = [UIColor colorWithHexString:@"#EEEFF2"];
        [addPhotoBtn setImage:[UIImage imageNamed:@"add_photo"] forState:UIControlStateNormal];
        addPhotoBtn.imageEdgeInsets = UIEdgeInsetsMake(35.0, 35.0, 35.0, 35.0);
        [addPhotoBtn addTarget:self action:@selector(addHomeworkPhotosAction) forControlEvents:UIControlEventTouchUpInside];
        [_addPhotoView addSubview:addPhotoBtn];
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(30, addPhotoBtn.bottom+13.0, kScreenWidth-60, 20.0)];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:11];
        tipsLab.textColor = [UIColor colorWithHexString:@"#B4B4B4"];
        tipsLab.text = @"*请上传你要辅导的作业图片*";
        [_addPhotoView addSubview:tipsLab];
    }
    return _addPhotoView;
}

#pragma mark 图片相册
-(PhotoFrameView *)photosFramView{
    if (!_photosFramView) {
        _photosFramView = [[PhotoFrameView alloc] initWithFrame:CGRectMake(10.0, kNavHeight+110, kScreenWidth-20,kScreenWidth-48) isSetting:YES];
        _photosFramView.delegate = self;
        _photosFramView.backgroundColor = [UIColor whiteColor];
        _photosFramView.bottomBoderRadius = 4.0;
    }
    return _photosFramView;
}


#pragma mark 连线
-(UIButton *)connenctBtn{
    if (!_connenctBtn) {
        _connenctBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-280)/2.0,kScreenHeight-80,280,55)];
        [_connenctBtn setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [_connenctBtn setTitle:@"连线" forState:UIControlStateNormal];
        [_connenctBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _connenctBtn.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        [_connenctBtn addTarget:self action:@selector(callTeacherForHelpAction) forControlEvents:UIControlEventTouchUpInside];
        _connenctBtn.timeInterval=2.0;
    }
    return _connenctBtn;
}

#pragma mark 图片数组
-(NSMutableArray *)photosArray{
    if (!_photosArray) {
        _photosArray = [[NSMutableArray alloc] init];
    }
    return _photosArray;
}

@end
