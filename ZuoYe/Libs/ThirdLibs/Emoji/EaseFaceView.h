/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */


#import <UIKit/UIKit.h>
#import "EaseFacialView.h"

@protocol EaseFaceViewDelegate

@required
/*!
 @method
 @brief 输入表情键盘的默认表情，或者点击删除按钮
 @param str       被选择的表情编码
 @param isDelete  是否为删除操作
 */
- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete;

/*!
 @method
 @brief 点击表情键盘的发送回调
 */
- (void)sendFace;

@end

@interface EaseFaceView : UIView <EaseFacialViewDelegate>

@property (nonatomic, weak) id<EaseFaceViewDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

/*!
 @method
 @brief 通过数据源获取表情分组数,
 @param emotionManagers 表情分组列表
 */
- (void)setEmotionManagers:(NSArray*)emotionManagers;

@end
