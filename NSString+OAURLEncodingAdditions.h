//
//  NSString+OAURLEncodingAdditions.h
//  SleepRecoding
//
//  Created by Havi on 15/8/15.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (OAURLEncodingAdditions)
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
@end
