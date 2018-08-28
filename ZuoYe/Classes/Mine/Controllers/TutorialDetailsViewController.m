//
//  TutorialDetailsViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/20.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TutorialDetailsViewController.h"
#import "ComplaintViewController.h"
#import "TutorialPayViewController.h"
#import "ConnectionSettingViewController.h"
#import "KRVideoPlayerController.h"
#import "STPopupController.h"

@interface TutorialDetailsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UIButton  *handleBtn;
}

@property (nonatomic ,strong) UITableView *detailsTableView;
@property (nonatomic ,strong) UIView      *footerView;
@property (nonatomic ,strong) UIView      *bottomView;

@property (nonatomic, strong) KRVideoPlayerController *videoController;

@end

@implementation TutorialDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    self.baseTitle = @"辅导详情";
    
    self.rigthTitleName = @"投诉";
    
    [self.view addSubview:self.detailsTableView];
    self.detailsTableView.tableFooterView = self.myTutorial.state==5?[[UIView alloc] init]:self.footerView;
    [self.view addSubview:self.bottomView];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1) {
        return @"我的老师";
    }else{
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (indexPath.section==0) {
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 120, 30)];
        titleLab.font = kFontWithSize(16);
        titleLab.textColor = [UIColor blackColor];
        titleLab.text = self.myTutorial.type==1?@"作业检查":@"作业辅导";
        [cell.contentView addSubview:titleLab];
        
        UILabel *dateTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, titleLab.bottom, 180, 20)];
        dateTimeLab.font = kFontWithSize(14);
        dateTimeLab.textColor = [UIColor lightGrayColor];
        dateTimeLab.text = self.myTutorial.datetime;
        [cell.contentView addSubview:dateTimeLab];
        
        UILabel *stateLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-90, 20, 70, 30)];
        stateLab.font = kFontWithSize(16);
        stateLab.textColor = [UIColor blackColor];
        stateLab.textAlignment = NSTextAlignmentRight;
        stateLab.text = [[ZYHelper sharedZYHelper] getStateStringWithIndex:self.myTutorial.state];
        [cell.contentView addSubview:stateLab];
    }else {
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        headImageView.image = [UIImage imageNamed:@"ic_m_head"];
        [cell.contentView addSubview:headImageView];
        
        UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10,5, 90, 20)];
        nameLab.font = kFontWithSize(14);
        nameLab.textColor = [UIColor blackColor];
        nameLab.text = self.myTutorial.name;
        [cell.contentView addSubview:nameLab];
        
        UILabel *levelLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, nameLab.bottom, 90, 20)];
        levelLab.font = kFontWithSize(13);
        levelLab.textColor = [UIColor darkGrayColor];
        levelLab.text = self.myTutorial.level;
        [cell.contentView addSubview:levelLab];
        
        UILabel *gradeLab = [[UILabel alloc] initWithFrame:CGRectMake(headImageView.right+10, levelLab.bottom, 90, 20)];
        gradeLab.font = kFontWithSize(13);
        gradeLab.textColor = [UIColor lightGrayColor];
        gradeLab.text = [NSString stringWithFormat:@"%@/%@",self.myTutorial.grade,self.myTutorial.subject];
        [cell.contentView addSubview:gradeLab];
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 70;
    }else{
        return 80;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0.5;
    }else{
        return 30;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}


#pragma mark -- Event Response
#pragma mark 投诉
-(void)rightNavigationItemAction{
    ComplaintViewController *complaintVC = [[ComplaintViewController alloc] init];
    [self.navigationController pushViewController:complaintVC animated:YES];
}

#pragma mark 回放
-(void)replayTutorialVideoAction:(UIButton *)sender{
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    [self playVideoWithURL:videoURL];
}

#pragma mark 联系客服
-(void)connectSeriveAction:(UIButton *)sender{
    
}

#pragma mark
-(void)handleAction:(UIButton *)sender{
    MyLog(@"button title：%@",sender.currentTitle);
    
    if ([sender.currentTitle isEqualToString:@"去付款"]) {
        TutorialPayViewController *payVC = [[TutorialPayViewController alloc] init];
        STPopupController *popupVC = [[STPopupController alloc] initWithRootViewController:payVC];
        popupVC.style = STPopupStyleBottomSheet;
        popupVC.navigationBarHidden = YES;
        [popupVC presentInViewController:self];
    }else{
        ConnectionSettingViewController *connectSettingVC = [[ConnectionSettingViewController alloc] init];
        [self.navigationController pushViewController:connectSettingVC animated:YES];
    }
}


#pragma mark -- 详情
-(UITableView *)detailsTableView{
    if (!_detailsTableView) {
        _detailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-60) style:UITableViewStyleGrouped];
        _detailsTableView.dataSource = self;
        _detailsTableView.delegate = self;
        _detailsTableView.estimatedSectionHeaderHeight = 0;
        _detailsTableView.estimatedSectionFooterHeight = 0;
        _detailsTableView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _detailsTableView;
}

#pragma mark  -- 视频和价格
-(UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (kScreenWidth-20)*(9.0/16.0)+60)];
        _footerView.backgroundColor = [UIColor bgColor_Gray];
        
        UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth-20,(kScreenWidth-20)*(9.0/16.0))];
        videoView.backgroundColor = [UIColor whiteColor];
        [_footerView addSubview:videoView];
        
        UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-60)/2, (160-40)/2, 40, 40)];
        [playBtn setImage:[UIImage imageNamed:@"play.jpg"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(replayTutorialVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [videoView addSubview:playBtn];
        
        UILabel *checkPriceLab = [[UILabel alloc] initWithFrame:CGRectMake(15, videoView.bottom+20, kScreenWidth/2-15, 20)];
        checkPriceLab.font = kFontWithSize(14);
        checkPriceLab.textColor = [UIColor blackColor];
        checkPriceLab.text = self.myTutorial.type == 1?[NSString stringWithFormat:@"检查价格：%.2f元",self.myTutorial.check_price]:[NSString stringWithFormat:@"辅导时长：%ld分%ld秒",self.myTutorial.duration/60,self.myTutorial.duration%60];
        [_footerView addSubview:checkPriceLab];
        
        UILabel *payLab = [[UILabel alloc] initWithFrame:CGRectMake(checkPriceLab.right, videoView.bottom+20, kScreenWidth/2-15, 20)];
        payLab.textColor = [UIColor blackColor];
        payLab.font = kFontWithSize(14);
        payLab.textAlignment = NSTextAlignmentRight;
        payLab.text = [NSString stringWithFormat:@"%@：¥%.2f",self.myTutorial.state==3?@"待付金额":@"已付金额",self.myTutorial.pay_price];
        [_footerView addSubview:payLab];
    }
    return _footerView;
}

#pragma mark 底部视图
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-60, kScreenWidth, 60)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        UIButton *connectServiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 90, 40)];
        [connectServiceBtn setTitle:@"联系客服" forState:UIControlStateNormal];
        [connectServiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        connectServiceBtn.layer.cornerRadius = 3;
        connectServiceBtn.layer.borderColor = [UIColor blackColor].CGColor;
        connectServiceBtn.layer.borderWidth = 1;
        connectServiceBtn.titleLabel.font = kFontWithSize(14);
        [connectServiceBtn addTarget:self action:@selector(connectSeriveAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:connectServiceBtn];
        
        handleBtn = [[UIButton alloc] initWithFrame:CGRectMake(connectServiceBtn.right+20, 10, kScreenWidth-connectServiceBtn.right-35, 40)];
        [handleBtn setTitle:self.myTutorial.state==3?@"去付款":@"重新连线" forState:UIControlStateNormal];
        [handleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        handleBtn.backgroundColor = [UIColor redColor];
        handleBtn.layer.cornerRadius=5;
        handleBtn.titleLabel.font = kFontWithSize(14);
        [handleBtn addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:handleBtn];
    }
    return _bottomView;
}

#pragma mark 视屏播放
- (void)playVideoWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0,(kScreenHeight - kScreenWidth*(9.0/16.0))/2.0, kScreenWidth, kScreenWidth*(9.0/16.0))];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
        }];
        [self.videoController showInWindow];
    }
    self.videoController.contentURL = url;
}



@end
