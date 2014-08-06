//
//  AppDelegate.m
//  CheckReview
//
//  Created by Zhiqiang on 7/21/14.
//  Copyright (c) 2014 Muling. All rights reserved.
//

#import "AppDelegate.h"
#import "TestCode.h"
#import "AnalyseAppReview.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //TestCode *a = [[TestCode alloc] init];
}
-(id)init{
    if (self=[super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserReviewEnd:) name:NotiCheckUserReviewEnd object:nil];
        result = [NSMutableArray array];
        //        NSArray * arr = [[FWQDateSource sharedManager] fwqAllReviewAppInfo];
        //        NSLog(@"%@",arr);
        userInfos = [[FWQDateSource sharedManager] fwqGetAppTaskUsers:@"364709193"].copy;
        NSMutableArray * nickNames = [[NSMutableArray alloc] initWithCapacity:userInfos.count];
        for (NSDictionary * dic in userInfos) {
            [nickNames addObject:dic[@"<user_nickname>"]];
        }
        AnalyseAppReview * aa = [[AnalyseAppReview alloc] initWithAppID:@"364709193" users:nickNames country:nil];
        NSLog(@"%@",aa);
        /*
         for (NSDictionary * dic in arr) {
         if (dic.allKeys.count==0) continue;
         //            if (![dic[@"<a_status>"] isEqualToString:@"2"]) continue;
         NSString * productID = dic[@"<a_id>"];
         NSLog(@"productID%@",productID);
         userInfos = [[FWQDateSource sharedManager] fwqGetAppTaskUsers:@"364709193"].copy;
         NSMutableArray * nickNames = [[NSMutableArray alloc] initWithCapacity:userInfos.count];
         for (NSDictionary * dic in userInfos) {
         [nickNames addObject:dic[@"<user_nickname>"]];
         }
         AnalyseAppReview * aa = [[AnalyseAppReview alloc] initWithAppID:productID users:nickNames country:nil];
         }
         */
        //取得状态为2时的产品，取到这些产品的用户昵称
        
        
    }
    return self;
}

-(void)checkUserReviewEnd:(NSNotification *)notification {
    NSDictionary * dic = [notification userInfo];
    NSArray * backArr = dic[@"NotiKey"];
    NSArray * good = [backArr objectAtIndex:1];
    if ([good.firstObject isEqualToString:@"NULL"]) {
        good = nil;
    }
    NSArray * bad = backArr.lastObject;
    if ([bad.firstObject isEqualToString:@"NULL"]) {
        bad = nil;
    }
    NSString *appID = backArr.firstObject;
    
    for (NSString * nickName in good) {
        NSString * userId = @"";
        for (NSDictionary * dic in userInfos) {
            if ([dic[@"<user_nickname>"] isEqualToString:nickName]) {
                userId = dic[@"<user_id>"];
                break;
            }
        }
        BOOL updateBack = [[FWQDateSource sharedManager] updateUser:userId ReviewStatus:0 withAppID:appID];
        NSLog(@"updateBack%u",updateBack);
    }
    for (NSString * nickName in bad) {
        NSString * userId = @"";
        for (NSDictionary * dic in userInfos) {
            if ([dic[@"<user_nickname>"] isEqualToString:nickName]) {
                userId = dic[@"<user_id>"];
                break;
            }
        }
        BOOL updateBack = [[FWQDateSource sharedManager] updateUser:userId ReviewStatus:2 withAppID:appID];
        NSLog(@"updateBack%u",updateBack);
    }
    //    [self notiGetEventSignInOK:nil];//update user data
    //    [self performSelectorOnMainThread:@selector(notiGetEventSignInOK:) withObject:nil waitUntilDone:NO];
}
@end
