//
//  PhotoFrameView.m
//  ZuoYe
//
//  Created by vision on 2018/8/4.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "PhotoFrameView.h"
#import "ImageCollectionViewCell.h"
#import "SDPhotoBrowser.h"


@interface PhotoFrameView ()<UICollectionViewDelegate,UICollectionViewDataSource,SDPhotoBrowserDelegate>{
    NSMutableArray  *photosArr;
    BOOL   _isSetting;
}

@property (nonatomic, strong)UICollectionView *collectionView;


@end

@implementation PhotoFrameView

-(instancetype)initWithFrame:(CGRect)frame isSetting:(BOOL)isSetting{
    self = [super initWithFrame:frame];
    if (self) {
        _isSetting = isSetting;
        photosArr = [[NSMutableArray alloc] init];
        [self setupImageCollectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return photosArr.count==9?9:photosArr.count+1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == photosArr.count&&photosArr.count<9) {
        cell.imgBtn.backgroundColor = [UIColor colorWithHexString:@"#EEEFF2"];
        [cell.imgBtn setImage:[UIImage imageNamed:@"add_photo"] forState:UIControlStateNormal];
        cell.imgBtn.imageEdgeInsets = UIEdgeInsetsMake(35.0, 35.0, 35.0, 35.0);
        cell.deleteBtn.hidden = YES;
    } else {
        UIImage *photoImg = photosArr[indexPath.row];
        [cell.imgBtn setImage:photoImg forState:UIControlStateNormal];
        cell.imgBtn.imageEdgeInsets = UIEdgeInsetsZero;
        cell.deleteBtn.hidden = NO;
    }
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.imgBtn.tag = indexPath.row;
    [cell.imgBtn addTarget:self action:@selector(photoFrameVIewDidSelectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark -- Event response
#pragma mark  删除图片
- (void)deleteBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoFrameViewDidDeleteImageWithIndex:)]) {
        [self.delegate photoFrameViewDidDeleteImageWithIndex:sender.tag];
    }
}

#pragma mark 选择图片
-(void)photoFrameVIewDidSelectPhotoAction:(UIButton *)sender{
    if (sender.tag == photosArr.count&&photosArr.count==9) {
        [self makeToast:@"最多只能上传9张图片" duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (sender.tag<photosArr.count) {
        SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
        photoBrowser.delegate = self;
        photoBrowser.currentImageIndex = sender.tag;
        photoBrowser.imageCount = photosArr.count;
        photoBrowser.sourceImagesContainerView = self.collectionView;
        [photoBrowser show];
    }else{
        if ([self.delegate respondsToSelector:@selector(photoFrameViewAddImage)]) {
            [self.delegate photoFrameViewAddImage];
        }
    }
    
}

#pragma mark  SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    // 不建议用此种方式获取小图，这里只是为了简单实现展示而已
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.imgBtn.currentImage;
}

#pragma mark -- Public Methods
-(void)updateCollectViewWithPhotosArr:(NSMutableArray *)arr{
    photosArr = arr;
    [self.collectionView reloadData];
}


#pragma mark -- Private Methods
-(void)setupImageCollectionView{
    
    CGFloat itemW = 0.0 ;
    CGFloat orginX = 0.0;
    if (_isSetting) {
        itemW = (self.width - 32.0-8.0)/3.0;
        orginX = 17.0;
    }else{
        itemW = (self.width -4*4.0)/3.0;
        orginX = 4.0;
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemW, itemW);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(orginX, 0, self.width-2*orginX, self.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor  = [UIColor whiteColor];
    [self.collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
//        self.collectionView.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addSubview:self.collectionView];
}




@end
