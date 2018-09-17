//
//  TakePicturesViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TakePicturesViewController.h"
#import "ReleaseDemandViewController.h"
#import "CheckReleaseViewController.h"
#import "TZImagePickerController.h"
#import "STPopupController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoFrameView.h"
#import "TZImageManager.h"


@interface TakePicturesViewController ()<AVCapturePhotoCaptureDelegate,PhotoFrameViewDelegate,TZImagePickerControllerDelegate>{
    NSMutableArray   *allSelectedPhotos;     //所有图片
    
    UIImage          *selectImage;
    
    BOOL             isTakenPicture;
    BOOL             isCompleteTakenPicture;
}

@property (nonatomic, strong) AVCaptureSession           *captureSession; // 会话
@property (nonatomic, strong) AVCaptureDevice            *captureDevice;   // 输入设备
@property (nonatomic, strong) AVCaptureDeviceInput       *captureDeviceInput; // 输入源
@property (nonatomic, strong) AVCapturePhotoOutput       *photoOutput;    // 图像输出
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; // 预览画面
@property (nonatomic, strong) AVCapturePhotoSettings     *photoSettings;    // 图像设置
@property (nonatomic, assign) AVCaptureFlashMode         mode;
@property (nonatomic, assign) AVCaptureDevicePosition    position;


@property (nonatomic, strong)UIButton        *handleButton;   //拍照或确认
@property (nonatomic, strong)UIButton        *cancelButton;   //手电筒或取消

/** 图片选择 **/
@property (nonatomic, strong)PhotoFrameView  *photFrameView;


@end

@implementation TakePicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"选择图片";
    self.rigthTitleName = @"确定";
    
    allSelectedPhotos = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.handleButton];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.photFrameView];

    [self setupCaptureSession];
    [self updateTaKePictureView];
}

#pragma mark -- Delegate
#pragma mark AVCapturePhotoCaptureDelegate
#pragma mark 确认拍照
-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(nonnull AVCapturePhoto *)photo error:(nullable NSError *)error{
    NSData *imageData = photo.fileDataRepresentation;
    selectImage= [UIImage imageWithData:imageData];
    
    [self.captureSession stopRunning];
    
    self.isHiddenNavBar = YES;
    [_handleButton setImage:[UIImage imageNamed:@"photograph_finish"] forState:UIControlStateNormal];
    [_cancelButton setImage:[UIImage imageNamed:@"photograph_retract"] forState:UIControlStateNormal];
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
        isCompleteTakenPicture = NO;
        [self updateTaKePictureView];
    }
}

#pragma mark TZImagePickerControllerDelegate
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [allSelectedPhotos addObjectsFromArray:photos];
    if (allSelectedPhotos.count>9) {
        [self.view makeToast:@"最多只能上传9张图片" duration:1.0 position:CSToastPositionCenter];
        [allSelectedPhotos removeObjectsInArray:photos];
        return;
    }
    
    if (self.isConnectionSetting) {
        if ([self.controllerDelegate respondsToSelector:@selector(takePicturesViewContriller:didGotPhotos:)]) {
            [self.controllerDelegate takePicturesViewContriller:self didGotPhotos:allSelectedPhotos];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        isCompleteTakenPicture = YES;
        [self updateTaKePictureView];
        [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
    }
}


#pragma mark -- Event Response
#pragma mark  拍照或确认
-(void)handlePhotoAction:(UIButton *)sender{
    if (!isTakenPicture) {   //拍照
        isTakenPicture = YES;
        self.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
        [self.photoSettings setFlashMode:self.mode];
        [self.photoOutput capturePhotoWithSettings:self.photoSettings delegate:self];
    }else{ //确定
        [allSelectedPhotos addObject:selectImage];
        if (self.isConnectionSetting) {
            if ([self.controllerDelegate respondsToSelector:@selector(takePicturesViewContriller:didGotPhotos:)]) {
                [self.controllerDelegate takePicturesViewContriller:self didGotPhotos:allSelectedPhotos];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            isCompleteTakenPicture = YES;
            [self updateTaKePictureView];
            [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
        }
    }
}

#pragma mark  手电筒或取消拍照
-(void)handleFlashlightOrCancelTakePhotoAction:(UIButton *)sender{
    if (isTakenPicture) { //取消
        isCompleteTakenPicture = NO;
        [self updateTaKePictureView];
    }else{  //打开手电筒
        
    }
}

#pragma mark 相册
-(void)rightNavigationItemAction{
    if ([self.rigthTitleName isEqualToString:@"相册"]) {
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:self];
        imagePickerVC.allowTakePicture = NO;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }else{
        BaseViewController *controller  = nil;
        if (self.type == TutoringTypeReview) {
            controller = [[CheckReleaseViewController alloc] init];
        }else{
            controller = [[ReleaseDemandViewController alloc] init];
        }
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:controller];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    }
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
    self.isHiddenNavBar = NO;
    if (isCompleteTakenPicture) {  //选择图片
        self.baseTitle = @"选择图片";
        self.rigthTitleName = @"确定";
        
        if (self.previewLayer) {
            [self.previewLayer removeFromSuperlayer];
            self.previewLayer =nil;
        }
        
        self.photFrameView.hidden = NO;
        self.handleButton.hidden = self.cancelButton.hidden =YES;
    }else{  //开始拍照
        self.baseTitle = @"拍照";
        self.rigthTitleName = @"相册";
    
        self.photFrameView.hidden = YES;
        self.handleButton.hidden = self.cancelButton.hidden = NO;
        
        isTakenPicture = NO;
        
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
        [self.captureSession startRunning];
    }
}


#pragma mark -- setters and getters
#pragma mark 相册
-(PhotoFrameView *)photFrameView{
    if (!_photFrameView) {
        _photFrameView = [[PhotoFrameView alloc] initWithFrame:CGRectMake(0,kNavHeight+10, kScreenWidth, kScreenHeight-kNavHeight-10) isSetting:NO];
        _photFrameView.delegate = self;
        _photFrameView.backgroundColor = [UIColor whiteColor];
    }
    return _photFrameView;
}

#pragma mark 预览框
-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _previewLayer;
}


#pragma mark 拍照或确认
-(UIButton *)handleButton{
    if (!_handleButton) {
        _handleButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-32, kScreenHeight-110.0, 64, 64)];
        [_handleButton setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
        [_handleButton addTarget:self action:@selector(handlePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handleButton;
}

#pragma mark 手电筒或取消
-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.handleButton.right+22.0, kScreenHeight-110.0+16.0,32, 32)];
        [_cancelButton setImage:[UIImage imageNamed:@"photograph_lighting"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(handleFlashlightOrCancelTakePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
