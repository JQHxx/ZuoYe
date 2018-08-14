//
//  AddPhotoView.h
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddPhotoViewDelegate <NSObject>

-(void)addHomeworkPhotosAction;

@end

@interface AddPhotoView : UIView

@property (nonatomic, weak )id<AddPhotoViewDelegate>delegate;

@end
