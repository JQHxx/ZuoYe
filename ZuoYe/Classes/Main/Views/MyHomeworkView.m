//
//  MyHomeworkView.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyHomeworkView.h"
#import "HorizontalFlowLayout.h"
#import "HomeworkCollectionViewCell.h"

@interface MyHomeworkView ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    UILabel  *countLabel;
}

@property (nonatomic ,strong)UICollectionView *myCollectionView ;

@end

@implementation MyHomeworkView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.boderRadius = 4.0;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel  *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(13, 9, 65, 20)];
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        titleLab.textColor = [UIColor colorWithHexString:@"#FF6161"];
        titleLab.text = @"我的作业";
        [self addSubview:titleLab];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width-120, 9, 105, 20)];
        countLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        countLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        countLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:countLabel];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(countLabel.right, 12, 6.5, 12)];
        imgView.image = [UIImage imageNamed:@"arrow2_personal_information"];
        [self addSubview:imgView];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(self.width-120, 0, 120, 35)];
        [btn addTarget:self action:@selector(showMoreHomeworksAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0,35, self.width, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
        [self addSubview:line];
        
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        // 设置UICollectionView为横向滚动
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // 每一行cell之间的间距
        flowLayout.minimumLineSpacing = 8.7;
        flowLayout.itemSize = CGSizeMake(149.3, 90);
        flowLayout.sectionInset  = UIEdgeInsetsMake(0, 15, 0, 15);
        
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, line.bottom,self.width, 115) collectionViewLayout:flowLayout];
        self.myCollectionView.showsHorizontalScrollIndicator =NO;
        self.myCollectionView.delegate = self;
        self.myCollectionView.dataSource = self;
        self.myCollectionView.backgroundColor = [UIColor whiteColor];
        [self.myCollectionView registerClass:[HomeworkCollectionViewCell class] forCellWithReuseIdentifier:@"HomeworkCollectionViewCell"];
        [self addSubview:self.myCollectionView];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.homeworksArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeworkCollectionViewCell" forIndexPath:indexPath];
    if (!cell ) {
        cell = [[HomeworkCollectionViewCell alloc] init];
    }
    HomeworkModel *model = self.homeworksArray[indexPath.item];
    [cell configCellWithHomework:model];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkModel *model = self.homeworksArray[indexPath.item];
    if ([self.viewDelegete respondsToSelector:@selector(myHomeworkView:didSelectCellForHomework:)]) {
        [self.viewDelegete myHomeworkView:self didSelectCellForHomework:model];
    }
}

#pragma mark 获取更多作业
-(void)showMoreHomeworksAction:(UIButton *)sender{
    if ([self.viewDelegete respondsToSelector:@selector(myHomeworkViewDidShowMoreHomeworkAction)]) {
        [self.viewDelegete myHomeworkViewDidShowMoreHomeworkAction];
    }
}

#pragma mark 作业数量
-(void)setHomeworkCount:(NSInteger)homeworkCount{
    _homeworkCount = homeworkCount;
    countLabel.text = [NSString stringWithFormat:@"全部（%ld）",homeworkCount];
}

-(void)setHomeworksArray:(NSMutableArray *)homeworksArray{
    _homeworksArray = homeworksArray;
    if (!_homeworksArray) {
        _homeworksArray = [[NSMutableArray alloc] init];
    }
    [self.myCollectionView reloadData];
    [self.myCollectionView layoutIfNeeded];
}


@end
