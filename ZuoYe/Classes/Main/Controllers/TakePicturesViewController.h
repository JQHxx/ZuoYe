//
//  TakePicturesViewController.h
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//



#import "BaseViewController.h"

@class TakePicturesViewController;
@protocol TakePicturesViewControllerDelegate<NSObject>

@optional
-(void)takePicturesViewContriller:(TakePicturesViewController *)controller didGotPhotos:(NSMutableArray *)photos;


@end



@interface TakePicturesViewController : BaseViewController

@property (nonatomic ,weak ) id <TakePicturesViewControllerDelegate>controllerDelegate;

@property (nonatomic, assign)TutoringType type; //辅导类型

@property (nonatomic,assign) BOOL  isConnectionSetting;



@end
