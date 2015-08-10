//
//  WeiXinAPI.m
//  SleepRecoding
//
//  Created by Havi on 15/8/10.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "WeiXinAPI.h"

@implementation WeiXinAPI

+(NSURLRequest*)getWeiXinInfoWith:(NSString*)wxCode
                       parameters:(NSDictionary*)parameters
                         finished:(WeiXinFinishedBlock)finished
                           failed:(WeiXinFailedBlock)failed
{
    NSString *tockenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAPPKey,WXAPPSecret,wxCode];
    [WTRequestCenter getWithURL:tockenUrl parameters:nil finished:^(NSURLResponse *response, NSData *data) {
        NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        HaviLog(@"微信是%@",obj);
        NSString *refreshTockenUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",WXAPPKey,[obj objectForKey:@"refresh_token"]];
        
        [WTRequestCenter getWithURL:refreshTockenUrl parameters:nil finished:^(NSURLResponse *response, NSData *data) {
            NSDictionary *obj = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"刷新tocken是%@",obj);
            NSString *userInfoUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",[obj objectForKey:@"access_token"],[obj objectForKey:@"openid"]];
            [WTRequestCenter getWithURL:userInfoUrl parameters:nil finished:finished failed:failed];
        } failed:^(NSURLResponse *response, NSError *error) {
            
        }];
    } failed:^(NSURLResponse *response, NSError *error) {
        
    }];
    return nil;

}

@end
