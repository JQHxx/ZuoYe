//
//  TakePicturesViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TakePicturesViewController.h"
#import "TZImagePickerController.h"
#import "STPopupController.h"
#import "ReleaseDemandViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoClipView.h"
#import "PhotoFrameView.h"
#import "TZImageManager.h"


@interface TakePicturesViewController ()<AVCapturePhotoCaptureDelegate,PhotoClipViewDelegate,PhotoFrameViewDelegate,TZImagePickerControllerDelegate>{
    NSMutableArray   *selectedAssets;
    NSMutableArray   *allSelectedPhotos;     //所有图片
    BOOL             isChoosePhoto; //拍照中
}

@property (nonatomic, strong) AVCaptureSession           *captureSession; // 会话
@property (nonatomic, strong) AVCaptureDevice            *captureDevice;   // 输入设备
@property (nonatomic, strong) AVCaptureDeviceInput       *captureDeviceInput; // 输入源
@property (nonatomic, strong) AVCapturePhotoOutput       *photoOutput;    // 图像输出
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; // 预览画面
@property (nonatomic, strong) AVCapturePhotoSettings     *photoSettings;    // 图像设置
@property (nonatomic, assign) AVCaptureFlashMode         mode;
@property (nonatomic, assign) AVCaptureDevicePosition    position;


@property (nonatomic, strong) UIView *bottomView;

/** 图片剪辑view */
@property (strong, nonatomic) PhotoClipView  *clipView;
/** 图片选择 **/
@property (nonatomic, strong)PhotoFrameView  *photFrameView;
@property (nonatomic, strong)UIButton        *confirmButton;

//
@property (nonatomic, strong)UIView          *demandView;


@end

@implementation TakePicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    allSelectedPhotos = [[NSMutableArray alloc] init];
    selectedAssets = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.photFrameView];
    [self.view addSubview:self.confirmButton];
    
    [self.view addSubview:self.bottomView];

    [self setupCaptureSession];
    [self updateTaKePictureView];
}


#pragma mark -- Delegate
#pragma mark AVCapturePhotoCaptureDelegate
-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(nonnull AVCapturePhoto *)photo error:(nullable NSError *)error{
    NSData *imageData = photo.fileDataRepresentation;
    UIImage *image = [UIImage imageWithData:imageData];
    [self.captureSession stopRunning];
    
    [self.view addSubview:self.clipView];
    self.clipView.image = image;
}

#pragma mark  PhotoClipViewDelegate
#pragma mark 取消拍照
-(void)photoClipViewCancelTakePhoto{
    
}

#pragma mark 确认选择图片
-(void)photoClipViewConfirmTakeImage:(UIImage *)image{
    //保存到相册
    [[TZImageManager manager] savePhotoWithImage:image completion:^(NSError *error) {
        if (error) {
            MyLog(@"图片保存失败 error:%@",error.localizedDescription);
        }else{
            [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    TZAssetModel *assertModel = [models firstObject];
                    [selectedAssets addObject:assertModel.asset];
                    
                    isChoosePhoto = YES;
                    [self updateTaKePictureView];
                    [allSelectedPhotos addObject:image];
                    [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
                    
                }];
            }];
        }
    }];
}

#pragma mark 重拍
-(void)photoClipViewRemakePhoto{
    [self.clipView removeFromSuperview];
    self.clipView = nil;
    [self.captureSession startRunning];
}

#pragma mark PhotoFrameViewDelegate
#pragma mark 删除图片
-(void)photoFrameViewDidDeleteImageWithIndex:(NSInteger)index{
    [allSelectedPhotos removeObjectAtIndex:index];
    [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
}

#pragma mark 打开图片或添加图片
-(void)photoFrameViewDidClickForTag:(NSInteger)tag andCell:(NSInteger)cellRow{
    if (tag == 10000) { //打开图片
        
    }else{ //添加图片
        isChoosePhoto = NO;
        [self updateTaKePictureView];
        [self.captureSession startRunning];
    }
}

#pragma mark TZImagePickerControllerDelegate
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    isChoosePhoto = YES;
    [self updateTaKePictureView];
    
    selectedAssets = [NSMutableArray arrayWithArray:assets];
    allSelectedPhotos = [NSMutableArray arrayWithArray:photos];
    [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
}


#pragma mark -- Event Response
-(void)takePictureAction{
    self.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    [self.photoSettings setFlashMode:self.mode];
    [self.photoOutput capturePhotoWithSettings:self.photoSettings delegate:self];
}

#pragma mark 相册
-(void)rightNavigationItemAction{
    if ([self.rigthTitleName isEqualToString:@"相册"]) {
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:9 columnNumber:4 delegate:self];
        imagePickerVC.selectedAssets = selectedAssets;
        imagePickerVC.allowTakePicture = NO;     // 相册不显示拍照
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

#pragma mark 确定
-(void)confirmSelectedPhotosAction{
    ReleaseDemandViewController *releaseDemandVC = [[ReleaseDemandViewController alloc] init];
    releaseDemandVC.type = self.type;
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:releaseDemandVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}


#pragma mark -- Private Methods
#pragma mark 创建会话
-(void)setupCaptureSession {
    self.position = AVCaptureDevicePositionBack;
    //1.创建会话
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto; //画质
    
    //2.创建输入设备
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //3.创建输入源
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    
    //4.创建图像输出
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    
    //5.连接输入与会话
    if ([self.captureSession canAddInput:self.captureDeviceInput]) {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    //6.连接输出与会话
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
}

#pragma mark 更新界面
-(void)updateTaKePictureView{
    if (isChoosePhoto) {  //选择图片
        self.baseTitle = @"选择图片";
        self.rigthTitleName = @"";
        
        [self.clipView removeFromSuperview];
        self.clipView = nil;
        
        [self.previewLayer removeFromSuperlayer];
        self.previewLayer =nil;
        
        self.photFrameView.hidden = self.confirmButton.hidden = NO;
        self.bottomView.hidden = YES;
        
        
    }else{  //开始拍照
        self.baseTitle = @"拍照";
        self.rigthTitleName = @"相册";
        
        self.photFrameView.hidden = self.confirmButton.hidden = YES;
        self.bottomView.hidden = NO;
        
        [UIView animateWithDuration:1.0 animations:^{
            [self.view.layer insertSublayer:self.previewLayer atIndex:0];
        } completion:^(BOOL finished) {
            [self.captureSession startRunning];
        }];
    }
}


#pragma mark -- setters and getters
#pragma mark 相册
-(PhotoFrameView *)photFrameView{
    if (!_photFrameView) {
        _photFrameView = [[PhotoFrameView alloc] initWithFrame:CGRectMake(0,kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-60)];
        _photFrameView.delegate = self;
    }
    return _photFrameView;
}

#pragma mark 确定
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight-60, kScreenWidth, 60)];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmSelectedPhotosAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark 预览框
-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _previewLayer.frame = CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-80-kNavHeight);
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _previewLayer;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-80, kScreenWidth, 80)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIButton *takeBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, 10, 60, 60)];
        [takeBtn setTitle:@"拍照" forState:UIControlStateNormal];
        takeBtn.backgroundColor=[UIColor blackColor];
        [takeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        takeBtn.layer.cornerRadius = 30;
        takeBtn.clipsToBounds=YES;
        [takeBtn addTarget:self action:@selector(takePictureAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:takeBtn];
    }
    return _bottomView;
}

#pragma mark 图片裁剪视图
-(PhotoClipView *)clipView{
    if (!_clipView) {
        _clipView = [[PhotoClipView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight)];
        _clipView.delegate = self;
    }
    return _clipView;
}

-(UIView *)demandView{
    if (!_demandView) {
        _demandView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200)];
        _demandView.backgroundColor = [UIColor lightGrayColor];
    }
    return _demandView;
}

@end
