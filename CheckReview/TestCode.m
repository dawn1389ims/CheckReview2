//
//  TestCode.m
//  TestFindFreeClass
//
//  Created by Zhiqiang on 7/18/14.
//  Copyright (c) 2014 Muling. All rights reserved.
//

#import "TestCode.h"
#define FWQDateStringFormat @"yyyy-MM-dd HH:mm:ss"
#define FWQReviewDateStrFormat @"yyyy-MM-dd"
@implementation TestCode
-(id)init{
    if (self=[super init]) {
        NSString *currentDate = [ToolClassTest get_ADateFormat:[NSDate date] dateFormat:FWQDateStringFormat];
        NSLog(@"currentDate:%@",currentDate);
        
        NSString * localDateStr = [ToolClassTest convertLocalDateStrFrom:currentDate];
        NSLog(@"localDateStr:%@",localDateStr);
        NSDate * b = [ToolClassTest getDateFromStr:currentDate dateFormat:FWQDateStringFormat];
        NSLog(@"current local Date:%@",b);
        NSDate *now = [NSDate date];
        NSLog(@"now:%@",now);
        NSTimeInterval goTime = [now timeIntervalSinceDate:b];
        NSLog(@"go :%f",goTime);
    }
    return self;
}
@end
@implementation ToolClassTest

+(NSDate *)getDateFromStr:(NSString *)dateStr dateFormat:(NSString *)dateTimeFormat{
    NSDate * aDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:dateTimeFormat];
    NSRange range = NSMakeRange(0,[dateStr length]);
    NSDate *readDate;
    NSError *error;
    [dateFormatter getObjectValue:&readDate forString:dateStr range:&range error:&error];
    //    [dateFormatter release];
    aDate = readDate.copy;
    return aDate;
}

+(NSString *) get_ADateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    //@"yy/MM/dd HH:MM"
    //@"yyyy-MM-dd"
    [dateFormat setDateFormat:dateTimeFormat];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    [dateFormat setTimeZone:timeZone];
    NSString *dTime = [dateFormat stringFromDate:date];
    return dTime;
}
+(NSString *)get_BDateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate = [date  dateByAddingTimeInterval: interval];//根据时区转换，计算正确的当前时间
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:dateTimeFormat];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];//BUG solu!
    [dateFormat setTimeZone:timeZone];
    NSString *dTime = [dateFormat stringFromDate:localDate];
    return dTime;
}
+(NSDate*)currentLocalDate{
    /*
     + (instancetype)dateWithTimeInterval:(NSTimeInterval)seconds sinceDate:(NSDate *)date
     */
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: [NSDate date]];
    NSDate *localDate = [[NSDate date]  dateByAddingTimeInterval: interval];
    // 打印结果 正确当前时间 localDate = 2013-08-16 17:01:04 +0000
    NSLog(@"localDate = %@",localDate);
    return localDate;
}
//时区问题
+(NSString*)currentDateStr{
    NSDate* cc=[ToolClassTest currentLocalDate];
    NSString *aa = [ToolClassTest get_ADateFormat:cc dateFormat:FWQDateStringFormat];
    NSLog(@"current date:%@",aa);
    return aa;
}
+(NSString*)convertLocalDateStrFrom:(NSString*)dateStr{
    NSDate* date = [ToolClassTest getDateFromStrNoTimeZone:dateStr dateFormat:FWQDateStringFormat];
    NSString * str = [ToolClassTest get_BDateFormat:date dateFormat:FWQDateStringFormat];
    return str;
}
//默认用的是sTZ
+(NSDate *)getDateFromStrNoTimeZone:(NSString *)dateStr dateFormat:(NSString *)dateTimeFormat{
    NSDate * aDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:dateTimeFormat];
    NSLog(@"default time zone:%@",dateFormatter.timeZone);
    NSRange range = NSMakeRange(0,[dateStr length]);
    NSDate *readDate;
    NSError *error;
    [dateFormatter getObjectValue:&readDate forString:dateStr range:&range error:&error];
    //    [dateFormatter release];
    aDate = readDate.copy;
    return aDate;
}
@end