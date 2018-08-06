//
//  PhotoFrameView.m
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PhotoFrameView.h"
#import "ImageCollectionViewCell.h"


#define kItemW  (kScreenWidth - 40)/3.0
#define kItemH  1.2*kItemW

@interface PhotoFrameView ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSMutableArray  *photosArr;
}

@property (nonatomic, strong)UICollectionView *collectionView;


@end

@implementation PhotoFrameView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        photosArr = [[NSMutableArray alloc] init];
        [self setupImageCollectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return photosArr.count;
}


#pragma mark -- Private Methods
-(void)setupImageCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kItemW, kItemH);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
    self.collectionView.scrollEnabled = NO;
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
}




@end
