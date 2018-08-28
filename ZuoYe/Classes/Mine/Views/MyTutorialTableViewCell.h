//
//  MyTutorialTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialModel.h"

@class MyTutorialTableViewCell;

@protocol MyTutorialTableViewCellDelegate<NSObject>

-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell payOrderOrConnectTeacherWithTutorial:(TutorialModel *)model;

-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell replayVideoWithTutorial:(TutorialModel *)model;

@end


@interface MyTutorialTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MyTutorialTableViewCellDelegate>delegate;

@property (nonatomic, strong) UIButton      *replayBtn;            //回放
@property (nonatomic, strong) UIButton       *myButton;             //付款或连线
@property (nonatomic, strong) TutorialModel  *tutorial;

@end
