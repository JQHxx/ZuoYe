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
#import "SelectTeacherView.h"
#import "TeacherCollectionViewCell.h"
#import "BRPickerView.h"
#import "LevelModel.h"
#import "OrderTimePickerView.h"
#import "DemandTableViewCell.h"
#import "SetValueModel.h"

@interface ReleaseDemandViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableArray  *teacherLevelsArr;
    
    NSInteger        timeType;          //0、实时 1、预约
    NSString         *orderTime;        //预约时间
    NSString         *gradeStr;         //年级
    NSString         *courseStr;        //科目
    
    LevelModel       *selLevelModel;    //选择老师等级
    
    NSMutableArray   *coursesArr;
}

@property (nonatomic, strong) UIButton          *cancelButton;       //关闭按钮
@property (nonatomic, strong) UILabel           *titleLabel;        //标题
@property (nonatomic, strong) UIButton          *confirmButton;     //确定

@property (nonatomic, strong) UITableView       *demandTableView;
@property (nonatomic, strong) SelectTeacherView *selTeacherView;    //选择老师

@property (nonatomic ,strong) NSMutableArray   *myValuesArray;


@end

@implementation ReleaseDemandViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = 345;
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
    
    self.view.topBoderRadius = 10.0;
    
    [self initReleaseDemandView];
    [self loadLevelsData];
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<3) {
        DemandTableViewCell *cell = [[DemandTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SetValueModel *model = self.myValuesArray[indexPath.row];
        cell.valueModel = model;
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell.contentView addSubview:self.selTeacherView];
        self.selTeacherView.levelsArray = teacherLevelsArr;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 3){
        return 150;
    }else{
        return 44;
    }
}

#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        kSelfWeak;
        [OrderTimePickerView showOrderTimePickerWithTitle:@"选择时间" defaultTime:@{} resultBlock:^(NSString *dayStr, NSString *hourStr, NSString *minuteStr) {
            MyLog(@"day:%@,hour:%@,minute:%@",dayStr,hourStr,minuteStr);
            NSString *tempHourStr = [hourStr substringToIndex:hourStr.length-1];
            NSString *tempMinuteStr = [minuteStr substringToIndex:minuteStr.length-1];
            timeType = 1;
            for (SetValueModel *model in self.myValuesArray) {
                if (model.value_id==0) {
                    model.value = [NSString stringWithFormat:@"%@%02ld%02ld",dayStr,[tempHourStr integerValue],[tempMinuteStr integerValue]];
                    model.isSet = YES;
                }
            }
             [weakSelf.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else if (indexPath.row==1) {  //选择科目
        NSArray *grades = @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
        kSelfWeak;
        [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:gradeStr isAutoSelect:NO resultBlock:^(id selectValue) {
            gradeStr = selectValue;
            coursesArr = [NSMutableArray arrayWithArray:[[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr]];
            
            for (SetValueModel *model in self.myValuesArray) {
                if (model.value_id==1) {
                    model.value = selectValue;
                    model.isSet = YES;
                }
            }
            [weakSelf.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else if (indexPath.row==2){
        kSelfWeak;
        [BRStringPickerView showStringPickerWithTitle:@"选择科目" dataSource:coursesArr defaultSelValue:courseStr isAutoSelect:NO resultBlock:^(id selectValue) {
            courseStr = selectValue;
            for (SetValueModel *model in self.myValuesArray) {
                if (model.value_id==2) {
                    model.value = selectValue;
                    model.isSet = YES;
                }
            }
            [weakSelf.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark  确定发布
-(void)confirmReleaseDemandAction{
    MyLog(@"辅导类型：%@,预约时间：%@,年级：%@，科目：%@,作业辅导：教师等级：%@；教师价格：%.2f",@"作业辅导",timeType==0?@"实时":orderTime,gradeStr,courseStr,selLevelModel.level,selLevelModel.price);
    
} 

#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadLevelsData{
    timeType=0;
    gradeStr = @"一年级";
    NSArray *courses = [[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr];
    coursesArr = [NSMutableArray arrayWithArray:courses];
    courseStr = nil;
    
    NSArray *images = @[@"release_time",@"release_grade",@"release_subject"];
    NSArray *titles = @[@"现在",gradeStr,@"请选择科目"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<images.count; i++) {
        SetValueModel *model = [[SetValueModel alloc] init];
        model.value_id = i;
        model.imgName = images[i];
        model.isSet = i<2;
        model.value = titles[i];
        [tempArr addObject:model];
    }
    self.myValuesArray = tempArr;

    
    NSArray *levels = @[@"普通教师",@"初级教师",@"中级教师",@"高级教师",@"特级教师",];
    NSArray *photos = @[@"teacher_grade_junior",@"teacher_grade_intermediate",@"teacher_grade_senior",@"teacher_grade_junior",@"teacher_grade_intermediate"];
    NSMutableArray *tempLevelArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<levels.count; i++) {
        LevelModel *level = [[LevelModel alloc] init];
        level.level = levels[i];
        level.head_image = photos[i];
        level.price = 1.0 + 0.2*i;
        [tempLevelArr addObject:level];
    }
    teacherLevelsArr = tempLevelArr;
    [self.demandTableView reloadData];
}

#pragma mark 初始化
-(void)initReleaseDemandView{
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.confirmButton];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,45.0,kScreenWidth, 0.5)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:lineLbl];
    
    [self.view addSubview:self.demandTableView];
}

#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, kScreenWidth-200, 22)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.text = @"作业辅导";
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4A4A4A"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

#pragma mark 取消
-(UIButton *)cancelButton{
    if(!_cancelButton){
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(17.0,12.0, 32,22)];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"#4A4A4A"] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [_cancelButton addTarget:self action:@selector(closeCurrentViewAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark 发布
-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-50, 12.0, 34, 22)];
        [_confirmButton setTitle:@"发布" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithHexString:@"#FF7568"] forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
        [_confirmButton addTarget:self action:@selector(confirmReleaseDemandAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}


#pragma mark 需求列表
-(UITableView *)demandTableView{
    if (!_demandTableView) {
        _demandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 46.0, kScreenWidth, 300.0) style:UITableViewStylePlain];
        _demandTableView.dataSource = self;
        _demandTableView.delegate = self;
        _demandTableView.tableFooterView = [[UIView alloc] init];
        _demandTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _demandTableView;
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

#pragma mark
-(NSMutableArray *)myValuesArray{
    if (!_myValuesArray) {
        _myValuesArray = [[NSMutableArray alloc] init];
    }
    return _myValuesArray;
}



@end
