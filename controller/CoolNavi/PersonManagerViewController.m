//
//  ViewController.m
//  CoolNavi
//
//  Created by ian on 15/1/19.
//  Copyright (c) 2015年 ian. All rights reserved.
//
#define kWindowHeight 205.0f
#import "PersonManagerViewController.h"
#import "CoolNavi.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MTStatusBarOverlay.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SHGetClient.h"
#import "PersonDetailTableViewCell.h"
#import "RMDateSelectionViewController.h"
#import "SHPutClient.h"

@interface PersonManagerViewController ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,RMDateSelectionViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CoolNavi *headerView;
@property (nonatomic, strong) NSDictionary *userInfoDic;
@property (nonatomic, strong) NSArray *cellIconArr;
@property (nonatomic, strong) NSArray *cellTitleArr;
@property (nonatomic, strong) NSArray *cellKeyDicArr;

@property (nonatomic,strong) RMDateSelectionViewController *datePickerSelectionVC;


@end

@implementation PersonManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellIconArr = @[@[@"name",@"birthday",@"gender",@"icon_phone_1",@"emergency_Contact",@"icon_phone1"],@[@"height",@"weight",@"home"]];
    self.cellTitleArr = @[@[@"姓名:",@"生日:",@"性别:",@"紧急联系人:",@"紧急联系人电话:"],@[@"身高:",@"体重:",@"家庭住址:"]];
    self.cellKeyDicArr = @[@[@"UserName",@"Birthday",@"Gender",@"EmergencyContact",@"Telephone"],@[@"Height",@"Weight",@"Address"]];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _headerView = [[CoolNavi alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kWindowHeight)backGroudImage:@"background" headerImageURL:@"http://d.hiphotos.baidu.com/image/pic/item/0ff41bd5ad6eddc4f263b0fc3adbb6fd52663334.jpg" title:@"匿名用户" subTitle:@""];
    __block typeof(self) weakSelf = self;
    _headerView.scrollView = self.tableView;
    _headerView.imgActionBlock = ^(){
        [weakSelf tapIconImage:nil];
    };
    _headerView.backBlock = ^(){
        [weakSelf.sideMenuViewController presentLeftMenuViewController];
    };
    [_headerView.backButton addTarget:self action:@selector(backToView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_headerView];
    
    //
    [self queryUserInfo];
}

//获取用户基本信息
- (void)queryUserInfo
{
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    SHGetClient *client = [SHGetClient shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    NSDictionary *dic = @{
                          @"UserId": thirdPartyLoginUserId, //手机号码
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    
    [client queryUserInfoWithHeader:header andWithPara:dic];
    if ([client cacheJson]) {
        self.userInfoDic = (NSDictionary*)[client cacheJson];
        [self.tableView reloadData];
    }
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [MMProgressHUD dismissAfterDelay:0.3];
        [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
            NSDictionary *dic = (NSDictionary *)request.responseJSONObject;
            self.userInfoDic = dic;
            [self.tableView reloadData];
        }];
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

#pragma mark 拍照
- (void)tapIconImage:(UIGestureRecognizer *)gesture
{
//    if (![self isNetworkExist]) {
//        
//        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
//        return;
//    }
    
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"设置头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选择", nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 255;
    
    CGRect rect = self.view.frame;
    //在这里解决了ios7中弹出照相机错误
    [sheet showFromRect:rect inView:[UIApplication sharedApplication].keyWindow animated:YES];
}

#pragma mark actionSheet代理

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 2:
                    // 取消
                    return;
                case 0:{
                    // 相机
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                        [self.view makeToast:@"请在设置中打开照相机权限" duration:3 position:@"center"];
                        NSLog(@"相机权限受限");
                    }else{
                        sourceType = UIImagePickerControllerSourceTypeCamera;
                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                        imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                        imagePickerController.delegate = self;
                        
                        imagePickerController.allowsEditing = YES;
                        
                        imagePickerController.sourceType = sourceType;
                        
                        [self presentViewController:imagePickerController animated:YES completion:^{}];
                    }
                    
                    break;
                }
                    
                case 1:{
                    // 相册
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        [self.view makeToast:@"请在设置中打开照片库权限" duration:3 position:@"center"];
                    }else{
                        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                        imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                        imagePickerController.delegate = self;
                        
                        imagePickerController.allowsEditing = YES;
                        
                        imagePickerController.sourceType = sourceType;
                        
                        [self presentViewController:imagePickerController animated:YES completion:^{
                            //                        self.navigationController.navigationBarHidden = YES;
                        }];
                    }
                    break;
                }
            }
        }
        else {
            if (buttonIndex == 1) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                imagePickerController.delegate = self;
                
                imagePickerController.allowsEditing = YES;
                
                imagePickerController.sourceType = sourceType;
                
                [self presentViewController:imagePickerController animated:YES completion:^{}];
                
            }
        }
        // 跳转到相机或相册页面
        
    }
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    // 保存图片至本地，方法见下文
//    [HaviAnimationView animationMoveUp:self.iconImageButton duration:1.8];
//    self.iconImageButton.image = image;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [self calculateIconImage:image];
        [self uploadWithImageData:imageData];
    });
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}
#define UploadImageSize          100000
- (NSData *)calculateIconImage:(UIImage *)image
{
    if(image){
        
        [image fixOrientation];
        CGFloat height = image.size.height;
        CGFloat width = image.size.width;
        NSData *data = UIImageJPEGRepresentation(image,1);
        
        float n;
        n = (float)UploadImageSize/data.length;
        data = UIImageJPEGRepresentation(image, n);
        while (data.length > UploadImageSize) {
            image = [UIImage imageWithData:data];
            height /= 2;
            width /= 2;
            image = [image scaleToSize:CGSizeMake(width, height)];
            data = UIImageJPEGRepresentation(image,1);
        }
        return data;
        
    }
    return nil;
}

#pragma mark 上传头像
- (void)uploadWithImageData:(NSData*)imageData
{
    NSDictionary *dicHeader = @{
                                @"AccessToken": @"123456789",
                                };
    NSString *urlStr = [NSString stringWithFormat:@"%@/v1/file/UploadFile/%@",BaseUrl,thirdPartyLoginUserId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:0 timeoutInterval:5.0f];
    [request setValue:[dicHeader objectForKey:@"AccessToken"] forHTTPHeaderField:@"AccessToken"];
    [self setRequest:request withImageData:imageData];
    NSLog(@"开始上传...");
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[dic objectForKey:@"ReturnCode"] intValue]==200) {
            [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                [overlay postImmediateFinishMessage:@"头像修改成功" duration:2 animated:YES];
                self.headerView.headerImageView.image = [UIImage imageWithData:imageData];
            });

            
        }
        NSLog(@"8.18测试结果Result--%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    }];
}

- (void)setRequest:(NSMutableURLRequest *)request withImageData:(NSData*)imageData
{
    NSMutableData *body = [NSMutableData data];
    // 表单数据
    
    /// 图片数据部分
    NSMutableString *topStr = [NSMutableString string];
    [body appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置请求类型为post请求
    request.HTTPMethod = @"post";
    // 设置request的请求体
    request.HTTPBody = body;
    // 设置头部数据，标明上传数据总大小，用于服务器接收校验
    [request setValue:[NSString stringWithFormat:@"%ld", body.length] forHTTPHeaderField:@"Content-Length"];
    // 设置头部数据，指定了http post请求的编码方式为multipart/form-data（上传文件必须用这个）。
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; image/png"] forHTTPHeaderField:@"Content-Type"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    HaviLog(@"cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)backToView
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        CGRect rect = _tableView.frame;
        rect.origin.y = 0;
        _tableView.frame = rect;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section==0) {
        return 5;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellReuseIdentifier  = @"cell";
    
    PersonDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    if (!cell) {
        cell = [[PersonDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifier andIndexPath:indexPath];
        cell.selectionStyle  = UITableViewCellSelectionStyleGray;
    }
    cell.personInfoTitle = [[self.cellTitleArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    cell.personInfoIconString = [[self.cellIconArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    cell.personInfoString = [NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            
        }else if (indexPath.row==1){
            [self tapedBirth:nil];
        }else if (indexPath.row==2){
        }
    }else{
        
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (thirdPartyLoginIcon.length>0) {
        [self.headerView.headerImageView setImageWithURL:[NSURL URLWithString:thirdPartyLoginIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
    }else{
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]isEqual:@""]) {
            NSString *url = [NSString stringWithFormat:@"%@/v1/file/DownloadFile/%@",BaseUrl,thirdPartyLoginUserId];
            [self.headerView.headerImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
        }else{
            if ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]]) {
                
                self.headerView.headerImageView.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]];
            }
        }
        
    }
}

#pragma mark 选择器
- (void)tapedBirth:(UITapGestureRecognizer *)gesture
{
    if (!_datePickerSelectionVC) {
        self.datePickerSelectionVC = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewDateType];
        _datePickerSelectionVC.delegate = self;
        _datePickerSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
        _datePickerSelectionVC.titleLabel.hidden = YES;
        _datePickerSelectionVC.hideNowButton = YES;
    }
    _datePickerSelectionVC.title = @"date";
    [_datePickerSelectionVC show];
}
#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSString *)aDate {
    if ([vc.title isEqualToString:@"date"]) {
        NSString *dateString = [NSString stringWithFormat:@"%@",aDate];
        NSString *dateSubString = [dateString substringWithRange:NSMakeRange(0, 10)];
        [self saveUserInfoWithKey:@"Birthday" andData:dateSubString];
//        self.birthteTextField.text = dateSubString;
    }else if ([vc.title isEqualToString:@"gender"]){
//        self.sexTextField.text = aDate;
    }else if ([vc.title isEqualToString:@"height"]){
//        self.heightTextField.text = aDate;
    }else if ([vc.title isEqualToString:@"weight"]){
//        self.weightTextField.text = aDate;
    }
    
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    HaviLog(@"Date selection was canceled");
}

#pragma mark 更新信息
- (void)saveUserInfoWithKey:(NSString *)key andData:(NSString *)data
{
    
    NSArray *images = @[[UIImage imageNamed:@"havi1_0"],
                        [UIImage imageNamed:@"havi1_1"],
                        [UIImage imageNamed:@"havi1_2"],
                        [UIImage imageNamed:@"havi1_3"],
                        [UIImage imageNamed:@"havi1_4"],
                        [UIImage imageNamed:@"havi1_5"]];
    [[MMProgressHUD sharedHUD] setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:nil status:nil images:images];
    
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": thirdPartyLoginUserId, //关键字，必须传递
                          key:data,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789",
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"保存%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadUserInfo" object:nil];
                [self queryUserInfo];
            }];
        }else{
            [MMProgressHUD dismissWithError:[NSString stringWithFormat:@"%@",resposeDic] afterDelay:2];
        }
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
