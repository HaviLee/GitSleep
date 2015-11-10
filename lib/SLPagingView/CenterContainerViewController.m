//
//  CenterContainerViewController.m
//  SleepRecoding
//
//  Created by Havi on 15/10/21.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "CenterContainerViewController.h"
#import "CenterViewTableViewCell.h"
#import "CHCircleGaugeView.h"

#import "NewSecondHeartViewController.h"
#import "NewSecondBreathViewController.h"
#import "SencondLeaveViewController.h"
#import "SencondTurnViewController.h"

@interface CenterContainerViewController ()
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) UITableView *leftTableView;
@property (nonatomic,strong) UITableView *rightTableView;
@property (nonatomic, strong) UILabel *leftSleepTimeLabel;//睡眠时长
@property (nonatomic, strong) UILabel *rightSleepTimeLabel;//睡眠时长
@property (nonatomic, strong) CHCircleGaugeView *leftCircleView;
@property (nonatomic, strong) NSArray *leftCellDataArr;
@property (nonatomic, strong) NSArray *subPageViewArr;
//
@property (nonatomic, strong) SencondLeaveViewController *sendLeaveView;
@property (nonatomic, strong) SencondTurnViewController *sendTurnView;
@property (nonatomic, strong) NewSecondBreathViewController *secondBreathView;
@property (nonatomic, strong) NewSecondHeartViewController *secondHeartView;

@end

@implementation CenterContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setPageViewController];
    [self setControllerBackGroundImage];
    
}

- (void)setControllerBackGroundImage
{
     self.subPageViewArr = @[self.secondHeartView,self.secondBreathView,self.sendLeaveView,self.sendTurnView];
    if (selectedThemeIndex == 0) {
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_night_%d",0]];
    }else{
        self.bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_bg_center_%d",1]];
    }
}

- (void)setPageViewController
{
    self.dataSource = [[NSMutableArray alloc] initWithArray:@[@"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!",
                                                              @"Hello world!", @"Shaqtin' a fool!", @"YEAHHH!"]];
    // Do any additional setup after loading the view.
    UILabel *navTitleLabel1 = [UILabel new];
    navTitleLabel1.text = @"梧桐植树";
    navTitleLabel1.font = [UIFont fontWithName:@"Helvetica" size:20];
    navTitleLabel1.textColor = [UIColor whiteColor];
    
    UILabel *navTitleLabel2 = [UILabel new];
    navTitleLabel2.text = @"哈维之家";
    navTitleLabel2.font = [UIFont fontWithName:@"Helvetica" size:20];
    navTitleLabel2.textColor = [UIColor whiteColor];
    
    SLPagingViewController *pageViewController = [[SLPagingViewController alloc] initWithNavBarItems:@[navTitleLabel1, navTitleLabel2]
                                                                                    navBarBackground:[UIColor colorWithRed:0.33 green:0.68 blue:0.91 alpha:1.000]
                                                                                               views:@[self.leftTableView, self.rightTableView]
                                                                                     showPageControl:YES];
    [pageViewController setCurrentPageControlColor:[UIColor whiteColor]];
    [pageViewController setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
    [pageViewController updateUserInteractionOnNavigation:NO];
    
    // Twitter Like
    pageViewController.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
        float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
        float width = [UIScreen mainScreen].bounds.size.width;
        CGFloat xOffset = scrollView.contentOffset.x;
        int i = 0;
        for(UILabel *v in subviews){
            CGFloat alpha = 0.0;
            if(v.frame.origin.x < mid)
                alpha = 1 - (xOffset - i*width) / width;
            else if(v.frame.origin.x >mid)
                alpha=(xOffset - i*width) / width + 1;
            else if(v.frame.origin.x == mid-5)
                alpha = 1.0;
            i++;
            v.alpha = alpha;
        }
    };
    
    pageViewController.didChangedPage = ^(NSInteger currentPageIndex){
        // Do something
        NSLog(@"index %ld", (long)currentPageIndex);
    };
//    pageViewController.navigationBarView.image = [UIImage imageNamed:@"navi_pg_night_0"];
//    [pageViewController.navigationBarView addSubview:self.menuButton];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:pageViewController];
    [self addChildViewController:navi];
    [self.view addSubview:navi.view];
    CGRect rect = self.view.frame;
    int datePickerHeight = self.view.frame.size.height*0.202623;
    rect.size.height = rect.size.height- datePickerHeight;
    [navi.view setFrame:rect];
    [self.view addSubview:self.datePicker];
}

#pragma mark setter

- (NewSecondHeartViewController*)secondHeartView
{
    if (!_secondHeartView) {
        _secondHeartView = [[NewSecondHeartViewController alloc]init];
    }
    return _secondHeartView;
}

- (NewSecondBreathViewController*)secondBreathView
{
    if (!_secondBreathView) {
        _secondBreathView = [[NewSecondBreathViewController alloc]init];
    }
    return _secondBreathView;
}

- (SencondLeaveViewController*)sendLeaveView
{
    if (_sendLeaveView == nil) {
        _sendLeaveView = [[SencondLeaveViewController alloc]init];
    }
    return _sendLeaveView;
}

- (SencondTurnViewController*)sendTurnView
{
    if (_sendTurnView == nil) {
        _sendTurnView = [[SencondTurnViewController alloc]init];
    }
    return _sendTurnView;
}


- (CHCircleGaugeView *)leftCircleView
{
    if (_leftCircleView == nil) {
        int datePickerHeight = self.view.frame.size.height*0.202623;
        if (ISIPHON4) {
            _leftCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35+60)];
        }else{
            _leftCircleView = [[CHCircleGaugeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35)];
        }
        _leftCircleView.trackTintColor = selectedThemeIndex==0?[UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f] : [UIColor colorWithRed:0.961f green:0.863f blue:0.808f alpha:1.00f];
        _leftCircleView.trackWidth = 1;
        _leftCircleView.gaugeStyle = CHCircleGaugeStyleOutside;
        _leftCircleView.gaugeTintColor = [UIColor blackColor];
        _leftCircleView.gaugeWidth = 15;
        _leftCircleView.valueTitleLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftCircleView.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftCircleView.responseColor = [UIColor greenColor];
        _leftCircleView.font = [UIFont systemFontOfSize:30];
        _leftCircleView.rotationValue = 100;
        _leftCircleView.value = 0.0;
    }
    return _leftCircleView;
}


- (UILabel *)leftSleepTimeLabel
{
    if (_leftSleepTimeLabel == nil) {
        _leftSleepTimeLabel = [[UILabel alloc]init];
        _leftSleepTimeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        _leftSleepTimeLabel.textAlignment = NSTextAlignmentCenter;
        _leftSleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _leftSleepTimeLabel.backgroundColor = [UIColor clearColor];
        _leftSleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _leftSleepTimeLabel.text = @"睡眠时长:0小时0分";
    }
    return _leftSleepTimeLabel;
}

- (UILabel *)rightSleepTimeLabel
{
    if (_rightSleepTimeLabel == nil) {
        _rightSleepTimeLabel = [[UILabel alloc]init];
        _rightSleepTimeLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
        _rightSleepTimeLabel.textAlignment = NSTextAlignmentCenter;
        _rightSleepTimeLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
        _rightSleepTimeLabel.backgroundColor = [UIColor clearColor];
        _rightSleepTimeLabel.font = [UIFont systemFontOfSize:17];
        _rightSleepTimeLabel.text = @"睡眠时长:0小时0分";
    }
    return _rightSleepTimeLabel;
}

- (UITableView *)leftTableView
{
    if (!_leftTableView) {
        CGRect rect = self.view.frame;
        _leftTableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
        _leftTableView.scrollEnabled = NO;
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.backgroundColor = [UIColor clearColor];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView
{
    if (!_rightTableView) {
        CGRect rect = self.view.frame;
        _rightTableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
        _rightTableView.scrollEnabled = NO;
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.backgroundColor = [UIColor clearColor];
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _rightTableView;
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<5) {
        
        if (indexPath.row==4) {
            return 30;
        }else{
            if (ISIPHON4) {
                return 34;
            }else
            {
                return 44;
            }
        }
    }else{
        if (indexPath.row==5) {
            int datePickerHeight = self.view.frame.size.height*0.202623;
            return self.view.frame.size.height - (64 + 4*44 +30 + 10)-datePickerHeight-10-35;
        }else{
            return 44;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.leftTableView]) {
        if (indexPath.row<5) {
            
            static NSString *cellIndetifier = @"leftCell";
            CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
            if (cell == nil) {
                cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
            }
            if (indexPath.row==4) {
                [cell addSubview:self.leftSleepTimeLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
                NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
                cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
                cell.cellData = [self.leftCellDataArr objectAtIndex:indexPath.row];
                cell.cellImageName = [cellImage objectAtIndex:indexPath.row];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                for (UIImageView*imageLine in cell.subviews) {
                    if (imageLine.tag == 100) {
                        [imageLine removeFromSuperview];
                    }
                }
                UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
                imageLine.tag = 100;
                [cell addSubview:imageLine];
                [imageLine makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.left).offset(5);
                    make.right.equalTo(cell.right).offset(-5);
                    make.bottom.equalTo(cell.bottom).offset(-1);
                    make.height.equalTo(0.5);
                }];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else{
            static NSString *cellIndentifier1 = @"leftCellLast";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier1];
            }
            if (indexPath.row==5) {
                [cell addSubview:self.leftCircleView];
            }else{
                cell.textLabel.text = @"li";
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            return cell;
            
        }
        
    }else{
        if (indexPath.row<5) {
            
            static NSString *cellIndetifier = @"rightCell";
            CenterViewTableViewCell *cell = (CenterViewTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
            if (cell == nil) {
                cell = [[CenterViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
            }
            if (indexPath.row==4) {
                [cell addSubview:self.leftSleepTimeLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else{
                NSArray *titleArr = @[@"心率",@"呼吸",@"离床",@"体动"];
                NSArray *cellImage = @[[NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_breathe_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex],[NSString stringWithFormat:@"icon_turn_over_%d",selectedThemeIndex]];
                cell.cellTitle = [titleArr objectAtIndex:indexPath.row];
                cell.cellData = [self.leftCellDataArr objectAtIndex:indexPath.row];
                cell.cellImageName = [cellImage objectAtIndex:indexPath.row];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                for (UIImageView*imageLine in cell.subviews) {
                    if (imageLine.tag == 100) {
                        [imageLine removeFromSuperview];
                    }
                }
                UIImageView *imageLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"line_640_%d",selectedThemeIndex]]];
                imageLine.tag = 100;
                [cell addSubview:imageLine];
                [imageLine makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(cell.left).offset(5);
                    make.right.equalTo(cell.right).offset(-5);
                    make.bottom.equalTo(cell.bottom).offset(-1);
                    make.height.equalTo(0.5);
                }];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            }
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }else{
            static NSString *cellIndentifier1 = @"rightCellLast";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier1];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier1];
            }
            if (indexPath.row==5) {
                [cell addSubview:self.leftCircleView];
            }else{
                cell.textLabel.text = @"li";
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.145f green:0.733f blue:0.957f alpha:0.15f];
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row<4) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.navigationController pushViewController:[self.leftCellDataArr objectAtIndex:indexPath.row] animated:YES];
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
