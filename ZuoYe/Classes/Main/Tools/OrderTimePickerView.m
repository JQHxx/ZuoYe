//
//  OrderTimePickerView.m
//  ZuoYe
//
//  Created by vision on 2018/8/10.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "OrderTimePickerView.h"
#import "NSDate+Extension.h"


@interface OrderTimePickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *showDayArray;
@property (nonatomic, strong) NSArray *hourArray;
@property (nonatomic, strong) NSArray *minuteArray;

@property (nonatomic, strong) NSMutableArray  *selHoursArray;
@property (nonatomic, strong) NSMutableArray  *selMinutesArray;

@property (nonatomic, strong) UIPickerView  *timePickerView;

@property (nonatomic,  copy ) NSString *myTitle;

@property (nonatomic, copy) OrderTimeResultBlock resultBlock;

@end

@implementation OrderTimePickerView



#pragma mark -- UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0) {
        return self.showDayArray.count;
    }else if (component==1){
        return self.selHoursArray.count;
    }else{
        return self.selMinutesArray.count;
    }
}

#pragma mark -- UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label;
    if (view) {
        label = (UILabel *)view;
    }else{
        label = [[UILabel alloc] init];
    }
    label.textAlignment = NSTextAlignmentCenter;
    if (component==0) {
        label.text = self.showDayArray[row];
    }else if (component==1){
        label.text = self.selHoursArray[row];
    }else{
        label.text = self.selMinutesArray[row];
    }
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger firstComponentSelectedRow = [self.timePickerView selectedRowInComponent:0];
    if (firstComponentSelectedRow == 0) {
        self.selHoursArray = [NSMutableArray arrayWithArray:[self validHourArray]];
        NSInteger secondComponentSelectedRow = [self.timePickerView selectedRowInComponent:1];
        if (secondComponentSelectedRow == 0 || component == 0) {
            self.selMinutesArray = [NSMutableArray arrayWithArray:[self validMinuteArray]];
        }else{
            self.selMinutesArray =[NSMutableArray arrayWithArray: [ZYHelper sharedZYHelper].minutesArray];
        }
    }else{
        NSInteger hourLen = 24 - self.hourArray.count;
        NSArray *allHoursArr = [ZYHelper sharedZYHelper].hoursArray;
        self.selHoursArray = [NSMutableArray arrayWithArray:[allHoursArr subarrayWithRange:NSMakeRange(0, hourLen+1)]];
        
        NSInteger minuteLen = 6 - self.minuteArray.count;
        NSArray *allMinutesArr = [ZYHelper sharedZYHelper].minutesArray;
        
        NSInteger secondComponentSelectedRow = [self.timePickerView selectedRowInComponent:1];
        if (secondComponentSelectedRow == self.selHoursArray.count - 1) {
            self.selMinutesArray = [NSMutableArray arrayWithArray: [allMinutesArr subarrayWithRange:NSMakeRange(0, minuteLen)]];
        }else{
            self.selMinutesArray = [NSMutableArray arrayWithArray: allMinutesArr];
        }
    }
    [self.timePickerView reloadAllComponents];
    
    //当第一列滑到第一个位置时，第二，三列滚回到0位置
    if (component == 0) {
        [self.timePickerView selectRow:0 inComponent:1 animated:YES];
        [self.timePickerView selectRow:0 inComponent:2 animated:YES];
    }
}


-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.width/3.0;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 44;
}

#pragma mark -- Public Methods
+(void)showOrderTimePickerWithTitle:(NSString *)title defaultTime:(NSDictionary *)defaultTimeDic resultBlock:(OrderTimeResultBlock)resultBlock{
    OrderTimePickerView *timePickerView = [[OrderTimePickerView alloc] initWithTitle:title resultBlock:resultBlock];
    [timePickerView showWithAnimation:YES];
}

#pragma mark  弹出视图方法
- (void)showWithAnimation:(BOOL)animation {
    //1. 获取当前应用的主窗口
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    if (animation) {
        // 动画前初始位置
        CGRect rect = self.alertView.frame;
        rect.origin.y = SCREEN_HEIGHT;
        self.alertView.frame = rect;
        
        // 浮现动画
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.alertView.frame;
            rect.origin.y -= kDatePicHeight + kTopViewHeight;
            self.alertView.frame = rect;
        }];
    }
}

#pragma mark - 关闭视图方法
- (void)dismissWithAnimation:(BOOL)animation {
    // 关闭动画
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.alertView.frame;
        rect.origin.y += kDatePicHeight + kTopViewHeight;
        self.alertView.frame = rect;
        
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.leftBtn removeFromSuperview];
        [self.rightBtn removeFromSuperview];
        [self.titleLabel removeFromSuperview];
        [self.lineView removeFromSuperview];
        [self.topView removeFromSuperview];
        [self.timePickerView removeFromSuperview];
        [self.alertView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
        
        self.leftBtn = nil;
        self.rightBtn = nil;
        self.titleLabel = nil;
        self.lineView = nil;
        self.topView = nil;
        self.timePickerView = nil;
        self.alertView = nil;
        self.backgroundView = nil;
    }];
}

#pragma mark 点击空白处
-(void)didTapBackgroundView:(UITapGestureRecognizer *)sender{
    [self dismissWithAnimation:YES];
}

#pragma mark - 取消按钮的点击事件
- (void)clickLeftBtn {
    [self dismissWithAnimation:YES];
}

#pragma mark - 确定按钮的点击事件
- (void)clickRightBtn {
    [self dismissWithAnimation:YES];
    if (self.resultBlock) {
        NSInteger firstIndex = [self.timePickerView selectedRowInComponent:0];
        NSInteger secondIndex = [self.timePickerView selectedRowInComponent:1];
        NSInteger thirdIndex = [self.timePickerView selectedRowInComponent:2];
        
        NSString *dayStr = self.showDayArray[firstIndex];
        NSString *hourStr = self.selHoursArray[secondIndex];
        NSString *minuteStr  = self.selMinutesArray[thirdIndex];
        
        self.resultBlock(dayStr,hourStr,minuteStr);
    }
    
}

#pragma mark -- Private methods
#pragma mark - 初始化自定义字符串选择器
- (instancetype)initWithTitle:(NSString *)title resultBlock:(OrderTimeResultBlock)resultBlock {
    if (self = [super init]) {
        self.myTitle = title;
        self.resultBlock = resultBlock;
        
        self.showDayArray = [self genShowDayArray];
        self.hourArray = [self validHourArray];
        self.minuteArray = [self validMinuteArray];
        
        self.selHoursArray = [NSMutableArray arrayWithArray:self.hourArray];
        self.selMinutesArray = [NSMutableArray arrayWithArray:self.minuteArray];
        
        [self initUI];
    }
    return self;
}

#pragma mark 初始化子试图
-(void)initUI{
    [super initUI];
    
    self.titleLabel.text = self.myTitle;
    
    [self.alertView addSubview:self.timePickerView];
}

#pragma mark 天
-(NSArray *)genShowDayArray{
    return @[@"今天",@"明天"];
}

#pragma mark 小时
-(NSArray *)validHourArray{
    NSDate *currentDate = [NSDate date];
    NSInteger currentHour = [[NSDate getHourFromDate:currentDate] integerValue];
    NSInteger currentMinute = [[NSDate getMinuteFromDate:currentDate] integerValue];
    
    if (currentMinute >=35) currentHour++;
    NSArray *allHourArray = [ZYHelper sharedZYHelper].hoursArray;
    return [allHourArray subarrayWithRange:NSMakeRange(currentHour, allHourArray.count - currentHour)];
}

#pragma mark 分钟
-(NSArray *)validMinuteArray{
    NSDate *currentDate = [NSDate date];
    NSInteger currentMinute = [[NSDate getMinuteFromDate:currentDate] integerValue];
    
    NSInteger startIndex =(NSInteger)(currentMinute/ 10.0 +2.5);
    if (currentMinute >= 35) startIndex = 0;
    if (currentMinute >= 45) startIndex = 1;
    if (currentMinute >= 55) startIndex = 2;
    NSArray *allMinuteArray = [ZYHelper sharedZYHelper].minutesArray;
    return [allMinuteArray subarrayWithRange:NSMakeRange(startIndex, allMinuteArray.count - startIndex)];
}



#pragma mark -- Getters
#pragma mark    选择器
-(UIPickerView *)timePickerView{
    if (!_timePickerView) {
        _timePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kTopViewHeight + 0.5, SCREEN_WIDTH, kDatePicHeight)];
        _timePickerView.backgroundColor = [UIColor whiteColor];
        _timePickerView.dataSource = self;
        _timePickerView.delegate = self;
    }
    return _timePickerView;
}



@end
