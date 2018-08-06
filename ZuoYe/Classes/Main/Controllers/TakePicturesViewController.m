//
//  TakePicturesViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TakePicturesViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoClipView.h"
#import "PhotoFrameView.h"


@interface TakePicturesViewController ()<AVCapturePhotoCaptureDelegate,PhotoClipViewDelegate>{
    
    NSMutableArray   *imagesArray;
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
@property (strong, nonatomic) PhotoClipView *clipView;

@property (nonatomic, strong)UIScrollView *rootScrollView;

@end

@implementation TakePicturesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.isHiddenNavBar = YES;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.bottomView];
    [self setupCaptureSession];
    
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
-(void)photoClipViewConfirmTakeImage:(UIImage *)image{
    [self.clipView removeFromSuperview];
    self.clipView = nil;
    
    self.isHiddenNavBar = NO;
    self.baseTitle = @"选择图片";
    
    
    
}

-(void)photoClipViewRemakePhoto{
    [self.clipView removeFromSuperview];
    self.clipView = nil;
    [self.captureSession startRunning];
}

#pragma mark -- Event Response
-(void)takePictureAction{
    self.photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    [self.photoSettings setFlashMode:self.mode];
    [self.photoOutput capturePhotoWithSettings:self.photoSettings delegate:self];
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
    
    //7.预览画面
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-80);
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.captureSession startRunning];
}


#pragma mark -- setters and getters
#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
    }
    return _rootScrollView;
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
        _clipView = [[PhotoClipView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _clipView.delegate = self;
    }
    return _clipView;
}



@end
