//
//  UploadImageApi.m
//  Solar
//
//  Created by tangqiao on 8/7/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "UploadImageApi.h"

@implementation UploadImageApi {
    UIImage *_image;
    NSString *_userId;
}

- (id)initWithImage:(UIImage *)image andUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _image = image;
        _userId = userId;
    }
    return self;
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    return header;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

//- (YTKRequestSerializerType)requestSerializerType {
//    return YTKRequestSerializerTypeJSON;
//}


- (NSString *)requestUrl {
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@",@"v1/file/UploadFile/",_userId];
    return detailUrl;
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/png";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (id)jsonValidator {
    return @{ @"imageId": [NSString class] };
}

- (NSString *)responseImageId {
    NSDictionary *dict = self.responseJSONObject;
    return dict[@"imageId"];
}

@end
