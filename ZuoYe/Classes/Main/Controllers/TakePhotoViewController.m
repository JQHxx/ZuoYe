//
//  TakePhotoViewController.m
//  ZuoYe
//
//  Created by vision on 2018/11/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TakePhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+Touch.h"
#import "TZImagePickerController.h"
#import "CheckReleaseViewController.h"
#import "ReleaseDemandViewController.h"
#import "RechargeViewController.h"
#import "STPopupController.h"
#import "PhotoFrameView.h"
#import "TKImageView.h"

@interface TakePhotoViewController ()<AVCapturePhotoCaptureDelegate,TZImagePickerControllerDelegate,PhotoFrameViewDelegate>{
    NSMutableArray   *allSelectedPhotos;     //所有图片
    UIImage          *selectImage;
    BOOL             isTakingPiture;
    BOOL             isCompleteTakenPicture;  //完成图片选择
}

/** 捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入） */
@property (strong, nonatomic) AVCaptureDevice *captureDevice;

/** 代表输入设备，使用AVCaptureDevice初始化 */
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;

/** 输出图片 */
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;

/** 由他将输入输出结合在一起，并开始启动捕获设备（摄像头） */
@property (strong, nonatomic) AVCaptureSession *captureSession;

/** 图像预览层，实时显示捕获的图像 */
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) AVCaptureDevicePosition    position;



@property (nonatomic, strong) UIButton    *backButton;  //返回

@property (nonatomic, strong) UIButton    *albumButton;  //相册

@property (nonatomic, strong) UIButton    *handleButton;   //拍照或确认

@property (nonatomic, strong) UIButton     *cancelButton;   //手电筒或取消

@property (nonatomic, strong) TKImageView  *tkImageView;  //图片裁剪

/** 图片选择 **/
@property (nonatomic, strong) PhotoFrameView  *photFrameView;

@property (nonatomic, strong) UILabel      *captureTipsLab;

@end

@implementation TakePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    allSelectedPhotos = [[NSMutableArray alloc] init];
    
    [self createCameraDistrict];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.albumButton]; //相册
    [self.view addSubview:self.handleButton]; //拍照
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.photFrameView];
    
    [self updateTaKePictureView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"拍照"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"拍照"];
}

#pragma mark - Delegate
#pragma make AVCapturePhotoCaptureDelegate
#pragma mark 确认拍照
-(void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
    NSData *imageData = photo.fileDataRepresentation;
    UIImage *aImage= [UIImage imageWithData:imageData];
    if (!kIsEmptyObject(aImage)) {
        MyLog(@"aimge width:%.f,height:%.f",aImage.size.width,aImage.size.height);
        
        [self.captureSession stopRunning];
        
        if (self.captureTipsLab) {
            [self.captureTipsLab removeFromSuperview];
            self.captureTipsLab = nil;
        }
        
        isTakingPiture = YES;
        if (_cancelButton.selected) {
            _cancelButton.selected = NO;
        }
        self.backButton.hidden = self.albumButton.hidden = YES;
        [_handleButton setImage:[UIImage imageNamed:@"photograph_finish"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"photograph_retract"] forState:UIControlStateNormal];
        
        [self.view insertSubview:self.tkImageView belowSubview:_handleButton];
        self.tkImageView.toCropImage = aImage;
    }
}

#pragma mark TZImagePickerControllerDelegate
-(void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    [allSelectedPhotos addObjectsFromArray:photos];
    
    [self.captureSession stopRunning];
    
    if (self.captureTipsLab) {
        [self.captureTipsLab removeFromSuperview];
        self.captureTipsLab = nil;
    }
    
    if (self.isConnectionSetting) {
        if ([self.controllerDelegate respondsToSelector:@selector(takePhotoViewContriller:didGotPhotos:)]) {
            [self.controllerDelegate takePhotoViewContriller:self didGotPhotos:allSelectedPhotos];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        isCompleteTakenPicture = YES;
        [self updateTaKePictureView];
        [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
    }
}

#pragma mark PhotoFrameViewDelegate
#pragma mark 添加图片
-(void)photoFrameViewAddImage{
    isCompleteTakenPicture = NO;
    [self updateTaKePictureView];
}

#pragma mark 删除图片
-(void)photoFrameViewDidDeleteImageWithIndex:(NSInteger)index{
    [allSelectedPhotos removeObjectAtIndex:index];
    [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
}

#pragma mark - Event Response
#pragma mark 返回
-(void)leftNavigationItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 确定
-(void)rightNavigationItemAction{
    NSMutableArray *imgArr = [[ZYHelper sharedZYHelper] imageDataProcessingWithImgArray:allSelectedPhotos];
    kSelfWeak;
    BaseViewController *controller  = nil;
    if (self.type == TutoringTypeReview) {
        CheckReleaseViewController *checkController = [[CheckReleaseViewController alloc] init];
        checkController.photosArray = imgArr;
        controller = checkController;
    }else{
        ReleaseDemandViewController *releaseController = [[ReleaseDemandViewController alloc] init];
        releaseController.photosArray = imgArr;
        controller = releaseController;
    }
    controller.backBlock = ^(id object) {
        BOOL isReleaseSuccess = [object boolValue];
        if (isReleaseSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popToRootViewControllerAnimated:NO];
                });
            });
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:controller];
            popupVC.style = STPopupStyleBottomSheet;
            popupVC.navigationBarHidden = YES;
            [popupVC presentInViewController:weakSelf];
        });
    });
}

#pragma mark 返回
-(void)cameraBackAction{
    if (allSelectedPhotos.count>0) {
        [self.captureSession stopRunning];
        if (self.isConnectionSetting) {
            if ([self.controllerDelegate respondsToSelector:@selector(takePhotoViewContriller:didGotPhotos:)]) {
                [self.controllerDelegate takePhotoViewContriller:self didGotPhotos:allSelectedPhotos];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            isCompleteTakenPicture = YES;
            [self updateTaKePictureView];
            [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark 打开相册
-(void)openAlbumAction{
    NSInteger count = kMaxPhotosCount - allSelectedPhotos.count;
    TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:count columnNumber:4 delegate:self];
    imagePickerVC.allowPickingVideo = NO;
    imagePickerVC.allowTakePicture = NO;
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

#pragma mark 拍照或确认
-(void)takePhotoAction:(UIButton *)sender{
    if (isTakingPiture) {
        isTakingPiture = NO;
        
        selectImage = self.tkImageView.currentCroppedImage;
        [allSelectedPhotos addObject:selectImage];
        
        if (self.isConnectionSetting) {
            if ([self.controllerDelegate respondsToSelector:@selector(takePhotoViewContriller:didGotPhotos:)]) {
                [self.controllerDelegate takePhotoViewContriller:self didGotPhotos:allSelectedPhotos];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            isCompleteTakenPicture = YES;
            [self updateTaKePictureView];
            [self.photFrameView updateCollectViewWithPhotosArr:allSelectedPhotos];
        }
    }else{
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
        [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
    }
}

#pragma mark  手电筒或取消拍照
-(void)handleFlashlightOrCancelTakePhotoAction:(UIButton *)sender{
    if (isTakingPiture) { //取消
        isCompleteTakenPicture = NO;
        [self updateTaKePictureView];
    }else{  //打开手电筒
        sender.selected = !sender.selected;
        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
        if (captureDeviceClass !=nil) {
            AVCaptureDevice *myDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([myDevice hasTorch]) {
                [myDevice lockForConfiguration:nil];
                if (sender.selected) {
                    [myDevice setTorchMode:AVCaptureTorchModeOn];
                }else{
                    [myDevice setTorchMode:AVCaptureTorchModeOff];
                }
                [myDevice unlockForConfiguration];
            }else{
                MyLog(@"初始化失败");
            }
        }else{
            MyLog(@"没有闪光设备");
            [self.view makeToast:@"没有闪光设备" duration:1.0 position:CSToastPositionCenter];
        }
    }
}

#pragma mark - Private methods
#pragma mark
- (void)createCameraDistrict{
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
    
    //生成预览层
    [self.view.layer addSublayer:self.previewLayer];
    
    //开始取景
    [self.captureSession startRunning];
}

#pragma mark 显示图片选择确认
-(void)updateTaKePictureView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tkImageView) {
            [self.tkImageView removeFromSuperview];
            self.tkImageView = nil;
        }
        
        if (isCompleteTakenPicture) {
            if (self.previewLayer) {
                [self.previewLayer removeFromSuperlayer];
                self.previewLayer =nil;
            }
            
            self.handleButton.hidden = self.backButton.hidden = self.albumButton.hidden = self.cancelButton.hidden  = YES;
            
            self.isHiddenNavBar = NO;
            self.baseTitle = @"选择图片";
            self.rigthTitleName = @"确定";
            self.photFrameView.hidden = NO;
            
        }else{ //开始拍照
            self.isHiddenNavBar = YES;
            self.photFrameView.hidden = YES;
            self.handleButton.hidden = self.backButton.hidden = self.albumButton.hidden = self.cancelButton.hidden  = NO;
            
            [self.view.layer insertSublayer:self.previewLayer atIndex:0];
            
            
            [self.view addSubview:self.captureTipsLab];
            
            [self.captureSession startRunning];
            
            isTakingPiture = NO;
            [_handleButton setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
            [_cancelButton setImage:[UIImage imageNamed:@"photograph_lighting_gray"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark - Getters
#pragma mark 预览框
-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _previewLayer.frame = CGRectMake(0,-10, kScreenWidth, kScreenHeight+10);
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        _previewLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _previewLayer;
}

#pragma mark  裁剪图片框
-(TKImageView *)tkImageView{
    if (!_tkImageView) {
        _tkImageView = [[TKImageView alloc] initWithFrame:CGRectMake(0, -10, kScreenWidth, kScreenHeight+10)];
        _tkImageView.needScaleCrop = YES;   //允许手指捏和缩放裁剪框
        _tkImageView.maskAlpha = 0.3;
    }
    return _tkImageView;
}

#pragma mark 返回
-(UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, KStatusHeight, 30, 40)];
        [_backButton setImage:[UIImage imageNamed:@"photograph_return"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(cameraBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

#pragma mark 相册
-(UIButton *)albumButton{
    if (!_albumButton) {
        _albumButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40, KStatusHeight, 30, 40)];
        [_albumButton setImage:[UIImage imageNamed:@"photograph_album"] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(openAlbumAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumButton;
}

#pragma mark 拍照
-(UIButton *)handleButton{
    if (!_handleButton) {
        CGFloat originY = isXDevice ?kScreenHeight-110.0:kScreenHeight-75.0;
        _handleButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-32, originY, 64, 64)];
        [_handleButton setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
        [_handleButton addTarget:self action:@selector(takePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        _handleButton.timeInterval = 2.0;
    }
    return _handleButton;
}

#pragma mark 手电筒或取消
-(UIButton *)cancelButton{
    if (!_cancelButton) {
        CGFloat originY = isXDevice ?kScreenHeight-110.0:kScreenHeight-75.0;
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.handleButton.right+22.0, originY+16.0,32, 32)];
        [_cancelButton setImage:[UIImage imageNamed:@"photograph_lighting_gray"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"photograph_lighting"] forState:UIControlStateSelected];
        [_cancelButton addTarget:self action:@selector(handleFlashlightOrCancelTakePhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark 图片选择
-(PhotoFrameView *)photFrameView{
    if (!_photFrameView) {
        _photFrameView = [[PhotoFrameView alloc] initWithFrame:CGRectMake(0,kNavHeight+5, kScreenWidth,kScreenHeight-kNavHeight-5) isSetting:NO];
        _photFrameView.delegate = self;
        _photFrameView.backgroundColor = [UIColor whiteColor];
    }
    return _photFrameView;
}

#pragma mark 拍照提示
-(UILabel *)captureTipsLab{
    if (!_captureTipsLab) {
        _captureTipsLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _captureTipsLab.textColor = [UIColor whiteColor];
        _captureTipsLab.numberOfLines = 0;
        _captureTipsLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _captureTipsLab.textAlignment = NSTextAlignmentCenter;
        _captureTipsLab.text = @"拍照要求清晰完整\n作业太多请分成多张拍摄";
        CGFloat tipsHeight = [_captureTipsLab.text boundingRectWithSize:CGSizeMake(kScreenWidth-60, kScreenHeight) withTextFont:_captureTipsLab.font].height;
        _captureTipsLab.frame = CGRectMake(30, (kScreenHeight-tipsHeight)/2.0, kScreenWidth-60, tipsHeight);
    }
    return _captureTipsLab;
}

@end
