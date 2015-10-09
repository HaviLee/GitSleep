//
//  EditAddressCellViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/9.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "EditAddressCellViewController.h"
#import "SHPutClient.h"

@interface EditAddressCellViewController ()<UITextViewDelegate>
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UITableView *cellTableView;
@property (nonatomic,strong) UITextView *cellTextField;
@property (nonatomic,strong) UILabel *cellFooterView;
@property (nonatomic,strong) NSString *cellString;
@end

@implementation EditAddressCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImageView.image = [UIImage imageNamed:@""];
    [self createNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *i = [UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",selectedThemeIndex]];
            [_backButton setImage:i forState:UIControlStateNormal];
            [_backButton setFrame:CGRectMake(-5, 0, 44, 44)];
            [_backButton addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
            return _backButton;
        }else if (nIndex==0){
            UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
            doneButton.frame = CGRectMake(self.view.frame.size.width-65, 0, 60, 44);
            [doneButton setTitle:@"保存" forState:UIControlStateNormal];
            doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [doneButton setTitleColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [doneButton addTarget:self action:@selector(saveInfo:) forControlEvents:UIControlEventTouchUpInside];
            return doneButton;
        }
        return nil;
    }];
    [self.view addSubview:self.cellTableView];
}

- (void)backToView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveInfo:(UIButton *)sender
{
    if (self.cellTextField.text.length==0) {
        [self.view makeToast:@"请输入地址信息" duration:2 position:@"center"];
        return;
    }
    
    if (![self checkIsValiadForString:self.cellTextField.text]) {
        [self.view makeToast:@"地址只能由10-40个中文字符组成" duration:3 position:@"center"];
        return;
    }
    
    [self saveUserInfoWithKey:self.cellString andData:self.cellTextField.text];
}

#pragma mark 更新信息
- (void)saveUserInfoWithKey:(NSString *)key andData:(NSString *)data
{
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
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
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [self.navigationController popViewControllerAnimated:YES];
            if (self.saveButtonClicked) {
                self.saveButtonClicked(1);
            }
        }else{
            [self.view makeToast:@"稍后重试" duration:2 position:@"center"];
        }
    } failure:^(YTKBaseRequest *request) {
        [self.view makeToast:@"网络出错啦,请检查您的网络" duration:2 position:@"center"];
    }];
}

#pragma mark setter

- (UITableView *)cellTableView
{
    if (!_cellTableView) {
        _cellTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,64 , self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _cellTableView.delegate = self;
        _cellTableView.dataSource = self;
        _cellTableView.scrollEnabled = NO;
    }
    return _cellTableView;
}

- (UITextView *)cellTextField
{
    if (!_cellTextField) {
        _cellTextField = [[UITextView alloc]init];
        _cellTextField.font = [UIFont systemFontOfSize:15];
        _cellTextField.frame = CGRectMake(10, 0, self.view.frame.size.width-20, 80);
        [_cellTextField becomeFirstResponder];
        _cellTextField.scrollEnabled = NO;
        _cellTextField.delegate = self;
        _cellTextField.alpha = 0.9;
        _cellTextField.returnKeyType = UIReturnKeyDone;
        
    }
    return _cellTextField;
}

- (UILabel *)cellFooterView
{
    if (!_cellFooterView) {
        _cellFooterView = [[UILabel alloc]init];
        _cellFooterView.text = @"I";
        _cellFooterView.frame = CGRectMake(15, 0, self.view.frame.size.width-30, 30);
        _cellFooterView.font = [UIFont systemFontOfSize:11];
        _cellFooterView.alpha = 0.4;
    }
    return _cellFooterView;
}

#pragma mark tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellInterfier = @"cellIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInterfier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellInterfier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:self.cellTextField];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    [backView addSubview:self.cellFooterView];
    return backView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCellInfoType:(NSString *)cellInfoType
{
    self.cellString = cellInfoType;
    self.cellFooterView.text = @"地址只能由40个以内中文字符组成";
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.cellInfoString) {
        self.cellTextField.text = self.cellInfoString;
    }
}

#pragma mark uitextfield

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
        if ([self checkIsValiadForString:textView.text]) {
            [self saveInfo:nil];
        }else{
            [self.view makeToast:@"超出地址字数范围" duration:2 position:@"center"];
        }
        return NO;
    }else{
        NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSInteger res = 40-[new length];
        if(res >= 0){
            return YES;
        }
        else{
            NSRange rg = {0,[text length]+res};
            if (rg.length>0) {
                NSString *s = [text substringWithRange:rg];
                [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            }
            [self.view makeToast:@"超出地址字数" duration:2 position:@"center"];
            return NO;
        }
    }
}

- (BOOL)checkIsValiadForString:(NSString *)checkString
{
    NSString *regex = @"[A-Za-z0-9\u4e00-\u9fa5]{0,40}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([pred evaluateWithObject:checkString]) {
        
        return YES;
    }else{
        return NO;
    }
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
