//
//  ReleaseDemandViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/9.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ReleaseDemandViewController.h"
#import "STPopupController.h"
#import "UIViewController+STPopup.h"
#import "DemandButton.h"

@interface ReleaseDemandViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UILabel      *titleLabel;        //标题
@property (nonatomic,strong) UIButton     *closeButton;       //关闭按钮
@property (nonatomic,strong) UITableView  *demandTableView;
@property (nonatomic,strong) DemandButton *timeButton;        //时间
@property (nonatomic,strong) DemandButton *gradeButton;       //年级
@property (nonatomic,strong) UIButton     *confirmButton;     //确定

@end

@implementation ReleaseDemandViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = kScreenHeight *0.65;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,self.titleLabel.bottom+19,kScreenWidth, 1)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.view addSubview:lineLbl];
    
    [self.view addSubview:self.demandTableView];
    [self.view addSubview:self.confirmButton];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (indexPath.row==0) {
        [cell.contentView addSubview:self.timeButton];
        [cell.contentView addSubview:self.gradeButton];
    }else if (indexPath.row==1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"科目";
        cell.detailTextLabel.text = @"数学";
    }else{
        
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row==2?180:55;
}

#pragma mark -- Event reponse
#pragma mark 关闭
-(void)closeCurrentViewAction{
    if(self.popupController){
        [self.popupController dismiss];
    }
}

#pragma mark  确定发布
-(void)confirmReleaseDemandAction{
    
}

#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth-40, 25)];
        _titleLabel.font = kFontWithSize(18);
        _titleLabel.text = self.type == TutoringTypeReview?@"作业检查":@"作业辅导";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 关闭
-(UIButton *)closeButton{
    if(!_closeButton){
        _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-30, 5, 30,30)];
        [_closeButton setImage:[UIImage imageNamed:@"pub_ic_lite_del"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeCurrentViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

#pragma mark 需求列表
-(UITableView *)demandTableView{
    if (!_demandTableView) {
        _demandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.bottom+20, kScreenWidth, kScreenHeight*0.65-self.titleLabel.bottom-60) style:UITableViewStylePlain];
        _demandTableView.dataSource = self;
        _demandTableView.delegate = self;
        _demandTableView.tableFooterView = [[UIView alloc] init];
    }
    return _demandTableView;
}

#pragma mark 预约时间
-(DemandButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [[DemandButton alloc] initWithFrame:CGRectMake(10, 10, kScreenWidth/2-20, 30)];
        [_timeButton setImage:[UIImage imageNamed:@"ic_login_num"] forState:UIControlStateNormal];
        [_timeButton setTitle:@"现在" forState:UIControlStateNormal];
    }
    return _timeButton;
}

#pragma mark 年级
-(DemandButton *)gradeButton{
    if (!_gradeButton) {
        _gradeButton = [[DemandButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+10, 10, kScreenWidth/2-20, 30)];
        [_gradeButton setImage:[UIImage imageNamed:@"ic_login_code"] forState:UIControlStateNormal];
        [_gradeButton setTitle:@"一年级" forState:UIControlStateNormal];
    }
    return _gradeButton;
}

#pragma mark 确定
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kScreenHeight*0.65-50, kScreenWidth, 50)];
        _confirmButton.backgroundColor = [UIColor redColor];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(confirmReleaseDemandAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}



@end
