//
//  CeshiViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/11.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "CeshiViewController.h"
#import "SHPostClient.h"
#import "SHGetClient.h"
#import "SHPutClient.h"
#import "UploadImageApi.h"
#import "GetImageApi.h"
#import "YTKBatchRequest.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface CeshiViewController ()<UITextViewDelegate>
@property (nonatomic, strong) UITextView *responseLabel;
@property (nonatomic, strong) UIImageView *imageViewP;
@end

@implementation CeshiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageViewP = [[UIImageView alloc]init];
    [self.view addSubview:self.imageViewP];
        // Do any additional setup after loading the view.
    [self.view addSubview:self.sideTableView];
    self.responseLabel = [[UITextView alloc]init];
    [self.view addSubview:self.responseLabel];
    [self.imageViewP makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(0);
        make.height.equalTo(100);
        make.centerX.equalTo(self.view.centerX);
        
    }];
    self.imageViewP.backgroundColor = [UIColor redColor];
    self.imageViewP.image = [UIImage imageNamed:@"head.jpeg"];
    [self.sideTableView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.imageViewP.bottom).offset(0);
        make.bottom.equalTo(self.responseLabel.top).offset(-5);
        make.right.equalTo(self.view.right).offset(0);
    }];
    [self createNavWithTitle:@"张三" createMenuItem:^UIView *(int nIndex)
          {
              if (nIndex == 1)
              {
                  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                  UIImage *i = [UIImage imageNamed:@"btn_list"];
                  [btn setImage:i forState:UIControlStateNormal];
                  [btn setFrame:CGRectMake(5, 6, 30, 30)];
                  [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
                  return btn;
              }else if (nIndex == 0){
                  self.rightButton.frame = CGRectMake(self.view.frame.size.width-35, 12, 20, 20);
                  [self.rightButton setBackgroundImage:[UIImage imageNamed:@"btn-detall@2x"] forState:UIControlStateNormal];
                  [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
                  return self.rightButton;
              }
              
              return nil;
          }];
//    self.sideTableView.backgroundColor = [UIColor clearColor];
    self.sideTableView.delegate = self;
    self.sideTableView.dataSource = self;
    self.sideArray = @[@"获取WIFI列表",@"新增用户接口OK",@"登录注册接口OK",@"修改用户接口fail",@"查询用户信息接口OK",@"查询用户关联设备OK",@"获取全局参数接口OK",@"查询传感器基本信息OK",@"用户关联产品码OK",@"读取传感器当日数据OK",@"读取传感器历史数据OK",@"查询是否有离床、久睡报警OK",@"上传图片OK",@"获取图片fail",@"获取短信验证码"];
    self.view.backgroundColor = [UIColor whiteColor];
//
    [self.responseLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.top.equalTo(self.sideTableView.bottom).offset(5);
        make.bottom.equalTo(self.view);
        make.height.equalTo(120);
    }];
    self.responseLabel.backgroundColor = [UIColor lightGrayColor];
    self.responseLabel.userInteractionEnabled = YES;
    self.responseLabel.delegate = self;
    
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sideArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defaultCellIndentifier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellIndentifier];
    }
    if (indexPath.row == 0) {
       
//        [cell addSubview:_imageViewP];
    }else{
        
        cell.textLabel.text = [self.sideArray objectAtIndex:indexPath.row];
    }
//    cell.textLabel.textColor = [UIColor redColor];
//    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 50;
    }else{
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.sideArray objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        case 0:{
            [self fetchSSIDInfo];
            break;
        }
        case 1:{
            [self addNewUserWithHeader:title];
            break;
        }
        case 2:{
            [self login:title];
            break;
        }
        case 3:{
            [self modifyInfo:title];
            break;
        }
        case 4:{
            [self queryInfo:title];
            break;
        }
        case 5:{
            [self queryDevice:title];
            break;
        }
        case 6:{
            [self queryGloablPara:title];
            break;
        }
        case 7:{
            [self querySensor:title];
            break;
        }
        case 8:{
            [self userProductCode:title];
            break;
        }
        case 9:{
            [self sensorData:title];
            break;
        }
        case 10:{
            [self sensorDataOld:title];
            break;
        }
        case 11:{
            [self getAlarm:title];
            break;
        }
        case 12:{
            [self uploadImage:title];
            break;
        }
        case 13:{
//            [self getImage:title];
            NSDictionary *header = @{
                                     @"AccessToken":@"123456789"
                                     };
            NSData *imageData = [self UpLoadFile:nil andUrl:@"http://webservice.meddo99.com:9000/v1/file/DownloadFile/13122785292" andHeader:header];
            NSDictionary *dic = [self dataToDictionary:imageData];
            HaviLog(@"查询的字典是%@",dic);
            self.imageViewP.image = [UIImage imageWithData:imageData];
            break;
        }
        case 14:{
            [self getCMSCode:title];
            break;
        }
            
        default:
            break;
    }
}

- (void)getCMSCode:(NSString *)title
{
    NSString *urlString1= [NSString stringWithFormat:@"【智照护】1002"];
    
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlString1, NULL, NULL,  kCFStringEncodingUTF8 ));
    NSString *urlString = [NSString stringWithFormat:@"http://sdk4report.eucp.b2m.cn:8080/sdkproxy/sendsms.action?cdkey=0SDK-EAA-6688-JESUQ&password=028760&phone=13122785292&message=%@&addserial=10010",encodedString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //

    [request setHTTPMethod:@"GET"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = nil;
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSDictionary *dic = [self dataToDictionary:resultData];
    HaviLog(@"the 结果 is %@",dic);
    
    /*
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"cdkey": @"0SDK-EAA-6688-JESUQ", //手机号码
                          @"password" : @"028760",
                          @"phone" : @"13122785292",
                          @"message" : @"【智护照】1001",
                          @"addserial" : @"10086",
                          };
    
    [client getCMSCode:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
     */
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    HaviLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        HaviLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return NO;
}

- (NSData *)UpLoadFile:(NSData *)data1 andUrl:(NSString *)url andHeader:(NSDictionary *)postParems
{
    
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //
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
        HaviLog(@"the 结果 is %@ 和 %@",resultData,urlResponese);
    
    return resultData;
}

- (NSDictionary *)dataToDictionary:(NSData *)data
{
    NSError *error;
    if (data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        return dic;
    }
    //    if (error) {
    //        return nil;
    //    }
    //    HaviLog(@"the error is %@",error);
    return nil;
}

- (void)getImage:(NSString *)title{
    
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"13122785292"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[a]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        HaviLog(@"succeed");
//        NSArray *requests = batchRequest.requestArray;
//        GetImageApi *a = (GetImageApi *)requests[0];
        // deal with requests result ...
    } failure:^(YTKBatchRequest *batchRequest) {
        HaviLog(@"failed");
    }];

//    GetImageApi *api = [[GetImageApi alloc]initWithImageId:@"Test6"];
//    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//        HaviLog(@"完成%@",request.responseJSONObject);
//        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
//        self.responseLabel.text = string;
//    } failure:^(YTKBaseRequest *request) {
//        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
//        self.responseLabel.text = string;
//        HaviLog(@"失败%@",request.responseJSONObject);
//    }];
    
    
//    SHGetClient *client = [SHGetClient shareInstance];
//    NSDictionary *header = @{
//                             @"AccessToken":@"123456789"
//                             };
//    
//    [client downloadImage:header andImageId:@"13122785292"];
//    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
//        HaviLog(@"完成%@",request.responseJSONObject);
//        NSString *string = [NSString stringWithFormat:@"%@:%@ %@",title,request.responseJSONObject,request];
//        self.responseLabel.text = string;
//    } failure:^(YTKBaseRequest *request) {
//        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
//        self.responseLabel.text = string;
//        HaviLog(@"失败%@",request.responseJSONObject);
//    }];
}

- (void)uploadImage:(NSString *)title
{
    UploadImageApi *api= [[UploadImageApi alloc]initWithImage:[UIImage imageNamed:@"people_onbed"] andUserId:@"13122785292"];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}
- (void)getAlarm:(NSString *)title
{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UUID": @"Test6", //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client queryAlarm:header andPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];

}
//读取传感器历史数据
- (void)sensorDataOld:(NSString *)title{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UUID": @"Test6", //手机号码
                          @"DataProperty" : @"2",
                          @"FromDate": @"20140123",
                          @"EndDate" : @"20140323",
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client querySensorDataOld:header andPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];

}

//读取传感器当日数据
- (void)sensorData:(NSString *)title{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UUID": @"Test6", //手机号码
                          @"DataProperty" : @"3",
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client querySensorDataToday:header andPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}
//用户关联产品码
- (void)userProductCode:(NSString *)title
{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UUID": @"Test6", //手机号码
                          @"UserId" : @"13122785292",
                          @"Description" : @"Test6",
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client querySensorInfoWith:header andPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}
//查询传感器基本信息

- (void)querySensor:(NSString *)title
{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UUID": @"Test6", //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client querySensorInfoWith:header andPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}
//获取全局参数
- (void)queryGloablPara:(NSString *)title{
    SHGetClient *client = [SHGetClient shareInstance];
//    NSDictionary *dic = @{
//                          @"UserId": @"13122785292", //手机号码
//                          };
//    NSDictionary *header = @{
//                             @"AccessToken":@"123456789"
//                             };
    
    [client getGloablParameter:nil];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}

//查询用户关联设备
- (void)queryDevice:(NSString *)title{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UserId": @"13122785292", //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client queryUserProductHeader:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}

//查询用户接口
- (void)queryInfo:(NSString *)title{
    SHGetClient *client = [SHGetClient shareInstance];
    NSDictionary *dic = @{
                          @"UserId": @"13122785292", //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client queryUserInfoWithHeader:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}

//新增用户接口
//    添加用户
- (void)addNewUserWithHeader:(NSString *)title{
    SHPostClient *client = [SHPostClient shareInstance];
    NSDictionary *dic = @{
                          @"CellPhone": @"13122785292", //手机号码
                          @"Email": @"", //邮箱地址，可留空，扩展注册用
                          @"Password": @"123456" //传递明文，服务器端做加密存储
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client addNewUserWithHeader:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
    } failure:^(YTKBaseRequest *request) {
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        self.responseLabel.text = string;
        HaviLog(@"失败%@",request.responseJSONObject);
    }];
}

//
- (void)login:(NSString *)title{
    //    登录
     SHGetClient *client = [SHGetClient shareInstance];
     NSDictionary *dic = @{
     @"CellPhone": @"13122785292", //手机号码
     @"Email": @"", //邮箱地址，可留空，扩展注册用
     @"Password": @"123456" //传递明文，服务器端做加密存储
     };
     NSDictionary *header = @{
     @"AccessToken":@"123456789"
     };
     
     [client loginUserWithHeader:header andWithPara:dic];
     [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
     HaviLog(@"完成%@",request.responseJSONObject);
         NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
         self.responseLabel.text = string;
     } failure:^(YTKBaseRequest *request) {
         NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
         self.responseLabel.text = string;
     HaviLog(@"失败%@",request.responseJSONObject);
     }];

}

- (void)modifyInfo:(NSString*)title{
        SHPutClient *client = [SHPutClient shareInstance];
        NSDictionary *dic = @{
                              @"UserID": @"13122785292", //关键字，必须传递
                              @"UserName": @"大王", //真实姓名
                              @"Password": @"123456", //密码
                              @"Birthday": @"1960-06-01", //生日
                              @"Gender": @"女", //性别
                              @"Height": @"170", //身高CM
                              @"Weight": @"60", //体重KG
                              @"Telephone": @"021-12345678", //电话
                              @"Address": @"上海市徐汇区肇嘉浜路XX号XX室", //家庭住址
                              @"EmergencyContact": @"张三", //紧急联系人
                              @"IsTimeoutAlarmOutOfBed": @"true", //是否离床报警，默认空值时取系统设定
                              @"AlarmTimeOutOfBed": @"120", //离床报警分钟数，默认空值时取系统设定
                              @"IsTimeoutAlarmSleepTooLong": @"true", //是否久睡报警，默认空值时取系统设定
                              @"AlarmTimeSleepTooLong": @"24" //久睡报警小时数，默认空值时取系统设定
    
                              };
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        [client modifyUserInfo:header andWithPara:dic];
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            HaviLog(@"完成%@",request.responseJSONObject);
            NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
            self.responseLabel.text = string;
        } failure:^(YTKBaseRequest *request) {
            NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
            self.responseLabel.text = string;
            HaviLog(@"失败%@",request.responseJSONObject);
        }];

}

//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
