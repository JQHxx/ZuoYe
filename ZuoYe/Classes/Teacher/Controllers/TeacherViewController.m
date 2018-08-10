//
//  TeacherViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "TeacherViewController.h"
#import "TeacherDetailsViewController.h"

#import "ItemTitleView.h"
#import "RecommandTableViewCell.h"
#import "FocusTableViewCell.h"

#import "TeacherModel.h"

@interface TeacherViewController ()<ItemTitleViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    BOOL   isFocusOn;
}


@property (nonatomic, strong)ItemTitleView   *titleView;
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
    return isFocusOn?1:self.recommandTeachersArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return isFocusOn?self.focusTeachersArray.count:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isFocusOn) {
        static NSString *cellIdentifier = @"FocusTableViewCell";
        FocusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"FocusTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        TeacherModel *model = self.focusTeachersArray[indexPath.row];
        [cell displayCellWithModel:model];
        
        cell.connectBtn.tag = indexPath.row;
        [cell.connectBtn addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }else{
        static NSString *cellIdentifier = @"RecommandTableViewCell";
        RecommandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RecommandTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        TeacherModel *model = self.recommandTeachersArray[indexPath.section];
        [cell appleDataForRecommandTeacher:model];
        
        cell.connectTeacherBtn.tag = indexPath.section;
        [cell.connectTeacherBtn addTarget:self action:@selector(toConnectTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isFocusOn?70:150;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return isFocusOn?1:10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TeacherModel *model = isFocusOn?self.focusTeachersArray[indexPath.row]:self.recommandTeachersArray[indexPath.section];
    TeacherDetailsViewController *detailsVC = [[TeacherDetailsViewController alloc] init];
    detailsVC.id = model.id;
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Custom Delegate
#pragma mark ItemTitleViewDelegate
-(void)itemTitleViewDidClickWithIndex:(NSInteger)index{
    isFocusOn = index;
    [self requestForTeachersDataWithIndex:index];
}

#pragma mark -- Event response
-(void)toConnectTeacherAction:(UIButton *)sender{
//    TeacherModel *model = isFocusOn?self.focusTeachersArray[sender.tag]:self.recommandTeachersArray[sender.tag];
    
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
        model.head = @"ic_m_head";
        model.name = names[i];
        model.grade = @"一年级";
        model.subjects = @"科目";
        model.schoolAge = i+4;
        model.level = levels[i];
        model.score = 5.0 - i*0.2;
        model.count = 1500 + i*50;
        model.price = 2.0 - 0.2*i;
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
-(ItemTitleView *)titleView{
    if (!_titleView) {
        _titleView = [[ItemTitleView alloc] initWithFrame:CGRectMake((kScreenWidth -120)/2, KStatusHeight, 120, kNavHeight-KStatusHeight) titles:@[@"推荐",@"关注"]];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark 老师列表
-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight-kTabHeight) style:UITableViewStyleGrouped];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.estimatedSectionHeaderHeight=0;
        _myTableView.estimatedSectionFooterHeight=0;
        _myTableView.tableFooterView = [[UIView alloc] init];
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
