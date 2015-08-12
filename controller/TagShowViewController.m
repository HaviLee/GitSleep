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
@interface TagShowViewController ()<TLTagsControlDelegate>

@property (nonatomic, strong) TLTagsControl *beforeSleepTag;
@property (nonatomic, strong) TLTagsControl *afterSleepTag;
@property (nonatomic, strong) UIImageView *beforeSleepImage;
@property (nonatomic, strong) UIImageView *afterSleepImage;
@property (nonatomic, strong) UILabel *beforeSleepLabel;
@property (nonatomic, strong) UILabel *afterSleepLabel;
@property (nonatomic, strong) NSMutableArray *beforeListArr;
@property (nonatomic, strong) NSMutableArray *afterListArr;
@property (nonatomic, strong) NSMutableArray *sendTagListArr;

@end

@implementation TagShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createClearBgNavWithTitle:@"睡眠报告" andTitleColor:[UIColor whiteColor] createMenuItem:^UIView *(int nIndex)
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
    [self setSleepTag];
    [self setSleepTagContraints];
    [self getTagLists];
}

#pragma mark setter meathod

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
        _beforeSleepTag = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 30) andTags:self.beforeListArr withTagsControlMode:TLTagsControlModeList];
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
        _beforeSleepImage.image = [UIImage imageNamed:@"night_icon"];
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
        _beforeSleepLabel.text = @"睡前报告";
        _beforeSleepLabel.textColor = [UIColor colorWithRed:0.247f green:0.369f blue:0.553f alpha:1.00f];
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
    [self.view addSubview:self.afterSleepImage];
    [self.view addSubview:self.afterSleepLabel];
    [self.view addSubview:self.beforeSleepTag];
    [self.view addSubview:self.afterSleepTag];
    [self.beforeSleepTag reloadTagSubviews];
    [self.afterSleepTag reloadTagSubviews];
    [self.beforeSleepTag setTapDelegate:self];
    [self.afterSleepTag setTapDelegate:self];
    
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
    
    [self.afterSleepImage makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.centerY).offset(40);
        make.left.equalTo(self.view.left).offset(20);
        make.height.equalTo(self.beforeSleepImage.width);
        make.height.equalTo(25);
    }];
    
    [self.afterSleepLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.afterSleepImage);
        make.left.equalTo(self.afterSleepImage.right).offset(15);
    }];
    
    [self.beforeSleepTag makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.beforeSleepImage.bottom).offset(20);
        make.left.equalTo(self.view.left).offset(5);
        make.right.equalTo(self.view.right).offset(-15);
        make.height.equalTo(30);
    }];
    
    [self.afterSleepTag makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.afterSleepImage.bottom).offset(20);
        make.left.equalTo(self.view.left).offset(5);
        make.right.equalTo(self.view.right).offset(-15);
        make.height.equalTo(30);
    }];
}

- (void)backToView:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TLTagsControlDelegate
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index {
    [self.sendTagListArr removeAllObjects];
    TagObject *tag = (TagObject *)tagsControl.tags[index];
    if (!tag.isEnabled) {
        
        if ([tagsControl isEqual:self.beforeSleepTag]) {
            tag.isSelect = !tag.isSelect;
            if (tag.isSelect) {
                [self.sendTagListArr addObject:@{
                                                 @"Tag" : tag.tagName,
                                                 @"TagType" : @"-1",
                                                 }];
            }else{
                if ([self.sendTagListArr containsObject:@{
                                                          @"Tag" : tag.tagName,
                                                          @"TagType" : @"-1",
                                                          }]) {
                    [self.sendTagListArr removeObject:@{
                                                        @"Tag" : tag.tagName,
                                                        @"TagType" : @"-1",
                                                        }];
                    
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
                [self.sendTagListArr addObject:@{
                                                 @"Tag" : tag.tagName,
                                                 @"TagType" : @"1",
                                                 }];
            }else{
                if ([self.sendTagListArr containsObject:@{
                                                          @"Tag" : tag.tagName,
                                                          @"TagType" : @"1",
                                                          }]) {
                    [self.sendTagListArr removeObject:@{
                                                        @"Tag" : tag.tagName,
                                                        @"TagType" : @"1",
                                                        }];
                    
                }
            }
            [self.afterListArr replaceObjectAtIndex:index withObject:tag];
            self.afterSleepTag.tags = self.afterListArr;
            [self.afterSleepTag reloadTagSubviews];
        }
    }
}

#pragma mark 提交标签

- (void)getTagLists
{
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
    
    [self.afterSleepTag reloadTagSubviews];
    [self.beforeSleepTag reloadTagSubviews];
}

- (void)sendTags:(UIButton *)sender
{
    if (HardWareUUID.length>0) {
        
        if (self.sendTagListArr.count==0) {
            [self.view makeToast:@"请选择标签" duration:2 position:@"center"];
            return;
        }
        HaviLog(@"提交标签标签是%@",self.sendTagListArr);
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
