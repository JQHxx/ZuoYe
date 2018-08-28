//
//  PaymentTableViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/23.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentModel.h"

@interface PaymentTableViewCell : UITableViewCell

@property (nonatomic, strong) UIButton *myButton;

@property (nonatomic, strong) PaymentModel *model;

@end
