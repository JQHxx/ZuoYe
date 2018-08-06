//
//  PhotoFrameView.h
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoFrameViewDelegate <NSObject>

//删除图片
-(void)photoFrameViewDidDeleteImageWithIndex:(NSInteger)index;

//点击图片或添加图片
-(void)photoFrameViewDidClickForTag:(NSInteger)tag andCell:(NSInteger)cellRow;

@end

@interface PhotoFrameView : UIView

@property (nonatomic, weak ) id<PhotoFrameViewDelegate>delegate;

- (void)updateCollectViewWithPhotosArr:(NSMutableArray *)arr;

@end
