//
//  AnalyseAppReview.h
//  FindFree
//
//  Created by Zhiqiang on 7/16/14.
//  Copyright (c) 2014 Muling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyseAppReview : NSObject
{
    NSArray * _userNickNames;
    NSMutableString * _backString;
    NSMutableArray * _userReviewOK;
    NSMutableArray * _userReviewNoorBad;
    NSMutableData * mutableData;
    NSString * _appID;
    NSString * _country;
}
@property (retain)NSArray * userNickNames;
@property (retain)NSMutableArray * userReviewOK;
@property (retain)NSMutableArray * userReviewNoorBad;
@property int currentPage;
-(id)initWithAppID:(NSString *)appID users:(NSArray*)users country:(NSString*)country;
@end
