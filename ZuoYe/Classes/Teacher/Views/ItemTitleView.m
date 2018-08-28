//
//  ItemTitleView.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ItemTitleView.h"

@interface ItemTitleView (){
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        btnWidth;
}

@end

@implementation ItemTitleView

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        
        btnWidth = frame.size.width/titles.count;
        for (int i=0; i<titles.count; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, frame.size.height)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
            btn.tag=i;
            [btn addTarget:self action:@selector(didSelectedItemForClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5.0,frame.size.height-3, btnWidth-10.0, 2.0)];
        line_lab.backgroundColor = [UIColor whiteColor];
        [self addSubview:line_lab];
    }
    return self;
}

-(void)didSelectedItemForClickAction:(UIButton *)sender{
    NSUInteger index=sender.tag;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        sender.selected=YES;
        selectBtn=sender;
        line_lab.frame=CGRectMake(index*btnWidth+5.0, 38, btnWidth-10.0, 2.0);
    }];
    if ([self.delegate respondsToSelector:@selector(itemTitleViewDidClickWithIndex:)]) {
        [self.delegate itemTitleViewDidClickWithIndex:sender.tag];
    }
}

@end
