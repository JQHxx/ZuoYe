//
//  TeacherHeaderView.h
//  ZuoYe
//
//  Created by vision on 2018/8/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherModel.h"

@protocol TeacherHeaderViewDelegate <NSObject>

-(void)teacherHeaderViewDidConcernAction;

-(void)teacherHeaderViewGetMoreCommentAction;


@end

@interface TeacherHeaderView : UIView

@property (nonatomic, weak )id<TeacherHeaderViewDelegate>delegate;

@property (nonatomic, strong) TeacherModel *teacher;


@end
