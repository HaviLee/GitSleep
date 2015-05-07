//
//  EditUserInfoViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/3/22.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "EditUserInfoViewController.h"
#import "GBPathImageView.h"
#import "EditUserDefalutTableViewCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "HaviAnimationView.h"
#import "MTStatusBarOverlay.h"
#import "UploadImageApi.h"
#import "ImageUtil.h"
#import "RMDateSelectionViewController.h"
#import "SHPutClient.h"
#import "MMPickerView.h"

@interface EditUserInfoViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,RMDateSelectionViewControllerDelegate>

@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,assign) CGRect originalFrame;
@property (nonatomic,assign) CGRect titleFrame;
@property (nonatomic,strong) UIButton *saveButton;
@property (nonatomic,strong) UILabel *userTitleLabel;
@property (nonatomic,strong) GBPathImageView *iconImageView1;
@property (nonatomic,strong) NSArray *titleArr;
@property (nonatomic,strong) NSArray *iconArr;
@property (nonatomic,strong) NSArray *textFieldArr;
@property (nonatomic,assign) CGFloat keyBoardHeight;
//
@property (nonatomic,strong) UITextField *nameTextField;
@property (nonatomic,strong) UILabel *birthteTextField;
@property (nonatomic,strong) UILabel *sexTextField;
@property (nonatomic,strong) UITextField *contactTextField;
@property (nonatomic,strong) UITextField *contactPhoneTextField;
@property (nonatomic,strong) UILabel *heightTextField;
@property (nonatomic,strong) UILabel *weightTextField;
@property (nonatomic,strong) UITextField *addressTextField;
@property (nonatomic,strong) UIImageView *editImage;//暂时取消

@property (nonatomic,strong) RMDateSelectionViewController *datePickerSelectionVC;
@property (nonatomic,strong) RMDateSelectionViewController *pickerSelectionVC;

@property (nonatomic,strong) NSMutableArray *heightArr;
@property (nonatomic,strong) NSMutableArray *weightArr;

@property (nonatomic,strong) NSString *selectString1;
@property (nonatomic,strong) NSString *selectString2;
@property (nonatomic,strong) NSString *selectString3;


@end

@implementation EditUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
            _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _backButton.frame = CGRectMake(0, 0, 44, 44);
            _backButton.contentMode = UIViewContentModeScaleAspectFill;
            [_backButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            [_backButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchUpInside];
            return _backButton;
        }else if (nIndex == 0){
            _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _saveButton.frame = CGRectMake(self.view.frame.size.width-40, 2, 30, 40);
            [self.userInfoTableView addSubview:_saveButton];
            [_saveButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_over_%d",selectedThemeIndex]] forState:UIControlStateNormal];
            _saveButton.contentMode = UIViewContentModeScaleAspectFit;
            [_saveButton addTarget:self action:@selector(saveUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            return self.saveButton;
        }
        
        return nil;
    }];
    
//
    self.titleArr = @[@[@"姓名:",@"生日:",@"性别:",@"紧急联系人:",@"紧急联系人电话:"],@[@"身高:",@"体重:",@"家庭住址:"]];
    self.iconArr = @[@[@"name",@"birthday",@"gender",@"emergency_Contact",@"icon_phone1"],@[@"height",@"weight",@"home"]];
    self.nameTextField = [[UITextField alloc]init];
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"UserName"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _nameTextField.text = @"***";
    }else{
        _nameTextField.text = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"UserName"];
    }
    _nameTextField.delegate = self;
//    
    self.birthteTextField = [[UILabel alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Birthday"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _birthteTextField.text = @"***";
    }else{
        NSString *birthString = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Birthday"];
        _birthteTextField.text = birthString;
    }
//    NSString *newString = [NSString stringWithFormat:@"%@-%@-%@",[birthString substringWithRange:NSMakeRange(0, 4)],[birthString substringWithRange:NSMakeRange(5, 2)],[birthString substringWithRange:NSMakeRange(8, 2)]];

    _birthteTextField.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedBirth:)];
    [_birthteTextField addGestureRecognizer:tapLabel];
//
    self.sexTextField = [[UILabel alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Gender"]].length == 0 || [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _sexTextField.text = @"***";
    }else{
        _sexTextField.text = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Gender"];
    }
    _sexTextField.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLabel1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedGender:)];
    [_sexTextField addGestureRecognizer:tapLabel1];
//
    self.contactTextField = [[UITextField alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"EmergencyContact"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _contactTextField.text = @"***";
    }else{
        _contactTextField.text = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"EmergencyContact"];
    }
    _contactTextField.delegate = self;
//    
    self.contactPhoneTextField = [[UITextField alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"CellPhone"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _contactPhoneTextField.text = @"***";
    }else{
        _contactPhoneTextField.text = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"CellPhone"];
    }
    _contactPhoneTextField.delegate = self;
//    
    self.heightTextField = [[UILabel alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Height"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _heightTextField.text = @"***";
    }else{
        _heightTextField.text = [NSString stringWithFormat:@"%@CM",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Height"]];
    }
    _heightTextField.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLabel2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedHeight:)];
    [_heightTextField addGestureRecognizer:tapLabel2];
//
    self.weightTextField = [[UILabel alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Weight"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _weightTextField.text = @"***";
    }else{
        _weightTextField.text = [NSString stringWithFormat:@"%@KG",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Weight"]];
    }
    _weightTextField.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapLabel3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedWeight:)];
    [_weightTextField addGestureRecognizer:tapLabel3];
//
    self.addressTextField = [[UITextField alloc]init];
    if ([NSString stringWithFormat:@"%@",[[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Address"]].length == 0|| [self.editUserInfoDic objectForKey:@"UserInfo"]==nil) {
        _addressTextField.text = @"***区***路***号";
    }else{
        _addressTextField.text = [[self.editUserInfoDic objectForKey:@"UserInfo"]objectForKey:@"Address"];
    }
    _addressTextField.delegate = self;
//    
    self.textFieldArr = @[@[self.nameTextField,_birthteTextField,_sexTextField,_contactTextField,_contactPhoneTextField],@[_heightTextField,_weightTextField,_addressTextField]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.heightArr = [[NSMutableArray alloc]init];
        self.weightArr = [[NSMutableArray alloc]init];
        for (int i = 10; i<301; i++) {
            [_heightArr addObject:[NSString stringWithFormat:@"%dCM",i]];
            [_weightArr addObject:[NSString stringWithFormat:@"%dKG",i]];
        }
    });
    _selectString1 = @"男";
    _selectString2 = [_heightArr objectAtIndex:0];
    _selectString3 = [_weightArr objectAtIndex:0];
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        self.nameTextField.text = @"";
    }else if ([textField isEqual:self.contactTextField]){
        self.contactTextField.text = @"";
    }else if([textField isEqual:self.contactPhoneTextField]){
        self.contactPhoneTextField.text = @"";
    }else if ([textField isEqual:self.addressTextField]){
        self.addressTextField.text = @"";
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField]) {
        if (self.nameTextField.text.length == 0) {
            self.nameTextField.text = @"***";
        }
    }else if ([textField isEqual:self.contactTextField]){
        if (self.contactTextField.text.length == 0) {
            self.contactTextField.text = @"***";
        }
    }else if([textField isEqual:self.contactPhoneTextField]){
        if (self.contactPhoneTextField.text.length == 0) {
            self.contactPhoneTextField.text = @"***";
        }
    }else if ([textField isEqual:self.addressTextField]){
        if (self.addressTextField.text.length == 0) {
            self.addressTextField.text = @"***区***路***号";
        }
    }
}
#pragma mark 更新信息
- (void)saveUserInfo:(UIButton *)sender
{
    HaviLog(@"保存");
    if ([self.nameTextField.text isEqualToString:@"***"]) {
        [ShowAlertView showAlert:@"请输入姓名"];
        return;
    }
    if ([self.birthteTextField.text isEqualToString:@"***"]) {
        [ShowAlertView showAlert:@"请输入生日"];
        return;
    }
    if ([self.sexTextField.text isEqualToString:@"***"]) {
        [ShowAlertView showAlert:@"请输入性别"];
        return;
    }
    if ([self.contactTextField.text isEqualToString:@"***"]) {
        [ShowAlertView showAlert:@"请输入紧急联系人"];
        return;
    }
    if ([self.contactPhoneTextField.text isEqualToString:@"***"]) {
        [ShowAlertView showAlert:@"请输入紧急联系人电话"];
        return;
    }
    NSString *height;
    if ([self.heightTextField.text isEqualToString:@"***"]) {
        height = @"";
    }else{
        NSRange range = [self.heightTextField.text rangeOfString:@"CM"];
        height = [self.heightTextField.text substringToIndex:range.location];
    }
    
    NSString *weight;
    if ([self.heightTextField.text isEqualToString:@"***"]) {
        weight = @"";
    }else{
        NSRange range = [self.weightTextField.text rangeOfString:@"KG"];
        weight = [self.weightTextField.text substringToIndex:range.location];
    }
    NSString *address;
    if ([self.addressTextField.text isEqualToString:@"***区***路***号"]) {
        address = @"";
    }else{
        address = self.addressTextField.text;
    }
    SHPutClient *client = [SHPutClient shareInstance];
    NSDictionary *dic = @{
                          @"UserID": GloableUserId, //关键字，必须传递
                          @"UserName": self.nameTextField.text, //真实姓名
                          @"Birthday": self.birthteTextField.text, //生日
                          @"Gender": self.sexTextField.text, //性别
                          @"Height": height, //身高CM
                          @"Weight": weight, //体重KG
                          @"Telephone": self.contactPhoneTextField.text, //电话
                          @"Address": address, //家庭住址
                          @"EmergencyContact":self.contactTextField.text,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    [client modifyUserInfo:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"保存%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [KVNProgress showSuccessWithStatus:@"修改成功" completion:^{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadUserInfo" object:nil];
                [self backToHome:nil];
            }];
        }
    } failure:^(YTKBaseRequest *request) {
        [KVNProgress showErrorWithStatus:@"修改失败,请稍候重试" completion:^{
            
        }];
    }];
}

//
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

- (void)tapedGender:(UITapGestureRecognizer *)gesture
{
    NSString *senderString = self.sexTextField.text;
    
    [MMPickerView showPickerViewInView:self.view
                           withStrings:@[@"男",@"女"]
                           withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                         MMtextColor: [UIColor blackColor],
                                         MMtoolbarColor: [UIColor whiteColor],
                                         MMbuttonColor: [UIColor blueColor],
                                         MMfont: [UIFont systemFontOfSize:35],
                                         MMvalueY: @0,
                                         MMselectedObject:_selectString1,
                                         MMtextAlignment:@1}
                            completion:^(NSString *selectedString) {
                                if ([selectedString isEqualToString:@"cancel"]) {
                                    self.sexTextField.text = senderString;
                                    HaviLog(@"button 的titile是%@",senderString);
                                }else{
                                    self.sexTextField.text = selectedString;
                                    _selectString1 = selectedString;
                                }
                            }];
    /*
    if (_pickerSelectionVC) {
        _pickerSelectionVC = nil;
    }
    if (!_pickerSelectionVC) {
        self.pickerSelectionVC = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _pickerSelectionVC.delegate = self;
        _pickerSelectionVC.titleLabel.hidden = YES;
        _pickerSelectionVC.hideNowButton = YES;
    }
    _pickerSelectionVC.pickerDataArray = @[@"男",@"女"];
    _pickerSelectionVC.title = @"gender";
    [_pickerSelectionVC show];
     */

}

- (void)tapedHeight:(UITapGestureRecognizer *)gesture
{
    NSString *senderString = self.heightTextField.text;
    if ([senderString isEqualToString:@"***"]) {
        _selectString2 = @"10CM";
    }else{
        _selectString2 = senderString;
    }
    
    [MMPickerView showPickerViewInView:self.view
                           withStrings:_heightArr
                           withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                         MMtextColor: [UIColor blackColor],
                                         MMtoolbarColor: [UIColor whiteColor],
                                         MMbuttonColor: [UIColor blueColor],
                                         MMfont: [UIFont systemFontOfSize:35],
                                         MMvalueY: @0,
                                         MMselectedObject:_selectString2,
                                         MMtextAlignment:@1}
                            completion:^(NSString *selectedString) {
                                if ([selectedString isEqualToString:@"cancel"]) {
                                    self.heightTextField.text = senderString;
                                    HaviLog(@"button 的titile是%@",senderString);
                                }else{
                                    self.heightTextField.text = selectedString;
                                    _selectString2 = selectedString;
                                }
                            }];
    /*
    if (_pickerSelectionVC) {
        _pickerSelectionVC = nil;
    }
    if (!_pickerSelectionVC) {
        self.pickerSelectionVC = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _pickerSelectionVC.delegate = self;
        _pickerSelectionVC.titleLabel.hidden = YES;
        _pickerSelectionVC.hideNowButton = YES;
    }
    
    _pickerSelectionVC.pickerDataArray = self.heightArr;
    _pickerSelectionVC.title = @"height";
    [_pickerSelectionVC show];
     */
}

- (void)tapedWeight:(UITapGestureRecognizer *)gesture
{
    NSString *senderString = self.weightTextField.text;
    if ([senderString isEqualToString:@"***"]) {
        _selectString3 = @"10KG";
    }else{
        _selectString3 = senderString;
    }
    
    [MMPickerView showPickerViewInView:self.view
                           withStrings:_weightArr
                           withOptions:@{MMbackgroundColor: [UIColor whiteColor],
                                         MMtextColor: [UIColor blackColor],
                                         MMtoolbarColor: [UIColor whiteColor],
                                         MMbuttonColor: [UIColor blueColor],
                                         MMfont: [UIFont systemFontOfSize:35],
                                         MMvalueY: @0,
                                         MMselectedObject:_selectString3,
                                         MMtextAlignment:@1}
                            completion:^(NSString *selectedString) {
                                if ([selectedString isEqualToString:@"cancel"]) {
                                    self.weightTextField.text = senderString;
                                    HaviLog(@"button 的titile是%@",senderString);
                                }else{
                                    self.weightTextField.text = selectedString;
                                    _selectString3 = selectedString;
                                }
                            }];
    /*
    if (_pickerSelectionVC) {
        _pickerSelectionVC = nil;
    }
    if (!_pickerSelectionVC) {
        self.pickerSelectionVC = [RMDateSelectionViewController dateSelectionControllerWith:PickerViewListType];
        _pickerSelectionVC.delegate = self;
        _pickerSelectionVC.titleLabel.hidden = YES;
        _pickerSelectionVC.hideNowButton = YES;
    }
    _pickerSelectionVC.pickerDataArray = self.weightArr;
    _pickerSelectionVC.title = @"weight";
    [_pickerSelectionVC show];
     */
}
#pragma mark datepicker delegate
#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSString *)aDate {
    if ([vc.title isEqualToString:@"date"]) {
        NSString *dateString = [NSString stringWithFormat:@"%@",aDate];
        NSString *dateSubString = [dateString substringWithRange:NSMakeRange(0, 10)];
        self.birthteTextField.text = dateSubString;
    }else if ([vc.title isEqualToString:@"gender"]){
        self.sexTextField.text = aDate;
    }else if ([vc.title isEqualToString:@"height"]){
        self.heightTextField.text = aDate;
    }else if ([vc.title isEqualToString:@"weight"]){
        self.weightTextField.text = aDate;
    }
   
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    HaviLog(@"Date selection was canceled");
}
#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }else{
        return 3;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"cell%d%d",(int)indexPath.section,(int)indexPath.row];
    EditUserDefalutTableViewCell *cell = [[EditUserDefalutTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier andIndexPath:indexPath];
    if ((indexPath.section == 0&& indexPath.row == 0)||(indexPath.section == 1&& indexPath.row == 0)) {
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
        imageLine.backgroundColor = [UIColor grayColor];
        imageLine.frame = CGRectMake(0, 0, self.view.bounds.size.width, 1);
        [cell addSubview:imageLine];
        imageLine.alpha = 0.5;
    }
    if ((indexPath.section == 0&& indexPath.row == 4)||(indexPath.section == 1&& indexPath.row == 2)) {
        UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line_abnormal_0"]];
        imageLine.backgroundColor = [UIColor grayColor];
        imageLine.frame = CGRectMake(0, TableViewCellHeight-1, self.view.bounds.size.width, 1);
        [cell addSubview:imageLine];
        imageLine.alpha = 0.5;
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0|| indexPath.row == 1||indexPath.row == 2|| indexPath.row == 3) {
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
    cell.userCellTitle = [[self.titleArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
//    [cell layoutSubviews];
    cell.iconTitle = [[self.iconArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITextField *text = [[self.textFieldArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    [cell.userEditView addSubview:text];
//    self.editImage = [[UIImageView alloc]init];
//    _editImage.image = [UIImage imageNamed:@"edit"];
//    [cell.userEditView addSubview:_editImage];
    [text makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cell.userEditView.centerX);
        make.centerY.equalTo(cell.userEditView.centerY);
        make.left.equalTo(cell.userEditView.left);
    }];
    
    
//    [_editImage makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(text.centerY);
//        make.right.equalTo(text.left).offset(-5);
//        make.height.width.equalTo(17);
//    }];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.userEditView.backgroundColor = [UIColor redColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 75;
    }else if (section == 1){
        return 20;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return TableViewCellHeight;
    }else if (indexPath.section == 1){
        return TableViewCellHeight;
    }
    return TableViewCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }
    return 0;;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
        sectionView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        UIImage *iconImage;
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentIconImage"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:fullPath]) {
            NSData *imageData = [NSData dataWithContentsOfFile:fullPath];
            iconImage = [[UIImage alloc] initWithData:imageData];
        }else{
            iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"head_portrait_%d",selectedThemeIndex]];
        }
//        self.iconImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, -50, 100, 100)];
//        self.iconImageView1.image = iconImage;
//        self.iconImageView1.layer.borderWidth = 2;
//        self.iconImageView1.layer.borderColor = [UIColor whiteColor].CGColor;
        self.iconImageView1 = [[GBPathImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, -50, 100, 100) image:iconImage pathType:GBPathImageViewTypeCircle pathColor:[UIColor whiteColor] borderColor:[UIColor lightGrayColor] pathWidth:0.0];
        [sectionView addSubview:self.iconImageView1];
//        self.iconImageView1.layer.cornerRadius = 50;
//        self.iconImageView1.layer.masksToBounds = YES;
        self.iconImageView1.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapIconImage:)];
        [self.iconImageView1 addGestureRecognizer:tap];
        
        self.originalFrame = self.iconImageView1.frame;
        self.userTitleLabel = [[UILabel alloc]init];
        [sectionView addSubview:self.userTitleLabel];
        self.userTitleLabel.textColor = [UIColor colorWithRed:0.149f green:0.702f blue:0.678f alpha:1.00f];
        self.userTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.userTitleLabel.font = DefaultWordFont;
        self.userTitleLabel.frame = CGRectMake((self.view.bounds.size.width-120)/2, 45, 120, 25);
        self.titleFrame = self.userTitleLabel.frame;
        self.userTitleLabel.text = @"点击修改头像";
        return sectionView;
    }
    /*
    else if (section == 1){
        UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        sectionView.backgroundColor = [UIColor colorWithRed:0.949f green:0.941f blue:0.945f alpha:1.00f];
        UILabel *labelShow = [[UILabel alloc]init];
        [sectionView addSubview:labelShow];
        labelShow.text = @"选填项";
        [labelShow makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(sectionView.left).offset(20);
            make.bottom.equalTo(sectionView.bottom).offset(-5);
        }];
        return sectionView;
    }
     */
    return nil;
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
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                    imagePickerController.delegate = self;
                    
                    imagePickerController.allowsEditing = YES;
                    
                    imagePickerController.sourceType = sourceType;
                    
                    [self presentViewController:imagePickerController animated:YES completion:^{}];

                    break;
                }
                    
                case 1:{
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                    imagePickerController.mediaTypes = @[(NSString*) kUTTypeImage];
                    imagePickerController.delegate = self;
                    
                    imagePickerController.allowsEditing = YES;
                    
                    imagePickerController.sourceType = sourceType;
                    
                    [self presentViewController:imagePickerController animated:YES completion:^{
//                        self.navigationController.navigationBarHidden = YES;
                    }];
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
    self.iconImageView1.originalImage = image;
    [self.iconImageView1 draw];
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
    [self saveImage:image withName:@"currentIconImage"];
    [HaviAnimationView animationMoveUp:self.iconImageView1 duration:1.8];
//    [self uploadImage:image andTitle:@"li"];
//    [self uploadImage:image andTitle:@"上传icon"];
    NSString *string = [NSString stringWithFormat:@"http://webservice.meddo99.com:9000/v1/file/UploadFile/%@/header",GloableUserId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self postRequestWithURL:string postParems:@{@"AccessToken":@"123456789"} picFilePath:@"li" picFileName:@"13122785292" withHeader:nil andData:[self calculateIconImage:image]];
    });
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
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



/*
 上传图片
 */
static NSString * const FORM_FLE_INPUT = @"file";
- (NSDictionary *)postRequestWithURL: (NSString *)url  // IN
                          postParems: (NSDictionary *)postParems // IN
                         picFilePath: (NSString *)picFilePath  // IN
                         picFileName: (NSString *)picFileName
                          withHeader: (NSDictionary *)headers
                             andData: (NSData *)data1;  // IN
{
    
    
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //
    NSArray *headerkeys;
    int     headercount;
    id      key,value;
    headerkeys=[postParems allKeys];
    headercount= (int)[headerkeys count];
    for (int i=0; i<headercount; i++) {
        key=[headerkeys objectAtIndex:i];
        value=[postParems objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    
    //分界线 --AaB03x
//    NSString *MPboundary=[NSString stringWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
//    //结束符 AaB03x--
////    NSString *endMPboundary=[NSString stringWithFormat:@"%@--",MPboundary];
//    //得到图片的data
//    NSData* data = nil;
    if(picFilePath){
//        data = data1;
    }
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
//    NSArray *keys= [postParems allKeys];
    /*
    //遍历keys
    for(int i=0;i<[keys count];i++)
    {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[postParems objectForKey:key]];
        
        HaviLog(@"添加字段的值==%@",[postParems objectForKey:key]);
    }
    */
    /*
    if(picFilePath){
        ////添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        
        //声明pic字段，文件名为boris.png
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",FORM_FLE_INPUT,picFileName];
        //声明上传文件的格式
        [body appendFormat:@"Content-Type: image/png,image/jpge,image/gif, image/jpeg, image/pjpeg, image/pjpeg\r\n\r\n"];
    }
    
    //声明结束符：--AaB03x--
    NSString *end=[NSString stringWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
     */
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    if(picFilePath){
        //将image的data加入
    }
    [myRequestData appendData:data1];
    //加入结束符--AaB03x--
//    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    //设置HTTPHeader中Content-Type的值
    NSString *content=[NSString stringWithFormat:@"multipart/form-data; image/png"];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", (int)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    
    NSHTTPURLResponse *urlResponese = nil;
    NSError *error = [[NSError alloc]init];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request   returningResponse:&urlResponese error:&error];
    NSDictionary *dic = [self dataToDictionary:resultData];
    if (dic) {
        HaviLog(@"%@",dic);
        if ([[dic objectForKey:@"ReturnCode"]intValue]==200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
                [overlay postImmediateFinishMessage:@"上传头像成功" duration:2 animated:YES];
            });
        }
        return dic;
    }
    return nil;
}



- (void)uploadImage:(UIImage *)iconImage andTitle:(NSString *)title
{
    UploadImageApi *api= [[UploadImageApi alloc]initWithImage:iconImage andUserId:@"13122785292"];
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        [overlay postImmediateFinishMessage:@"上传成功" duration:2 animated:YES];
        HaviLog(@"完成%@",request.responseJSONObject);
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        HaviLog(@"%@",string);
    } failure:^(YTKBaseRequest *request) {
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        [overlay postImmediateFinishMessage:@"上传成功" duration:2 animated:YES];
        NSString *string = [NSString stringWithFormat:@"%@:%@",title,request.responseJSONObject];
        HaviLog(@"失败%@,%@",request.responseJSONObject,string);
    }];
}
//NSData * UIImageJPEGRepresentation (UIImage *image, CGFloat compressionQuality)
//
#pragma mark - 保存图片至沙盒
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    if ([imageData writeToFile:fullPath atomically:YES]) {
        HaviLog(@"写入头像到本地");
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    HaviLog(@"cancel");
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
         [self setNeedsStatusBarAppearanceUpdate];
    }];
}


#pragma mark 滚动视图delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    HaviLog(@"滚动视图%lf",offset);
    self.backButton.alpha = self.saveButton.alpha = 1-offset/110;
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

- (void)animationToOriginalPostion
{
    [UIView beginAnimations:@"PositionAnition" context:NULL];
    [UIView setAnimationDuration:0.55f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.iconImageView1.frame = self.originalFrame;
    self.userTitleLabel.frame = self.titleFrame;
    [UIView commitAnimations];
}

- (void)animationToNewPositionAnimation //位移动画
{
    
    [UIView beginAnimations:@"PositionAnition" context:NULL];
    [UIView setAnimationDuration:0.55f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    self.iconImageView1.frame = CGRectMake(20, 5, 65, 65);
    self.userTitleLabel.frame = CGRectMake(100, 20, 120, 30);
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    HaviLog(@"touched view");
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)backToHome:(UIButton *)sender
{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //增加监听，当键盘出现或改变时收出消息
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
}

//当键盘出现或改变时调用,父类方法重写。
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    CGRect userRect = self.userInfoTableView.frame;
    userRect.size.height -= height;
    self.keyBoardHeight = height;
    self.userInfoTableView.tableView.frame = userRect;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect userRect = self.userInfoTableView.frame;
    userRect.size.height += self.keyBoardHeight;
    self.userInfoTableView.tableView.frame = self.view.bounds;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [super viewWillDisappear:animated];
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
