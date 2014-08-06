//
//  AnalyseAppReview.m
//  FindFree
//
//  Created by Zhiqiang on 7/16/14.
//  Copyright (c) 2014 Muling. All rights reserved.
//

#import "AnalyseAppReview.h"

@implementation AnalyseAppReview
@synthesize userNickNames = _userNickNames;
@synthesize userReviewOK = _userReviewOK;
@synthesize userReviewNoorBad = _userReviewNoorBad;
//访问多个网页取得产品信息时使用
-(id)initWithAppID:(NSString *)appID users:(NSArray*)users country:(NSString*)country
{
    if (self=[super init]) {
        self.userNickNames=users.copy;
        
        _appID = appID.copy;
        if (!country) _country = @"cn";else _country = country;
        self.userReviewOK=[NSMutableArray array];
        self.userReviewNoorBad=[NSMutableArray array];
        self.currentPage=1;
        [self beginRequsetCssURL:[self requestCSSPage:1]];
        mutableData=[NSMutableData dataWithCapacity:0];
        _backString =[[NSMutableString alloc] init];
    }
    return  self;
}
-(NSString *)requestCSSPage:(int)arg{
//    NSString * result = [NSString stringWithFormat:@"http://itunes.apple.com/rss/customerreviews/page=%d/id=%@/sortby=mostrecent/json?l=en&cc=%@",arg,_appID,_country];
//    return result;
    return @"http://itunes.apple.com/rss/customerreviews/page=1/id=364709193/sortby=mostrecent/json?l=en&cc=cn";
}
-(void)beginRequsetCssURL:(NSString*)urlStr{
    NSURL *aUrl = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [NSURLConnection connectionWithRequest:urlRequest delegate:self];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"1111");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
    //    NSLog(@"0--0%lu,%lu",(unsigned long)[mutableData length],data.length);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString * dataStr = [[NSString alloc]initWithData:mutableData encoding:NSUTF8StringEncoding];
    [_backString appendString:dataStr];
    mutableData=[NSMutableData dataWithCapacity:0];
    NSScanner * scanner = [NSScanner scannerWithString:dataStr];
    if ([scanner scanUpToString:@"\"last\"" intoString:NULL]) {
        [scanner scanUpToString:@"page=" intoString:NULL];
        NSUInteger b = [scanner scanLocation];
        NSUInteger begin = b+5;
        [scanner scanUpToString:@"/" intoString:NULL];
        NSUInteger e = [scanner scanLocation];
        NSString * lastPage = [dataStr substringWithRange:NSMakeRange(begin, e-begin)];
        NSLog(@"CC:%@",lastPage);
        if (lastPage.intValue) {
            if (lastPage.intValue>self.currentPage) {
                self.currentPage++;
                [self beginRequsetCssURL:[self requestCSSPage:self.currentPage]];;
            }else if (lastPage.intValue==self.currentPage){
                NSArray * analyses = [self analyseCSSTypeString:_backString];
                NSMutableArray * nickNames = [NSMutableArray arrayWithCapacity:analyses.count];
                NSMutableArray * rates = [NSMutableArray arrayWithCapacity:analyses.count];
                for (NSDictionary * ddd in analyses) {
                    [nickNames addObject:ddd[@"\"name\":"]];
                    [rates addObject:ddd[@"\"im:rating\":"]];
                }
                //检查该产品的这些用户的评价信息
                /*
                 检查标准：
                 完成；
                 未完成：评星不够、字数不够、差评；
                 不良记录：找不到评论
                 */
                for (NSString * user in self.userNickNames) {
                    if ([nickNames containsObject:user]) {
                        NSUInteger num = [nickNames indexOfObject:user];
                        NSString *rateStr= [rates objectAtIndex:num];
                        if (rateStr.intValue>=CheckReviewSmallRate) {
                            [self.userReviewOK addObject:user];
                        }else{
                            [self.userReviewNoorBad addObject:user];
                        }
                    }else{
                        [self.userReviewNoorBad addObject:user];
                    }
                }
                //721
                NSArray * goods = @[@"NULL"];
                NSArray * bads = @[@"NULL"];
                if (self.userReviewOK&&self.userReviewOK.count>0) {
                    goods = self.userReviewOK.copy;
                }
                if (self.userReviewNoorBad&&self.userReviewNoorBad.count>0) {
                    bads = self.userReviewNoorBad.copy;
                }
                NSArray * arr = @[_appID,goods,bads];
                [[NSNotificationCenter defaultCenter] postNotificationName:NotiCheckUserReviewEnd object:@"1" userInfo:@{@"NotiKey": arr}];
            }
        }
    };
}
-(void)backMainThread:(NSDictionary*)dic{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotiCheckUserReviewEnd object:Nil userInfo:dic];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@--fail get info",_appID);
}

-(NSArray *)analyseCSSTypeString:(NSString*)dataInfo{
//    NSString * clearStr = [dataInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * skipStr = @"\"author\":{\"name\"";
    NSMutableString * string1 = [NSMutableString stringWithString:dataInfo];
    while ([string1 rangeOfString:skipStr].length) {
        NSRange range = [string1 rangeOfString:skipStr];
        [string1 deleteCharactersInRange:range];
    }
    
    NSArray *keyKeys = @[@"\"name\":",@"\"im:version\":",@"\"im:rating\":",@"\"id\":",@"\"title\":",@"\"content\":"];
    NSString * labKey = @"\"label\":\"";
    NSMutableArray * arg = [[NSMutableArray alloc] init];
    NSScanner *scanner=[NSScanner scannerWithString:string1];
    while (![scanner isAtEnd]) {
        NSMutableDictionary * dicInfo = [[NSMutableDictionary alloc] initWithCapacity:keyKeys.count];
        for (NSString * aKeys in keyKeys) {
                if ([string1 rangeOfString:aKeys].length==0) {
                    continue;
                }
                [scanner scanUpToString:aKeys intoString:NULL];
                [scanner scanUpToString:labKey intoString:NULL];
                NSUInteger begin=[scanner scanLocation]+labKey.length;
                if (begin<scanner.string.length) {
                    [scanner setScanLocation:begin];//Location move right
                    BOOL checkQQ = [scanner scanUpToString:@"\"" intoString:NULL];
                    if (checkQQ) {
                        NSUInteger idxB=[scanner scanLocation];
                        NSString *result=[[scanner string] substringWithRange:NSMakeRange(begin, idxB-begin)];
                        if (result) {
                            [dicInfo setObject:result forKey:aKeys];
                        }
                    }
                }else{
                    if (DLGAnalyseCss)NSLog(@"%@ find out bound",aKeys);
                    break;
                }
        }
        if (dicInfo.allKeys.count!=0) {
            [arg addObject:dicInfo];
            NSLog(@"find item%@",dicInfo);
        }
    }
    return arg;
}
@end
