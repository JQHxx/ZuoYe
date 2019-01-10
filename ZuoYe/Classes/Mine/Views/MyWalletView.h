//
//  MyWalletView.h
//  ZuoYe
//
//  Created by vision on 2018/12/6.
//  Copyright © 2018 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MyWalletViewDelegate <NSObject>

-(void)myWalletViewShow;

-(void)myWalletViewToRecharge;

@end

@interface MyWalletView : UIView

@property (nonatomic,weak )id<MyWalletViewDelegate>delegate;

@property (nonatomic,assign) double balance;
@property (nonatomic,assign) double myCredit;

@end

NS_ASSUME_NONNULL_END
