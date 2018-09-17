//
//  LoginButton.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "LoginButton.h"

@implementation LoginButton

-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"login_bg_btn"] forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
    }
    return self;
}

@end
