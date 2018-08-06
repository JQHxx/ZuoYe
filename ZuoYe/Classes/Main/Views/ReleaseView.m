//
//  ReleaseView.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ReleaseView.h"

@implementation ReleaseView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *titles = @[@"作业检查",@"作业辅导"];
        CGFloat btnW = (kScreenWidth -40)/2.0;
        CGFloat btnH = self.frame.size.height - 60;
        for (NSInteger i=0; i<titles.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10+(btnW+20)*i, 10, btnW, btnH)];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor blueColor];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(releaseHomeworkRecomandWithTag:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(30, btnH+20, kScreenWidth-60, 30)];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.font = kFontWithSize(13);
        tipsLab.textColor = [UIColor lightGrayColor];
        tipsLab.text = @"*两者都需求请选择作业检查即可*";
        [self addSubview:tipsLab];
        
    }
    return self;
}

#pragma mark -- Event Response
-(void)releaseHomeworkRecomandWithTag:(UIButton *) sender{
    if ([self.delegate respondsToSelector:@selector(releaseViewDidReleasedHomeworkRecomandWithTag:)]) {
        [self.delegate releaseViewDidReleasedHomeworkRecomandWithTag:sender.tag-100];
    }
}


@end
