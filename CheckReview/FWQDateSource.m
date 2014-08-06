//
//  FWQDateSource.m
//  FindFree
//
//  Created by Zhiqiang on 14-7-4.
//  Copyright (c) 2014年 Muling. All rights reserved.
//

#import "FWQDateSource.h"

static NSImage *ATThumbnailImageFromImage(NSImage *image) {
    NSSize imageSize = [image size];
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    CGFloat bigImage = BIG_IMAGE_WEIGHT/BIG_IMAGE_HEIGHT;
    CGFloat allLege = 0.0;
    if (imageAspectRatio>bigImage) {
        allLege = BIG_IMAGE_WEIGHT;
    }else{
        allLege = BIG_IMAGE_HEIGHT;
    }
    // Create a thumbnail image from this image (this part of the slow operation)
    NSSize thumbnailSize = NSMakeSize(allLege * imageAspectRatio, allLege);
    NSImage *thumbnailImage = [[NSImage alloc] initWithSize:thumbnailSize];
    [thumbnailImage lockFocus];
    [image drawInRect:NSMakeRect(0, 0, thumbnailSize.width, thumbnailSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    [thumbnailImage unlockFocus];
    
#if DEMO_MODE
    // We delay things with an explicit sleep to get things slower for the demo!
    usleep(250000);
#endif
    return thumbnailImage;
}
static NSImage *layOutImageFrom(NSArray *images){
    NSSize imageSize = [images.firstObject size];
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    CGFloat bigImage = BIG_IMAGE_WEIGHT/BIG_IMAGE_HEIGHT;
    NSSize thumbnailSize = NSZeroSize;
    if (imageAspectRatio>bigImage) {
        thumbnailSize.width = BIG_IMAGE_WEIGHT;
        thumbnailSize.height = BIG_IMAGE_WEIGHT*imageSize.height/imageSize.width;
    }else{
        thumbnailSize.height = BIG_IMAGE_HEIGHT;
        thumbnailSize.width = BIG_IMAGE_HEIGHT*imageSize.width/imageSize.height;
    }
    int tt = BIG_IMAGE_WEIGHT/(thumbnailSize.width);
    float space = (BIG_IMAGE_WEIGHT -thumbnailSize.width*tt)/(tt+1);
    NSSize aSize = thumbnailSize;
    aSize.width =aSize.width*tt+space*(tt+1);
    NSImage *thumbnailImage = [[NSImage alloc] initWithSize:aSize];
//    NSLog(@"pic num:%d\n\nimage count:%d",tt,(int)images.count);
    [thumbnailImage lockFocus];
    for(int index = 0;index<tt;index++){
        NSImage * arg = [images objectAtIndex:index];
        [arg drawInRect:NSMakeRect(index*(thumbnailSize.width+space), 0, thumbnailSize.width, thumbnailSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
//    NSLog(@"item size:%@\nspace:%f\ndraw end size:%@",NSStringFromSize(thumbnailSize),space,NSStringFromSize(thumbnailImage.size));
    [thumbnailImage unlockFocus];
    
#if DEMO_MODE
    // We delay things with an explicit sleep to get things slower for the demo!
    usleep(250000);
#endif
    return thumbnailImage;
}
static NSOperationQueue *ATSharedOperationQueue() {
    static NSOperationQueue *_ATSharedOperationQueue = nil;
    if (_ATSharedOperationQueue == nil) {
        _ATSharedOperationQueue = [[NSOperationQueue alloc] init];
        // We limit the concurrency to see things easier for demo purposes. The default value NSOperationQueueDefaultMaxConcurrentOperationCount will yield better results, as it will create more threads, as appropriate for your processor
        [_ATSharedOperationQueue setMaxConcurrentOperationCount:2];
    }
    return _ATSharedOperationQueue;
}

//从数据库取到数据
@implementation FWQDateSource
@synthesize allReviewApps;
@synthesize isPassWordRight;
-(id)init{
    if (self=[super init]) {
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCallBackData:) name:NotifFWQCallBack object:nil];
    }
    return self;
}
static FWQDateSource * sharedFWQ = nil;

+ (FWQDateSource*)sharedManager
{
    @synchronized(self) {
        if (sharedFWQ == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedFWQ;
}

//为了确保有且只有一个实例，有必要覆盖一下+ (id)allocWithZone:(NSZone *)zone 这个方法，如果不小心调用了alloc方法，则又会创建一个实例
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedFWQ == nil) {
            sharedFWQ = [super allocWithZone:zone];
            
            return sharedFWQ;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
-(void)sendMessageRegister:(NSDictionary*)dic{
    
}
- (void)getCallBackData:(NSNotification *)notification{
    NSDictionary * dic = notification.userInfo;
    NSString * idKey = dic.allKeys.lastObject;
    FFAppEntity * backO = [dic objectForKey:idKey];
    NSLog(@"%@",backO);
}

/*解析xml固定格式字符段之间信息的方法：
 对固定模式的字符串值的筛选，对数组元素的区分。
 */
-(NSArray *)arrFromData:(NSString*)dataInfo mark:(int)markNum{
    NSString * str = [dataInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSLog(@"select:%@",str);
    NSMutableArray *arg = [NSMutableArray array];
    //    NSArray *nodeKey = @[@"<applist>",@"</applist>"];
    NSArray *scannSequence = nil;
    switch (markNum) {
        case CCFWQ_ALL_APP:
        {
            NSArray *idKey = @[@"<a_id>",@"</a_id>"];
            NSArray *urlKey = @[@"<a_url>",@"</a_url>"];
            NSArray *feeKey = @[@"<a_fee>",@"</a_fee>"];
            NSArray *backKey = @[@"<a_rback>",@"</a_rback>"];
            NSArray *durKey = @[@"<a_dura>",@"</a_dura>"];
            NSArray *countKey = @[@"<a_count>",@"</a_count>"];
            NSArray *stateKey = @[@"<a_status>",@"</a_status>"];
            scannSequence = @[idKey,urlKey,feeKey,backKey,durKey,countKey,stateKey];
        }
            break;
        case CCFWQ_USER_GET_A_REVIEW:
        {
            NSArray *idKey = @[@"<user_id>",@"</user_id>"];
            NSArray *appKey = @[@"<app_id>",@"</app_id>"];
            NSArray *beginKey = @[@"<app_begindate>",@"</app_begindate>"];
            NSArray *timeKey = @[@"<timeduration>",@"</timeduration>"];
            scannSequence = @[idKey,appKey,beginKey,timeKey];
        }
            break;
        case CCFWQ_USER_ALL_REVIEW:
        {
            NSArray *idKey = @[@"<user_id>",@"</user_id>"];
            NSArray *appKey = @[@"<app_id>",@"</app_id>"];
            NSArray *beginKey = @[@"<app_begindate>",@"</app_begindate>"];
            NSArray *reviewDateKey = @[@"<app_reviewdate>",@"</app_reviewdate>"];
            NSArray *statusKey = @[@"<review_status>",@"</review_status>"];
            NSArray *durKey = @[@"<app_timeduration>",@"</app_timeduration>"];
            scannSequence = @[idKey,appKey,beginKey,reviewDateKey,statusKey,durKey];
        }
            break;
        case CCFWQ_USER_ACCOUNT_INFO:
        {
            NSArray *idKey = @[@"<user_id>",@"</user_id>"];
            NSArray *email = @[@"<user_email>",@"</user_email>"];
            NSArray *withdrawusering = @[@"<user_withdrawusering>",@"</user_withdrawusering>"];
            NSArray *PayAccount = @[@"<user_PayAccount>",@"</user_PayAccount>"];
            NSArray *nickname = @[@"<user_nickname>",@"</user_nickname>"];
            NSArray *referrer = @[@"<user_referrer>",@"</user_referrer>"];
            NSArray *county = @[@"<user_county>",@"</user_county>"];
            NSArray *password = @[@"<user_password>",@"</user_password>"];
            scannSequence = @[idKey,email,withdrawusering,PayAccount,nickname,referrer,county,password];
        }
            break;
            case CCFWQ_ALL_APP_TASK_USER:
        {
            NSArray *idKey = @[@"<user_id>",@"</user_id>"];
            NSArray *appKey = @[@"<app_id>",@"</app_id>"];
            NSArray *nicknameKey = @[@"<user_nickname>",@"</user_nickname>"];
            scannSequence = @[idKey,appKey,nicknameKey];
        }
            break;
        default:
            break;
    }
    /*Scanner 会出现BUG的情况：当检索的字符就在开始时，会返回NO
     717发现问题：当摘取body标签中的内容后，字符串的第一个标签因为那个原因不能正确取到所以*/
    NSScanner *scanner=[NSScanner scannerWithString:str];
    while (![scanner isAtEnd]) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithCapacity:scannSequence.count];
        for (NSArray * aKeys in scannSequence) {
            if ([scanner scanUpToString:aKeys.firstObject intoString:NULL]) {
                NSUInteger idxA=[scanner scanLocation];
                NSUInteger idxAL=[aKeys.firstObject length];
                if ([scanner scanUpToString:aKeys.lastObject intoString:NULL]) {
                    NSUInteger idxB=[scanner scanLocation];
                    NSString *result=[[scanner string] substringWithRange:NSMakeRange(idxA+idxAL, idxB-idxA-idxAL)];
                    [dic setObject:result forKey:aKeys.firstObject];
                }
            }
        }
        if (dic.allKeys.count!=0) {
            [arg addObject:dic];
        }
    }
    return arg;
}

-(NSDictionary *)analyseSingleAppJSONString:(NSString*)dataInfo{
    NSString * clearStr = [dataInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *keyKeys = @[@"trackName",@"trackViewUrl",@"supportedDevices",@"description",@"formattedPrice",@"artworkUrl60",@"screenshotUrls",@"genres",@"kind"];

    NSMutableDictionary * dicInfo = [[NSMutableDictionary alloc] initWithCapacity:keyKeys.count];
    for (int index=0; index<keyKeys.count; index++) {
        NSString * aKeys =[keyKeys objectAtIndex:index];
        if ([clearStr rangeOfString:aKeys].length==0) {
            NSLog(@"key not find :%@",aKeys);
            continue;
        }
        if (DLGCheckScanner)NSLog(@"find key :%@",aKeys);
        NSScanner *scanner=[NSScanner scannerWithString:clearStr];
        [scanner scanUpToString:aKeys intoString:NULL];
        [scanner scanUpToString:@":" intoString:NULL];
        NSUInteger valueIndex = [scanner scanLocation]+1;
        if (valueIndex>scanner.string.length-1) {
            if (DLGCheckScanner)NSLog(@"%@ find out bound",aKeys);
        }else{
            char strOrArrMark = [scanner.string characterAtIndex:valueIndex];
            if (DLGCheckScanner)NSLog(@"Check Str:%c",strOrArrMark);
            [scanner setScanLocation:valueIndex];//跳过本字符的后引号，和内容字符的前引号
            //判断是字符串属性还是数组属性，通过"trackName":"Guess The Emoji"
            if (strOrArrMark == '"') {
                //当scanUpToString方法发现解析当前位置的字符时会返回NO所以需要手动移动location
                [scanner scanUpToString:@"\"" intoString:NULL];
                [scanner scanString:@"\"\\" intoString:NULL];//@"\"\\\""会和下边的scanLocation＋1冲突，暂时用当前方法
                NSUInteger begin=[scanner scanLocation]+1;
                if (begin<scanner.string.length) {
                    [scanner setScanLocation:begin];//Location move right
                }
                BOOL checkQQ = [scanner scanUpToString:@"\"" intoString:NULL];
                if (checkQQ) {
                    NSUInteger idxB=[scanner scanLocation];
                    NSString *result=[[scanner string] substringWithRange:NSMakeRange(begin, idxB-begin)];
                    if (DLGCheckScanner)NSLog(@"++%lu,%lu",(unsigned long)valueIndex,(unsigned long)idxB);
                    if (DLGCheckScanner)NSLog(@"++:%@",result);
                    if (result) {
                        [dicInfo setObject:result forKey:aKeys];
                    }
                }
            }else if (strOrArrMark == '['){
                NSMutableArray * arrArg = [NSMutableArray array];
                BOOL breakOut = YES;
                NSUInteger itemIndex = 0;
                do {
                    //第一个元素冒号之前没有逗号，所以不取逗号
                    if (itemIndex!=0) [scanner scanUpToString:@"," intoString:NULL];
                    [scanner scanUpToString:@"\"" intoString:NULL];
                    itemIndex=[scanner scanLocation]+1;
                    if (itemIndex<scanner.string.length) {
                        [scanner setScanLocation:itemIndex];//Location move right
                    }else{
                        break;
                    }
                    [scanner scanUpToString:@"\"" intoString:NULL];
                    NSUInteger arrE=[scanner scanLocation];
                    NSString *result=[[scanner string] substringWithRange:NSMakeRange(itemIndex, arrE-itemIndex)];
                    itemIndex = arrE;
                    [arrArg addObject:result];
                    //判断数组终止符
                    if (arrE+1<scanner.string.length) {
                        char endMark = [scanner.string characterAtIndex:arrE+1];
                        if (endMark==']') {
                            breakOut = NO;
                        }
                    }
                } while (breakOut);
                [dicInfo setObject:arrArg forKey:aKeys];
            }
        }
    }
    if (DLGCheckScanner) NSLog(@"sss result:%@",dicInfo);
    return dicInfo;
}

//取得所有review的app
-(NSArray *)fwqAllReviewAppInfo{
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/applist.php"];
    NSURL *url = [NSURL URLWithString:add];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    if (DLGCheckFWQData)NSLog(@"str=%@",str);
    return [self arrFromData:str mark:CCFWQ_ALL_APP];
}

//取得用户ID，登记任务
-(NSArray*)fwqSendTaskRequest:(NSString*)appId {
    //    NSString *appId=[sender identifier];
    FFUserEntity *u=[FFUserEntity sharedManager];
    NSString *ema=u.userEamil;
    NSString *userId = u.userID;
    NSLog(@"userid====%@",userId);
    if (userId ==NULL) {
        NSLog(@"userid is no!!!!");
        return nil;
    }else{
        NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/review.php"];
        NSURL *url = [NSURL URLWithString:add];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
        NSString *currentDate = [ToolClass get_ADateFormat:[NSDate date] dateFormat:FWQDateStringFormat];
        NSString *str =[NSString stringWithFormat:@"user_id=%@&app_id=%@&app_begindate=%@",userId,appId,currentDate];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        [request setHTTPBody:data];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        NSString *str2=[self getRece:str1];
        NSLog(@"取得用户ID，登记任务userid=%@",str2);
        //返回登录结束的信息，字典
        NSString * repeatAlertStr = @"is have";
        if ([str2 rangeOfString:repeatAlertStr].length!=0) {
            return nil;
        }else{
            return [self arrFromData:str1 mark:CCFWQ_USER_GET_A_REVIEW];
        }
    }
}
//ML721
-(NSArray*)fwqGetAppTaskUsers:(NSString*)appID{
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/appuser.php"];
    NSURL *url = [NSURL URLWithString:add];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str =[NSString stringWithFormat:@"app_id=%@",appID];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
//    NSString *str2=[self getRece:str1];
    NSArray * analy1 = [self arrFromData:str1 mark:CCFWQ_ALL_APP_TASK_USER];
    NSMutableArray * analy2 = [[NSMutableArray alloc] init];
    for (NSDictionary * dic in analy1) {
        if (![dic[@"<user_id>"] isEqualToString:@""]) {
            [analy2 addObject:dic];
        }
    }
    return analy2;
}
-(BOOL)updateUser:(NSString *)userID ReviewStatus:(int)isOK withAppID:(NSString *)appID{
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/changereviewstatus.php"];
    NSURL *url = [NSURL URLWithString:add];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str =[NSString stringWithFormat:@"user_id=%@&app_id=%@&status=%@",userID,appID,[NSString stringWithFormat:@"%d",isOK]];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSString *str2=[self getRece:str1];
    if ([str2 rangeOfString:@"is change"].length) {
        return YES;
    }else if ([str2 rangeOfString:@"update shibai"].length){
        NSLog(@"update shibai");
        return NO;
    }else if ([str2 rangeOfString:@"is not review"].length){
        NSLog(@"is not review");
        return NO;
    }else{
        NSLog(@"not check wanted value:%@",str2);
        return NO;
    }
}
//根据邮箱取得用户ID
-(NSDictionary *)fwqSearchUserInfoByEmail:(NSString *)email
{
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/user.php"];
    NSURL *url = [NSURL URLWithString:add];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str =[NSString stringWithFormat:@"email=%@",email];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSArray * arrr = [self arrFromData:str1 mark:CCFWQ_USER_ACCOUNT_INFO];
    return arrr.firstObject;
}
//查询用户的所有任务信息
-(NSArray *)fwqGetUserReviewInfo:(NSString*)email
{
    //    NSString *email=@"22@qq.com";
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/userreview.php"];
    NSURL *url = [NSURL URLWithString:add];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str =[NSString stringWithFormat:@"user_email=%@",email];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSString *str2 = [self getRece:str1];
    NSLog(@"userreview:%@",str2);
    return [self arrFromData:str2 mark:CCFWQ_USER_ALL_REVIEW];
}
//取消任务操作
-(NSString*)removeDefaultUserReview:(NSString*)appID
{
    FFUserEntity *u=[FFUserEntity sharedManager];
    NSString *userId=u.userID;
    NSLog(@"userid====%@",userId);
    int user_id=userId.intValue;
    int app_id=appID.intValue;//882404907
    NSString *add=[NSString stringWithFormat:@"http://115.29.102.9/reviewapp/user/removeuserreview.php"];
    NSURL *url = [NSURL URLWithString:add];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str =[NSString stringWithFormat:@"user_id=%d&app_id=%d",user_id,app_id];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSString *str2=[self getRece:str1];
    NSLog(@"取消任务操作userid=%@",str2);
    return str2;
}

-(NSString *)getUserId:(NSString *)str
{
    if ([str isEqualToString:@""]) {
        return @"no";
    }
    NSRange bodyBegin;
    NSRange bodyEnd;
    bodyBegin=[str rangeOfString:@"<user_id>"];
    bodyEnd=[str rangeOfString:@"</user_id>"];
    NSString *receivedStr=[str substringWithRange:NSMakeRange(bodyBegin.location+bodyBegin.length, bodyEnd.location-bodyBegin.location-bodyBegin.length)];
    receivedStr = [receivedStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return receivedStr;
    
}
-(NSString *)getRece:(NSString *)str
{
    if ([str isEqualToString:@""]) {
        return @"empty result ERROR!";
    }
    NSRange bodyBegin;
    NSRange bodyEnd;
    bodyBegin=[str rangeOfString:@"<body>"];
    bodyEnd=[str rangeOfString:@"</body>"];
//    NSLog(@"FWQ INFO AA:%@",str);
//    if (bodyBegin.length!=0&&bodyEnd.length!=0) {
//        return @"invlid result ERROR!";
//    }
    NSString *receivedStr=[str substringWithRange:NSMakeRange(bodyBegin.location+bodyBegin.length, bodyEnd.location-bodyBegin.location-bodyBegin.length)];
    receivedStr = [receivedStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return receivedStr;
}
@end

@implementation FFTaskEntity
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil){
        [self setAppID:[aDecoder decodeObject]];//从aDecoder数据流中解码出下一个对象，并设置name实例变量
        [self setUrl:[aDecoder decodeObject]];
        [self setReviewBack:[aDecoder decodeObject]];
        [self setStatus:[aDecoder decodeObject]];
        [self setIconImage:[aDecoder decodeObject]];
        [self setName:[aDecoder decodeObject]];
        [self setPrice:[aDecoder decodeObject]];
        [self setCategory:[aDecoder decodeObject]];
        [self setUserID:[aDecoder decodeObject]];
        [self setBeginDate:[aDecoder decodeObject]];
        [self setTimeduration:[aDecoder decodeObject]];
        [self setName:[aDecoder decodeObject]];
        NSLog(@"call init");
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self appID]];//将name实例变量编码到coder的数据流中
    [aCoder encodeObject:[self url]];
    [aCoder encodeObject:[self reviewBack]];
    [aCoder encodeObject:[self status]];
    [aCoder encodeObject:[self name]];
    [aCoder encodeObject:[self price]];
    [aCoder encodeObject:[self category]];
    [aCoder encodeObject:[self userID]];
    [aCoder encodeObject:[self beginDate]];
    [aCoder encodeObject:[self timeduration]];
    [aCoder encodeObject:[self name]];
}
-(id)init{
    if (self=[super init]) {
        self.appID = @"";
        self.userID = @"";
        self.timeduration=@"";
        self.status=@"";
//        self.iconImage = [NSImage imageNamed:NSImageNameTrashFull];
        self.name = @"";
        self.category=[NSArray array];
        self.url = @"";
        self.reviewBack=@"";
        self.beginDate = @"";
        self.price=@"";
    }
    return self;
}
-(id)initWithAppID:(NSString *)appID{
    if (self=[super init]) {
//        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
//        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
//        [requestUrlString appendFormat:@"?id=%@",appID];
//        NSLog(@"url str:%@",requestUrlString);
//        NSURL *aUrl = [NSURL URLWithString:requestUrlString];
//        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    }
    return  self;
}

@end

@implementation FFUserEntity

static FFUserEntity * sharedMyUser = nil;

+ (FFUserEntity*)sharedManager
{
    @synchronized(self) {
        if (sharedMyUser == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedMyUser;
}

//为了确保有且只有一个实例，有必要覆盖一下+ (id)allocWithZone:(NSZone *)zone 这个方法，如果不小心调用了alloc方法，则又会创建一个实例
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedMyUser == nil) {
            sharedMyUser = [super allocWithZone:zone];
            
            return sharedMyUser;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

@end
@implementation FFAppEntity
@synthesize appID=_appID;
@synthesize url=_url;
@synthesize serviceFee=_serviceFee;
@synthesize reviewBack=_reviewBack;
@synthesize timeDuration=_timeDuration;
@synthesize reviewCount=_reviewCount;
@synthesize status=_status;
@synthesize users=_users;
@synthesize snapShotImage=_snapShotImage;
@synthesize iconImage=_iconImage;
@synthesize name=_name;
@synthesize price=_price;
@synthesize category=_category;
@synthesize detail=_detail;
@synthesize iconImageUrl=_iconImageUrl;
@synthesize imageUrls=_imageUrls;
@synthesize device=_device;
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil){
        [self setAppID:[aDecoder decodeObject]];//从aDecoder数据流中解码出下一个对象，并设置name实例变量
        [self setUrl:[aDecoder decodeObject]];
        [self setServiceFee:[aDecoder decodeObject]];
        [self setReviewBack:[aDecoder decodeObject]];
        [self setTimeDuration:[aDecoder decodeObject]];
        [self setReviewCount:[aDecoder decodeObject]];
        [self setStatus:[aDecoder decodeObject]];
        [self setUsers:[aDecoder decodeObject]];
        [self setSnapShotImage:[aDecoder decodeObject]];
        [self setIconImage:[aDecoder decodeObject]];
        [self setName:[aDecoder decodeObject]];
        [self setPrice:[aDecoder decodeObject]];
        [self setCategory:[aDecoder decodeObject]];
        [self setDetail:[aDecoder decodeObject]];
        [self setIconImageUrl:[aDecoder decodeObject]];
        [self setImageUrls:[aDecoder decodeObject]];
        [self setDevice:[aDecoder decodeObject]];
        NSLog(@"call init");
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[self appID]];//将name实例变量编码到coder的数据流中
    [aCoder encodeObject:[self url]];
    [aCoder encodeObject:[self serviceFee]];
    [aCoder encodeObject:[self reviewBack]];
    [aCoder encodeObject:[self timeDuration]];
    [aCoder encodeObject:[self reviewCount]];
    [aCoder encodeObject:[self status]];
    [aCoder encodeObject:[self users]];
    [aCoder encodeObject:[self snapShotImage]];
    [aCoder encodeObject:[self iconImage]];
    [aCoder encodeObject:[self name]];
    [aCoder encodeObject:[self price]];
    [aCoder encodeObject:[self category]];
    [aCoder encodeObject:[self detail]];
    [aCoder encodeObject:[self iconImageUrl]];
    [aCoder encodeObject:[self imageUrls]];
    [aCoder encodeObject:[self device]];
}

//访问多个网页取得产品信息时使用
-(id)initWithAppID:(NSString *)appID
{
    if (self=[super init]) {
        self.appID = appID;
        self.url = @"";
        self.serviceFee=@"";
        self.reviewBack=@"";
        self.timeDuration=@"";
        self.reviewCount=@"";
        self.status=@"";
        self.name = @"";
        self.price=@"";
        self.category=[NSArray array];
        self.detail=@"";
        self.imageUrls=[NSArray array];
        self.device=@"";
        self.iconImageUrl=@"";
        self.reviewBack=@"";
        NSMutableString *requestUrlString = [[NSMutableString alloc] init];
        [requestUrlString appendFormat:@"http://itunes.apple.com/lookup"];
        [requestUrlString appendFormat:@"?id=%@",appID];
        NSLog(@"url str:%@",requestUrlString);
        NSURL *aUrl = [NSURL URLWithString:requestUrlString];
        NSURLRequest *urlRequest=[NSURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        mutableData=[NSMutableData dataWithCapacity:0];
//        //同步请求检查数据：
//        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:aUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//        [self dealDateSetApp:received];
    }
    return  self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mutableData appendData:data];
//    NSLog(@"0--0%lu,%lu",(unsigned long)[mutableData length],data.length);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self dealDateSetApp:mutableData];
    mutableData=[NSMutableData dataWithCapacity:0];
//    NSLog(@"connectionDidFinishLoading");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@--fail get info",self.url);
}
-(void)dealDateSetApp:(NSData*)aData{
    NSString * dataStr = [[NSString alloc]initWithData:aData encoding:NSUTF8StringEncoding];
    NSDictionary * result = [[FWQDateSource sharedManager] analyseSingleAppJSONString:dataStr];
    //    NSError *jsonError;
    //    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data.copy
    //                                                                   options:0
    //                                                                     error:&jsonError];
    //    NSLog(@"%@",jsonError);
    //    NSArray *infoArray = [jsonDictionary objectForKey:@"results"];
    NSString * proName = [result objectForKey:@"trackName"];
    NSLog(@"result::%@",proName);
    NSString * proUrlStr = [result objectForKey:@"trackViewUrl"];
    NSString *detailStr = [result objectForKey:@"description"];
    NSString * priceStr = [result objectForKey:@"formattedPrice"];
//    NSLog(@"price check:%@",detailStr);
    NSString *iconImageURLStr = [result objectForKey:@"artworkUrl60"];
    
    NSArray * screenShots = [result objectForKey:@"screenshotUrls"];//ipadScreenshotUrls
    NSArray * categorys = [result objectForKey:@"genres"];
    NSArray * deviceArr = [result objectForKey:@"supportedDevices"];
    NSString * kindValue = [result objectForKey:@"kind"];
//    NSLog(@"categorys ccc:%@",deviceArr);
    self.iconImageUrl= iconImageURLStr?iconImageURLStr:@"";
    if (screenShots&&screenShots.count>0) {
        self.imageUrls = screenShots;
    }
    self.name = proName?proName:@"";
    self.url = proUrlStr?proUrlStr:@"";
    if (categorys&&categorys.count>0) {
        self.category = categorys;
    }
    if (deviceArr&&deviceArr.count>0) {
        NSMutableString * deviceStr = [[NSMutableString alloc] init];
        for (NSString *arg in deviceArr) {
            if ([arg rangeOfString:@"iPhone"].length>0) {
                if ([deviceStr rangeOfString:@"iPhone"].length==0) {
                    if (deviceStr.length>0) {
                        [deviceStr appendString:@","];
                    }
                    [deviceStr appendString:@"iPhone"];
                }
            }else if ([arg rangeOfString:@"iPad"].length>0){
                if ([deviceStr rangeOfString:@"iPad"].length==0) {
                    if (deviceStr.length>0) {
                        [deviceStr appendString:@","];
                    }
                    [deviceStr appendString:@"iPad"];
                }
            }
        }
        self.device = deviceStr.copy;
    }
    if ([kindValue rangeOfString:@"mac"].length>0){
        if (self.device.length==0) {
            self.device = @"Mac";
        }else self.device = [self.device stringByAppendingString:@",Mac"];
        
    }
    self.detail = detailStr?detailStr:@"";
    self.price = priceStr?priceStr:@"";
    //bundleId,primaryGenreName,trackId,price
    if (self.autoLoadIcon) {
        [self loadIconImage];
    }
}
+(NSString*)tranArrToStr:(NSArray*)arr{
    NSMutableString *result = [[NSMutableString alloc] init];
    for (int i=0; i<arr.count; i++) {
        if (i!=0) {
            [result appendString:@","];
        }
        [result appendString:[arr objectAtIndex:i]];
    }
    return result;
}
@end
NSString *const FFEntityPropertyNamedApp = @"snapShotImage";
NSString *const FFEntityPropertyIconImage = @"iconImage";//

@implementation ToolClass

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
    NSDate* cc=[ToolClass currentLocalDate];
    NSString *aa = [ToolClass get_ADateFormat:cc dateFormat:FWQDateStringFormat];
    NSLog(@"current date:%@",aa);
    return aa;
}
+(NSString*)convertLocalDateStrFrom:(NSString*)dateStr{
    NSDate* date = [ToolClass getDateFromStrNoTimeZone:dateStr dateFormat:FWQDateStringFormat];
    NSString * str = [ToolClass get_BDateFormat:date dateFormat:FWQDateStringFormat];
    return str;
}
+(NSDate *)getDateFromStrNoTimeZone:(NSString *)dateStr dateFormat:(NSString *)dateTimeFormat{
    NSDate * aDate = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:dateTimeFormat];
    NSRange range = NSMakeRange(0,[dateStr length]);
    NSDate *readDate;
    NSError *error;
    [dateFormatter getObjectValue:&readDate forString:dateStr range:&range error:&error];
    //    [dateFormatter release];
    aDate = readDate.copy;
    return aDate;
}
@end