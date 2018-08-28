//
//  ChatToolBar.h
//  ZuoYe
//
//  Created by vision on 2018/8/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChatToolBarDelegate<NSObject>

@optional

/*
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;


@end

@interface ChatToolBar : UIView

@property (nonatomic ,weak)id<ChatToolBarDelegate>delegate;

@end
