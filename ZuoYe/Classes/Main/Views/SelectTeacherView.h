//
//  SelectTeacherView.h
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LevelModel.h"

typedef void(^DidSelectedLevelBlock)(LevelModel *model);


@interface SelectTeacherView : UIView

@property (nonatomic, strong) NSMutableArray        *levelsArray;
@property (nonatomic, copy )DidSelectedLevelBlock   selLevelBlock;


@end
