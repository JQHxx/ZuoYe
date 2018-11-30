//
//  ZYHelper.m
//  ZuoYe
//
//  Created by vision on 2018/8/3.
//  Copyright © 2018年 vision. All rights reserved.
//

#import "ZYHelper.h"
#import "SBJSON.h"
#import <PhotosUI/PhotosUI.h>
#import "UIImage+Extend.h"

@implementation ZYHelper

singleton_implementation(ZYHelper)

#pragma mark 天
-(NSArray *)daysArray{
    return @[@"今天", @"明天"];
}

#pragma mark 小时
-(NSArray *)hoursArray{
    return @[@"0点", @"1点", @"2点", @"3点", @"4点", @"5点", @"6点", @"7点", @"8点", @"9点", @"10点", @"11点", @"12点", @"13点", @"14点", @"15点", @"16点", @"17点", @"18点", @"19点", @"20点", @"21点", @"22点", @"23点"];
}

#pragma mark 分钟
-(NSArray *)minutesArray{
    return @[@"0分", @"10分", @"20分", @"30分", @"40分", @"50分"];
}

#pragma mark 根据年级获取科目
-(NSArray *)getCourseForGrade:(NSString *)grade{
    NSArray *arr =nil;
    if ([grade isEqualToString:@"初一"]||[grade isEqualToString:@"初二"]||[grade isEqualToString:@"初三"]) {
        arr = self.subjects;
    }else{
        arr = @[@"语文",@"数学",@"英语"];
    }
    return arr;
}

#pragma mark 获取年级
-(NSArray *)grades{
    NSString *fliePath = [self getFilePathWithFileName:@"grade"];
    NSArray *myGrades = [NSArray arrayWithContentsOfFile:fliePath];
    return myGrades.count>0?myGrades:@[@"一年级",@"二年级",@"三年级",@"四年级",@"五年级",@"六年级",@"初一",@"初二",@"初三"];
}

#pragma mark 设置年级
-(void)setGrades:(NSArray *)grades{
    if (grades.count>0) {
        NSString *filepath = [self getFilePathWithFileName:@"grade"];
        NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in grades) {
            [tempArr addObject:dict[@"grade"]];
        }
        [tempArr writeToFile:filepath atomically:YES];
    }
}

#pragma mark 解析年级
-(NSString *)parseToGradeStringForGrades:(NSArray *)gradesArr{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];
    NSArray *sortedArray = [gradesArr sortedArrayUsingDescriptors:descriptors];
    
    if ([sortedArray containsObject:@"初一"]||[sortedArray containsObject:@"初二"]||[sortedArray containsObject:@"初三"]) {
        return [sortedArray componentsJoinedByString:@"/"];
    }else{
        NSString *grade = @"";
        for (NSString *gradeStr in sortedArray) {
            grade =[grade stringByAppendingString:[gradeStr substringToIndex:1]];
            grade = [grade stringByAppendingString:@"/"];
        }
        NSString *tempStr = [grade substringToIndex:grade.length-1];
        return [tempStr stringByAppendingString:@"年级"];
    }
}

#pragma mark 获取年级
-(NSArray *)subjects{
    NSString *fliePath = [self getFilePathWithFileName:@"subject"];
    NSArray *mySujects = [NSArray arrayWithContentsOfFile:fliePath];
    return mySujects.count>0?mySujects:@[@"语文",@"数学",@"英语",@"物理",@"化学",@"生物",@"历史",@"地理",@"道德与法治"];
}

#pragma mark 设置年级
-(void)setSubjects:(NSArray *)subjects{
    NSString *filepath = [self getFilePathWithFileName:@"subject"];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in subjects) {
        [tempArr addObject:dict[@"subject"]];
    }
    [tempArr writeToFile:filepath atomically:YES];
}


#pragma mark 时间戳转化为时间
- (NSString *)timeWithTimeIntervalNumber:(NSNumber *)timeNum format:(NSString *)format{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeNum integerValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

#pragma mark 将某个时间转化成 时间戳
-(NSNumber *)timeSwitchTimestamp:(NSString *)formatTime format:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime];    //将字符串按formatter转成nsdate
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

#pragma mark --其他数据转json数据
-(NSString *)getValueWithParams:(id)params{
    SBJsonWriter *writer=[[SBJsonWriter alloc] init];
    NSString *value=[writer stringWithObject:params];
    MyLog(@"value:%@",value);
    return value;
}

#pragma mark 对图片base64加密
- (NSMutableArray *)imageDataProcessingWithImgArray:(NSMutableArray *)imgArray{
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSInteger i = 0; i < imgArray.count; i++) {
        NSData *imageData = [UIImage zipNSDataWithImage:imgArray[i]];
//        NSData *imageData = UIImagePNGRepresentation(imgArray[i]);
        //将图片数据转化为64为加密字符串
        NSString *encodeResult = [imageData base64EncodedStringWithOptions:0];
        [photoArray addObject:encodeResult];
    }
    return photoArray;
}

#pragma mark 获取视频第一帧
-(UIImage *)getVideoPreViewImageWithUrl:(NSURL *)videoUrl{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark -- Private methods
#pragma mark  获取年级目录
-(NSString *)getFilePathWithFileName:(NSString *)fileName{
    //获取plist文件的路径
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    return [path1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
}

@end
