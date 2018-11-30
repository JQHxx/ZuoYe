//
//  CheckReleaseViewController.m
//  ZuoYe
//
//  Created by vision on 2018/9/12.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "CheckReleaseViewController.h"
#import "STPopupController.h"
#import "UIViewController+STPopup.h"
#import "CheckPriceView.h"
#import "DemandTableViewCell.h"
#import "SetValueModel.h"
#import "BRStringPickerView.h"
#import "NSDate+Extension.h"
#import "RechargeViewController.h"

@interface CheckReleaseViewController ()<UITableViewDelegate ,UITableViewDataSource>{
    NSString         *gradeStr;         //年级
    NSString         *courseStr;        //科目
    NSMutableArray   *coursesArr;
    
    NSArray        *gradesArr;
    double         checkprice;
}

@property (nonatomic, strong) UIButton          *cancelButton;       //关闭按钮
@property (nonatomic, strong) UILabel           *titleLabel;        //标题
@property (nonatomic, strong) UIButton          *confirmButton;     //确定

@property (nonatomic, strong) UITableView       *demandTableView;
@property (nonatomic, strong) CheckPriceView    *checkPriceView;    //检查价格

@property (nonatomic ,strong) NSMutableArray   *myValuesArray;

@end

@implementation CheckReleaseViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        CGFloat h = 290;
        self.contentSizeInPopup = CGSizeMake(kScreenWidth, h);
        self.landscapeContentSizeInPopup = CGSizeMake(kScreenHeight, h);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
    self.view.topBoderRadius = 10.0;
    
    gradesArr = [ZYHelper sharedZYHelper].grades;
    coursesArr = [[NSMutableArray alloc] init];
    
    checkprice = 10.0;
    
    [self initCheckReleaseView];
    [self loadData];
}

#pragma mark -- UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<2) {
        DemandTableViewCell *cell = [[DemandTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        SetValueModel *model = self.myValuesArray[indexPath.row];
        cell.valueModel = model;
        return cell;
    }else{
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.checkPriceView];
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
        return 110;
    }else{
        return 44;
    }
}

#pragma mark -- UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     if (indexPath.row==0) {  //选择年级
        NSArray *grades = @[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
        kSelfWeak;
        [BRStringPickerView showStringPickerWithTitle:@"选择年级" dataSource:grades defaultSelValue:gradeStr isAutoSelect:NO resultBlock:^(id selectValue) {
            gradeStr = selectValue;
            coursesArr = [NSMutableArray arrayWithArray:[[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr]];
            
            for (SetValueModel *model in self.myValuesArray) {
                if (model.value_id==0) {
                    model.value = selectValue;
                    model.isSet = YES;
                }
            }
            [weakSelf.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else if (indexPath.row==1){
        kSelfWeak;
        [BRStringPickerView showStringPickerWithTitle:@"选择科目" dataSource:coursesArr defaultSelValue:courseStr isAutoSelect:NO resultBlock:^(id selectValue) {
            courseStr = selectValue;
            for (SetValueModel *model in self.myValuesArray) {
                if (model.value_id==1) {
                    model.value = selectValue;
                    model.isSet = YES;
                }
            }
            [weakSelf.demandTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    
}

#pragma mark -- Event Response
#pragma mark 取消发布
-(void)cancelReleaseAction{
    if(self.popupController){
        [self.popupController dismiss];
    }
}

#pragma mark 发布
-(void)confirmReleaseCheckAction{
    [self.view endEditing:YES];
    
   __block double myCredit = [[NSUserDefaultsInfos getValueforKey:kUserCredit] doubleValue];
    if (myCredit<checkprice) {
        [self.view makeToast:@"可用额度不足，请充值后发布作业" duration:1.5 position:CSToastPositionCenter];
    }else{
        if (kIsEmptyString(courseStr)) {
            [self.view makeToast:@"请先选择科目" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        
        if (checkprice<0.01) {
            [self.view makeToast:@"检查价格不能为0" duration:1.0 position:CSToastPositionCenter];
            return;
        }
        
        //年级
        NSInteger gradeInt = [gradesArr indexOfObject:gradeStr]+1;
        //科目
        NSArray *subjects = [ZYHelper sharedZYHelper].subjects;
        NSInteger subjectInt = [subjects indexOfObject:courseStr]+1;
        
        kSelfWeak;
        NSString *imageArrJsonStr = [TCHttpRequest getValueWithParams:self.photosArray];
        NSString *body = [NSString stringWithFormat:@"pic=%@&dir=2",imageArrJsonStr];
        [TCHttpRequest postMethodWithURL:kUploadPicAPI body:body success:^(id json) {
            NSArray *imagesUrl = [json objectForKey:@"data"];
            NSString * imgJsonStr = [TCHttpRequest getValueWithParams:imagesUrl];
            NSString *body2 = [NSString stringWithFormat:@"token=%@&images=%@&label=1&grade=%ld&subject=%ld&price=%.2f",kUserTokenValue,imgJsonStr,gradeInt,subjectInt,checkprice];
            [TCHttpRequest postMethodWithURL:kJobPublishAPI body:body2 success:^(id json) {
                NSInteger status=[[json objectForKey:@"error"] integerValue];
                NSString *message=[json objectForKey:@"msg"];
                if (status==3) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:message duration:1.0 position:CSToastPositionCenter];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if(weakSelf.popupController){
                            [weakSelf.popupController dismiss];
                        }
                        weakSelf.backBlock([NSNumber numberWithBool:NO]);
                    });
                    
                }else{
                    [ZYHelper sharedZYHelper].isUpdateHome = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view makeToast:@"作业检查发布成功" duration:1.0 position:CSToastPositionCenter];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if(weakSelf.popupController){
                            [weakSelf.popupController dismiss];
                        }
                        weakSelf.backBlock([NSNumber numberWithBool:YES]);
                    });
                }
            }];
        }];
    }
    
    
}


#pragma mark -- Private methods
#pragma mark 初始化
-(void)initCheckReleaseView{
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.confirmButton];
    
    UILabel *lineLbl = [[UILabel alloc] initWithFrame:CGRectMake(0,45.0,kScreenWidth, 0.5)];
    lineLbl.backgroundColor = [UIColor colorWithHexString:@"#D8D8D8"];
    [self.view addSubview:lineLbl];
    
    [self.view addSubview:self.demandTableView];
}

#pragma mark -- Private methods
#pragma mark 加载数据
-(void)loadData{
    NSString *grade = [NSUserDefaultsInfos getValueforKey:kUserGrade];
    gradeStr = kIsEmptyString(grade)?@"一年级": grade;
    
    NSArray *courses = [[ZYHelper sharedZYHelper] getCourseForGrade:gradeStr];
    coursesArr = [NSMutableArray arrayWithArray:courses];
    courseStr = nil;
    
    NSArray *images = @[@"release_grade",@"release_subject"];
    NSArray *titles = @[gradeStr,@"请选择科目"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<images.count; i++) {
        SetValueModel *model = [[SetValueModel alloc] init];
        model.value_id = i;
        model.imgName = images[i];
        model.isSet = YES;
        model.value = titles[i];
        [tempArr addObject:model];
    }
    self.myValuesArray = tempArr;
    [self.demandTableView reloadData];
}

#pragma mark -- getters and setters
#pragma mark 标题
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 12, kScreenWidth-200, 22)];
        _titleLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleMedium size:16];
        _titleLabel.text = @"作业检查";
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
        [_cancelButton addTarget:self action:@selector(cancelReleaseAction) forControlEvents:UIControlEventTouchUpInside];
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
        [_confirmButton addTarget:self action:@selector(confirmReleaseCheckAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

#pragma mark 需求列表
-(UITableView *)demandTableView{
    if (!_demandTableView) {
        _demandTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45.5, kScreenWidth, 245.0) style:UITableViewStylePlain];
        _demandTableView.dataSource = self;
        _demandTableView.delegate = self;
        _demandTableView.tableFooterView = [[UIView alloc] init];
        _demandTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _demandTableView;
}

#pragma mark 检查价格
-(CheckPriceView *)checkPriceView{
    if (!_checkPriceView) {
        _checkPriceView = [[CheckPriceView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 110)];
        _checkPriceView.getPriceBlock = ^(double aPrice) {
            checkprice = aPrice;
        };
    }
    return _checkPriceView;
}

#pragma mark
-(NSMutableArray *)myValuesArray{
    if (!_myValuesArray) {
        _myValuesArray = [[NSMutableArray alloc] init];
    }
    return _myValuesArray;
}

@end
