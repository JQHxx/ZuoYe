//
//  MyTutorialViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/8.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MyTutorialViewController.h"

#import "MyTutorialTableViewCell.h"

@interface MyTutorialViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView      *tutorialTableView;
@property (nonatomic, strong) NSMutableArray   *tutorialArray;

@end

@implementation MyTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"我的辅导";
    
    [self.view addSubview:self.tutorialTableView];
    
    
    
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.tutorialArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"MyTutorialTableViewCell";
    MyTutorialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[MyTutorialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadMyTutorialData{
    
}

#pragma mark -- getters
#pragma mark  辅导列表
-(UITableView *)tutorialTableView{
    if (!_tutorialTableView) {
        _tutorialTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStyleGrouped];
        _tutorialTableView.delegate = self;
        _tutorialTableView.dataSource = self;
    }
    return _tutorialTableView;
}

#pragma mark 我的辅导信息
-(NSMutableArray *)tutorialArray{
    if (!_tutorialArray) {
        _tutorialArray = [[NSMutableArray alloc] init];
    }
    return _tutorialArray;
}



@end
