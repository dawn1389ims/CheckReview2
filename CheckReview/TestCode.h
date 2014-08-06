//
//  TestCode.h
//  TestFindFreeClass
//
//  Created by Zhiqiang on 7/18/14.
//  Copyright (c) 2014 Muling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCode : NSObject
-(id)init;
@end
@interface ToolClassTest : NSObject
+(NSDate *)getDateFromStr:(NSString *)dateStr dateFormat:(NSString *)dateTimeFormat;
+(NSString *) get_ADateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat;
+(NSString *)get_BDateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat;
+(NSDate*)currentLocalDate;
+(NSString*)currentDateStr;
+(NSString*)convertLocalDateStrFrom:(NSString*)dateStr;
@end