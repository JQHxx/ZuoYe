//
//  ConnectionSettingViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ConnectionSettingViewController.h"
#import "TakePicturesViewController.h"
#import "ConnecttingViewController.h"
#import "TutoringTypeView.h"
#import "AddPhotoView.h"
#import "PhotoFrameView.h"
#import "CheckPriceView.h"
#import "TeacherInfoView.h"


@interface ConnectionSettingViewController ()<PhotoFrameViewDelegate,AddPhotoViewDelegate>{
    TutoringType   tutoringType;
    double         checkPrice;
}

@property (nonatomic, strong) UIScrollView      *rootScrollView;   //根视图
@property (nonatomic, strong) TutoringTypeView  *typeView;         //辅导类型
@property (nonatomic, strong) AddPhotoView      *addPhotoView;      //上传图片
@property (nonatomic, strong) PhotoFrameView    *photosFramView;   //作业相册
@property (nonatomic, strong) CheckPriceView    *checkPriceView;   //作业检查
@property (nonatomic, strong) TeacherInfoView   *infoView;



@end

@implementation ConnectionSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"连线设置";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    tutoringType = TutoringTypeReview;
    [self initSettingVew];
}

#pragma mark -- Delegate
#pragma mark PhotoFrameViewDelegate
-(void)photoFrameViewDidClickForTag:(NSInteger)tag andCell:(NSInteger)cellRow{
    
}

#pragma mark  AddPhotoViewDelegate
#pragma mark 上传图片
-(void)addHomeworkPhotosAction{
    TakePicturesViewController *takePicturesVC = [[TakePicturesViewController alloc] init];
    takePicturesVC.isConnectionSetting = YES;
    takePicturesVC.backBlock = ^(NSMutableArray *photosArray) {
        self.addPhotoView.hidden = YES;
        self.photosFramView.hidden = NO;
        [self.photosFramView updateCollectViewWithPhotosArr:photosArray];
        
        CGFloat viewHeight = kItemH *(photosArray.count/3) + kItemH;
        self.photosFramView.frame = CGRectMake(0, self.typeView.bottom+10, kScreenWidth, viewHeight+10);
        self.checkPriceView.frame = CGRectMake(0, self.photosFramView.bottom+10, kScreenWidth, 80);
        self.rootScrollView.contentSize=CGSizeMake(kScreenWidth, self.checkPriceView.top+self.checkPriceView.height);
    };
    [self.navigationController pushViewController:takePicturesVC animated:YES];
}

#pragma mark 连线老师
-(void)callTeacherForHelpAction{
    ConnecttingViewController *connecttingVC = [[ConnecttingViewController alloc] init];
    connecttingVC.type = tutoringType;
    [self.navigationController pushViewController:connecttingVC animated:YES];
}

#pragma mark -- private Methods
#pragma mark 初始化界面
-(void)initSettingVew{
    [self.view addSubview:self.rootScrollView];
    
    [self.rootScrollView addSubview:self.typeView];
    [self.rootScrollView addSubview:self.typeView];
    [self.rootScrollView addSubview:self.addPhotoView];
    [self.rootScrollView addSubview:self.photosFramView];
    self.photosFramView.hidden = YES;
    [self.rootScrollView addSubview:self.checkPriceView];
    [self.view addSubview:self.infoView];
    
}

#pragma mark -- Getters
#pragma mark 根视图
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-80)];
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rootScrollView;
}

#pragma mark 辅导类型
-(TutoringTypeView *)typeView{
    if (!_typeView) {
        _typeView = [[TutoringTypeView alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 70)];
        kSelfWeak;
        _typeView.getTypeblock = ^(TutoringType type) {
            tutoringType = type;
            weakSelf.checkPriceView.hidden = tutoringType == TutoringTypeHelp?YES:NO;
        };
    }
    return _typeView;
}

#pragma mark 上传图片
-(AddPhotoView *)addPhotoView{
    if (!_addPhotoView) {
        _addPhotoView = [[AddPhotoView alloc] initWithFrame:CGRectMake(0, self.typeView.bottom+10, kScreenWidth, 200)];
        _addPhotoView.delegate = self;
    }
    return _addPhotoView;
}

#pragma mark 图片相册
-(PhotoFrameView *)photosFramView{
    if (!_photosFramView) {
        _photosFramView = [[PhotoFrameView alloc] initWithFrame:CGRectMake(0, self.typeView.bottom+10, kScreenWidth, 200) isEditing:NO];
        _photosFramView.delegate = self;
    }
    return _photosFramView;
}

#pragma mark 作业检查价格
-(CheckPriceView *)checkPriceView{
    if (!_checkPriceView) {
        _checkPriceView = [[CheckPriceView alloc] initWithFrame:CGRectMake(0, self.photosFramView.bottom+10, kScreenWidth, 80)];
        _checkPriceView.getPriceBlock = ^(double aPrice) {
            checkPrice = aPrice;
        };
    }
    return _checkPriceView;
}

#pragma mark 底部老师视图
-(TeacherInfoView *)infoView{
    if (!_infoView) {
        _infoView = [[TeacherInfoView alloc] initWithFrame:CGRectMake(0, kScreenHeight-80, kScreenWidth, 80)];
        
        UIButton *callBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 110, 20,100, 40)];
        [callBtn setTitle:@"去连线" forState:UIControlStateNormal];
        [callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        callBtn.backgroundColor = [UIColor orangeColor];
        callBtn.layer.cornerRadius = 5;
        [callBtn addTarget:self action:@selector(callTeacherForHelpAction) forControlEvents:UIControlEventTouchUpInside];
        [_infoView addSubview:callBtn];
    }
    return _infoView;
}


@end
