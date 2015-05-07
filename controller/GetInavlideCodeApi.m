//
//  GetInavlideCodeApi.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetInavlideCodeApi.h"

@interface GetInavlideCodeApi ()
@property (nonatomic,strong) NSMutableData *receiveData;
@end

@implementation GetInavlideCodeApi

static GetInavlideCodeApi *_client;
+ (GetInavlideCodeApi *)shareInstance
{
    if (_client == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _client = [[GetInavlideCodeApi alloc]init];
        
        });
    }
    return _client;
}

- (void)getInvalideCode:(NSDictionary *)dic witchBlock:(void (^)(NSData *receiveData))success
{
    if (!dic) {
        HaviLog(@"参数不能为空");
        return;
    }
    NSString *cell = [dic objectForKey:@"cell"];
    NSString *code = [dic objectForKey:@"codeMessage"];
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)code, NULL, NULL,  kCFStringEncodingUTF8 ));
    NSString *urlString = [NSString stringWithFormat:@"http://sdk4report.eucp.b2m.cn:8080/sdkproxy/sendsms.action?cdkey=6SDK-EMY-6688-KGVMO&password=585015&phone=%@&message=%@&addserial=10010",cell,encodedString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //
    
    //http method
    [request setHTTPMethod:@"GET"];
    [NSURLConnection connectionWithRequest:request delegate:self];
    self.successCompletionBlock = success;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receiveData=[NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receiveData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.successCompletionBlock(self.receiveData);
}
@end
