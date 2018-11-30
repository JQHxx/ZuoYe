//
//  TakePhotoViewController.h
//  ZuoYe
//
//  Created by vision on 2018/11/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@class TakePhotoViewController;
@protocol TakePhotoViewControllerDelegate<NSObject>

@optional
-(void)takePhotoViewContriller:(TakePhotoViewController *)controller didGotPhotos:(NSMutableArray *)photos;

@end

@interface TakePhotoViewController : BaseViewController

@property (nonatomic ,weak ) id <TakePhotoViewControllerDelegate>controllerDelegate;

@property (nonatomic, assign)TutoringType type; //辅导类型

@property (nonatomic,assign) BOOL  isConnectionSetting;

@end

NS_ASSUME_NONNULL_END
