//
//  HomeworkViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "HomeworkViewController.h"
#import "HomeworkDetailsViewController.h"
#import "HomeworkTableViewCell.h"
#import "SlideMenuView.h"
#import "HomeworkModel.h"

@interface HomeworkViewController ()<SlideMenuViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSInteger selectIndex;
}

@property (nonatomic, strong)SlideMenuView     *titleView;
@property (nonatomic, strong)UITableView       *homeworkTableView;

@property (nonatomic, strong) NSMutableArray   *checkHomeworksArray;
@property (nonatomic, strong) NSMutableArray   *tutorialHomeworksArray;

@end

@implementation HomeworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectIndex = 0;
    
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.homeworkTableView];
    
    [self loadHomeworkData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return selectIndex==0?self.checkHomeworksArray.count:self.tutorialHomeworksArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HomeworkTableViewCell";
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[HomeworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HomeworkModel *model = nil;
    if (selectIndex==0) {
        model = self.checkHomeworksArray[indexPath.section];
    }else{
        model = self.tutorialHomeworksArray[indexPath.section];
    }
    [cell displayCellWithHomework:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeworkModel *model = nil;
    if (selectIndex==0) {
        model = self.checkHomeworksArray[indexPath.section];
    }else{
        model = self.tutorialHomeworksArray[indexPath.section];
    }
    HomeworkDetailsViewController *detailsVC = [[HomeworkDetailsViewController alloc] init];
    detailsVC.homework = model;
    [self.navigationController pushViewController:detailsVC animated:YES];
}

#pragma mark -- Delegate
#pragma mark SlideMenuViewDelegate
-(void)slideMenuView:(SlideMenuView *)menuView didSelectedWithIndex:(NSInteger)index{
    selectIndex = index;
    [self loadHomeworkData];
}

#pragma mark -- Private Methods
#pragma mark 获取数据
-(void)loadHomeworkData{
    
    NSMutableArray *tempCheckArr = [[NSMutableArray alloc] init];
    NSMutableArray *tempTutorialArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<15; i++) {
        HomeworkModel *model = [[HomeworkModel alloc] init];
        model.type = i%2;
        model.grade = @"一年级";
        model.subject = @"数学";
        model.coverImage = @"zuoye";
        model.state = i%3;
        model.time_type = i%2;
        model.check_price = 10.0 + i*0.5;
        model.perPrice = 1.0 + i*0.5;
        model.order_time = @"今天 12:30";
        NSMutableArray *tempImages = [[NSMutableArray alloc] init];
        for (NSInteger j=0; j<=i; j++) {
            NSString *imgName = @"zuoye";
            [tempImages addObject:imgName];
        }
        model.images = tempImages;
        if (model.type==0) {
            [tempCheckArr addObject:model];
        }else{
            [tempTutorialArr addObject:model];
        }
    }
    self.checkHomeworksArray = tempCheckArr;
    self.tutorialHomeworksArray = tempTutorialArr;
    [self.homeworkTableView reloadData];
}

#pragma mark -- Getters and Setters
#pragma mark 标题栏
-(SlideMenuView *)titleView{
    if (!_titleView) {
        _titleView = [[SlideMenuView alloc] initWithFrame:CGRectMake((kScreenWidth -200)/2, KStatusHeight, 200, kNavHeight-KStatusHeight) btnTitleFont:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16] color:[UIColor colorWithHexString:@"#4A4A4A"] selColor:[UIColor colorWithHexString:@"#FF6161"] showLine:NO];
        _titleView.isShowUnderLine = YES;
        _titleView.myTitleArray = @[@"作业检查",@"作业辅导"];
        _titleView.currentIndex = selectIndex;
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.delegate = self;
    }
    return _titleView;
}

#pragma mark  辅导列表
-(UITableView *)homeworkTableView{
    if (!_homeworkTableView) {
        _homeworkTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleView.bottom, kScreenWidth, kScreenHeight-kNavHeight-self.titleView.bottom) style:UITableViewStyleGrouped];
        _homeworkTableView.delegate = self;
        _homeworkTableView.dataSource = self;
        _homeworkTableView.showsVerticalScrollIndicator = NO;
        _homeworkTableView.estimatedSectionHeaderHeight=0;
        _homeworkTableView.estimatedSectionFooterHeight=0;
    }
    return _homeworkTableView;
}

#pragma mark 作业检查
-(NSMutableArray *)checkHomeworksArray{
    if (!_checkHomeworksArray) {
        _checkHomeworksArray  = [[NSMutableArray alloc] init];
    }
    return _checkHomeworksArray;
}

#pragma mark 作业辅导
-(NSMutableArray *)tutorialHomeworksArray{
    if (!_tutorialHomeworksArray) {
        _tutorialHomeworksArray  = [[NSMutableArray alloc] init];
    }
    return _tutorialHomeworksArray;
}

@end
