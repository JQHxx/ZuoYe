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
@optional
-(void)photoFrameViewDidDeleteImageWithIndex:(NSInteger)index;

//添加图片
-(void)photoFrameViewAddImage;

@end


@interface PhotoFrameView : UIView

@property (nonatomic, weak ) id<PhotoFrameViewDelegate>delegate;

-(instancetype)initWithFrame:(CGRect)frame isSetting:(BOOL)isSetting;

- (void)updateCollectViewWithPhotosArr:(NSMutableArray *)arr;

@end
