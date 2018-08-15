//
//  TutoringViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutoringViewController.h"
#import "PhotosView.h"

@interface TutoringViewController ()

@property (nonatomic, strong) PhotosView     *photosView;
@property (nonatomic, strong) UIScrollView   *whiteboardView;

@end

@implementation TutoringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootScrollView.backgroundColor = [UIColor lightGrayColor];
    
    [self.rootScrollView addSubview:self.photosView];
    [self.rootScrollView insertSubview:self.whiteboardView belowSubview:self.endBtn];
    
    [self loadData];
}


-(void)loadData{
    NSArray *tempArr = @[@"chujijiaoshi",@"zhongjijiaoshi",@"gaojijiaoshi",@"chujijiaoshi",@"zhongjijiaoshi",@"gaojijiaoshi",@"chujijiaoshi",@"zhongjijiaoshi",@"gaojijiaoshi"];
    self.photosView.photosArray = [NSMutableArray arrayWithArray:tempArr];
}

#pragma mark -- Getters
#pragma mark 图片
-(PhotosView *)photosView{
    if (!_photosView) {
        _photosView = [[PhotosView alloc] initWithFrame:CGRectMake(0, KStatusHeight+10, kScreenWidth,300)];
    }
    return _photosView;
}

#pragma mark 白板
-(UIScrollView *)whiteboardView{
    if (!_whiteboardView) {
        _whiteboardView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.photosView.bottom, kScreenWidth, kScreenHeight-self.photosView.bottom)];
        _whiteboardView.backgroundColor = [UIColor whiteColor];
    }
    return _whiteboardView;
}

@end
