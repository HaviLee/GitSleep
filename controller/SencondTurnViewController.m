//
//  SencondTurnViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/9/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "SencondTurnViewController.h"
#import "DataTableViewCell.h"

@interface SencondTurnViewController ()
@property (nonatomic, strong) UIImageView *leaveImage;
@property (nonatomic, strong) UILabel *sleepTimeLabel;
@property (nonatomic, strong) UIView *circleSleepView;
@property (nonatomic, strong) UILabel *timesLabel;
@property (nonatomic, strong) UILabel *circleTitle;
@property (nonatomic, strong) UILabel *circleSubTitle;
@property (nonatomic, strong) UITableView *bottomTableView;
@end

@implementation SencondTurnViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavigationView];
    [self createSubView];
    [self.view addSubview:self.bottomTableView];
    
}

#pragma mark 创建view

- (void)createSubView
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 203)];
    backView.backgroundColor = [UIColor clearColor];
    [backView addSubview:self.leaveImage];
    [backView addSubview:self.sleepTimeLabel];
    [backView addSubview:self.circleSleepView];
    [self.circleSleepView addSubview:self.timesLabel];
    [self.circleSleepView addSubview:self.circleTitle];
    [self.circleSleepView addSubview:self.circleSubTitle];
    [self.leaveImage makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView);
        make.height.equalTo(34);
        make.width.equalTo(51);
        make.left.equalTo(backView.left).offset((self.view.frame.size.width-51-150)/2);
        
    }];
    [self.sleepTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.leaveImage.centerY);
        make.height.equalTo(30);
        make.width.equalTo(150);
        make.left.equalTo(self.leaveImage.right).offset(20);
    }];
    
    [self.circleSleepView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(backView.centerX);
        make.top.equalTo(self.leaveImage.bottom).offset(25);
        make.width.equalTo(139);
        make.width.equalTo(self.circleSleepView.height);
    }];
    
    [self.timesLabel makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self.circleSleepView.center);
        make.height.equalTo(20);
        make.width.equalTo(20);
    }];
    
    [self.circleTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timesLabel.centerX);
        make.bottom.equalTo(self.timesLabel.top).offset(-10);
        make.height.equalTo(30);
        make.width.equalTo(100);
    }];
    
    [self.circleSubTitle makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.timesLabel.centerX);
        make.top.equalTo(self.timesLabel.bottom).offset(10);
        make.height.equalTo(20);
        make.width.equalTo(20);
    }];
    
    [self.view addSubview:backView];
}

- (void)createNavigationView
{
    //    isUp = YES;
    //    self.viewHeight = self.view.frame.size.height;
    //    _modalAnimationController = [[ModalAnimation alloc] init];
    [self createClearBgNavWithTitle:nil createMenuItem:^UIView *(int nIndex) {
        if (nIndex == 1)
        {
            [self.leftButton addTarget:self action:@selector(backToHomeView:) forControlEvents:UIControlEventTouchUpInside];
            return self.leftButton;
        }
        else if (nIndex == 0){
            if ([self isThirdAppAllInstalled]) {
                self.rightButton.frame = CGRectMake(self.view.frame.size.width-40, 0, 30, 44);
                [self.rightButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"btn_share_%d",selectedThemeIndex]] forState:UIControlStateNormal];
                [self.rightButton addTarget:self action:@selector(shareApp:) forControlEvents:UIControlEventTouchUpInside];
                return self.rightButton;
            }
            return nil;
        }
        return nil;
    }];
}

#pragma mark setter

- (UITableView *)bottomTableView
{
    if (_bottomTableView == nil) {
        _bottomTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,203+64 , self.view.frame.size.width, self.view.frame.size.height-204-64) style:UITableViewStylePlain];
        _bottomTableView.backgroundColor = [UIColor clearColor];
        _bottomTableView.delegate = self;
        _bottomTableView.dataSource = self;
        _bottomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _bottomTableView;
}

- (UIImageView *)leaveImage
{
    if (_leaveImage==nil) {
        _leaveImage = [[UIImageView alloc]init];
        //                       WithFrame:CGRectMake(100, 0, 51, 34)];
        _leaveImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_getup_%d",selectedThemeIndex]];
    }
    return _leaveImage;
}

- (UILabel *)sleepTimeLabel
{
    if (_sleepTimeLabel==nil) {
        _sleepTimeLabel = [[UILabel alloc]init];
        //                           WithFrame:CGRectMake(151, 2, 100, 30)];
        _sleepTimeLabel.text = @"睡眠时长为:8小时";
        _sleepTimeLabel.font = [UIFont systemFontOfSize:17];
    }
    return _sleepTimeLabel;
}

- (UIView *)circleSleepView
{
    if (_circleSleepView == nil) {
        _circleSleepView = [[UIView alloc]init];
        _circleSleepView.layer.cornerRadius = 68.5;
        _circleSleepView.layer.masksToBounds = YES;
        _circleSleepView.backgroundColor = selectedThemeIndex==0?[self colorWithHex:0x0e254c alpha:1]:[self colorWithHex:0x5e8abe alpha:1];
    }
    return _circleSleepView;
}

- (UILabel *)timesLabel
{
    if (_timesLabel == nil) {
        _timesLabel = [[UILabel alloc]init];
        _timesLabel.text = @"5";
        _timesLabel.font = [UIFont systemFontOfSize:25];
        _timesLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timesLabel;
}

- (UILabel *)circleTitle{
    if (_circleTitle==nil) {
        _circleTitle = [[UILabel alloc]init];
        _circleTitle.text = @"您昨晚离床";
        _circleTitle.font = [UIFont systemFontOfSize:15];
        _circleTitle.textAlignment = NSTextAlignmentCenter;
        
    }
    return _circleTitle;
}

- (UILabel *)circleSubTitle
{
    if (_circleSubTitle==nil) {
        _circleSubTitle = [[UILabel alloc]init];
        _circleSubTitle.font = [UIFont systemFontOfSize:15];
        _circleSubTitle.textAlignment = NSTextAlignmentCenter;
        _circleSubTitle.text = @"次";
        
    }
    return _circleSubTitle;
}

#pragma mark tableview 代理函数

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.bottomTableView]) {
        
        static NSString *cellTitle = @"cellTitle";
        DataTableViewCell *cell = (DataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellTitle];
        if (cell==nil) {
            cell = [[DataTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTitle];
        }
        if (indexPath.row%2==0) {
            cell.leftTitleName = @"";
            cell.leftSubTitleName = @"";
        }else{
            cell.rightTitleName = @"9月1日";
            cell.rightSubTitleName = @"22:30";
        }
        cell.backgroundColor = [UIColor clearColor];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
}

#pragma mark button 实现方法

- (void)backToHomeView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareApp:(UIButton *)sender
{
    [self.shareMenuView show];
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
