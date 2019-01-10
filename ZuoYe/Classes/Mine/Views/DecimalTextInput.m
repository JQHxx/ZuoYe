//
//  DecimalTextInput.m
//  ZuoYe
//
//  Created by vision on 2018/12/5.
//  Copyright © 2018 vision. All rights reserved.
//

#import "DecimalTextInput.h"

@implementation DecimalTextInput

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        self.textColor = [UIColor blackColor];
        self.keyboardType=UIKeyboardTypeDecimalPad;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        view.backgroundColor = [UIColor bgColor_Gray];
        self.inputAccessoryView = view;
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth * 0.8, 5, 40, 40)];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.titleLabel.font=[UIFont boldSystemFontOfSize:16];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(confirmEdit) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
    }
    return self;
}

-(void)confirmEdit{
    [self resignFirstResponder];
}

@end
