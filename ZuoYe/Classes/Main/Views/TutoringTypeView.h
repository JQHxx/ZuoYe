//
//  TutoringTypeView.h
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GetTutoringTypeBlock)(TutoringType type);

@interface TutoringTypeView : UIView

@property (nonatomic , copy )GetTutoringTypeBlock getTypeblock;

@end
