//
//  PhotoFrameView.m
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PhotoFrameView.h"
#import "ImageCollectionViewCell.h"




@interface PhotoFrameView ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSMutableArray  *photosArr;
    BOOL            isEditingPhotos;
}

@property (nonatomic, strong)UICollectionView *collectionView;


@end

@implementation PhotoFrameView

-(instancetype)initWithFrame:(CGRect)frame isEditing:(BOOL)isEditing{
    self = [super initWithFrame:frame];
    if (self) {
        isEditingPhotos = isEditing;
        
        
        self.backgroundColor = [UIColor whiteColor];
        
        photosArr = [[NSMutableArray alloc] init];
        [self setupImageCollectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return isEditingPhotos?photosArr.count+1:photosArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == photosArr.count) {
        cell.imgView.image = [UIImage imageNamed:@"ic_frame_add"];
        cell.imgView.contentMode = UIViewContentModeScaleAspectFit;
        cell.deleteBtn.hidden = YES;
    } else {
        UIImage *photoImg = photosArr[indexPath.row];
        cell.imgView.image = photoImg;
        cell.imgView.contentMode = UIViewContentModeScaleToFill;
        cell.deleteBtn.hidden = !isEditingPhotos;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger selTag = indexPath.row == photosArr.count?10001:1000;
    if ([self.delegate respondsToSelector:@selector(photoFrameViewDidClickForTag:andCell:)]) {
        [self.delegate photoFrameViewDidClickForTag:selTag andCell:indexPath.row];
    }
}

#pragma mark -- Event response
#pragma mark  删除图片
- (void)deleteBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoFrameViewDidDeleteImageWithIndex:)]) {
        [self.delegate photoFrameViewDidDeleteImageWithIndex:sender.tag];
    }
}

#pragma mark -- Public Methods
-(void)updateCollectViewWithPhotosArr:(NSMutableArray *)arr{
    photosArr = arr;
    CGFloat viewHeight = kItemH *(photosArr.count/3) + kItemH;
    self.collectionView.frame = CGRectMake(0, 0, kScreenWidth, viewHeight);
    [self.collectionView reloadData];
}


#pragma mark -- Private Methods
-(void)setupImageCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kItemW, kItemH);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor  = [UIColor whiteColor];
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = isEditingPhotos;
    [self addSubview:self.collectionView];
}




@end
