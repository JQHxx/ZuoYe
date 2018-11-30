//
//  WhiteboardCmdHandler.h
//  ZYForTeacher
//
//  Created by vision on 2018/10/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhiteboardPoint.h"
#import "WhiteboardCommand.h"
#import "WhiteboardManager.h"

@protocol WhiteboardCmdHandlerDelegate <NSObject>

@optional
- (void)onReceivePoint:(WhiteboardPoint *)point from:(NSString *)sender;
- (void)onReceiveCmd:(WhiteBoardCmdType)type from:(NSString *)sender;
- (void)onReceiveBoardCmd:(WhiteBoardCmdType)type index:(NSInteger)index from:(NSString *)sender;

@end

@interface WhiteboardCmdHandler : NSObject<WhiteboardManagerDataHandler>

- (instancetype)initWithDelegate:(id<WhiteboardCmdHandlerDelegate>)delegate;

- (void)sendPureCmd:(WhiteBoardCmdType)type;

@end
