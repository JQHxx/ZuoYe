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
#import "CheckPriceView.h"
#import "SelectTeacherView.h"
#import "TeacherCollectionViewCell.h"
#import "BRPickerView.h"
#import "DemandButton.h"
#import "LevelModel.h"
#import "OrderTimePickerView.h"

@interface ReleaseDemandViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray  *teacherLevelsArr;
    
    NSInteger        timeType;          //0、实时 1、预约
    NSString         *orderTime;        //预约时间
    NSString         *gradeStr;         //年级
    NSString         *courseStr;        //科目
    double           checkPrice;        //检查价格
    LevelModel       *selLevelModel;    //选择老师等级
    
    NSMutableArray   *coursesArr;
}

@property (nonatomic, strong) UILabel           *titleLabel;        //标题
@property (nonatomic, strong) UIButton          *closeButton;       //关闭按钮
@property (nonatomic, strong) UITableView       *demandTableView;
@property (nonatomic, strong) DemandButton      *timeButton;        //时间
@property (nonatomic, strong) DemandButton      *gradeButton;       //年级
@property (nonatomic, strong) CheckPriceView    *checkPriceView;    //检查价格
@property (nonatomic, strong) SelectTeacherView *selTeacherView;    //选择老师
@property (nonatomic, strong) UIButton          *confirmButton;     //确定

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
    
    teacherLevelsArr = [[NSMutableArray alloc] init];
    selLevelModel = [[LevelModel alloc] init];
    coursesArr = [[NSMutableArray alloc] init];
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.closeButton];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,self.titleLabel.bottom+19,kScreenWidth, 1)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#dddddd"];
    [self.view addSubview:lineLbl];
    
    [self.view addSubview:self.demandTableView];
    [self.view addSubview:self.confirmButton];
    
    [self loadLevelsData];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        [cell.contentView addSubview:self.timeButton];
        [cell.contentView addSubview:self.gradeButton];
    }else if (indexPath.row==1){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"科目";
        cell.detailTextLabel.text = courseStr;
    }else{
        if(self.type == TutoringTypeReview){
            [cell.contentView addSubview:self.checkPriceView];
        }else{
            [cell.contentView addSubview:self.selTeacherView];
            self.selTeacherView.levelsArray = teacherLevelsArr;
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
        return self.type == TutoringTypeReview?80:150;
    }else{
        return 55;
    }
}

#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {  //选择科目
        [BRStringPickerView showStringPickerWithTitle:@"选择科目" dataSource:coursesArr defaultSelValue:courseStr isAutoSelect:NO resultBlock:^(id selectValue) {
            courseStr = selectValue;
            [self.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

#pragma mark -- Event reponse
#pragma mark 关闭
-(void)closeCurrentViewAction{
    if(self.popupController){
        [self.popupController dismiss];
    }
}

#pragma mark  设置预约时间
- (void)changeOrderTimeAction:(UIButton *)sender{
    [OrderTimePickerView showOrderTimePickerWithTitle:@"选择时间" defaultTime:@{} resultBlock:^(NSString *dayStr, NSString *hourStr, NSString *minuteStr) {
        MyLog(@"day:%@,hour:%@,minute:%@",dayStr,hourStr,minuteStr);
        NSString *tempHourStr = [hourStr substringToIndex:hourStr.length-1];
        NSString *tempMinuteStr = [minuteStr substringToIndex:minuteStr.length-1];
        [self.timeButton setTitle:[NSString stringWithFormat:@"%@ %02ld点%02ld分",dayStr,[tempHourStr integerValue],[tempMinuteStr integerValue]] forState:UIControlStateNormal];
    }];
}

#pragma mark 修改年级
-(void)changeGradeAction:(UIButton *)sender{
    NSArray *grades = @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
    [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:gradeStr isAutoSelect:NO resultBlock:^(id selectValue) {
        gradeStr = selectValue;
        [self.gradeButton setTitle:gradeStr forState:UIControlStateNormal];
        coursesArr = [NSMutableArray arrayWithArray:[[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr]];
    }];
}

#pragma mark  确定发布
-(void)confirmReleaseDemandAction{
    MyLog(@"辅导类型：%@,预约时间：%@,年级：%@，科目：%@,检查价格:%.2f,作业辅导：教师等级：%@；教师价格：%.2f",self.type==TutoringTypeReview?@"作业检查":@"作业辅导",timeType==0?@"实时":orderTime,gradeStr,courseStr,checkPrice,selLevelModel.level,selLevelModel.price);
    
} 

#pragma mark -- Private methods
-(void)loadLevelsData{
    timeType=0;
    [self.timeButton setTitle:timeType==0?@"现在":orderTime forState:UIControlStateNormal];
    
    gradeStr = @"一年级";
    [self.gradeButton setTitle:gradeStr forState:UIControlStateNormal];
    
    NSArray *courses = [[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr];
    coursesArr = [NSMutableArray arrayWithArray:courses];
    
    courseStr = @"数学";
    
    NSArray *levels = @[@"普通教师",@"初级教师",@"中级教师",@"高级教师",@"特级教师"];
    NSArray *photos = @[@"chujijiaoshi",@"zhongjijiaoshi",@"gaojijiaoshi",@"zhongjijiaoshi",@"gaojijiaoshi"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<levels.count; i++) {
        LevelModel *level = [[LevelModel alloc] init];
        level.level = levels[i];
        level.head_image = photos[i];
        level.price = 1.0 + 0.2*i;
        [tempArr addObject:level];
    }
    teacherLevelsArr = tempArr;
    [self.demandTableView reloadData];
}

#pragma mark -- getters and setters
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
        [_timeButton addTarget:self action:@selector(changeOrderTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}

#pragma mark 年级
-(DemandButton *)gradeButton{
    if (!_gradeButton) {
        _gradeButton = [[DemandButton alloc] initWithFrame:CGRectMake(kScreenWidth/2+10, 10, kScreenWidth/2-20, 30)];
        [_gradeButton setImage:[UIImage imageNamed:@"ic_login_code"] forState:UIControlStateNormal];
        [_gradeButton addTarget:self action:@selector(changeGradeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gradeButton;
}

#pragma mark 检查价格
-(CheckPriceView *)checkPriceView{
    if (!_checkPriceView) {
        _checkPriceView = [[CheckPriceView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)];
        _checkPriceView.getPriceBlock = ^(double aPrice) {
            checkPrice = aPrice;
        };
    }
    return _checkPriceView;
}

#pragma mark 选择老师
-(SelectTeacherView *)selTeacherView{
    if (!_selTeacherView) { 
        _selTeacherView = [[SelectTeacherView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
        _selTeacherView.selLevelBlock = ^(LevelModel *model) {
            selLevelModel = model;
        };
    }
    return _selTeacherView;
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
