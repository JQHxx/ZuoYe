//
//  CheckResultViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/15.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CheckResultViewController.h"
#import "UIViewController+STPopup.h"
#import "STPopupController.h"
#import "TutorialPayViewController.h"
#import "PaySuccessViewController.h"
#import "TutorialModel.h"
#import "iCarousel.h"
#import "ZYCustomPageControl.h"
#import "SDPhotoBrowser.h"

@interface CheckResultViewController ()<iCarouselDataSource,iCarouselDelegate,SDPhotoBrowserDelegate>{
    UIImageView  *headImageView;
    UILabel      *nameLabel;
    UILabel      *gradeLabel;
    UILabel      *priceLabel;
    
    TutorialModel  *myTutorial;
}

@property (nonatomic, strong) UILabel       *titleLabel;            //标题
@property (nonatomic, strong) UIButton      *closeButton;             //关闭按钮
@property (nonatomic ,strong) iCarousel     *photosCarousel;
@property (nonatomic, strong) UIView        *selectView;
@property (nonatomic ,strong) ZYCustomPageControl *pageControl;
@property (nonatomic ,strong) UIView        *teacherView;
@property (nonatomic ,strong) UILabel       *payAmountLab;
@property (nonatomic ,strong) UIButton      *payButton;

@property (nonatomic ,strong) NSMutableArray  *jobCheckPicsArray;

@end

@implementation CheckResultViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = kScreenHeight-90;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth-38, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    myTutorial = [[TutorialModel alloc] init];
    
    [self initCheckResultView];
    [self loadCheckResultData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"作业检查结果"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"作业检查结果"];
}

#pragma mark -- iCarouselDataSource
-(NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return self.jobCheckPicsArray.count;
}

-(UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    if (view==nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth-148, kScreenHeight-kNavHeight-263)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
        imageView.tag = 1000+index;
        imageView.userInteractionEnabled = YES;
        [view addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookOverFullJobImageAction:)];
        [imageView addGestureRecognizer:tap];
    }
    UIImageView *imageView = [view viewWithTag:1000+index];
    NSString *imgUrl = [self.jobCheckPicsArray objectAtIndex:index];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"task_details_loading"]];
    
    return view;
}

#pragma mark -- iCarouselDelegate
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    MyLog(@"___1 %ld",carousel.currentItemIndex);
    UIView *view = carousel.currentItemView;
    self.selectView = view;
    self.pageControl.currentPage = carousel.currentItemIndex;
}

- (void)carouselDidScroll:(iCarousel *)carousel{
    MyLog(@"___2 %ld",carousel.currentItemIndex);
    if (self.selectView != carousel.currentItemView) {
        self.selectView.backgroundColor = [UIColor clearColor];
        UIView *view = carousel.currentItemView;
        view.backgroundColor = [UIColor whiteColor];
        self.pageControl.currentPage = carousel.currentItemIndex;
    }
}

-(CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform{
    static CGFloat max_sacle = 1.0f;
    static CGFloat min_scale = 0.75f;
    if (offset <= 1 && offset >= -1) {
        float tempScale = offset < 0 ? 1+offset : 1-offset;
        float slope = (max_sacle - min_scale) / 1;
        
        CGFloat scale = min_scale + slope*tempScale;
        transform = CATransform3DScale(transform, scale, scale, 1);
    }else{
        transform = CATransform3DScale(transform, min_scale, min_scale, 1);
    }
    return CATransform3DTranslate(transform, offset * self.photosCarousel.itemWidth * 1.4, 0.0, 0.0);
}

#pragma mark - SDPhotoBrowserDelegate
#pragma mark 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
    UIImageView *imageView = [self.selectView viewWithTag:index+1000];
    return imageView.image;
}

#pragma mark
-(NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    NSString *imgUrl = self.jobCheckPicsArray[index];
    return [NSURL URLWithString:imgUrl];
}

#pragma mark 去付款
-(void)payCheckOrderAction:(UIButton *)sender{
    TutorialPayViewController *payVC = [[TutorialPayViewController alloc] initWithIsOrderIn:YES];
    payVC.orderId = self.oid;
    payVC.payAmount = [myTutorial.pay_money doubleValue];
    payVC.label = 1;
    kSelfWeak;
    payVC.backBlock = ^(id object) {
        if (weakSelf.popupController) {
            [weakSelf.popupController dismissWithCompletion:^{
                PaySuccessViewController *paySuccessVC = [[PaySuccessViewController alloc] init];
                paySuccessVC.pay_amount = [object doubleValue];
                [weakSelf.navigationController pushViewController:paySuccessVC animated:YES];
            }];
        }
    };
    STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
    popupVC.style = STPopupStyleBottomSheet;
    popupVC.navigationBarHidden = YES;
    [popupVC presentInViewController:self];
}

#pragma mark
-(void)closeCheckResultViewAction:(UIButton *)sender{
    if (self.popupController) {
        [self.popupController dismissWithCompletion:nil];
    }
}

#pragma mark 查看大图
-(void)lookOverFullJobImageAction:(UITapGestureRecognizer *)sender{
    NSInteger selectIndex = sender.view.tag-1000;
    MyLog(@"selectIndex:%ld",selectIndex);
    
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = selectIndex;
    photoBrowser.imageCount = self.jobCheckPicsArray.count;
    photoBrowser.sourceImagesContainerView = self.photosCarousel;
    [photoBrowser show];
}

#pragma mark -- Private methods
#pragma mark 初始化
-(void)initCheckResultView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.photosCarousel];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.teacherView];
    [self.view addSubview:self.payAmountLab];
    [self.view addSubview:self.payButton];
    self.payButton.hidden = YES;
}

#pragma mark 加载数据
-(void)loadCheckResultData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&oid=%@",kUserTokenValue,self.oid];
    [TCHttpRequest postMethodWithURL:kOrderDetailsAPI body:body success:^(id json) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *dict = [json objectForKey:@"data"];
            [myTutorial setValues:dict];
            
            weakSelf.jobCheckPicsArray = [NSMutableArray arrayWithArray:myTutorial.pics];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.pageControl.hidden = weakSelf.jobCheckPicsArray.count<2;
                weakSelf.pageControl.numberOfPages = weakSelf.jobCheckPicsArray.count;
                [weakSelf.photosCarousel reloadData];
                
                [headImageView sd_setImageWithURL:[NSURL URLWithString:myTutorial.trait] placeholderImage:[UIImage imageNamed:@"head_image"]];
                nameLabel.text = myTutorial.name;
                gradeLabel.text = [NSString stringWithFormat:@"%@/%@",myTutorial.grade,myTutorial.subject];
                priceLabel.text = [NSString stringWithFormat:@"¥%.2f",[myTutorial.price doubleValue]];
                NSString *priceStr =nil;
                if ([myTutorial.status integerValue]==2) {
                   priceStr = [NSString stringWithFormat:@"已付款：%.2f元",[myTutorial.pay_money doubleValue]];
                    weakSelf.payButton.hidden = YES;
                }else{
                   priceStr = [NSString stringWithFormat:@"应付款：%.2f元",[myTutorial.pay_money doubleValue]];
                   weakSelf.payButton.hidden = NO;
                }
                NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:priceStr];
                [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#FF6161"] range:NSMakeRange(4, priceStr.length-4)];
                weakSelf.payAmountLab.attributedText = attributeStr;
            });
        });
    }];
}

#pragma mark -- Getters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, kScreenWidth-36-40, 22)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.text = @"作业检查结果";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-40-38, 5, 35,35)];
        [_closeButton setImage:[UIImage imageNamed:@"check_popup_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeCheckResultViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark 滚动图片
-(iCarousel *)photosCarousel{
    if (!_photosCarousel) {
        _photosCarousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom, kScreenWidth-36,kScreenHeight-kNavHeight-203)];
        _photosCarousel.delegate = self;
        _photosCarousel.dataSource = self;
        _photosCarousel.pagingEnabled = NO;
        _photosCarousel.bounces = NO;
        _photosCarousel.type = iCarouselTypeCustom;
    }
    return _photosCarousel;
}

#pragma mark
-(ZYCustomPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[ZYCustomPageControl alloc] initWithFrame:CGRectMake(0, self.photosCarousel.bottom-10, kScreenWidth, 5)];
        _pageControl.currentPage = 0;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.inactiveImage = [UIImage imageNamed:@"Oval"];
        _pageControl.inactiveImageSize = CGSizeMake(5.0, 5.0);
        _pageControl.currentImage = [UIImage imageNamed:@"Rectangle"];
        _pageControl.currentImageSize = CGSizeMake(10, 5);
        _pageControl.currentPageIndicatorTintColor = [UIColor clearColor];
        _pageControl.pageIndicatorTintColor = [UIColor clearColor];
    }
    return _pageControl;
}


#pragma mark 老师信息
-(UIView *)teacherView{
    if(!_teacherView){
        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(0, self.photosCarousel.bottom+10, kScreenWidth-36, 69)];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(17, 0, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [_teacherView addSubview:bgHeadImageView];
        
        //头像
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 3, 52, 52)];
        headImageView.boderRadius = 26.0;
        [_teacherView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13.0, 11.0, 80, 20)];
        nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_teacherView addSubview:nameLabel];
        
        gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13, nameLabel.bottom+1.0, 90, 17)];
        gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        [_teacherView addSubview:gradeLabel];
        
        UILabel *priceTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-90.0, nameLabel.top,74, 20)];
        priceTitleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        priceTitleLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        priceTitleLab.textAlignment = NSTextAlignmentCenter;
        priceTitleLab.text = @"检查价格";
        [_teacherView addSubview:priceTitleLab];
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-90.0,priceTitleLab.bottom+2.0, 74.0, 17.0)];
        priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        [_teacherView addSubview:priceLabel];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0,68,kScreenWidth-36, 0.5)];
        lineView.backgroundColor  = kLineColor;
        [_teacherView addSubview:lineView];
    }
    return _teacherView;
}

#pragma mark 付款金额
-(UILabel *)payAmountLab{
    if (!_payAmountLab) {
        _payAmountLab = [[UILabel alloc] initWithFrame:CGRectMake(23, self.teacherView.bottom+15, 180, 22)];
        _payAmountLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _payAmountLab.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    }
    return _payAmountLab;
}

#pragma mark 去付款
-(UIButton *)payButton{
    if (!_payButton) {
        _payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-128, self.teacherView.bottom+12, 80, 80*(76.0/172.0))];
        _payButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        [_payButton setBackgroundImage:[UIImage imageNamed:@"button_2"] forState:UIControlStateNormal];
        [_payButton setTitle:@"去付款" forState:UIControlStateNormal];
        [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(payCheckOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}

-(NSMutableArray *)jobCheckPicsArray{
    if (!_jobCheckPicsArray) {
        _jobCheckPicsArray = [[NSMutableArray alloc] init];
    }
    return _jobCheckPicsArray;
}

@end
