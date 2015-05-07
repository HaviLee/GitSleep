//
//  GetImageApi.m
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "GetImageApi.h"

@implementation GetImageApi {
    NSString *_imageId;
}

- (id)initWithImageId:(NSString *)imageId {
    self = [super init];
    if (self) {
        _imageId = imageId;
    }
    return self;
}
- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPost;
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"v1/file/DownloadFile/%@", _imageId];
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    return header;
}

//- (BOOL)useCDN {
//    return YES;
//}

//- (NSString *)resumableDownloadPath {
//    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
//    NSString *filePath = [cachePath stringByAppendingPathComponent:_imageId];
//    return filePath;
//}

@end
