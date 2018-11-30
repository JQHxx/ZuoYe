//
//  MessageListTableViewCell.h
//  ZYForTeacher
//
//  Created by vision on 2018/10/22.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@interface MessageListTableViewCell : UITableViewCell

@property (nonatomic,strong)MessageModel  *messageModel;

@property (nonatomic,strong)UIButton  *checkDetailsBtn;

@end
