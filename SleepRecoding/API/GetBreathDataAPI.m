//
//  GetBreathDataAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/4/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "GetBreathDataAPI.h"
#import "YTKNetworkConfig.h"
#import "YTKNetworkPrivate.h"

@interface GetBreathDataAPI ()

//@property (strong, nonatomic) id cacheJson;

@end

@implementation GetBreathDataAPI
+ (GetBreathDataAPI*)shareInstance
{
    static GetBreathDataAPI *_shClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shClient = [[GetBreathDataAPI alloc]init];
    });
    return _shClient;
}
//重写父类；

//1，请求方法：
- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodGet;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    return _urlHeaderDic;
}

- (id)requestArgument
{
    return _urlParaDic;
}

- (NSString *)requestUrl {
    return _detailUrl;
}//

- (void)getBreathData:(NSDictionary *)header withDetailUrl:(NSString *)detailURL{
    _detailUrl = detailURL;
    _urlHeaderDic = header;
}
/*
#pragma mark 自定义缓存

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *requestInfo = [NSString stringWithFormat:@"%@",requestUrl];
    HaviLog(@"自己做的缓存名称是%@",requestInfo);
    return requestInfo;
}
//cache的路径
- (NSString *)cacheFilePath {
    NSString *path = [self cacheBasePath];//缓存几路径。
    path = [path stringByAppendingPathComponent:@"heart.archiver"];
    HaviLog(@"缓存路径是%@",path);
    return path;
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path2 = [self cacheFileName];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:[NSString stringWithFormat:@"LazyRequestCache/%@",path2]];
    [self checkDirectory:path];
    return path;
}

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        YTKLog(@"create cache directory failed, error = %@", error);
    } else {
        HaviLog(@"创建文件夹成功");
    }
}

- (void)requestCompleteFilter {
    [super requestCompleteFilter];
    [self saveJsonResponseToCacheFileHavi:[super responseJSONObject]];
}

- (void)saveJsonResponseToCacheFileHavi:(id)jsonResponse {
    NSDictionary *json = jsonResponse;
    if (json != nil) {
        if ([NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]]) {
            HaviLog(@"缓存成功");
        }else{
            HaviLog(@"失败");
        }
    }
}

- (id)cacheJson {
    NSString *path = [self cacheFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    id cacheJson = nil;
    if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
       cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return cacheJson;
}
*/
@end
