//
//  GetInavlideCodeApi.h
//  SleepRecoding
//
//  Created by Havi_li on 15/3/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetInavlideCodeApi : NSObject
@property (nonatomic, copy) void (^successCompletionBlock)(NSData *);

+ (GetInavlideCodeApi *)shareInstance;

- (void)getInvalideCode:(NSDictionary *)dic witchBlock:(void (^)(NSData *receiveData))success;

@end
