//
//  MyHomeworkView.h
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeworkModel.h"

@class MyHomeworkView;
@protocol MyHomeworkViewDelegate<NSObject>

//获取更多作业
-(void)myHomeworkViewDidShowMoreHomeworkAction;

-(void)myHomeworkView:(MyHomeworkView *)homeworkView didSelectCellForHomework:(HomeworkModel *)model;

@end

@interface MyHomeworkView : UIView

@property (nonatomic ,weak ) id<MyHomeworkViewDelegate>viewDelegete;

@property (nonatomic , assign) NSInteger homeworkCount;
@property (nonatomic , strong) NSMutableArray  *homeworksArray;

@end
