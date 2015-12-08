//
//  BackgroundModelManager.h
//  SelfService
//
//  Created by shanezhang on 14-8-19.
//  Copyright (c) 2014年 Beijing ShiShiKe Technologies Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Singleton.h"

@interface BackgroundModelManager : NSObject
//single_interface(BackgroundModelManager)
/**
 *  开启后台模式
 */
- (void)openBackgroundModel;
@end
