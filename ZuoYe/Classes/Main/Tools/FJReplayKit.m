//
//  FJReplayKit.m
//  ZuoYe
//
//  Created by vision on 2019/1/10.
//  Copyright © 2019 vision. All rights reserved.
//

#import "FJReplayKit.h"

@implementation FJReplayKit

singleton_implementation(FJReplayKit)


#pragma mark -- Public Methods
#pragma mark 开始录制
-(void)startRecord{
    
    if ([RPScreenRecorder sharedRecorder].recording==YES) {
        MyLog(@"FJReplayKit:已经开始录制");
        return;
    }
    if ([[RPScreenRecorder sharedRecorder] isAvailable]) {
        MyLog(@"FJReplayKit:录制开始初始化");
        [[RPScreenRecorder sharedRecorder] startRecordingWithMicrophoneEnabled:YES handler:^(NSError *error){
            if (error) {
                MyLog(@"FJReplayKit:开始录制error %@",error);
            }else{
                MyLog(@"FJReplayKit:开始录制");
                if ([_delegate respondsToSelector:@selector(replayRecordStart)]) {
                    [_delegate replayRecordStart];
                }
            }
        }];
    }
    else {
        MyLog(@"FJReplayKit:环境不支持ReplayKit录制");
    }
    
}

#pragma mark 结束录制
-(void)stopRecord{
    MyLog(@"FJReplayKit:正在结束录制");
    [[RPScreenRecorder sharedRecorder] stopRecordingWithHandler:^(RPPreviewViewController *previewViewController, NSError *  error){
        if (error) {
            MyLog(@"FJReplayKit:结束录制error %@", error);
            
        }else {
            MyLog(@"FJReplayKit:录制完成");
            
        }
    }];
}



@end
