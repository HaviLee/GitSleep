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
#import "EditCellInfoViewController.h"
#import "EditAddressCellViewController.h"

@interface PersonManagerViewController ()<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,RMDateSelectionViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CoolNavi *headerView;
@property (nonatomic, strong) NSDictionary *userInfoDic;
@property (nonatomic, strong) NSArray *cellIconArr;
@property (nonatomic, strong) NSArray *cellTitleArr;
@property (nonatomic, strong) NSArray *cellKeyDicArr;

@property (nonatomic,strong) RMDateSelectionViewController *datePickerSelectionVC;
@property (nonatomic,strong) RMDateSelectionViewController *gerderPicker;
@property (nonatomic,strong) RMDateSelectionViewController *heightPicker;
@property (nonatomic,strong) RMDateSelectionViewController *weightPicker;

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
    NSArray *arr = self.navigationController.viewControllers;
    
    if ([self isEqual:[arr objectAtIndex:0]]) {

       
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",1]];
        [_headerView.backButton setImage:i forState:UIControlStateNormal];
        _headerView.backBlock = ^(){
            [weakSelf.sideMenuViewController presentLeftMenuViewController];
        };
    }else{
        UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",1]];
        [_headerView.backButton setImage:i forState:UIControlStateNormal];
        _headerView.backBlock = ^(){
            [weakSelf backToView];
        };
    }
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
            NSString *titlePhone = [[self.userInfoDic objectForKey:@"UserInfo"] objectForKey:@"CellPhone"];
            self.headerView.titleLabel.text = titlePhone;
        }];
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
    
}

#pragma mark 拍照
- (void)tapIconImage:(UIGestureRecognizer *)gesture
{
    
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
    HaviLog(@"开始上传...");
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([[dic objectForKey:@"ReturnCode"] intValue]==200) {
            [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]];
            [[NSUserDefaults standardUserDefaults]synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [JDStatusBarNotification showWithStatus:@"头像上传成功" dismissAfter:2 styleName:JDStatusBarStyleDark];
                self.headerView.headerImageView.image = [UIImage imageWithData:imageData];
            });

            
        }
        HaviLog(@"8.18测试结果Result--%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
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
    [self.navigationController popViewControllerAnimated:YES];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
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
    if (self.userInfoDic.count>0) {
        if (indexPath.section==1 && indexPath.row==0) {
            cell.personInfoString = [NSString stringWithFormat:@"%@ CM",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
            
        }else if (indexPath.section==1 && indexPath.row==1){
            cell.personInfoString = [NSString stringWithFormat:@"%@ KG",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
        }else{
            cell.personInfoString = [NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==1&&indexPath.row==2) {
        if ([self heightForText:[NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]]]<60) {
            return 60;
        }else{
            return [self heightForText:[NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]]];
        }
    }else{
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row==1){
            [self tapedBirth:nil];
        }else if (indexPath.row==2){
            [self tapedGender:nil];
        }else{
            EditCellInfoViewController *cellInfo = [[EditCellInfoViewController alloc]init];
            if(indexPath.row==0){
                cellInfo.cellInfoType = @"UserName";
            }else if (indexPath.row==3){
                cellInfo.cellInfoType = @"EmergencyContact";
            }else if (indexPath.row==4){
                cellInfo.cellInfoType = @"Telephone";
            }
            cellInfo.saveButtonClicked = ^(NSUInteger index) {
                [self queryUserInfo];
            };
            [self.navigationController pushViewController:cellInfo animated:YES];
        }
    }else{
        if (indexPath.row==0) {
            [self tapedHeight:nil];
        }else if (indexPath.row==1){
            [self tapedWeight:nil];
        }else{
            EditAddressCellViewController *cell = [[EditAddressCellViewController alloc]init];
            cell.cellInfoType = @"Address";
            if ([NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]].length>0) {
                cell.cellInfoString = [NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.cellKeyDicArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
            }
            cell.saveButtonClicked = ^(NSUInteger index) {
                [self queryUserInfo];
            };
            [self.navigationController pushViewController:cell animated:YES];
        }
        
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

- (void)tapedHeight:(UITapGestureRecognizer *)gesture
{
    if (!_heightPicker) {
        self.heightPicker = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _heightPicker.delegate = self;
        _heightPicker.titleLabel.hidden = YES;
        _heightPicker.hideNowButton = YES;
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i=50; i<200; i++) {
                [arr addObject:[NSString stringWithFormat:@"%d CM",i]];
            }
            _heightPicker.pickerDataArray = arr;
        });
    }
    _heightPicker.title = @"height";
    [_heightPicker show];
}

- (void)tapedWeight:(UITapGestureRecognizer *)gesture
{
    if (!_weightPicker) {
        self.weightPicker = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _weightPicker.delegate = self;
        _weightPicker.titleLabel.hidden = YES;
        _weightPicker.hideNowButton = YES;
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (int i=40; i<100; i++) {
                [arr addObject:[NSString stringWithFormat:@"%d KG",i]];
            }
            _weightPicker.pickerDataArray = arr;
        });
    }
    _weightPicker.title = @"weight";
    [_weightPicker show];
}

- (void)tapedGender:(UITapGestureRecognizer *)gesture
{
    if (!_gerderPicker) {
        self.gerderPicker = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _gerderPicker.delegate = self;
        _gerderPicker.titleLabel.hidden = YES;
        _gerderPicker.hideNowButton = YES;
        _gerderPicker.pickerDataArray = @[@"男",@"女"];
    }
    _gerderPicker.title = @"gender";
    [_gerderPicker show];
}

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
    if (aDate) {
        
        if ([vc.title isEqualToString:@"date"]) {
            NSString *dateString = [NSString stringWithFormat:@"%@",aDate];
            NSString *dateSubString = [dateString substringWithRange:NSMakeRange(0, 10)];
            [self saveUserInfoWithKey:@"Birthday" andData:dateSubString];
        }else if ([vc.title isEqualToString:@"gender"]){
            [self saveUserInfoWithKey:@"Gender" andData:aDate];
        }else if ([vc.title isEqualToString:@"height"]){
            NSRange range = [aDate rangeOfString:@" CM"];
            NSString *height = [aDate substringToIndex:range.location];
            [self saveUserInfoWithKey:@"Height" andData:height];
        }else if ([vc.title isEqualToString:@"weight"]){
            NSRange range = [aDate rangeOfString:@" KG"];
            NSString *weight = [aDate substringToIndex:range.location];
            [self saveUserInfoWithKey:@"Weight" andData:weight];
        }
    }
    
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    HaviLog(@"Date selection was canceled");
}

#pragma mark 更新信息
- (void)saveUserInfoWithKey:(NSString *)key andData:(NSString *)data
{
    if (data.length>0) {
        
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
}

#pragma mark 计算高度
- (CGFloat)heightForText:(NSString *)text
{
    //设置计算文本时字体的大小,以什么标准来计算
    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGFloat width = self.view.frame.size.width-185;
    return [text boundingRectWithSize:CGSizeMake(width, 100) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil].size.height+15;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
