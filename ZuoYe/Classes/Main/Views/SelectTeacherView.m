//
//  SelectTeacherView.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "SelectTeacherView.h"
#import "TeacherCollectionViewCell.h"
#import "LevelModel.h"

@interface SelectTeacherView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView      *myCollectionView;


@end

@implementation SelectTeacherView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
//        self.myCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.myCollectionView.showsHorizontalScrollIndicator = NO;
        self.myCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.myCollectionView registerClass:[TeacherCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TeacherCollectionViewCell class])];
        [self.myCollectionView setBackgroundColor:[UIColor clearColor]];
        [self.myCollectionView setDelegate:self];
        [self.myCollectionView setDataSource:self];
        [self addSubview:self.myCollectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.levelsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TeacherCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TeacherCollectionViewCell class]) forIndexPath:indexPath];
    
    LevelModel *model = self.levelsArray[indexPath.row];
    [cell updateCellWithLevel:model];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LevelModel *selModel = self.levelsArray[indexPath.row];
    for (LevelModel *model in self.levelsArray) {
        if (model.level == selModel.level) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
    }
    [self.myCollectionView reloadData];
    
    MyLog(@"didSelectItemAtIndexPath -- 教师等级：%@，价格：%.2f",selModel.name,[selModel.price doubleValue]);
    self.selLevelBlock(selModel);
}

#pragma mark UICollectionViewDelegateFlowLayout
#pragma mark 水平排放(变成一排展示)
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 106);
}

-(void)setLevelsArray:(NSMutableArray *)levelsArray{
    _levelsArray = levelsArray;
    if (levelsArray) {
        levelsArray = [[NSMutableArray alloc] init];
    }
    [self.myCollectionView reloadData];
}

@end
