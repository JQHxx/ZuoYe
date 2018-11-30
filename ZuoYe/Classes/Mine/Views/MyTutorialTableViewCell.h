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

//去付款
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell payOrderActionWithTutorial:(TutorialModel *)model;
//再次连线
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell connectTeacherWithTutorial:(TutorialModel *)model;
//取消订单
-(void)myTutorialTableViewCell:(MyTutorialTableViewCell *)tableViewCell cancelOrderWithTutorial:(TutorialModel *)model;

@end


@interface MyTutorialTableViewCell : UITableViewCell

@property (nonatomic, weak) id<MyTutorialTableViewCellDelegate>delegate;

@property (nonatomic, strong) UIButton       *payButton;           //付款
@property (nonatomic, strong) UIButton       *cancelButton;       //取消订单
@property (nonatomic, strong) UIButton       *connectButton;       //连线
@property (nonatomic, strong) TutorialModel  *tutorial;

@end
