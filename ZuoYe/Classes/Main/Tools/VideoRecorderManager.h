//
//  VideoRecorderManager.h
//  ZuoYe
//
//  Created by vision on 2018/10/16.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoRecorderManager : NSObject

singleton_interface(VideoRecorderManager)

-(void)startRecord;

-(void)endRecord;

@end
