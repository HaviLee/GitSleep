//
//  QueryDataCacheAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/5/5.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "QueryDataCacheAPI.h"

@interface QueryDataCacheAPI ()

@property (strong, nonatomic) id cacheJson;
@property (assign, nonatomic) BOOL isCache;//控制当天数据不缓存

@end

@implementation QueryDataCacheAPI
#pragma mark 自定义缓存

- (NSString *)cacheFileName {
    NSString *requestUrl = [self requestUrl];
    NSString *requestInfo = [NSString stringWithFormat:@"%@&%@",requestUrl,GloableUserId];
//    HaviLog(@"自己做的缓存名称是%@",requestInfo);
    return requestInfo;
}
//cache的路径
- (NSString *)cacheFilePath {
    NSString *path = [self cacheBasePath];//缓存几路径。
    path = [path stringByAppendingPathComponent:@"cache.archiver"];
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
        HaviLog(@"create cache directory failed, error = %@", error);
    } else {
//        HaviLog(@"创建文件夹成功");
    }
}

- (void)requestCompleteFilter {
    [super requestCompleteFilter];
    [self saveJsonResponseToCacheFileHavi:[super responseJSONObject]];
}

- (void)saveJsonResponseToCacheFileHavi:(id)jsonResponse {
    NSDictionary *json = jsonResponse;
    if (json != nil && self.isCache) {
        if ([NSKeyedArchiver archiveRootObject:json toFile:[self cacheFilePath]]) {
//            HaviLog(@"缓存成功");
            self.isCache = NO;
        }else{
            HaviLog(@"失败");
        }
    }
}

- (id)cacheJson {
    if (!_cacheJson) {
        
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        return _cacheJson;
    }else{
        return _cacheJson;
    }
}

- (id)getCacheJsonWithDate:(NSString *)queryDate
{
    self.cacheJson = nil;
    self.isCache = NO;
    NSDate *now = [NSDate date];
    NSString *nowDateString = [NSString stringWithFormat:@"%@",now];
    int dateNow = [[NSString stringWithFormat:@"%@%@%@",[nowDateString substringWithRange:NSMakeRange(0, 4)],[nowDateString substringWithRange:NSMakeRange(5, 2)],[nowDateString substringWithRange:NSMakeRange(8, 2)]]intValue];
    int query = [queryDate intValue];
    if (query < dateNow) {
        NSString *path = [self cacheFilePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
            _cacheJson = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
        self.isCache = YES;
    }
    return _cacheJson;
}


@end
