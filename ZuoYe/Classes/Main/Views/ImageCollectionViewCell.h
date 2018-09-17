//
//  ImageCollectionViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIButton    *imgBtn;
@property (nonatomic, strong) UIButton    *deleteBtn;
@property (nonatomic, assign) NSInteger   row;

@end
