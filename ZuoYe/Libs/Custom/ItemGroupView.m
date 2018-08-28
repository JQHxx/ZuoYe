//
//  ItemGroupView.m
//  ZuoYe
//
//  Created by vision on 2018/8/7.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ItemGroupView.h"

#define kBtnWidth 70

@interface ItemGroupView (){
    UIButton       *selectBtn;
    UILabel        *line_lab;
    
    CGFloat        viewHeight;
    CGFloat        btnWidth;
    NSUInteger     num;
}

@property (nonatomic,strong)UIScrollView *rootScrollView;


@end

@implementation ItemGroupView

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        viewHeight=frame.size.height;
        
        self.rootScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, viewHeight)];
        self.rootScrollView.showsHorizontalScrollIndicator=NO;
        [self addSubview:self.rootScrollView];
        
        num=titles.count;
        if (kBtnWidth*num<frame.size.width) {
            btnWidth=frame.size.width/num;
            self.rootScrollView.contentSize=CGSizeMake(frame.size.width, viewHeight);
        }else{
            btnWidth=kBtnWidth;
            self.rootScrollView.contentSize=CGSizeMake(btnWidth*num, viewHeight);
        }
        
        for (int i=0; i<num; i++) {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(i*btnWidth, 0, btnWidth, viewHeight)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
            btn.tag=100+i;
            [btn addTarget:self action:@selector(changeItemForClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.rootScrollView addSubview:btn];
            
            if (i==0) {
                selectBtn=btn;
                selectBtn.selected=YES;
            }
        }
        
        line_lab=[[UILabel alloc] initWithFrame:CGRectMake(5.0,viewHeight-3, btnWidth-10.0, 2.0)];
        line_lab.backgroundColor = kLineColor;
        [self.rootScrollView addSubview:line_lab];
        
        
    }
    return self;
}

-(void)changeItemForClickAction:(UIButton *)sender{
    NSUInteger index=sender.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        sender.selected=YES;
        selectBtn=sender;
        line_lab.frame=CGRectMake(index*btnWidth+5.0, 38, btnWidth-10.0, 2.0);
//        if (index>=2&&index<num-2) {
//            CGPoint position=CGPointMake((index-2)*btnWidth-10, 0);
//            [self.rootScrollView setContentOffset:position animated:YES];
//        }
    }];
    
    if ([_viewDelegate respondsToSelector:@selector(itemGroupView:didClickActionWithIndex:)]) {
        [_viewDelegate itemGroupView:self didClickActionWithIndex:sender.tag];
    }
}

-(void)changeItemForSwipMenuAction:(UIButton *)sender{
    NSUInteger index=sender.tag-100;
    [UIView animateWithDuration:0.2 animations:^{
        selectBtn.selected=NO;
        sender.selected=YES;
        selectBtn=sender;
        line_lab.frame=CGRectMake(index*btnWidth+5.0, 38, btnWidth-10.0, 2.0);
        if (index>=2&&index<num-2) {
            CGPoint position=CGPointMake((index-2)*btnWidth-10, 0);
            [self.rootScrollView setContentOffset:position animated:YES];
        }
    }];
}

@end
