//
//  MyConnecttingViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/17.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyConnecttingViewController.h"
#import "TeacherModel.h"

#define kBtnCapW (kScreenWidth-140-85)/2.0

@interface MyConnecttingViewController ()

@property (nonatomic ,strong) UIImageView   *bgImageView;     //背景
@property (nonatomic ,strong) UIView        *navBarView;     //导航栏
@property (nonatomic ,strong) UIView        *rootView;
@property (nonatomic ,strong) UIImageView   *headImageView;     //头像
@property (nonatomic ,strong) UILabel       *nameLabel;         //姓名
@property (nonatomic ,strong) UILabel       *gradeLabel;        //年级
@property (nonatomic ,strong) UILabel       *scoreLabel;        //评分
@property (nonatomic, strong) UILabel       *priceLabel;        //辅导价格
@property (nonatomic, strong) UILabel       *totalTimeLabel;    //辅导时长
@property (nonatomic, strong) UILabel       *checkCountLabel;   //检查次数
@property (nonatomic, strong) UILabel       *connecttingLabel;   //正在请求连线
@property (nonatomic, strong) UIButton      *refuseButton;   //拒绝
@property (nonatomic, strong) UIButton       *acceptButton;   //接受

@end

@implementation MyConnecttingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initConnecttingView];
    [self loadMyConnecttingView];
    
    
}

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -- Event Response
#pragma mark 取消
-(void)refuseConnecttingAction{
    [self responseFromCallWithAccept:NO];
}

#pragma mark 接受
-(void)acceptConnecttingAction{
    [self responseFromCallWithAccept:YES];
}

#pragma mark -- Private Methods
#pragma mark 初始化
- (void)initConnecttingView{
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.rootView];
    
    CGFloat orginY = kScreenWidth<375.0?60.0:100.0;
    UIImageView *bgHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-120)/2.0,orginY, 120, 120)];
    bgHeadImageView.image = [UIImage imageNamed:@"connection_head_image_white"];
    [self.view addSubview:bgHeadImageView];
    [self.view addSubview:self.headImageView];
    
    [self.rootView addSubview:self.nameLabel];
    [self.rootView addSubview:self.gradeLabel];
    
    UIView *line1= [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth/2.0,self.nameLabel.bottom+5.0,0.5, 19)];
    line1.backgroundColor  = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.rootView addSubview:line1];
    
    [self.rootView addSubview:self.scoreLabel];
    
    // 作业辅导价格 作业辅导时长 作业检查次数
    NSArray *images = @[@"tutor_price",@"tutor_time",@"tutor_frequency"];
    NSArray *titles = @[@"作业辅导价格",@"作业辅导时长",@"作业检查次数"];
    for (NSInteger i=0; i<3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth/3.0)*i+(kScreenWidth/3.0-28)/2.0,self.gradeLabel.bottom+25, 28, 28)];
        imgView.image = [UIImage imageNamed:images[i]];
        [self.rootView addSubview:imgView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(i*(kScreenWidth/3.0), imgView.bottom+5.0, kScreenWidth/3.0, 20)];
        lab.text = titles[i];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14];
        lab.textColor = [UIColor colorWithHexString:@" #4A4A4A"];
        [self.rootView addSubview:lab];
        if (i==0) {
            self.priceLabel = lab;
        }else if (i==1){
            self.totalTimeLabel = lab;
        }else{
            self.checkCountLabel = lab;
        }
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(i*(kScreenWidth/3.0), lab.bottom+2.0, kScreenWidth/3.0, 20)];
        titleLab.text = titles[i];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        titleLab.textColor = [UIColor colorWithHexString:@"#9B9B9B"];
        [self.rootView addSubview:titleLab];
    }
    
    UIView *line2= [[UIView alloc] initWithFrame:CGRectMake(26,self.gradeLabel.bottom+120,kScreenWidth-51, 0.5)];
    line2.backgroundColor  = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.rootView addSubview:line2];
    
    [self.rootView addSubview:self.connecttingLabel];
    [self.rootView addSubview:self.refuseButton];
    [self.rootView addSubview:self.acceptButton];
}

#pragma mark 加载数据
-(void)loadMyConnecttingView{
    if (kIsEmptyString(self.teacher.trait)) {
        _headImageView.image = [UIImage imageNamed:@"default_head_image_small"];
    }else{
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:self.teacher.trait] placeholderImage:[UIImage imageNamed:@"default_head_image_small"]];
    }
    _nameLabel.text = self.teacher.tch_name;
    NSString *gradeStr = [[ZYHelper sharedZYHelper] parseToGradeStringForGrades:self.teacher.grade];
    _gradeLabel.text = [NSString stringWithFormat:@"%@ %@",gradeStr,self.teacher.subject ];
    self.scoreLabel.text = [NSString stringWithFormat:@"评分 %.1f",[self.teacher.score doubleValue]];
    self.priceLabel.text = [NSString stringWithFormat:@"%.f元/分钟",[self.teacher.guide_price doubleValue]];
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%ld分钟%ld秒",[self.teacher.guide_time integerValue]/60,[self.teacher.guide_time integerValue]%60];
    self.checkCountLabel.text = [NSString stringWithFormat:@"%@次",self.teacher.check_num];
}

#pragma mark -- gettters and setters
#pragma mark 头部背景图
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.image = [UIImage imageNamed:@"background1"];
    }
    return _bgImageView;
}

#pragma mark 导航栏
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavHeight)];
        
        UILabel  *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-180)/2, KStatusHeight, 180, 44)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text = @"作业101";
        [_navBarView addSubview:titleLabel];
    }
    return _navBarView;
}

#pragma mark
-(UIView *)rootView{
    if (!_rootView) {
        CGFloat orginY = kScreenWidth<375.0?120.0:160.0;
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0,orginY, kScreenWidth, kScreenHeight-orginY)];
        _rootView.backgroundColor = [UIColor whiteColor];
        _rootView.topBoderRadius = 8.0;
    }
    return _rootView;
}

#pragma mark 头像
-(UIImageView *)headImageView{
    if (!_headImageView) {
        CGFloat orginY = kScreenWidth<375.0?70.0:110.0;
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - 100)/2.0,orginY, 100, 100)];
        _headImageView.boderRadius = 50.0;
    }
    return _headImageView;
}

#pragma mark 姓名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 76, kScreenWidth-80, 25)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:18];
        
        _nameLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
    }
    return _nameLabel;
}

#pragma mark 年级/科目
-(UILabel *)gradeLabel{
    if (!_gradeLabel) {
        _gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0-130, self.nameLabel.bottom,120, 25)];
        _gradeLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _gradeLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _gradeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _gradeLabel;
}

#pragma mark 年级/科目
-(UILabel *)scoreLabel{
    if (!_scoreLabel) {
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2.0+10, self.nameLabel.bottom, 120, 25)];
        _scoreLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _scoreLabel.textColor = [UIColor colorWithHexString:@"#808080"];
    }
    return _scoreLabel;
}

#pragma mark 连线
-(UILabel *)connecttingLabel{
    if (!_connecttingLabel) {
        _connecttingLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, self.scoreLabel.bottom+144, kScreenWidth-120, 20)];
        _connecttingLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:14];
        _connecttingLabel.textColor = [UIColor colorWithHexString:@"#808080"];
        _connecttingLabel.text = @"对方正在请求与你连线...";
        _connecttingLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _connecttingLabel;
}

#pragma mark 拒绝
-(UIButton *)refuseButton{
    if (!_refuseButton) {
        _refuseButton = [[UIButton alloc] initWithFrame:CGRectMake(kBtnCapW, self.connecttingLabel.bottom+29, 69, 100)];
        [_refuseButton setImage:[UIImage imageNamed:@"connection_cancel"] forState:UIControlStateNormal];
        [_refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        _refuseButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:16];
        _refuseButton.imageEdgeInsets = UIEdgeInsetsMake(-(_refuseButton.height - _refuseButton.titleLabel.height- _refuseButton.titleLabel.frame.origin.y-9),0, 0, 0);
        _refuseButton.titleEdgeInsets = UIEdgeInsetsMake(_refuseButton.imageView.height+_refuseButton.imageView.frame.origin.y, -_refuseButton.imageView.width, 0, 0);
        [_refuseButton addTarget:self action:@selector(refuseConnecttingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refuseButton;
}

#pragma mark 接受
-(UIButton *)acceptButton{
    if (!_acceptButton) {
        _acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-kBtnCapW-69, self.connecttingLabel.bottom+29, 69, 100)];
        [_acceptButton setImage:[UIImage imageNamed:@"connection_accept"] forState:UIControlStateNormal];
        [_acceptButton setTitle:@"接受" forState:UIControlStateNormal];
        [_acceptButton setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        _acceptButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleSemibold size:16];
        _acceptButton.imageEdgeInsets = UIEdgeInsetsMake(-(_acceptButton.height - _acceptButton.titleLabel.height- _acceptButton.titleLabel.frame.origin.y-9),0, 0, 0);
        _acceptButton.titleEdgeInsets = UIEdgeInsetsMake(_acceptButton.imageView.height+_acceptButton.imageView.frame.origin.y, -_acceptButton.imageView.width, 0, 0);
        [_acceptButton addTarget:self action:@selector(acceptConnecttingAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _acceptButton;
}

@end
