//
//  UserInfoViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/2/28.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "UserInfoViewController.h"
#import "HaviAnimationView.h"

#import "UserInfoNameTableViewCell.h"
#import "UserInfoPhoneTableViewCell.h"
#import "UserContactTableViewCell.h"
#import "EditUserInfoViewController.h"
#import "SHGetClient.h"
#import "UserInfoTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface UserInfoViewController ()<UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic,assign) CGRect originalFrame;
@property (nonatomic,assign) CGRect titleFrame;
@property (nonatomic,strong) NSDictionary *userInfoDic;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSArray *iconArr;
@property (nonatomic,strong) NSArray *keyDic;
//

@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
    self.navigationController.navigationBarHidden = YES;
    self.titleArr = @[@[@"姓名:",@"生日:",@"性别:",@"手机:",@"紧急联系人:",@"紧急联系人电话:"],@[@"身高:",@"体重:",@"家庭住址:"]];
    self.iconArr = @[@[@"name",@"birthday",@"gender",@"icon_phone_1",@"emergency_Contact",@"icon_phone1"],@[@"height",@"weight",@"home"]];
    self.keyDic = @[@[@"UserName",@"Birthday",@"Gender",@"CellPhone",@"EmergencyContact",@"Telephone"],@[@"Height",@"Weight",@"Address"]];

//
    [self.view addSubview:self.userInfoTableView];
    self.userInfoTableView.tableView.delegate = self;
    self.userInfoTableView.tableView.dataSource = self;
    self.userInfoTableView.headerImageView.userInteractionEnabled = YES;
    self.userInfoTableView.tableView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
    self.userInfoTableView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
    self.userInfoTableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            NSArray *arr = self.navigationController.viewControllers;
            if ([self isEqual:[arr objectAtIndex:0]]) {
                
                _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"re_order_%d",selectedThemeIndex]];
                [_backButton setImage:i forState:UIControlStateNormal];
                [_backButton setFrame:CGRectMake(5, 0, 44, 44)];
                [_backButton addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]];
                [_backButton setImage:i forState:UIControlStateNormal];
                [_backButton setFrame:CGRectMake(5, 0, 44, 44)];
                [_backButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchUpInside];
            }
            return _backButton;
        }else if (nIndex == 0){
            _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _editButton.frame = CGRectMake(self.view.frame.size.width-44, 2, 40, 44);
            [self.userInfoTableView addSubview:_editButton];
            [_editButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_compose_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            _editButton.contentMode = UIViewContentModeScaleAspectFit;
            [_editButton addTarget:self action:@selector(editUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            return self.editButton;
        }
        
        return nil;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HaviAnimationView animationRevealFromTop:self.iconImageButton];
    });
    [self queryUserInfo];
    //获取用户头像
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
    return resultData;
}

//获取用户基本信息
- (void)queryUserInfo
{
    /*old
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"加载中..."];
     */
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
        [self.userInfoTableView.tableView reloadData];
    }
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [MMProgressHUD dismissAfterDelay:0.3];
        [[MMProgressHUD sharedHUD] setDismissAnimationCompletion:^{
            NSDictionary *dic = (NSDictionary *)request.responseJSONObject;
            self.userInfoDic = dic;
            [self.userInfoTableView.tableView reloadData];
        }];
    } failure:^(YTKBaseRequest *request) {
        [MMProgressHUD dismiss];
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];

}


- (void)editUserInfo:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadUserInfo:) name:@"reloadUserInfo" object:nil];
    EditUserInfoViewController *edit = [[EditUserInfoViewController alloc]init];
    edit.editUserInfoDic = self.userInfoDic;
    [self.navigationController pushViewController:edit animated:YES];
}

- (void)reloadUserInfo:(NSNotification *)noti
{
    [self queryUserInfo];
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [[self.titleArr objectAtIndex:0] count];
    }else{
        return [[self.titleArr objectAtIndex:1] count];
    }
        
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *nameIdentifier = @"nameCell";
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nameIdentifier];
    if (!cell) {
        cell = [[UserInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameIdentifier andIndexPath:indexPath];
    }
    cell.userCellTitle = [[self.titleArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    //    [cell layoutSubviews];
    cell.iconTitle = [[self.iconArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (self.userInfoDic.count>0) {
        
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                if ([NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]].length!=0) {
                    cell.cellDataString = [NSString stringWithFormat:@"%@CM",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
                }
            }else if (indexPath.row == 1){
                if ([NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]].length!=0) {
                    cell.cellDataString = [NSString stringWithFormat:@"%@KG",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
                }
            }else{
                cell.cellDataString = [NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
            }
        }else{
            cell.cellDataString = [NSString stringWithFormat:@"%@",[[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:[[self.keyDic objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]];
        }
    }
    cell.backgroundColor = [UIColor whiteColor];
    if ((indexPath.section == 0&& indexPath.row == 0)||(indexPath.section == 1&& indexPath.row == 0)) {
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
        imageLine.backgroundColor = [UIColor grayColor];
        imageLine.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1);
        [cell addSubview:imageLine];
        imageLine.alpha = 0.5;
    }
    if ((indexPath.section == 0&& indexPath.row == 6)||(indexPath.section == 1&& indexPath.row == 2)) {
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
        imageLine.backgroundColor = [UIColor grayColor];
        imageLine.frame = CGRectMake(0, TableViewCellHeight-1, self.view.bounds.size.width, 1);
        [cell addSubview:imageLine];
        imageLine.alpha = 0.5;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0|| indexPath.row == 1||indexPath.row == 2|| indexPath.row == 3||indexPath.row == 4||indexPath.row == 5) {
            UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
            imageLine.frame = CGRectMake(15, TableViewCellHeight-1, self.view.bounds.size.width-15, 1);
            [cell addSubview:imageLine];
            imageLine.alpha = 0.5;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0|| indexPath.row == 1) {
            UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
            imageLine.frame = CGRectMake(15, TableViewCellHeight-1, self.view.bounds.size.width-15, 1);
            [cell addSubview:imageLine];
            imageLine.alpha = 0.5;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 75;
    }else if (section == 1){
        return 20;
    }else if (section == 2){
        return 40;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section==0) {
//        return 120;
//    }else if (indexPath.section == 1){
//        return 180;
//    }
//    return 120;
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 10;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
        sectionView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        [sectionView addSubview:self.iconImageButton];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIconImage:)];
        [_iconImageButton addGestureRecognizer:tap];
        
        self.originalFrame = self.iconImageButton.frame;
        self.userTitleLabel = [[UILabel alloc]init];
        [sectionView addSubview:_userTitleLabel];
        _userTitleLabel.textColor = [UIColor colorWithRed:0.149f green:0.702f blue:0.678f alpha:1.00f];
        _userTitleLabel.textAlignment = NSTextAlignmentCenter;
        _userTitleLabel.font = DefaultWordFont;
        _userTitleLabel.frame = CGRectMake((self.view.bounds.size.width-120)/2, 50, 120, 25);
        self.titleFrame = _userTitleLabel.frame;
        _userTitleLabel.text = [[self.userInfoDic objectForKey:@"UserInfo"]objectForKey:@"UserName"];
        return sectionView;
    }else if (section == 1){
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        sectionView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        return sectionView;
    }else if (section == 2){
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        sectionView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        UILabel *labelShow = [[UILabel alloc]init];
        [sectionView addSubview:labelShow];
        labelShow.text = @"紧急联系人";
        [labelShow makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sectionView.left).offset(20);
            make.bottom.equalTo(sectionView.bottom).offset(-5);
        }];
        return sectionView;
    }
    return nil;
}

- (void)backToHome:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    self.backButton.alpha = self.editButton.alpha = 1-offset/110;
    if (offset>125) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    if (offset > 75) {
        [self animationToNewPositionAnimation];
    }else {
        [self animationToOriginalPostion];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [HaviAnimationView animationFlipFromLeft:self.iconImageView1];
}

- (void)animationToOriginalPostion
{
    [UIView beginAnimations:@"old" context:NULL];
    [UIView setAnimationDuration:0.55f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.iconImageButton.frame = CGRectMake((self.view.bounds.size.width-100)/2, -50, 100, 100);
    
    self.userTitleLabel.frame = self.titleFrame;
    [UIView commitAnimations];
}

- (void)animationToNewPositionAnimation //位移动画
{
    
    [UIView beginAnimations:@"new" context:NULL];
    [UIView setAnimationDuration:0.55f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.iconImageButton.frame = CGRectMake(20, 5, 65, 65);
    self.userTitleLabel.frame = CGRectMake(100, 20, 120, 30);
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (finished) {
        if ([animationID isEqualToString:@"old"]) {
            self.iconImageButton.layer.cornerRadius = 50;
            self.iconImageButton.layer.masksToBounds = YES;

        }else{
            self.iconImageButton.layer.cornerRadius = 32.5;
            self.iconImageButton.layer.masksToBounds = YES;

        }
    }
}

- (void)tapIconImage:(UITapGestureRecognizer *)gesture
{
    [HaviAnimationView animationRevealFromTop:self.iconImageButton ];
}

- (UIImageView *)iconImageButton
{
    if (_iconImageButton == nil) {
        _iconImageButton = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, -50, 100, 100)];
        _iconImageButton.layer.borderWidth = 1.5;
        _iconImageButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconImageButton.layer.cornerRadius = 50;
        _iconImageButton.layer.masksToBounds = YES;
        _iconImageButton.userInteractionEnabled = YES;
        _iconImageButton.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]];
        
    }
    return _iconImageButton;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (thirdPartyLoginIcon.length>0) {
        [self.iconImageButton setImageWithURL:[NSURL URLWithString:thirdPartyLoginIcon] placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]]];
    }else{
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]isEqual:@""]) {
            self.iconImageButton.image = [UIImage imageWithData:[self downloadWithImage:self.iconImageButton]];
            
        }else{
            if ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]]) {
                
                self.iconImageButton.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]dataForKey:[NSString stringWithFormat:@"%@%@",thirdPartyLoginUserId,thirdPartyLoginPlatform]]];
            }
        }

    }
    
    [super viewWillAppear:animated];
}

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
