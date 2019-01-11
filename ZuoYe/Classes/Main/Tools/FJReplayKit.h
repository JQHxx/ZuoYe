//
//  FJReplayKit.h
//  ZuoYe
//
//  Created by vision on 2019/1/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReplayKit/ReplayKit.h>

@protocol FJReplayDelegate <NSObject>
@optional
/**
 *  开始录制回调
 */
-(void)replayRecordStart;
/**
 *  录制结束或错误回调
 */
-(void)replayRecordFinishWithMovieURL:(NSURL *)videoURL;
/**
 *  保存到系统相册成功回调
 */
-(void)saveToLibrarySuccess;

@end


@interface FJReplayKit : NSObject

singleton_interface(FJReplayKit)

/**
 *  代理
 */
@property (nonatomic,weak) id <FJReplayDelegate> delegate;
/**
 *  是否正在录制
 */
@property (nonatomic,assign,readonly) BOOL isRecording;
/**
 *  单例对象
 */
+(instancetype)sharedReplay;
/**
 是否显示录制按钮
 */
-(void)catreButton:(BOOL)iscate;
/**
 *  开始录制
 */
-(void)startRecord;
/**
 *  结束录制
 *  isShow是否录制完后自动展示视频预览页
 */
-(void)stopRecord;



@end


