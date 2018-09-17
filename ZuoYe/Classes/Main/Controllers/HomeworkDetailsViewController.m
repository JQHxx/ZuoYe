//
//  HomeworkDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkDetailsViewController.h"
#import "CancelViewController.h"
#import "PhotosView.h"
#import "TeacherModel.h"

@interface HomeworkDetailsViewController (){
    UILabel     *typeLabel;
    UILabel     *gradeLabel;
    UILabel     *priceLabel;
    UILabel     *stateLabel;
    UIImageView *stateImageView;
    
    UIImageView *headImageView;
    UILabel     *nameLabel;
    UILabel     *stageLabel;
}

@property (nonatomic ,strong) UIScrollView *rootScrollView;
@property (nonatomic ,strong) UIView     *homeworkView;
@property (nonatomic ,strong) PhotosView *photosView;
@property (nonatomic ,strong) UIView     *teacherView;

@end

@implementation HomeworkDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"作业详情";
    self.rigthTitleName = @"取消";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self initHomeworkDetailsView];
    [self loadHomeworkDetailData];
    
}

#pragma mark -- Event Response
#pragma mark 取消
-(void)rightNavigationItemAction{
    CancelViewController *cancelVC = [[CancelViewController alloc] init];
    [self.navigationController pushViewController:cancelVC animated:YES];
}

#pragma mark 联系老师
-(void)contactTeacherAction:(UIButton *)sender{
    
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadHomeworkDetailData{
    typeLabel.text = self.homework.type==0?@"作业检查":@"作业辅导";
    gradeLabel.text = [NSString stringWithFormat:@"%@/%@",self.homework.grade,self.homework.subject];
    
    NSString *tempStr = nil;
    if (self.homework.type==0) {
        tempStr = [NSString stringWithFormat:@"检查价格：%.2f元",self.homework.check_price];
    }else{
        tempStr = [NSString stringWithFormat:@"辅导价格：%.2f元/分钟",self.homework.perPrice];
    }
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:tempStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4A4A4A"] range:NSMakeRange(0, 5)];
    priceLabel.attributedText = attributeStr;
    
    self.photosView.photosArray = [NSMutableArray arrayWithArray:@[@"homework",@"homework",@"homework",@"homework"]];
    
    if (self.homework.state==0) {
        stateLabel.text = @"待接单";
        stateImageView.image = [UIImage imageNamed:@"order_wait_receipt"];
        self.teacherView.hidden = YES;
        self.rootScrollView.contentSize =CGSizeMake(kScreenWidth, self.photosView.top+self.photosView.height);
    }else{
        stateLabel.text = @"已接单";
        stateImageView.image = [UIImage imageNamed:@"order_already_received"];
        
        headImageView.image = [UIImage imageNamed:self.homework.teacher.head];
        nameLabel.text = self.homework.teacher.name;
        stageLabel.text = [NSString stringWithFormat:@"%@/%@",self.homework.teacher.tech_stage,self.homework.subject];
        
        self.teacherView.hidden = NO;
        self.rootScrollView.contentSize =CGSizeMake(kScreenWidth, self.teacherView.top+self.teacherView.height);
    }
}

#pragma mark 初始化
-(void)initHomeworkDetailsView{
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.homeworkView];
    [self.rootScrollView addSubview:self.photosView];
    [self.rootScrollView addSubview:self.teacherView];
    self.teacherView.hidden = YES;
    self.rootScrollView.contentSize =CGSizeMake(kScreenWidth, self.photosView.top+self.photosView.height);
}

#pragma mark -- Getters and Setters
#pragma mark
-(UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight)];
        _rootScrollView.backgroundColor = [UIColor bgColor_Gray];
        _rootScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rootScrollView;
}

#pragma mark 作业信息
-(UIView *)homeworkView{
    if (!_homeworkView) {
        _homeworkView = [[UIView alloc] initWithFrame:CGRectMake(10,9, kScreenWidth-20, 102)];
        _homeworkView.boderRadius = 4;
        _homeworkView.backgroundColor = [UIColor whiteColor];
        
        //辅导类型
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,13, 68, 22)];
        typeLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        typeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        typeLabel.layer.cornerRadius = 2.0;
        typeLabel.layer.borderColor = [UIColor colorWithHexString:@"#FF6161"].CGColor;
        typeLabel.layer.borderWidth = 1.0;
        typeLabel.textAlignment = NSTextAlignmentCenter;
        [_homeworkView addSubview:typeLabel];
        
        //年级/科目
        gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, typeLabel.bottom+10.0, 100, 20)];
        gradeLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_homeworkView addSubview:gradeLabel];
        
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, gradeLabel.bottom+4.0, 167.0, 20.0)];
        priceLabel.textColor = [UIColor colorWithHexString:@"#FF6161"];
        priceLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        [_homeworkView addSubview:priceLabel];
        
        //接单状态
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-75, 8.0, 52, 20.0)];
        stateLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        stateLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        stateLabel.textAlignment = NSTextAlignmentRight;
        [_homeworkView addSubview:stateLabel];
        
        stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-20-77, 44, 77, 58)];
        [_homeworkView addSubview:stateImageView];
    }
    return _homeworkView;
}

#pragma mark 图片
-(PhotosView *)photosView{
    if (!_photosView) {
        _photosView = [[PhotosView alloc] initWithFrame:CGRectMake(0, self.homeworkView.bottom+15, kScreenWidth, 360) bgColor:[UIColor bgColor_Gray]];
    }
    return _photosView;
}

#pragma mark 老师信息
-(UIView *)teacherView{
    if (!_teacherView) {
        _teacherView = [[UIView alloc] initWithFrame:CGRectMake(10, self.photosView.bottom+20, kScreenWidth-20, 80)];
        _teacherView.boderRadius=4.0;
        _teacherView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 58, 58)];
        bgHeadImageView.backgroundColor = [UIColor colorWithHexString:@"#FFE0D3"];
        bgHeadImageView.boderRadius = 29.0;
        [_teacherView addSubview:bgHeadImageView];
        
        //头像
        headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(19, 14, 52, 52)];
        [_teacherView addSubview:headImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13.0, 22.0, 60, 20)];
        nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        [_teacherView addSubview:nameLabel];
        
        stageLabel = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+13, nameLabel.bottom+3.0, 120, 20)];
        stageLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
        stageLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        [_teacherView addSubview:stageLabel];
        
        UIButton *contactButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-76, 11.0, 44.0, 60.0)];
        [contactButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [contactButton setTitle:@"联系老师" forState:UIControlStateNormal];
        [contactButton setTitleColor:[UIColor colorWithHexString:@"#808080"] forState:UIControlStateNormal];
        contactButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:10];
        contactButton.imageEdgeInsets = UIEdgeInsetsMake(-(contactButton.height - contactButton.titleLabel.height- contactButton.titleLabel.y-16),0, 0, 0);
        contactButton.titleEdgeInsets = UIEdgeInsetsMake(contactButton.imageView.height+contactButton.imageView.y, -contactButton.imageView.width, 0, 0);
        [contactButton addTarget:self action:@selector(contactTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        [_teacherView addSubview:contactButton];
        
    }
    return _teacherView;
}


@end
