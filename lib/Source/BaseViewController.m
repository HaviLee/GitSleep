//
//  BaseViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/26.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BaseViewController.h"
#import "QHConfiguredObj.h"
#import "YTKNetworkPrivate.h"
#import "THPinViewController.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import "Toast+UIView.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import "AppDelegate.h"
#import "LXActivity.h"
#import <TencentOpenAPI/QQApiInterface.h>
//

@interface BaseViewController ()<THPinViewControllerDelegate,LXActivityDelegate>
{
    float _nSpaceNavY;
}
@property (nonatomic, copy) NSString *correctPin;//验证密码
@property (nonatomic, assign) int remainingPinEntries;//验证次数
@end

@implementation BaseViewController

- (void)loadView {
    [super loadView];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

#pragma mark 心率呼吸
- (ToggleView *)timeSwitchButton
{
    if (!_timeSwitchButton) {
        _timeSwitchButton = [[ToggleView alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 130, 15, 120, 25) toggleViewType:ToggleViewTypeNoLabel toggleBaseType:ToggleBaseTypeDefault toggleButtonType:ToggleButtonTypeChangeImage];
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
            [self.timeSwitchButton changeLeftImageWithTime:0.5];;
        }else{
            [self.timeSwitchButton changeRightImageWithTime:0.5];
        }
        
    }
    return _timeSwitchButton;
}

- (UIImageView *)gifImageUp
{
    if (!_gifImageUp) {
        _gifImageUp = [[UIImageView alloc]init];
        _gifImageUp.frame = CGRectMake((self.view.frame.size.width-30)/2, 5, 25, 9);
        NSArray *gifArray = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"btn_up_one"],
                             [UIImage imageNamed:@"btn_up_two"],
                             [UIImage imageNamed:@"btn_up_three"],nil];
        _gifImageUp.animationImages = gifArray; //动画图片数组
        _gifImageUp.animationDuration = 1; //执行一次完整动画所需的时长
        _gifImageUp.animationRepeatCount = 0;  //动画重复次数
    }
    [_gifImageUp startAnimating];
    return _gifImageUp;
}

- (UIImageView *)gifImageDown
{
    if (!_gifImageDown) {
        _gifImageDown = [[UIImageView alloc]init];
        _gifImageDown.frame = CGRectMake((self.view.frame.size.width-30)/2, 5, 25, 9);
        NSArray *gifArray = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"btn_down_one"],
                             [UIImage imageNamed:@"btn_down_two"],
                             [UIImage imageNamed:@"btn_down_three"],
                             nil];
        _gifImageDown.animationImages = gifArray; //动画图片数组
        _gifImageDown.animationDuration = 1; //执行一次完整动画所需的时长
        _gifImageDown.animationRepeatCount = 0;  //动画重复次数
    }
    [_gifImageDown startAnimating];
    return _gifImageDown;
}

- (UIImageView *)diagnoseImage
{
    if (!_diagnoseImage) {
        _diagnoseImage = [[UIImageView alloc]init];
        _diagnoseImage.frame = CGRectMake(13, 23, 15, 15);
        _diagnoseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_diagnostic_message_%d",selectedThemeIndex]];
    }
    return _diagnoseImage;
}

- (LabelLine *)diagonseTitle
{
    if (!_diagonseTitle) {
        _diagonseTitle = [[LabelLine alloc]init];
        _diagonseTitle.frame = CGRectMake(35, 10, 100, 40);
        _diagonseTitle.text = @"诊断报告";
        _diagonseTitle.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        _diagonseTitle.font = [UIFont systemFontOfSize:17];
        
    }
    return _diagonseTitle;
}

- (LabelLine *)diagnoseChoice
{
    if (!_diagnoseChoice) {
        _diagnoseChoice = [[LabelLine alloc]init];
        _diagnoseChoice.frame = CGRectMake(10, 0, 100, 40);
        _diagnoseChoice.text = @"建议";
        _diagnoseChoice.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        _diagnoseChoice.font = [UIFont systemFontOfSize:17];
        
    }
    return _diagnoseChoice;
}

- (LabelLine *)diagnoseResult
{
    if (!_diagnoseResult) {
        _diagnoseResult = [[LabelLine alloc]init];
        _diagnoseResult.frame = CGRectMake(10, 0, 100, 40);
        _diagnoseResult.text = @"诊断";
        _diagnoseResult.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        _diagnoseResult.font = [UIFont systemFontOfSize:17];
        
    }
    return _diagnoseResult;
}

- (LabelLine *)diagnoseExplain
{
    if (!_diagnoseExplain) {
        _diagnoseExplain = [[LabelLine alloc]init];
        _diagnoseExplain.frame = CGRectMake(10, 0, 100, 40);
        _diagnoseExplain.text = @"解释";
        _diagnoseExplain.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _diagnoseExplain.font = [UIFont systemFontOfSize:17];
        
    }
    return _diagnoseExplain;
}

- (UILabel *)diagnoseShow
{
    if (!_diagnoseShow) {
        _diagnoseShow = [[UILabel alloc]init];
        _diagnoseShow.frame = CGRectMake(35, 50, self.view.frame.size.width-20, 40);
        _diagnoseShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];;
        _diagnoseShow.font = [UIFont systemFontOfSize:15];
        _diagnoseShow.text = @"还没有数据,赶快躺下来试试吧";
        _diagnoseShow.numberOfLines = 0;
    }
    return _diagnoseShow;
}

#pragma mark 时间处理格式

- (NSDateFormatter *)dateFormmatterBase
{
    if (!_dateFormmatterBase) {
        _dateFormmatterBase = [[NSDateFormatter alloc]init];
        [_dateFormmatterBase setDateFormat:@"yyyyMMdd"];
        _dateFormmatterBase.timeZone = self.tmZoneBase;
    }
    return _dateFormmatterBase;
}

- (NSDateComponents*)dateComponentsBase
{
    if (!_dateComponentsBase) {
        _dateComponentsBase = [[NSDateComponents alloc] init];
        _dateComponentsBase.timeZone = self.tmZoneBase;
    }
    return _dateComponentsBase;
}

- (NSTimeZone *)tmZoneBase
{
    if (!_tmZoneBase) {
        _tmZoneBase = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:_tmZoneBase];
    }
    return _tmZoneBase;
}

- (UIImageView*)bgImageView
{
    if (_bgImageView == nil) {
        _bgImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
        int picIndex = [QHConfiguredObj defaultConfigure].nThemeIndex;
        NSString *imageName = [NSString stringWithFormat:@"pic_bg_%d",picIndex];
        _bgImageView.image = [UIImage imageNamed:imageName];
    }
    return _bgImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bgImageView];
    // Do any additional setup after loading the view
    self.view.backgroundColor = RGBA(236.f, 236.f, 236.f, 1);
    [self setStatusBarDefine];
    [self addObserver];
    //进行检测是不是有app 密码
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{AppPassWordKey:@"NO"}];
    [self isShowAppSettingPassWord];
    //监听网络
    
}

//reachablility changed

#pragma mark 分享
/**
 *  分享
 *
 *  @return
 */
- (CHTumblrMenuView *)shareMenuView
{
    if (!_shareMenuView) {
        _shareMenuView = [[CHTumblrMenuView alloc] init];
        __block typeof(self) weakSelf = self;
        if ([WXApi isWXAppInstalled]) {
            [_shareMenuView addMenuItemWithTitle:@"朋友圈" andIcon:[UIImage imageNamed:@"icon_wechat"] andSelectedBlock:^{
                HaviLog(@"Text selected");
                [weakSelf sendImageContent];
            }];
            [_shareMenuView addMenuItemWithTitle:@"微信好友" andIcon:[UIImage imageNamed:@"weixin"] andSelectedBlock:^{
                HaviLog(@"Quote selected");
                [weakSelf sendImageToFriend];
                
            }];
        }
        if ([WeiboSDK isWeiboAppInstalled]) {
            [_shareMenuView addMenuItemWithTitle:@"新浪微博" andIcon:[UIImage imageNamed:@"sina"] andSelectedBlock:^{
                HaviLog(@"Photo selected");
                [weakSelf shareButtonPressed];
            }];
        }
        
    }
    return _shareMenuView;
}

- (LXActivity*)shareNewMenuView
{
    
    NSArray *shareButtonTitleArray = @[@"朋友圈",@"微信好友",@"新浪微博",@"QQ好友",@"QQ空间"];
    NSArray *shareButtonImageNameArray = @[@"icon_wechat",@"weixin",@"sina",@"qq",@"qqzone"];
    
    _shareNewMenuView = [[LXActivity alloc] initWithTitle:@"分享到社交平台" delegate:self cancelButtonTitle:nil ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonImageNameArray];
    return _shareNewMenuView;
}

- (void)didClickOnImageIndex:(NSInteger *)imageIndex
{
    NSLog(@"%d",(int)imageIndex);
    if ((int)imageIndex ==0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self sendImageContent];
        });
        
    }else if ((int)imageIndex==1){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self sendImageToFriend];
        });
    }else if ((int)imageIndex == 2){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shareButtonPressed];
        });
    }else if ((int)imageIndex == 3){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shareButtonQQ];
        });
    }else if ((int)imageIndex == 4){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self shareButtonQQZone];
        });
    }
}


#pragma mark 分享到qq

- (void)shareButtonQQZone
{
    NSString *utf8String = @"http://www.meddo.com.cn";
    NSString *title = @"智照护";
    NSString *description = @"我正在使用智照护App";
    NSString *previewImageUrl = @"http://www.meddo.com.cn/images/logo.jpg";
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:utf8String]
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    if (sent ==0) {
        HaviLog(@"分享成功");
    }else{
        [self.view makeToast:@"分享出错啦" duration:2 position:@"center"];
    }
}

- (void)shareButtonQQ
{
    NSData *data;
    UIImage *image1 = [self captureScreen];
    
    if (UIImagePNGRepresentation(image1) == nil) {
        
        data = UIImageJPEGRepresentation(image1, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image1);
    }    //
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:data
                                               previewImageData:data
                                                          title:@"智照护"
                                                    description:@"我正在使用智照护app"];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
    //将内容分享到qq
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    if (sent ==0) {
        HaviLog(@"分享成功");
    }else{
        [self.view makeToast:@"分享出错啦" duration:2 position:@"center"];
    }

}

#pragma mark 分享到微博
- (void)shareButtonPressed
{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WBRedirectURL;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare] authInfo:authRequest access_token:myDelegate.wbtoken];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    [WeiboSDK sendRequest:request];
}

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    message.text = NSLocalizedString(@"我正在使用智照护App,快来使用啦!", nil);
    WBImageObject *image = [WBImageObject object];
    NSData *data;
    UIImage *image1 = [self captureScreen];

    if (UIImagePNGRepresentation(image1) == nil) {
        
        data = UIImageJPEGRepresentation(image1, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image1);
    }
    image.imageData = data;
    message.imageObject = image;
    return message;
}
#pragma mark 分享给好友
- (void)sendImageToFriend
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = @"专访张小龙：产品之上的世界观";
    message.description = @"微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。";
    UIImage *image = [self captureScreen];
    [message setThumbImage:image];
    
    WXImageObject *ext = [WXImageObject object];
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
    }
    ext.imageData = data;
    
    message.mediaObject = ext;
    message.mediaTagName = @"WECHAT_TAG_JUMP_APP";
    message.messageExt = @"这是第三方带的测试字段";
    message.messageAction = @"<action>dotalist</action>";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}
#pragma mark 分享到朋友圈
- (void)sendImageContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *image = [self captureScreen];
    [message setThumbImage:image];
    WXImageObject *ext = [WXImageObject object];
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil) {
        
        data = UIImageJPEGRepresentation(image, 1);
        
    } else {
        
        data = UIImagePNGRepresentation(image);
    }
    ext.imageData = data;
    
    message.mediaObject = ext;
    message.title = @"智照护";
    message.mediaTagName = @"WECHAT_TAG_JUMP_APP";
    message.messageExt = @"智照护-您的睡眠管家";
    message.messageAction = @"<action>dotalist</action>";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}

#pragma mark 自定义状态栏
/**
 *  自定义状态栏
 */
- (void)setStatusBarDefine
{
    _statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 0.f)];
    _nSpaceNavY = 0;
    _statusBarView.frame = CGRectMake(_statusBarView.frame.origin.x, _statusBarView.frame.origin.y, _statusBarView.frame.size.width, 20.f);
    _statusBarView.backgroundColor = [UIColor clearColor];
    ((UIImageView *)_statusBarView).backgroundColor = [UIColor clearColor];
    [self.view addSubview:_statusBarView];
    _nSpaceNavY = 0;
}
/**
 *  自定义导航栏有背景图片
 *
 *  @param szTitle  导航栏标题
 *  @param menuItem 导航栏的左右两侧的button
 */
- (void)createNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem
{
    UIImageView *navIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, _nSpaceNavY, self.view.frame.size.width, 64-_nSpaceNavY)];
    navIV.tag = 3000;
    int picIndex = [QHConfiguredObj defaultConfigure].nThemeIndex;
    NSString *imageName = [NSString stringWithFormat:@"navigation_bar_bg_%d",picIndex];
    [navIV setImage:[UIImage imageNamed:imageName]];
    [self.view addSubview:navIV];
    
    /* { 导航条 } */
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = [UIColor clearColor];
    [self.view addSubview:_navView];
    _navView.userInteractionEnabled = YES;
    
    if (szTitle != nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
        [titleLabel setText:szTitle];
        titleLabel.tag = 3001;
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor]];
        [titleLabel setFont:DefaultWordFont];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [_navView addSubview:titleLabel];
    }
    
    UIView *item1 = menuItem(0);
    if (item1 != nil)
    {
        [_navView addSubview:item1];
    }
    UIView *item2 = menuItem(1);
    if (item2 != nil)
    {
        _rightV = item2;
        [_navView addSubview:item2];
    }
}
/**
 *  创建透明的导航栏
 *
 *  @param szTitle  标题
 *  @param menuItem 左右放回键
 */
- (void)createClearBgNavWithTitle:(NSString *)szTitle createMenuItem:(UIView *(^)(int nIndex))menuItem
{
    UIImageView *navIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, _nSpaceNavY, self.view.frame.size.width, 64-_nSpaceNavY)];
    navIV.tag = 2000;
    [self.view addSubview:navIV];
    
    /* { 导航条 } */
    _clearNavView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = [UIColor clearColor];
    [self.view addSubview:_clearNavView];
    _clearNavView.userInteractionEnabled = YES;
    
    if (szTitle != nil)
    {
        self.clearNaviTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_clearNavView.frame.size.width - 200)/2, 0, 200, 44)];
        [_clearNaviTitleLabel setText:szTitle];
        _clearNaviTitleLabel.tag = 2001;
        [_clearNaviTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_clearNaviTitleLabel setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor]];
        [_clearNaviTitleLabel setFont:DefaultWordFont];
        [_clearNaviTitleLabel setBackgroundColor:[UIColor clearColor]];
        [_clearNavView addSubview:_clearNaviTitleLabel];
    }
    
    UIView *item1 = menuItem(0);
    if (item1 != nil)
    {
        [_clearNavView addSubview:item1];
    }
    UIView *item2 = menuItem(1);
    if (item2 != nil)
    {
        _clearRightV = item2;
        [_clearNavView addSubview:item2];
    }
}

- (void)createClearBgNavWithTitle:(NSString *)szTitle andTitleColor:(UIColor *)color createMenuItem:(UIView *(^)(int nIndex))menuItem
{
    UIImageView *navIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, _nSpaceNavY, self.view.frame.size.width, 64-_nSpaceNavY)];
    navIV.tag = 2000;
    [self.view addSubview:navIV];
    
    /* { 导航条 } */
    _clearNavView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
    ((UIImageView *)_navView).backgroundColor = [UIColor clearColor];
    [self.view addSubview:_clearNavView];
    _clearNavView.userInteractionEnabled = YES;
    
    if (szTitle != nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_clearNavView.frame.size.width - 200)/2, 0, 200, 40)];
        [titleLabel setText:szTitle];
        titleLabel.tag = 2001;
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:color];
        [titleLabel setFont:DefaultWordFont];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [_clearNavView addSubview:titleLabel];
    }
    
    UIView *item1 = menuItem(0);
    if (item1 != nil)
    {
        [_clearNavView addSubview:item1];
    }
    UIView *item2 = menuItem(1);
    if (item2 != nil)
    {
        _clearRightV = item2;
        [_clearNavView addSubview:item2];
    }
}


- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadThemeImage) name:RELOADIMAGE object:nil];
    //检测设置APP密码
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(isShowAppSettingPassWord) name:AppPassWorkSetOkNoti object:nil];
    //移除检测
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeAppSettingPassWord) name:AppPassWordCancelNoti object:nil];
}
#pragma mark 设备锁
- (void)removeAppSettingPassWord
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                      object:nil];
    }
}

- (void)isShowAppSettingPassWord
{
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
}

#pragma mark 设备锁
- (void)showPinViewAnimated:(BOOL)animated
{
    THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    self.correctPin = [[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey];
    pinViewController.promptTitle = @"密码验证";
    pinViewController.promptColor = [UIColor whiteColor];
    pinViewController.view.tintColor = [UIColor whiteColor];
    
    // for a solid background color, use this:
    pinViewController.backgroundColor = [UIColor colorWithRed:0.141f green:0.165f blue:0.208f alpha:1.00f];
    
    // for a translucent background, use this:
    self.view.tag = THPinViewControllerContentViewTag;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    pinViewController.translucentBackground = NO;
    UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
    NSArray *arr = nav.viewControllers;
    UIViewController *controller = [arr lastObject];
    [controller presentViewController:pinViewController animated:animated completion:nil];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (!isThirdLogin) {
        [self showPinViewAnimated:NO];
    }
}

#pragma mark - THPinViewControllerDelegate

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 4;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
    if ([pin isEqualToString:self.correctPin]) {
        return YES;
    } else {
        self.remainingPinEntries--;
        HaviLog(@"还能输入%d次",self.remainingPinEntries);
        return NO;
    }
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    //f返回yes可以无限次的验证
    return YES;
}

- (void)incorrectPinEnteredInPinViewController:(THPinViewController *)pinViewController
{
    if (self.remainingPinEntries > 6 / 2) {
        return;
    }
    
}

- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(THPinViewController *)pinViewController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //默认值改变
        [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:AppPassWordKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //移除后台检测
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:AppPassWordKey] isEqualToString:@"NO"]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
                                                          object:nil];
        }
        LoginViewController *login = [[LoginViewController alloc]init];
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
        navi.navigationBarHidden = YES;
        [self presentViewController:navi animated:YES completion:nil];
    });
}
/**
 *  子类重写此方法，进行切换主题
 */
- (void)reloadThemeImage
{
    UIImageView *navIV = (UIImageView *)[self.view viewWithTag:3000];
    int picIndex = [QHConfiguredObj defaultConfigure].nThemeIndex;
    selectedThemeIndex = picIndex;
    NSString *imageName = [NSString stringWithFormat:@"navigation_bar_bg_%d",picIndex];
    [navIV setImage:[UIImage imageNamed:imageName]];
    UILabel *label1 = (UILabel *)[_navView viewWithTag:3001];
    label1.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    UILabel *label2 = (UILabel *)[_navView viewWithTag:2001];
    label2.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    [self.leftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]] forState:UIControlStateNormal];
     self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_%d",picIndex]];
}

/**
 *  将nsdata数据转换位字典
 *
 *  @param data data数据
 *
 *  @return 返回字典
 */
- (NSDictionary *)dataToDictionary:(NSData *)data
{
    NSError *error;
    if (data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            HaviLog(@"转换错误%@",error)
        };
        return dic;
    }
    return nil;
}

/**
 *
 *  @return
 */
#pragma mark setter
- (CalendarHomeViewController *)chvc
{
    if (_chvc == nil) {
        _chvc = [[CalendarHomeViewController alloc]init];
        
        _chvc.calendartitle = @"日历";
        NSDate *date = [[NSDate date]dateByAddingHours:8];
        NSDate *oldDate = [self.dateFormmatterBase dateFromString:@"20150101"];
        int day = (int)[date daysFrom:oldDate]+1;
        [_chvc setAirPlaneToDay:day ToDateforString:[NSString stringWithFormat:@"2015-01-01"]];//飞机初始化方法
    }
    return _chvc;
}

- (UIButton *)menuButton
{
    if (!_menuButton) {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
        [_menuButton setImage:i forState:UIControlStateNormal];
        [_menuButton setFrame:CGRectMake(5, 0, 44, 44)];
        [_menuButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, 0, 44, 44);
        [_leftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _rightButton;
}

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

- (UIImageView *)gifHeart
{
    if (!_gifHeart) {
        _gifHeart = [[UIImageView alloc]init];
        _gifHeart.frame = CGRectMake(0, 0, 40, 40);
    }
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_1_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_2_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_3_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_4_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_5_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_6_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_7_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"heart_8_%d",selectedThemeIndex]],nil];
    _gifHeart.animationImages = gifArray; //动画图片数组
    _gifHeart.animationDuration = 5; //执行一次完整动画所需的时长
    _gifHeart.animationRepeatCount = 0;  //动画重复次数
    [_gifHeart startAnimating];
    return _gifHeart;
}

- (UIImageView *)gifbreath
{
    if (!_gifbreath) {
        _gifbreath = [[UIImageView alloc]init];
        _gifbreath.frame = CGRectMake(0, 0, 40, 40);
    }
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe1_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe2_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe3_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe4_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe5_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe6_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe7_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"breathe8_%d",selectedThemeIndex]],nil];
    _gifbreath.animationImages = gifArray; //动画图片数组
    _gifbreath.animationDuration = 5; //执行一次完整动画所需的时长
    _gifbreath.animationRepeatCount = 0;  //动画重复次数
    [_gifbreath startAnimating];
    return _gifbreath;

}

- (UIImageView *)gifLeave
{
    if (!_gifLeave) {
        _gifLeave = [[UIImageView alloc]init];
        _gifLeave.frame = CGRectMake(0, 0, 40, 40);
    }
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up1_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up2_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up3_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up4_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up5_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up6_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"get_up7_%d",selectedThemeIndex]],nil];
    _gifLeave.animationImages = gifArray; //动画图片数组
    _gifLeave.animationDuration = 5; //执行一次完整动画所需的时长
    _gifLeave.animationRepeatCount = 0;  //动画重复次数
    [_gifLeave startAnimating];
    return _gifLeave;
    
}

- (UIImageView *)gifTurn
{
    if (!_gifTurn) {
        _gifTurn = [[UIImageView alloc]init];
        _gifTurn.frame = CGRectMake(0, 0, 40, 40);
    }
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:[NSString stringWithFormat:@"leave1_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"leave2_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"leave3_%d",selectedThemeIndex]],
                         [UIImage imageNamed:[NSString stringWithFormat:@"leave4_%d",selectedThemeIndex]],nil];
    _gifTurn.animationImages = gifArray; //动画图片数组
    _gifTurn.animationDuration = 5; //执行一次完整动画所需的时长
    _gifTurn.animationRepeatCount = 0;  //动画重复次数
    [_gifTurn startAnimating];
    return _gifTurn;
    
}


//- (UUChart *)chartTable
//{
//    if (!_chartTable) {
//        
//        _chartTable = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 170)
//                                                  withSource:nil
//                                                   withStyle:UUChartBarStyle];
//    }
//    return _chartTable;
//}

- (DatePickerView *)datePicker
{
    if (!_datePicker) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        _datePicker = [[DatePickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - datePickerHeight, self.view.frame.size.width,datePickerHeight)];
    }
    return _datePicker;
}


- (OTCover *)userInfoTableView
{
    if (!_userInfoTableView) {
        _userInfoTableView = [[OTCover alloc] initWithTableViewWithHeaderImage:[UIImage imageNamed:@"pic_heder_portrait"] withOTCoverHeight:150];
    }
    return _userInfoTableView;
}

- (UITableView *)sideTableView {
    if (!_sideTableView) {
        _sideTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _sideTableView.backgroundColor = [UIColor clearColor];
        _sideTableView.delegate = self;
        _sideTableView.dataSource = self;
    }
    return _sideTableView;
}

#pragma tableView

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sideArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *stringIndentifier = @"sideIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stringIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringIndentifier];
    
    }
    return cell;
}

#pragma center

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 处理键盘事件
- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

//登出时进行此操作
- (void)showLoginView:(NSNotification *)noti
{
    LoginViewController *login = [[LoginViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:login];
    navi.navigationBarHidden = YES;
    [self presentViewController:navi animated:YES completion:^{
        //        [self tapImage:nil];
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }];
    
}


/**
 *  移除通知
 *
 *  @param animated 
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

#pragma mark 进行时间缓存
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
        [YTKNetworkPrivate addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"HaviRequestCache"];
    [self checkDirectory:path];
    return path;
}

- (NSString *)cacheFileNameWithType:(NSString *)type {
    NSString *requestInfo = [NSString stringWithFormat:@"%@",@"timeCache"];
    NSString *cacheFileName = [YTKNetworkPrivate md5StringFromString:requestInfo];
    return cacheFileName;
}

- (NSString *)cacheFilePathWithName:(NSString *)nameType {
    NSString *cacheFileName = [self cacheFileNameWithType:nameType];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (int)cacheFileDuration:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // get file attribute
    NSError *attributesRetrievalError = nil;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:path
                                                             error:&attributesRetrievalError];
    if (!attributes) {
        YTKLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return -1;
    }
    int seconds = -[[attributes fileModificationDate] timeIntervalSinceNow];
    return seconds;
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];

    return destinationDateNow;
}

- (NSDate*)getNowDate
{
    return [self getNowDateFromatAnDate:[NSDate date]];
}

#pragma mark 检测网络
+ (NSInteger)networkStatus
{
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.oschina.net"];
    return reachability.currentReachabilityStatus;
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}

- (UIImage *) captureScreen {
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark 下载头像

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

- (BOOL)isThirdAppAllInstalled
{
    return [WeiboSDK isWeiboAppInstalled]||[WXApi isWXAppInstalled];
}


@end
