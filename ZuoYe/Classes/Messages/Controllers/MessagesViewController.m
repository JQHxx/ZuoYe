//
//  MessagesViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageModel.h"
#import "MessageTableViewCell.h"
#import "SystemNewsViewController.h"
#import "MessagesListViewController.h"

@interface MessagesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView      *messagesTableView;
@property (nonatomic,strong) NSMutableArray   *messagesArr;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"消息";
    self.view.backgroundColor = [UIColor bgColor_Gray];
    
    [self.view addSubview:self.messagesTableView];
    [self loadMessageData];
}

#pragma mark
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZYHelper sharedZYHelper].isUpdateMessageInfo) {
        [self loadMessageData];
        [ZYHelper sharedZYHelper].isUpdateMessageInfo = NO;
    }
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagesArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"MessageTableViewCell";
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    MessageModel *model = self.messagesArr[indexPath.row];
    [cell messageCellDisplayWithMessage:model messageType:indexPath.row];
    return cell;
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row==0) {
        SystemNewsViewController *systemNewsVC = [[SystemNewsViewController alloc] init];
        [self.navigationController pushViewController:systemNewsVC animated:YES];
    }else{
        MessagesListViewController *messageListVC = [[MessagesListViewController alloc] init];
        [self.navigationController pushViewController:messageListVC animated:YES];
    }
    
}


#pragma mark -- Private Methods
#pragma mark 加载数据
-(void)loadMessageData{
    kSelfWeak;
    NSString *body = [NSString stringWithFormat:@"token=%@",kUserTokenValue];
    [TCHttpRequest postMethodWithoutLoadingForURL:kMessageLastAPI body:body success:^(id json) {
        NSDictionary *data = [json objectForKey:@"data"];
        
        NSMutableArray *tempMessageArr = [[NSMutableArray alloc] init];
        //系统消息
        NSDictionary *systemDict = [data valueForKey:@"sys"];
        MessageModel *systemModel = [[MessageModel alloc] init];
        [systemModel setValues:systemDict];
        systemModel.icon = @"news";
        systemModel.myTitle = @"系统消息";
        systemModel.desc = systemDict[@"desc"];
        [tempMessageArr addObject:systemModel];
        
        NSDictionary *checkDict = [data valueForKey:@"check"];
        MessageModel *checkModel = [[MessageModel alloc] init];
        [checkModel setValues:checkDict];
        checkModel.icon = @"news_home_inspect";
        checkModel.myTitle = @"作业检查";
        [tempMessageArr addObject:checkModel];
        weakSelf.messagesArr = tempMessageArr;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.messagesTableView reloadData];
        });
        
    }];
}


#pragma mark -- 消息列表视图
-(UITableView *)messagesTableView{
    if (!_messagesTableView) {
        _messagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,kNavHeight+5, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _messagesTableView.dataSource = self;
        _messagesTableView.delegate = self;
        _messagesTableView.tableFooterView = [[UIView alloc] init];
        _messagesTableView.backgroundColor = [UIColor bgColor_Gray];
        _messagesTableView.estimatedSectionFooterHeight = 0.0;
        _messagesTableView.estimatedSectionHeaderHeight = 0.0;
    }
    return _messagesTableView;
}

#pragma mark 消息
-(NSMutableArray *)messagesArr{
    if (!_messagesArr) {
        _messagesArr = [[NSMutableArray alloc] init];
    }
    return _messagesArr;
}

@end
