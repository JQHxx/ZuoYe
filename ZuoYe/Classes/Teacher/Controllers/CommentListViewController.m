//
//  CommentListViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/18.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommentTableViewCell.h"
#import "CommentModel.h"

@interface CommentListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *commentTableView;
@property (nonatomic, strong) NSMutableArray  *commentArray;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"评论";
    
    [self.view addSubview:self.commentTableView];
    
    [self loadCommentData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CommentTableViewCell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CommentModel *model = self.commentArray[indexPath.row];
    cell.commentModel = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentModel *model = self.commentArray[indexPath.row];
    CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-50-20, CGFLOAT_MAX) withTextFont:kFontWithSize(14)].height;
    return commentH+70;
}


#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadCommentData{
    NSArray *names = @[@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小明老师",@"小美老师",@"张三老师",@"李四老师",@"王五老师",@"小明老师"];
    NSArray *comments = @[@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。",@"如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。如果你无法简洁的表达你的想法，那只说明你还不够了解它。"];
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<names.count; i++) {
        CommentModel *model = [[CommentModel alloc] init];
        model.head_image = @"ic_m_head";
        model.name = names[i];
        model.score = (double)(i+5)*0.5;
        model.create_time = [NSString stringWithFormat:@"2018-08-%ld %02ld:%02ld",i+12,i*3,i*5+3];
        model.comment = comments[i];
        [tempArr addObject:model];
    }
    self.commentArray = tempArr;
    [self.commentTableView reloadData];
}


#pragma mark -- getters and setters
#pragma mark 评论列表
-(UITableView *)commentTableView{
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [[UIView alloc] init];
    }
    return _commentTableView;
}

-(NSMutableArray *)commentArray{
    if (!_commentArray) {
        _commentArray = [[NSMutableArray alloc] init];
    }
    return _commentArray;
}


@end
