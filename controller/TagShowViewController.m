//
//  TagShowViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TagShowViewController.h"
#import "TLTagsControl.h"
#import "UploadTagAPI.h"
#import "GetTagListAPI.h"
@interface TagShowViewController ()<TLTagsControlDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) TLTagsControl *beforeSleepTag;
@property (nonatomic, strong) TLTagsControl *afterSleepTag;
@property (nonatomic, strong) UIImageView *beforeSleepImage;
@property (nonatomic, strong) UIImageView *afterSleepImage;
@property (nonatomic, strong) UILabel *beforeSleepLabel;
@property (nonatomic, strong) UILabel *afterSleepLabel;
@property (nonatomic, strong) NSMutableArray *beforeListArr;
@property (nonatomic, strong) NSMutableArray *afterListArr;
@property (nonatomic, strong) NSMutableArray *sendTagListArr;
@property (nonatomic, strong) UILabel *sleepLabel;
//
@property (nonatomic, strong) UIPickerView *tagDatePicker;
@property (nonatomic, strong) NSArray *proTimeList;
@property (nonatomic, strong) NSArray *proTitleList;
@property (nonatomic, strong) NSArray *proDay;
@property (nonatomic, strong) NSString *dayIndex;

@end

@implementation TagShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createClearBgNavWithTitle:self.tagIndex==0?@"睡前标签":@"睡后标签" andTitleColor:[UIColor whiteColor] createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
             [self.leftButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_back_%d",1]] forState:UIControlStateNormal];
             return self.leftButton;

         }else if (nIndex == 0){
             self.rightButton.frame = CGRectMake(self.view.frame.size.width-60, 0, 50, 44);
             self.rightButton.titleLabel.font = DefaultWordFont;
             [self.rightButton addTarget:self action:@selector(sendTags:) forControlEvents:UIControlEventTouchUpInside];
             [self.rightButton setTitle:@"保存" forState:UIControlStateNormal];
             [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             return self.rightButton;
         }
         return nil;
     }];
    self.bgImageView.image = [UIImage imageNamed:@"bg_pic_tag"];
    _proTimeList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",nil];
    _proTitleList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",nil];
    NSRange range = [self.timeDate rangeOfString:@"FromDate="];
    NSString *day = [self.timeDate substringWithRange:NSMakeRange(range.location+range.length+6, 2)];
    _proDay = @[day,[NSString stringWithFormat:@"%d",[day intValue]+1]];
    [self setSleepTag];
    [self setSleepTagContraints];
    [self getTagLists];
}

#pragma mark setter meathod

- (UILabel *)sleepLabel
{
    if (_sleepLabel == nil) {
        _sleepLabel = [[UILabel alloc]init];
        _sleepLabel.textColor = [UIColor whiteColor];
        _sleepLabel.font = [UIFont systemFontOfSize:17];
        _sleepLabel.textAlignment = NSTextAlignmentCenter;
        if (self.tagIndex==0) {
            _sleepLabel.text = @"您的睡觉时间是00日00点00分";
        }else{
            _sleepLabel.text = @"您的起床时间是00日00点00分";
        }
    }
    return _sleepLabel;
}

- (UIPickerView *)tagDatePicker
{
    if (_tagDatePicker==nil) {
        _tagDatePicker = [[UIPickerView alloc]init];
        _tagDatePicker.frame = CGRectMake(0, 250, self.view.frame.size.width, 150);
        _tagDatePicker.delegate = self;
        _tagDatePicker.dataSource = self;
        _tagDatePicker.tintColor = [UIColor whiteColor];
        UILabel *mao = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width)/3*2, 52, 10, 50)];
        mao.textColor = [UIColor whiteColor];
        mao.text = @":";
        mao.font = [UIFont systemFontOfSize:27];
        [_tagDatePicker addSubview:mao];
        UILabel *mao1 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width)/3-20, 53, 20, 53)];
        mao1.textColor = [UIColor whiteColor];
        mao1.text = @"日";
        mao1.font = [UIFont systemFontOfSize:20];
        [_tagDatePicker addSubview:mao1];

        
    }
    return _tagDatePicker;
}

- (void)setTimeDate:(NSString *)timeDate
{
    _timeDate = timeDate;
}

- (NSMutableArray *)sendTagListArr
{
    if (_sendTagListArr==nil) {
        _sendTagListArr = [[NSMutableArray alloc]init];
    }
    return _sendTagListArr;
}

- (NSMutableArray *)beforeListArr
{
    if (_beforeListArr == nil) {
        _beforeListArr = [[NSMutableArray alloc]init];
        TagObject *tag1 = [[TagObject alloc]init];
        tag1.tagName = @"运动健身";
        tag1.isSelect = NO;
        tag1.isEnabled = NO;
        
        TagObject *tag2 = [[TagObject alloc]init];
        tag2.tagName = @"晚饭过量";
        tag2.isSelect = NO;
        tag2.isEnabled = NO;
        
        TagObject *tag3 = [[TagObject alloc]init];
        tag3.tagName = @"吃的晚了";
        tag3.isEnabled = NO;
        tag3.isSelect = NO;
        [_beforeListArr addObject:tag1];
        [_beforeListArr addObject:tag2];
        [_beforeListArr addObject:tag3];
    }
    return _beforeListArr;
}

- (NSMutableArray *)afterListArr
{
    if (_afterListArr == nil) {
        _afterListArr = [[NSMutableArray alloc]init];
        TagObject *tag1 = [[TagObject alloc]init];
        tag1.tagName = @"噩梦过多";
        tag1.isEnabled = NO;
        tag1.isSelect = NO;
        
        TagObject *tag2 = [[TagObject alloc]init];
        tag2.tagName = @"离床过频";
        tag2.isSelect = NO;
        tag2.isEnabled = NO;
        
        TagObject *tag3 = [[TagObject alloc]init];
        tag3.tagName = @"翻身过多";
        tag3.isSelect = NO;
        tag3.isEnabled = NO;
        [_afterListArr addObject:tag1];
        [_afterListArr addObject:tag2];
        [_afterListArr addObject:tag3];
    }
    return _afterListArr;
}

- (TLTagsControl *)beforeSleepTag
{
    if (_beforeSleepTag==nil) {
        if (self.tagIndex == 0) {
            _beforeSleepTag = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 30) andTags:self.beforeListArr withTagsControlMode:TLTagsControlModeList];
        }else{
            _beforeSleepTag = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 30) andTags:self.afterListArr withTagsControlMode:TLTagsControlModeList];
        }
        _beforeSleepTag.padding = 21;
        _beforeSleepTag.tagsBackgroundColor = [UIColor colorWithRed:0.212f green:0.498f blue:0.553f alpha:1.00f];
        _beforeSleepTag.tagsTextColor = [UIColor lightGrayColor];
        
    }
    return _beforeSleepTag;
}

- (TLTagsControl *)afterSleepTag
{
    if (_afterSleepTag==nil) {
        _afterSleepTag = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 30) andTags:self.afterListArr withTagsControlMode:TLTagsControlModeList];
        _afterSleepTag.tagsBackgroundColor = [UIColor colorWithRed:0.114f green:0.847f blue:0.553f alpha:1.00f];
        _afterSleepTag.tagsTextColor = [UIColor lightGrayColor];
    }
    return _afterSleepTag;
}

- (UIImageView *)beforeSleepImage
{
    if (_beforeSleepImage==nil) {
        _beforeSleepImage = [[UIImageView alloc]init];
        _beforeSleepImage.image = [UIImage imageNamed:self.tagIndex ==0 ? @"night_icon":@"day_icon"];
    }
    return _beforeSleepImage;
}

- (UIImageView *)afterSleepImage
{
    if (_afterSleepImage==nil) {
        _afterSleepImage = [[UIImageView alloc]init];
        _afterSleepImage.image = [UIImage imageNamed:@"day_icon"];
    }
    return _afterSleepImage;
}

- (UILabel *)beforeSleepLabel
{
    if (_beforeSleepLabel==nil) {
        _beforeSleepLabel = [[UILabel alloc]init];
        _beforeSleepLabel.text = self.tagIndex==0?@"睡前报告标签":@"睡后报告标签";
        _beforeSleepLabel.textColor = self.tagIndex==0?[UIColor colorWithRed:0.247f green:0.369f blue:0.553f alpha:1.00f]:[UIColor colorWithRed:0.106f green:0.851f blue:0.557f alpha:1.00f];
    }
    return _beforeSleepLabel;
}

- (UILabel *)afterSleepLabel
{
    if (_afterSleepLabel == nil) {
        _afterSleepLabel = [[UILabel alloc]init];
        _afterSleepLabel.text = @"睡眠报告";
        _afterSleepLabel.textColor = [UIColor colorWithRed:0.106f green:0.851f blue:0.557f alpha:1.00f];
    }
    return _afterSleepLabel;
}

#pragma mark UI方法
- (void)setSleepTag
{
    [self.view addSubview:self.beforeSleepImage];
    [self.view addSubview:self.beforeSleepLabel];
//    [self.view addSubview:self.afterSleepImage];
//    [self.view addSubview:self.afterSleepLabel];
    [self.view addSubview:self.beforeSleepTag];
//    [self.view addSubview:self.afterSleepTag];
    [self.beforeSleepTag reloadTagSubviews];
//    [self.afterSleepTag reloadTagSubviews];
    [self.beforeSleepTag setTapDelegate:self];
    [self.view addSubview:self.sleepLabel];
//    [self.afterSleepTag setTapDelegate:self];
    
    [self.view addSubview:self.tagDatePicker];
    

    
}

- (void)setSleepTagContraints
{
    [self.beforeSleepImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(84);
        make.left.equalTo(self.view.left).offset(20);
        make.height.equalTo(self.beforeSleepImage.width);
        make.height.equalTo(25);
    }];
    
    [self.beforeSleepLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.beforeSleepImage);
        make.left.equalTo(self.beforeSleepImage.right).offset(15);
    }];
    
//    [self.afterSleepImage makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.view.centerY).offset(40);
//        make.left.equalTo(self.view.left).offset(20);
//        make.height.equalTo(self.beforeSleepImage.width);
//        make.height.equalTo(25);
//    }];
//    
//    [self.afterSleepLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.afterSleepImage);
//        make.left.equalTo(self.afterSleepImage.right).offset(15);
//    }];
    
    [self.beforeSleepTag makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beforeSleepImage.bottom).offset(20);
        make.left.equalTo(self.view.left).offset(5);
        make.right.equalTo(self.view.right).offset(-15);
        make.height.equalTo(30);
    }];
    
//    [self.afterSleepTag makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.afterSleepImage.bottom).offset(20);
//        make.left.equalTo(self.view.left).offset(5);
//        make.right.equalTo(self.view.right).offset(-15);
//        make.height.equalTo(30);
//    }];
    
    [self.sleepLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tagDatePicker.top).offset(-25);
        make.left.equalTo(self.view.left).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
        make.height.equalTo(30);

    }];
}

- (void)backToView:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TLTagsControlDelegate
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index {
    TagObject *tag = (TagObject *)tagsControl.tags[index];
    if (!tag.isEnabled) {
        
        if (self.tagIndex==0) {
            tag.isSelect = !tag.isSelect;
            if (tag.isSelect) {
                [self.sendTagListArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                 @"Tag" : tag.tagName,
                                                 @"TagType" : @"-1",
                                                 }]];
            }else{
                if ([self.sendTagListArr containsObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                          @"Tag" : tag.tagName,
                                                          @"TagType" : @"-1",
                                                          }]]) {
                    [self.sendTagListArr removeObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                      @"Tag" : tag.tagName,
                                                                                                      @"TagType" : @"-1",
                                                                                                      }]];
                    
                }
            }
            [self.beforeListArr replaceObjectAtIndex:index withObject:tag];
            self.beforeSleepTag.tags = self.beforeListArr;
            [self.beforeSleepTag reloadTagSubviews];
            NSLog(@"beforeTag \"%@ 内容是%@\" was tapped", tagsControl.tags[index],tag.tagName);
            
        }else{
            NSLog(@"afterTag \"%@\" was tapped", tagsControl.tags[index]);
            tag.isSelect = !tag.isSelect;
            if (tag.isSelect) {
                [self.sendTagListArr addObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                 @"Tag" : tag.tagName,
                                                 @"TagType" : @"1",
                                                 }]];
            }else{
                if ([self.sendTagListArr containsObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                          @"Tag" : tag.tagName,
                                                          @"TagType" : @"1",
                                                          }]]) {
                    [self.sendTagListArr removeObject:[NSMutableDictionary dictionaryWithDictionary:@{
                                                                                                      @"Tag" : tag.tagName,
                                                                                                      @"TagType" : @"1",
                                                                                                      }]];
                    
                }
            }
            [self.afterListArr replaceObjectAtIndex:index withObject:tag];
            self.beforeSleepTag.tags = self.afterListArr;
            [self.beforeSleepTag reloadTagSubviews];
        }
    }
}

#pragma mark 提交标签

- (void)getTagLists
{
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithStatus:@"请求中..."];
    NSDictionary *dic = @{
                          @"url" : _timeDate,
                          };
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetTagListAPI *client = [GetTagListAPI shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client getTagTagWithHeader:header andWithPara:dic];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        HaviLog(@"用户的标签是%@",resposeDic);
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            [MMProgressHUD dismiss];
            [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                [self refreshTag:[resposeDic objectForKey:@"Tags"]];
            }];
        }else{
            HaviLog(@"%@",resposeDic);
            [MMProgressHUD dismissWithError:@"出错啦" afterDelay:1];
        }
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

- (void)refreshTag:(NSArray *)tagArr
{
    if (tagArr.count>0) {
        for (NSDictionary *dic in tagArr) {
            //1睡后
            if ([[dic objectForKey:@"TagType"]intValue]==1) {
                for (TagObject *tag in self.afterListArr) {
                    if ([tag.tagName isEqualToString:[dic objectForKey:@"Tag"]]) {
                        tag.isSelect = !tag.isSelect;
                        tag.isEnabled = YES;
                    }
                }
            }else{
                for (TagObject *tag in self.beforeListArr) {
                    if ([tag.tagName isEqualToString:[dic objectForKey:@"Tag"]]) {
                        tag.isSelect = !tag.isSelect;
                        tag.isEnabled = YES;
                    }
                }
            }
        }
        
//        [self.afterSleepTag reloadTagSubviews];
        [self.beforeSleepTag reloadTagSubviews];
    }
}

- (void)sendTags:(UIButton *)sender
{
    if (HardWareUUID.length>0) {
        
        if (self.sendTagListArr.count==0) {
            [self.view makeToast:@"请选择标签" duration:2 position:@"center"];
            return;
        }
        if (self.tagIndex==0) {
            NSRange range = [self.sleepLabel.text rangeOfString:@"您的睡觉时间是"];
            if ([[self.sleepLabel.text substringWithRange:NSMakeRange(range.length+range.location, 2)]intValue]==0){
                [self.view makeToast:@"请选择时间" duration:2 position:@"center"];
                return;
            }
        }else{
            NSRange range = [self.sleepLabel.text rangeOfString:@"您的起床时间是"];
            if ([[self.sleepLabel.text substringWithRange:NSMakeRange(range.length+range.location, 2)]intValue]==0){
                [self.view makeToast:@"请选择时间" duration:2 position:@"center"];
                return;
            }
        }
        
        HaviLog(@"提交标签标签是%@日式是%@",self.sendTagListArr,self.dayIndex);
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
        [MMProgressHUD showWithStatus:@"保存中..."];
        NSDictionary *dic = @{
                              @"UUID" : HardWareUUID,
                              @"UserID" : thirdPartyLoginUserId,
                              @"Tags" : self.sendTagListArr,
                              };
        NSDictionary *header = @{
                                 @"AccessToken":@"123456789"
                                 };
        UploadTagAPI *client = [UploadTagAPI shareInstance];
        if ([client isExecuting]) {
            [client stop];
        }
        [MMProgressHUD dismiss];
        for (NSMutableDictionary *dic in self.sendTagListArr) {
            [dic setObject:self.dayIndex forKey:@"UserTagDate"];
        }
        NSLog(@"所有的标签是%@",self.sendTagListArr);
        [client uploadTagWithHeader:header andWithPara:dic];
        [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
            if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
                [MMProgressHUD dismiss];
                [[MMProgressHUD sharedHUD]setDismissAnimationCompletion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }else{
                HaviLog(@"%@",resposeDic);
                [MMProgressHUD dismissWithError:@"出错啦" afterDelay:1];
            }
        } failure:^(YTKBaseRequest *request) {
            
        }];
    }else{
        [self.view makeToast:@"请先绑定设备ID" duration:2 position:@"center"];
    }
}

#pragma mark uipicker 代理
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [_proDay count];
    }else if (component==1){
        return [_proTitleList count];
    }
    
    return [_proTimeList count];
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return self.view.frame.size.width/3;
//    if (component == 1||component==0) {
//        return 40;
//    }
//    return 100;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    int rowDay = (int)[pickerView selectedRowInComponent:0];
    //取得选择的是第1列的哪一行
    int rowHour = (int)[pickerView selectedRowInComponent:1];
    int rowMinute = (int)[pickerView selectedRowInComponent:2];
    NSLog(@"时间是%@：%@",[_proDay objectAtIndex:rowDay],[_proTitleList objectAtIndex:rowHour]);
    if(self.tagIndex==0){
        self.sleepLabel.text = [NSString stringWithFormat:@"您的睡觉时间是%@日%@点%@分",[_proDay objectAtIndex:rowDay],[_proTimeList objectAtIndex:rowHour],[_proTitleList objectAtIndex:rowMinute]];
    }else{
        self.sleepLabel.text = [NSString stringWithFormat:@"您的起床时间是%@日%@点%@分",[_proDay objectAtIndex:rowDay],[_proTimeList objectAtIndex:rowHour],[_proTitleList objectAtIndex:rowMinute]];
    }
    NSRange range = [self.timeDate rangeOfString:@"FromDate="];
    NSString *day = [self.timeDate substringWithRange:NSMakeRange(range.location+range.length, 6)];
    self.dayIndex = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:00",[day substringToIndex:4],[day substringFromIndex:4],[_proDay objectAtIndex:rowDay],[_proTimeList objectAtIndex:rowHour],[_proTitleList objectAtIndex:rowMinute]];
    
    
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    NSLog(@"调用%s ,%d",__FUNCTION__,__LINE__);
    
    
    return  50;
}

// 自定义指定列的每行的视图，即指定列的每行的视图行为一致
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    NSLog(@"调用%s ,%d",__FUNCTION__,__LINE__);
    
    
    //取得指定列的宽度
    CGFloat width=[self pickerView:pickerView widthForComponent:component];
    
    //取得指定列，行的高度
    CGFloat height=[self pickerView:pickerView rowHeightForComponent:component];
    
    //定义一个视图
    UIView *myView=[[UIView alloc] init];
    
    //指定视图frame
    myView.frame=CGRectMake(0, 0, width, height);
    
    UILabel *labelOnComponent=[[UILabel alloc] init];
    labelOnComponent.textColor = [UIColor whiteColor];
    labelOnComponent.frame=myView.frame;
    labelOnComponent.font=[UIFont systemFontOfSize:27];
    labelOnComponent.textAlignment = NSTextAlignmentCenter;
    
    
    if (component==0) {
        //如果是第0列
        
        //以行为索引，取得字体
        UIFont *font=[self.proDay objectAtIndex:row];
        //在label上显示改字体
        labelOnComponent.text=[NSString stringWithFormat:@"%@",font];
        
    }
    else if(component==1){
        //如果是第1列
        //以说选择行为索引，取得颜色数组中的颜色，并把label的背景色设为该颜色
        labelOnComponent.text=[self.proTimeList objectAtIndex:row];
        
    }
    else if(component==2){
        //如果是第1列
        //以说选择行为索引，取得颜色数组中的颜色，并把label的背景色设为该颜色
        labelOnComponent.text=[self.proTitleList objectAtIndex:row];
        
    }

    [myView addSubview:labelOnComponent];
    
    return myView;
    
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
