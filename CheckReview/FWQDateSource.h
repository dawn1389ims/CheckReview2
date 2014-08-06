//
//  FWQDateSource.h
//  FindFree
//
//  Created by Zhiqiang on 14-7-4.
//  Copyright (c) 2014年 Muling. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 访问FWQ，取得需要的数据：
 发送信息，响应操作：
 */
@interface FWQDateSource : NSObject
{
    NSArray *_allReviewApps;
    BOOL _isPassWordRight;
}
@property (retain) NSArray * allReviewApps;
@property BOOL isPassWordRight;
-(void)sendMessageRegister:(NSDictionary*)dic;
+ (FWQDateSource*)sharedManager;
-(NSArray *)fwqAllReviewAppInfo;
-(NSArray *)arrFromData:(NSString*)dataInfo mark:(int)markNum;
-(NSArray*)fwqSendTaskRequest:(NSString*)appId;
-(NSString*)removeDefaultUserReview:(NSString*)appID;
-(NSArray *)fwqGetUserReviewInfo:(NSString*)email;
-(NSString *)getUserId:(NSString *)str;
-(NSString *)getRece:(NSString *)str;
-(NSDictionary *)fwqSearchUserInfoByEmail:(NSString *)email;
-(NSArray*)fwqGetAppTaskUsers:(NSString*)appID;
-(BOOL)updateUser:(NSString *)userID ReviewStatus:(int)isOK withAppID:(NSString *)appID;
@end

@interface FFTaskEntity : NSObject <NSCoding,NSCopying>{
@private
    NSString *_appID;
    NSString *_userID;
    NSString *_beginDate;
    NSString *_timeduration;
    NSString *_status;
    NSImage *_iconImage;
    NSString *_name;
    NSArray *_category;
    NSString *_url;
    NSString *_reviewBack;
    NSString *_price;
}
@property(retain) NSString *appID;
@property(retain) NSString *userID;
@property(retain) NSString *beginDate;
@property(retain) NSString *timeduration;
@property(retain) NSString *status;
@property(retain) NSImage *iconImage;
@property(retain) NSString *name;
@property(retain) NSArray *category;
@property(retain) NSString *url;
@property(retain) NSString *reviewBack;
@property(retain) NSString *price;
@end

@interface FFUserEntity : NSObject {
@private
    NSString *_userID;
    NSString *_userEamil;
    NSString *_withDrawUsering;
    NSString *_payAccount;
    NSString *_userNickname;
    NSString *_referrer;
    NSString *_country;
    NSString *_password;
    NSString *_rank;
    NSMutableArray *_apps;
    NSDictionary *dicUser;
}
@property(retain) NSString *userID;
@property(retain) NSString *userEamil;
@property(retain) NSString *withDrawUsering;
@property(retain) NSString *payAccount;
@property(retain) NSString *userNickname;
@property(retain) NSString *referrer;
@property(retain) NSString *country;
@property(retain) NSString *password;
@property(retain) NSString *rank;
@property(retain) NSMutableArray *apps;
+ (FFUserEntity*)sharedManager;

@end

@interface FFAppEntity : NSObject <NSCoding,NSCopying>{
@private
    //ML FWQ Info
    NSString *_appID;
    NSString *_url;
    NSString *_serviceFee;
    NSString *_reviewBack;
    NSString *_timeDuration;
    NSString *_reviewCount;
    NSString *_status;
    NSMutableArray *_users;
    //APP Store Info
    NSImage *_snapShotImage;
    NSImage *_iconImage;
    NSString *_name;
    NSString *_price;
    NSArray *_category;
    NSString *_detail;
    NSString *_iconImageUrl;
    NSArray *_imageUrls;
    NSString * _device;
    
    NSMutableData * mutableData;
    
}
@property(retain) NSString *appID;
@property(retain) NSString *url;
@property(retain) NSString *serviceFee;
@property(retain) NSString *reviewBack;
@property(retain) NSString *timeDuration;
@property(retain) NSString *reviewCount;
@property(retain) NSString *status;
@property(retain) NSMutableArray *users;
@property(retain) NSImage  *snapShotImage;
@property(retain) NSImage  *iconImage;
@property(retain) NSString *name;
@property(retain) NSString *price;
@property(retain) NSArray *category;
@property(retain) NSString *detail;
@property(retain) NSString *iconImageUrl;
@property(retain) NSArray *imageUrls;
@property(retain) NSString *device;
@property BOOL imageLoading;
@property BOOL autoLoadIcon;
// Asynchronously loads the image (if not already loaded). A KVO notification is sent out when the image is loaded.
- (void)loadImage;
- (void)loadIconImage;
-(id)initWithAppID:(NSString *)appID;
+(NSString*)tranArrToStr:(NSArray*)arr;
@end
@interface ToolClass : NSObject
+(NSDate *)getDateFromStr:(NSString *)dateStr dateFormat:(NSString *)dateTimeFormat;
+(NSString *) get_ADateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat;
+(NSString *)get_BDateFormat:(NSDate *)date dateFormat:(NSString *)dateTimeFormat;
+(NSDate*)currentLocalDate;
+(NSString*)currentDateStr;
+(NSString*)convertLocalDateStrFrom:(NSString*)dateStr;
@end
