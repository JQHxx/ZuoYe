//
//  TeacherViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherViewController.h"
#import "TeacherDetailsViewController.h"
#import "ConnectionSettingViewController.h"
#import "SlideMenuView.h"
#import "RecommandTableViewCell.h"
#import "FocusTableViewCell.h"
#import "TeacherModel.h"

@interface TeacherViewController ()<UITableViewDelegate,UITableViewDataSource,SlideMenuViewDelegate>{
    BOOL   isFocusOn;
}


@property (nonatomic, strong)SlideMenuView   *titleView;
@property (nonatomic, strong)UITableView     *myTableView;

@property (nonatomic, strong)NSMutableArray  *recommandTeachersArray;  //推荐老师
@property (nonatomic, strong)NSMutableArray  *focusTeachersArray;      //关注老师

@end

@implementation TeacherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn = YES;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.myTableView];
    [self requestForTeachersDataWithIndex:0];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return isFocusOn?self.focusTeachersArray.count:self.recommandTeachersArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isFocusOn) {
        static NSString *cellIdentifier = @"FocusTableViewCell";
        FocusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[FocusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TeacherModel *model = self.focusTeachersArray[indexPath.row];
        [cell displayCellWithModel:model];
        
        cell.connectButton.userInteractionEnabled = model.isOnline;
        cell.connectButton.tag = indexPath.row;
        [cell.connectButton addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"RecommandTableViewCell";
        RecommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[RecommandTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TeacherModel *model = self.recommandTeachersArray[indexPath.section];
        [cell displayCellWithTeacher:model];
        
        cell.connectButton.tag = indexPath.section;
        [cell.connectButton addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isFocusOn?90:96.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeacherModel *model = isFocusOn?self.focusTeachersArray[indexPath.row]:self.recommandTeachersArray[indexPath.section];
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.id = model.id;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Custom Delegate
#pragma mark ItemTitleViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    isFocusOn = index;
    [self requestForTeachersDataWithIndex:index];
}

#pragma mark -- Event response
-(void)toConnectTeacherAction:(UIButton *)sender{
    TeacherModel *model = isFocusOn?self.focusTeachersArray[sender.tag]:self.recommandTeachersArray[sender.tag];
    ConnectionSettingViewController *settingVC = [[ConnectionSettingViewController alloc] init];
    settingVC.teacherModel = model;
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark -- Private Methods
#pragma mark load Data
-(void)requestForTeachersDataWithIndex:(NSInteger)index{
    NSArray *names =@[@"小美老师",@"张三",@"李四",@"王五",@"小芳老师"];
    NSArray *levels = @[@"特级教师",@"高级教师",@"中级教师",@"初级教师",@"普通教师"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<5; i++) {
        TeacherModel *model = [[TeacherModel alloc] init];
        model.id = i+1;
        model.head = @"photo";
        model.name = names[i];
        model.grade = @"一年级";
        model.subjects = @"科目";
        model.schoolAge = i+4;
        model.level = levels[i];
        model.score = 5.0 - i*0.2;
        model.count = 1500 + i*50;
        model.price = 2.0 - 0.2*i;
        model.tech_stage = @"小学";
        model.isOnline = i%2;
        [tempArr addObject:model];
    }
    
    if (index==0) {
        self.recommandTeachersArray = tempArr;
    }else{
        self.focusTeachersArray = tempArr;
    }
    [self.myTableView reloadData];
}


#pragma mark -- Setters and Getters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -120)/2, KStatusHeight, 120, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"推荐",@"关注"];
         _titleView.currentIndex = 0;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark 老师列表
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-kTabHeight) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.estimatedSectionHeaderHeight=0;
        _myTableView.estimatedSectionFooterHeight=0;
        _myTableView.tableFooterView = [[UIView alloc] init];
        _myTableView.backgroundColor = isFocusOn ? [UIColor whiteColor]:[UIColor bgColor_Gray];
        _myTableView.separatorStyle = isFocusOn?UITableViewCellSeparatorStyleSingleLine:UITableViewCellSeparatorStyleNone;
    }
    return _myTableView;
}

#pragma mark 推荐老师数组
-(NSMutableArray *)recommandTeachersArray{
    if (!_recommandTeachersArray) {
        _recommandTeachersArray = [[NSMutableArray alloc] init];
    }
    return _recommandTeachersArray;
}

#pragma mark 关注老师数组
-(NSMutableArray *)focusTeachersArray{
    if (!_focusTeachersArray) {
        _focusTeachersArray = [[NSMutableArray alloc] init];
    }
    return _focusTeachersArray;
}



@end
