//
//  WhiteboardCmdHandler.m
//  ZYForTeacher
//
//  Created by vision on 2018/10/11.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "WhiteboardCmdHandler.h"
#import "WhiteboardManager.h"


@interface WhiteboardCmdHandler ()

@property (nonatomic, strong) NSMutableString *cmdsSendBuffer;

@property (nonatomic, assign) UInt64 refPacketID;

@property (nonatomic, weak) id<WhiteboardCmdHandlerDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *syncPoints;

@end

@implementation WhiteboardCmdHandler

- (instancetype)initWithDelegate:(id<WhiteboardCmdHandlerDelegate>)delegate{
    if (self = [super init]) {
        _delegate = delegate;
        _cmdsSendBuffer = [[NSMutableString alloc] init];
        _syncPoints = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark 发送指令
- (void)sendPureCmd:(WhiteBoardCmdType)type{
    NSString *cmd = [WhiteboardCommand pureCommand:type];
    [_cmdsSendBuffer appendString:cmd];
    [self doSendCmds];
}

#pragma mark  -- WhiteboardManagerDataHandler
#pragma mark 处理接收到的数据
-(void)handleReceivedData:(NSData *)data sender:(NSString *)sender{
    NSString *cmdsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    MyLog(@"handleReceivedData:%@",cmdsString);
    NSArray *cmdsArray = [cmdsString componentsSeparatedByString:@";"];
    for (NSString *cmdString in cmdsArray) {
        if (cmdString.length == 0) {
            continue;
        }
        
        NSArray *cmd = [cmdString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":,"]];
        NSInteger type = [cmd[0] integerValue];
        switch (type) {
            case WhiteBoardCmdTypePointStart:
            case WhiteBoardCmdTypePointMove:
            case WhiteBoardCmdTypePointEnd:
            {
                MyLog(@"point cmd: %@", cmdString);
                if (cmd.count == 5) {
                    
                    WhiteboardPoint *point = [[WhiteboardPoint alloc] init];
                    point.type = type;
                    point.xScale = [cmd[1] floatValue];
                    point.yScale = [cmd[2] floatValue];
                    point.colorRGB = [cmd[3] intValue];
                    point.lineWidth = [cmd[4] doubleValue];
                    
                    if (_delegate) {
                        [_delegate onReceivePoint:point from:sender];
                    }
                }else {
                    MyLog(@"Invalid point cmd: %@", cmdString);
                }
                break;
            }
            case WhiteBoardCmdTypeCancelLine:
            case WhiteBoardCmdTypeClearLines:
            case WhiteBoardCmdTypeExam:
            case WhiteBoardCmdTypeStartCoach:
            case WhiteBoardCmdTypeEndCoach:
            case WhiteBoardCmdTypeCancelCoach:
            {
                if (_delegate) {
                    [_delegate onReceiveCmd:type from:sender];
                }
                break;
            }
            case WhiteBoardCmdTypeAddWhiteboard:
            case WhiteBoardCmdTypeChooseWhiteboard:
            case WhiteBoardCmdTypeDeleteWhiteboard:
            {
                MyLog(@"Whiteboard cmd: %@", cmdString);
                NSInteger  itemIndex = [cmd[1] integerValue];
                if (_delegate) {
                    [_delegate onReceiveBoardCmd:type index:itemIndex from:sender];
                }
            }
            default:
                break;
        }
    }
}

#pragma mark -- Private Methods
#pragma mark 发送数据
- (void)doSendCmds{
    if (_cmdsSendBuffer.length>0) {
        NSString *cmd =  [WhiteboardCommand packetIdCommand:_refPacketID++];
        [_cmdsSendBuffer appendString:cmd];
        [[WhiteboardManager sharedWhiteboardManager] sendRTSData:[_cmdsSendBuffer dataUsingEncoding:NSUTF8StringEncoding] toUser:nil];
        MyLog(@"send data %@", _cmdsSendBuffer);
        [_cmdsSendBuffer setString:@""];
    }
}



@end
