//
//  AddPhotoView.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "AddPhotoView.h"

@implementation AddPhotoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *addPhotoBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-150)/2, 10, 150, 150)];
        addPhotoBtn.backgroundColor = [UIColor blueColor];
        [addPhotoBtn addTarget:self action:@selector(addHomeworkPhotosAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addPhotoBtn];
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(30, addPhotoBtn.bottom+5, kScreenWidth-60, 30)];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.font = kFontWithSize(13);
        tipsLab.textColor = [UIColor lightGrayColor];
        tipsLab.text = @"*请上传你要辅导的作业图片*";
        [self addSubview:tipsLab];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, tipsLab.bottom+5, frame.size.width, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [self addSubview:lineView];
        
        
    }
    return self;
}

#pragma mark 添加作业图片
-(void)addHomeworkPhotosAction{
    if ([self.delegate respondsToSelector:@selector(addHomeworkPhotosAction)]) {
        [self.delegate addHomeworkPhotosAction];
    }
}

@end
