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
#import "MJRefresh.h"

@interface CommentListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSInteger page;
}

@property (nonatomic, strong) UITableView *commentTableView;
@property (nonatomic, strong) NSMutableArray  *commentArray;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"评论";
    
    self.view.backgroundColor = [UIColor bgColor_Gray];
    page = 1;
    
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
    CGFloat commentH=[model.comment boundingRectWithSize:CGSizeMake(kScreenWidth-97.0, CGFLOAT_MAX) withTextFont:[UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12]].height;
    return commentH+60;
}


#pragma mark -- Private methods
#pragma mark 加载最新评论信息
-(void)loadNewCommentListData{
    page=1;
    [self loadCommentData];
}

#pragma mark 加载更多评论信息
-(void)loadMoreCommentListData{
    page++;
    [self loadCommentData];
}

#pragma mark 加载数据
-(void)loadCommentData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@&tid=%@&page=%ld",kUserTokenValue,self.tch_id,page];
    [TCHttpRequest postMethodWithURL:kGetTeacherCommentsAPI body:body success:^(id json) {
        NSArray *data = [json objectForKey:@"data"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in data) {
            CommentModel *model = [[CommentModel alloc] init];
            [model setValues:dict];
            [tempArr addObject:model];
        }
        if (page==1) {
            weakSelf.commentArray = tempArr;
        }else{
            [weakSelf.commentArray addObjectsFromArray:tempArr];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.commentTableView.mj_footer.hidden = tempArr.count<20;
            [weakSelf.commentTableView reloadData];
            [weakSelf.commentTableView.mj_header endRefreshing];
            [weakSelf.commentTableView.mj_footer endRefreshing];
        });
    }];
}


#pragma mark -- getters and setters
#pragma mark 评论列表
-(UITableView *)commentTableView{
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight+3, kScreenWidth, kScreenHeight-kNavHeight-3) style:UITableViewStylePlain];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [[UIView alloc] init];
        
        //  下拉加载最新
        MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewCommentListData)];
        header.automaticallyChangeAlpha=YES;
        header.lastUpdatedTimeLabel.hidden=YES;
        _commentTableView.mj_header=header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCommentListData)];
        footer.automaticallyRefresh = NO;
        _commentTableView.mj_footer = footer;
        footer.hidden=YES;
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
