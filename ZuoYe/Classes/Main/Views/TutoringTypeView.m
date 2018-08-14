//
//  TutoringTypeView.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutoringTypeView.h"

@interface TutoringTypeView (){
    UIButton   *checkBtn;   // 检查
    UIButton   *helpBtn;    //辅导
}



@end

@implementation TutoringTypeView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 20)];
        titleLabel.font = kFontWithSize(16);
        titleLabel.text = @"辅导类型";
        titleLabel.textColor = [UIColor blackColor];
        [self addSubview:titleLabel];
        
        NSArray *btnTitles = @[@"作业检查",@"作业辅导"];
        CGFloat btnW = (frame.size.width - titleLabel.width-70)/2.0;
        for (NSInteger i=0; i<btnTitles.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(titleLabel.right+40+btnW*i, 5, btnW, 30)];
            [btn setImage:[UIImage imageNamed:@"ic_eqment_pick_un"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"ic_eqment_pick_on"] forState:UIControlStateSelected];
            [btn setTitle:btnTitles[i] forState:UIControlStateNormal];
            btn.titleLabel.font = kFontWithSize(14);
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 20);
            btn.tag = i;
            [btn addTarget:self action:@selector(chooseTutoringTypeAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
            if (i==0) {
                btn.selected = YES;
                [btn setTitleColor:kSystemColor forState:UIControlStateNormal];
                checkBtn = btn;
            }else{
                btn.selected = NO;
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                helpBtn = btn;
                
            }
        }
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(30, titleLabel.bottom+5, kScreenWidth-60, 30)];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.font = kFontWithSize(13);
        tipsLab.textColor = [UIColor lightGrayColor];
        tipsLab.text = @"*两者都需求请选择作业检查即可*";
        [self addSubview:tipsLab];
        
         UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, tipsLab.bottom+5, frame.size.width, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [self addSubview:lineView];
        
    }
    return self;
}

#pragma mark -- action
-(void)chooseTutoringTypeAction:(UIButton *)sender{
    if (sender.tag==0) {
        checkBtn.selected = YES;
        helpBtn.selected = NO;
        [checkBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
        [helpBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }else{
        checkBtn.selected = NO;
        helpBtn.selected = YES;
        [checkBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [helpBtn setTitleColor:kSystemColor forState:UIControlStateNormal];
    }
    
    self.getTypeblock(sender.tag+1);
}

@end
