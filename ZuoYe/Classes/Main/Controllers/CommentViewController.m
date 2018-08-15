//
//  CommentViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CommentViewController.h"
#import "UIViewController+STPopup.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = kScreenHeight *0.65;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}



@end
