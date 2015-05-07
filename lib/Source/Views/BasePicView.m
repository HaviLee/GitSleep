//
//  BasePicView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/3/6.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BasePicView.h"
@implementation BasePicView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.929f green:0.929f blue:0.929f alpha:1.00f];

    }
    return self;
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
        _diagonseTitle.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];;
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
        _diagnoseChoice.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];;
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
        _diagnoseResult.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];;
        _diagnoseResult.font = [UIFont systemFontOfSize:17];
        
    }
    return _diagnoseResult;
}

- (UILabel *)diagnoseShow
{
    if (!_diagnoseShow) {
        _diagnoseShow = [[UILabel alloc]init];
        _diagnoseShow.frame = CGRectMake(35, 50, self.frame.size.width-20, 40);
        _diagnoseShow.textColor = selectedThemeIndex==0?DefaultColor:[UIColor grayColor];;
        _diagnoseShow.font = [UIFont systemFontOfSize:15];
        _diagnoseShow.text = @"昨晚您的心率不是太稳定，呼吸较快，总体睡眠不是很好";
        _diagnoseShow.numberOfLines = 0;
    }
    return _diagnoseShow;
}

- (UIImageView *)gifImageUp
{
    if (!_gifImageUp) {
        _gifImageUp = [[UIImageView alloc]init];
        _gifImageUp.frame = CGRectMake((self.frame.size.width-30)/2, 5, 25, 9);
        NSArray *gifArray = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"btn_up_one"],
                             [UIImage imageNamed:@"btn_up_two"],
                             [UIImage imageNamed:@"btn_up_three"],nil];
        _gifImageUp.animationImages = gifArray; //动画图片数组
        _gifImageUp.animationDuration = 1; //执行一次完整动画所需的时长
        _gifImageUp.animationRepeatCount = 999;  //动画重复次数
        [_gifImageUp startAnimating];
    }
    return _gifImageUp;
}

- (UIImageView *)gifImageDown
{
    if (!_gifImageDown) {
        _gifImageDown = [[UIImageView alloc]init];
        _gifImageDown.frame = CGRectMake((self.frame.size.width-30)/2, 5, 25, 9);
        NSArray *gifArray = [NSArray arrayWithObjects:
                             [UIImage imageNamed:@"btn_down_one"],
                             [UIImage imageNamed:@"btn_down_two"],
                             [UIImage imageNamed:@"btn_down_three"],
                             nil];
        _gifImageDown.animationImages = gifArray; //动画图片数组
        _gifImageDown.animationDuration = 1; //执行一次完整动画所需的时长
        _gifImageDown.animationRepeatCount = 999;  //动画重复次数
        [_gifImageDown startAnimating];
    }
    return _gifImageDown;
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

- (UILabel *)diagnoseSubLabel
{
    if (!_diagnoseSubLabel) {
        
    }
    return _diagnoseSubLabel;
}
/*
- (ToggleView *)timeSwitchButton
{
    if (!_timeSwitchButton) {
        _timeSwitchButton = [[ToggleView alloc]initWithFrame:CGRectMake(self.frame.size.width - 130, 15, 120, 25) toggleViewType:ToggleViewTypeNoLabel toggleBaseType:ToggleBaseTypeDefault toggleButtonType:ToggleButtonTypeChangeImage];
        _timeSwitchButton.toggleDelegate = self;
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
            [self.timeSwitchButton changeLeftImageWithTime:0.5];;
        }else{
            [self.timeSwitchButton changeRightImageWithTime:0.5];
        }
        
    }
    return _timeSwitchButton;
}
*/
- (UITableView *)chartTableView
{
    if (!_chartTableView) {
        _chartTableView = [[UITableView alloc]initWithFrame:self.frame style:UITableViewStylePlain];
        _chartTableView.backgroundColor = [UIColor clearColor];
        _chartTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _chartTableView;
}
/*
#pragma mark toggleView delegate

- (void)selectLeftButton
{
    HaviLog(@"左侧");
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
        [self.timeSwitchButton changeRightImageWithTime:0];
    }else{
        isUserDefaultTime = NO;
        [self.timeSwitchButton changeLeftImageWithTime:1.5];
        [[NSNotificationCenter defaultCenter]postNotificationName:TwtityFourHourNoti object:nil];
    }
}

- (void)selectRightButton
{
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:SleepSettingSwitchKey]isEqualToString:@"NO"]) {
        [ShowAlertView showAlert:@"请到设置中开启睡眠时间设定"];
        [self.timeSwitchButton changeLeftImageWithTime:0];
    }else{
        isUserDefaultTime = YES;
        [self.timeSwitchButton changeRightImageWithTime:1.5];
        //    _timeSwitchButton.selectedButton = ToggleButtonSelectedRight;
        [[NSNotificationCenter defaultCenter]postNotificationName:UserDefaultHourNoti object:nil];
        HaviLog(@"右侧");
    }
}
*/
- (UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white www.stuhack.com
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)dealloc
{
    self.gifImageDown = nil;
    self.gifImageUp = nil;
}

@end
