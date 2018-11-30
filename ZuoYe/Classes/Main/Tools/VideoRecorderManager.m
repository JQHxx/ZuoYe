//
//  VideoRecorderManager.m
//  ZuoYe
//
//  Created by vision on 2018/10/16.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "VideoRecorderManager.h"
#import <ReplayKit/ReplayKit.h>
#import <Photos/Photos.h>

@interface VideoRecorderManager(){
    NSString     *videoOutPath;
}

@property (nonatomic ,strong) RPScreenRecorder *screenRecorder;

@property (nonatomic ,strong) AVAssetWriter  *assetWriter;
@property (nonatomic ,strong) AVAssetWriterInput *assetWriterInput;


@end

@implementation VideoRecorderManager

singleton_implementation(VideoRecorderManager)

#pragma mark 开始录制
-(void)startRecord{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isSystemVersionOk]) {
            self.screenRecorder = [RPScreenRecorder sharedRecorder];
            if ([self.screenRecorder isAvailable]) {
                MyLog(@"ReplayKit:录制开始初始化");
                self.screenRecorder.microphoneEnabled = YES;
                
                if (self.screenRecorder.isRecording) {
                    return;
                }
                /*
                NSError *error = nil;
                NSArray *pathDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *outputURL = pathDocuments[0];
                
                videoOutPath = [[outputURL stringByAppendingPathComponent:[NSString stringWithFormat:@"%u", arc4random() % 1000]] stringByAppendingPathExtension:@"mp4"];
                self.assetWriter = [AVAssetWriter assetWriterWithURL:[NSURL fileURLWithPath:videoOutPath] fileType:AVFileTypeMPEG4 error:&error];
                
                NSDictionary *compressionProperties =
                @{
                  AVVideoAverageBitRateKey       :  [NSNumber numberWithDouble:2000 * 1000],
                  };
                
                NSNumber* width= [NSNumber numberWithFloat:kScreenWidth];
                NSNumber* height = [NSNumber numberWithFloat:kScreenHeight];
                NSDictionary *videoSettings =
                @{
                  AVVideoCompressionPropertiesKey : compressionProperties,
                  AVVideoCodecKey                 : AVVideoCodecTypeH264,
                  AVVideoWidthKey                 : width,
                  AVVideoHeightKey                : height};
                
                
                self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
                self.assetWriterInput.expectsMediaDataInRealTime = YES;
                if ([self.assetWriter canAddInput:self.assetWriterInput]) {
                    [self.assetWriter addInput:self.assetWriterInput];
                }
                
                [self.screenRecorder startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
                    if (error) {
                        MyLog(@"录制失败，error:%@",error.localizedDescription);
                    }else{
                        if (CMSampleBufferDataIsReady(sampleBuffer)) {
                            if (self.assetWriter.status == AVAssetWriterStatusUnknown && bufferType == RPSampleBufferTypeVideo) {
                                [self.assetWriter startWriting];
                                //丢掉无用帧
                                CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                                int64_t videopts  = CMTimeGetSeconds(pts) * 1000;
                                if(videopts < 0)
                                    return ;
                                
                                [self.assetWriter startSessionAtSourceTime:pts];
                            }
                            
                            if (self.assetWriter.status == AVAssetWriterStatusFailed) {
                                NSLog(@"An error occured.");
                                [[RPScreenRecorder sharedRecorder] stopCaptureWithHandler:^(NSError * _Nullable error) {}];
                                return;
                            }
                            if (bufferType == RPSampleBufferTypeVideo) {
                                if (self.assetWriterInput.isReadyForMoreMediaData) {
                                    //将sampleBuffer添加进视频输入源
                                    [self.assetWriterInput appendSampleBuffer:sampleBuffer];
                                }else{
                                    MyLog(@"Not ready for video");
                                }
                            }
                        }
                    }
                } completionHandler:^(NSError * _Nullable error) {
                    if (!error) {
                        MyLog(@"Recording started successfully.");
                    }else{
                        MyLog(@"Recording started error %@",error);
                    }
                }];
                 
                 */
                
                [self.screenRecorder startRecordingWithHandler:^(NSError * _Nullable error) {
                    if (error) {
                        MyLog(@"录制失败,error:%@",error.localizedDescription);
                    }else{
                        MyLog(@"*****startRecording successful!****");
                    }
                }];
            }else{
                MyLog(@"ReplayKit:环境不支持ReplayKit录制");
            }
        }else{
            MyLog(@"ReplayKit:系统版本需要是iOS9.0及以上才支持ReplayKit录制");
        }
    });
}

#pragma mark 结束录制
-(void)endRecord{
    if (@available(iOS 11.0,*)) {
        [self.screenRecorder stopCaptureWithHandler:^(NSError * _Nullable error) {
            if (error) {
                MyLog(@"stopCaptureWithHandler error %@", error);
            }else{
                if (_assetWriter) {
                    [_assetWriter finishWritingWithCompletionHandler:^{
                        MyLog(@"finishWritingWithCompletionHandler");
                        NSURL *fileUrl = [NSURL fileURLWithPath:videoOutPath];
                        NSError *error;
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
                        } error:&error];
                        if (error) {
                            MyLog(@"保存视频到相册失败,error:%@",error.localizedDescription);
                        }else{
                            MyLog(@"保存视频到相册成功");
                        }
                    }];
                }
            }
            
        }];
    }else{
        MyLog(@"CDPReplay:system < 11.0");
    }
}

#pragma mark 检测系统版本
- (BOOL)isSystemVersionOk {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        return NO;
    } else {
        return YES;
    }
}

@end
