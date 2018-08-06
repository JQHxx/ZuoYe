//
//  ReleaseView.h
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReleaseViewDelegate <NSObject>

-(void)releaseViewDidReleasedHomeworkRecomandWithTag:(NSInteger)tag;

@end

@interface ReleaseView : UIView

@property (nonatomic , weak)id<ReleaseViewDelegate>delegate;

@end
