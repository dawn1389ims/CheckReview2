//
//  GolbalKey.h
//  FindFree
//
//  Created by Zhiqiang on 14-7-4.
//  Copyright (c) 2014年 Muling. All rights reserved.
//

#ifndef FindFree_GolbalKey_h
#define FindFree_GolbalKey_h

#define NotifFWQCallBack @"NotifFWQCallBack"
enum {
    ActionCatg,
    ArcadeCatg,
    EducationCatg,
};
enum{
    CCFWQ_ALL_APP = 1,
    CCFWQ_USER_GET_A_REVIEW,
    CCFWQ_USER_ALL_REVIEW,
    CCFWQ_USER_ACCOUNT_INFO,
    
    //721
    CCFWQ_ALL_APP_TASK_USER,
//    CCFWQ_ALL_
};
extern NSString *const FFEntityPropertyNamedApp;
extern NSString *const FFEntityPropertyIconImage;

#define DLGCheckScanner 0
#define DLGCheckTableView 0
#define DLGCheckStartedTableView 1
#define DLGCheckFWQData 0
#define DLGAnalyseCss 1
#define NotiSignInOK @"EventSignInOK"
#define NotiReviewOK @"EventReviewOK"
#define NotiOpenSignIn @"OpenSignInView"
#define NotiCheckUserReviewEnd @"CheckUserReviewEnd"
#define NotiAdvertViewChoice @"AdvertViewChoice"
#define BIG_IMAGE_WEIGHT 500.0//446.0
#define BIG_IMAGE_HEIGHT 263.0//263.0
#define FWQDateStringFormat @"yyyy-MM-dd HH:mm:ss"
#define FWQReviewDateStrFormat @"yyyy-MM-dd"
#define FWQRebackDay 3
#define UDKeyRegisterLimit @"UserRegisterLimit"
#define CheckReviewSmallRate 1

#endif
