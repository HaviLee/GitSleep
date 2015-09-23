//
//  XMGPersonViewController.m
//  个人详情控制器
//
//  Created by yz on 15/8/13.
//  Copyright (c) 2015年 yz. All rights reserved.
//

#import "XMGPersonViewController.h"
#import "YZWeiBoTableViewController.h"
#import "XMGPersonTableViewController.h"

@interface XMGPersonViewController ()

@end

#pragma mark - XMGPersonViewController继承YZPersonViewController，是它的子类

@implementation XMGPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置个人头像
    self.personIconImage = [UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]];
    
    // 设置个人明信片
    self.personCardImage = [UIImage imageNamed:@"pic_heder_portrait"];

    // 设置导航条标题
    self.title = @"智照护";
    
    
    // 添加子控制器，需要显示几个子控制器的tableView就添加几个，跟UITabBarController用法一样。
    // tabBar上按钮的标题 = 子控制器的标题
    // 个人
    XMGPersonTableViewController *personVC = [[XMGPersonTableViewController alloc] init];
    
    personVC.title = @"个人";
    
    [self addChildViewController:personVC];
    
//    // 微博
//    YZWeiBoTableViewController *weiboVC = [[YZWeiBoTableViewController alloc] init];
//    
//    weiboVC.title = @"微博";
//    
//    [self addChildViewController:weiboVC];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (thirdPartyLoginIcon.length>0) {
//        [self.personIconImage setImageWithURL:[NSURL URLWithString:thirdPartyLoginIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
    }else{
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]isEqual:@""]) {
            self.personIconImage = [UIImage imageWithData:[self downloadWithImage:nil]];
            
        }else{
            if ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]]) {
                
                self.personIconImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]];
            }
        }
        
    }
}

- (NSData *)downloadWithImage:(UIImageView *)imageview
{
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,thirdPartyLoginUserId];
    NSData *imageData = [self downLoadImageWithUrl:url andHeader:header];
    return imageData;
    
}
- (NSData *)downLoadImageWithUrl:(NSString *)url andHeader:(NSDictionary *)postParems
{
    
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:10];
    NSArray *headerkeys;
    int     headercount;
    id      key,value;
    headerkeys=[postParems allKeys];
    headercount = (int)[headerkeys count];
    for (int i=0; i<headercount; i++) {
        key=[headerkeys objectAtIndex:i];
        value=[postParems objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    //http method
    [request setHTTPMethod:@"GET"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    if (resultData) {
        [[NSUserDefaults standardUserDefaults]setObject:resultData forKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    return resultData;
}
@end
