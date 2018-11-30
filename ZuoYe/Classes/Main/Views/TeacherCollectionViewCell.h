//
//  TeacherCollectionViewCell.h
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelModel.h"

@interface TeacherCollectionViewCell : UICollectionViewCell

-(void)updateCellWithLevel:(LevelModel *)model;



@end
