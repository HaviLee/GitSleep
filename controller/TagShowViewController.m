//
//  TagShowViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/8/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "TagShowViewController.h"
#import "TLTagsControl.h"
@interface TagShowViewController ()<TLTagsControlDelegate>

@property (nonatomic, strong) TLTagsControl *beforeSleepTag;
@property (nonatomic, strong) TLTagsControl *afterSleepTag;
@property (nonatomic, strong) UIImageView *beforeSleepImage;
@property (nonatomic, strong) UIImageView *afterSleepImage;
@property (nonatomic, strong) UILabel *beforeSleepLabel;
@property (nonatomic, strong) UILabel *afterSleepLabel;
@property (nonatomic, strong) NSMutableArray *beforeListArr;
@property (nonatomic, strong) NSMutableArray *afterListArr;

@end

@implementation TagShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavWithTitle:@"睡眠报告" createMenuItem:^UIView *(int nIndex)
     {
         if (nIndex == 1)
         {
             [self.leftButton addTarget:self action:@selector(backToView:) forControlEvents:UIControlEventTouchUpInside];
             return self.leftButton;

         }
         return nil;
     }];
//    self.bgImageView.image = nil;
    [self setSleepTag];
    [self setSleepTagContraints];
    
}

#pragma mark setter meathod

- (NSMutableArray *)beforeListArr
{
    if (_beforeListArr == nil) {
        _beforeListArr = [[NSMutableArray alloc]init];
        TagObject *tag1 = [[TagObject alloc]init];
        tag1.tagName = @"运动健身";
        tag1.isSelect = NO;
        
        TagObject *tag2 = [[TagObject alloc]init];
        tag2.tagName = @"晚饭过量";
        tag2.isSelect = NO;
        
        TagObject *tag3 = [[TagObject alloc]init];
        tag3.tagName = @"吃的晚了";
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
        tag1.isSelect = NO;
        
        TagObject *tag2 = [[TagObject alloc]init];
        tag2.tagName = @"离床过频";
        tag2.isSelect = NO;
        
        TagObject *tag3 = [[TagObject alloc]init];
        tag3.tagName = @"翻身过多";
        tag3.isSelect = NO;
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
        _beforeSleepTag.tagsBackgroundColor = [UIColor colorWithRed:0.278f green:0.624f blue:0.616f alpha:1.00f];
        _beforeSleepTag.tagsTextColor = [UIColor lightGrayColor];
        
    }
    return _beforeSleepTag;
}

- (TLTagsControl *)afterSleepTag
{
    if (_afterSleepTag==nil) {
        _afterSleepTag = [[TLTagsControl alloc]initWithFrame:CGRectMake(0, 100, 300, 30) andTags:self.afterListArr withTagsControlMode:TLTagsControlModeList];
        _afterSleepTag.tagsBackgroundColor = [UIColor colorWithRed:0.278f green:0.624f blue:0.616f alpha:1.00f];
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
        _beforeSleepLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
    }
    return _beforeSleepLabel;
}

- (UILabel *)afterSleepLabel
{
    if (_afterSleepLabel == nil) {
        _afterSleepLabel = [[UILabel alloc]init];
        _afterSleepLabel.text = @"睡眠报告";
        _afterSleepLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];
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
    
    if ([tagsControl isEqual:self.beforeSleepTag]) {
        NSLog(@"beforeTag \"%@\" was tapped", tagsControl.tags[index]);
        TagObject *tag = (TagObject *)tagsControl.tags[index];
        tag.isSelect = !tag.isSelect;
        [self.beforeListArr replaceObjectAtIndex:index withObject:tag];
        self.beforeSleepTag.tags = self.beforeListArr;
        [self.beforeSleepTag reloadTagSubviews];
        
    }else{
        NSLog(@"afterTag \"%@\" was tapped", tagsControl.tags[index]);
        TagObject *tag = (TagObject *)tagsControl.tags[index];
        tag.isSelect = !tag.isSelect;
        [self.afterListArr replaceObjectAtIndex:index withObject:tag];
        self.afterSleepTag.tags = self.afterListArr;
        [self.afterSleepTag reloadTagSubviews];
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
