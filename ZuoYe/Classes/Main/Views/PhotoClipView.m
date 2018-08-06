//
//  PhotoClipView.m
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PhotoClipView.h"
#import "PECropView.h"

@interface PhotoClipView ()

@property (nonatomic, strong)PECropView * cropView;

@end

@implementation PhotoClipView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.cropView = [[PECropView alloc] initWithFrame:CGRectMake(0, 30, self.width, self.height-80)];
        [self addSubview:self.cropView];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-80, self.width, 80)];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomView];
        
        UIButton *confirmBtn = [[UIButton alloc]  initWithFrame:CGRectMake((self.width-60)/2, 10, 60, 60)];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setBackgroundColor:[UIColor blackColor]];
        confirmBtn.layer.cornerRadius = 30;
        confirmBtn.clipsToBounds = YES;
        [confirmBtn addTarget:self action:@selector(confirmChoosePhoto) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:confirmBtn];
        
        UIButton *remakeBtn = [[UIButton alloc]  initWithFrame:CGRectMake(self.width-60, 10, 60, 60)];
        [remakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
        [remakeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [remakeBtn addTarget:self action:@selector(remakePhoto) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:remakeBtn];
        
    }
    return self;
}

#pragma mark -- event response
-(void)confirmChoosePhoto{
    if ([self.delegate respondsToSelector:@selector(photoClipViewConfirmTakeImage:)]) {
        [self.delegate photoClipViewConfirmTakeImage:self.cropView.croppedImage];
    }
}

-(void)remakePhoto{
    if ([self.delegate respondsToSelector:@selector(photoClipViewRemakePhoto)]) {
        [self.delegate photoClipViewRemakePhoto];
    }
}


-(void)setImage:(UIImage *)image{
    _image = image;
    self.cropView.image = image;
}



@end
