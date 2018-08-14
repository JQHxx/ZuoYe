//
//  MessagesViewController.m
//  ZuoYe
//
//  Created by vision on 2018/8/13.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "MessagesViewController.h"
#import "ConversationTableViewCell.h"
#import "SystemNewsModel.h"

@interface MessagesViewController ()<UITableViewDelegate,UITableViewDataSource>{
    
    SystemNewsModel   *systemNewsModel;
}

@property (nonatomic,strong) UITableView     *messagesTableView;
@property (nonatomic,strong) NSMutableArray  *conservationsArray;

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"消息";
    
    systemNewsModel = [[SystemNewsModel alloc] init];
    systemNewsModel.isRead = NO;
    systemNewsModel.title = @"充值活动满100送10";
    systemNewsModel.send_time = @"今天 16:00";
    
    [self.view addSubview:self.messagesTableView];
}

#pragma mark -- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0?1:self.conservationsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"ConversationTableViewCell";
    ConversationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    id model;
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            model=systemNewsModel;
        }
    }else{
        model=self.conservationsArray[indexPath.row];
    }
    [cell conversationCellDisplayWithModel:model];
    
    return cell;
}

#pragma mark -- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==1&&self.conservationsArray.count>0) {
        return 40;
    }else{
        return 0.1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1&&self.conservationsArray.count>0) {
        return @"我的老师";
    }else{
        return @"";
    }
}

#pragma mark -- 消息列表视图
-(UITableView *)messagesTableView{
    if (!_messagesTableView) {
        _messagesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavHeight, kScreenWidth, kScreenHeight-kNavHeight) style:UITableViewStylePlain];
        _messagesTableView.dataSource = self;
        _messagesTableView.delegate = self;
        _messagesTableView.tableFooterView = [[UIView alloc] init];
        _messagesTableView.backgroundColor = [UIColor bgColor_Gray];
    }
    return _messagesTableView;
}

#pragma mark 会话列表
-(NSMutableArray *)conservationsArray{
    if (!_conservationsArray) {
        _conservationsArray = [[NSMutableArray alloc] init];
    }
    return _conservationsArray;
}

@end
