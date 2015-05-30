
//
//  LiveLeaveDataViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/5/7.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LiveLeaveDataViewController.h"
#import "LeaveLive.h"
#import "DataShowChartTableViewCell.h"
#import "XCoordinatorView.h"
#import "YCoordinatrorView.h"
#import "PaddingHeader.h"
#import "GetLeaveLiveDataAPI.h"
#import "GetDefatultSleepAPI.h"


@interface LiveLeaveDataViewController ()

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) LeaveLive *heartMoniterView;
@property (nonatomic, strong) UITableView *upTableView;
//坐标轴
@property (nonatomic, strong) XCoordinatorView *xRowView;
@property (nonatomic, strong) YCoordinatrorView *yRowView;
@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, strong) NSTimer *getDataTimer;
@property (nonatomic, strong) NSTimer *getSleepTimer;

@property (nonatomic, strong) NSMutableArray *ceshiArr;
@property (nonatomic,assign)  int data;
@property (nonatomic,strong) NSDate *queryEndDateString;
@property (nonatomic,strong) NSDateFormatter *dateFormmatterHeart;


@end

@implementation LiveLeaveDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加日历
    self.ceshiArr = [[NSMutableArray alloc]init];
    for ( int i= 0; i<230; i++) {
        int num = [self getRandomNumber:0 to:0];
        [self.ceshiArr addObject:[NSNumber numberWithInt:num]];
    }
//    self.queryEndDateString = [NSDate date];
    self.viewHeight = self.view.frame.size.height;
    CGRect rect = self.datePicker.frame;
    rect.origin.y = rect.origin.y - 64;
    self.datePicker.frame = rect;
    [self.view addSubview:self.datePicker];
    [self.datePicker.calenderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"menology_%d",selectedThemeIndex]] forState:UIControlStateNormal];
    self.datePicker.monthLabel.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    self.datePicker.userInteractionEnabled = NO;
    //
    [self.view addSubview:self.upTableView];
    //
    void (^createData)(void) = ^{
        NSString *tempString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableArray *tempData = [[tempString componentsSeparatedByString:@","] mutableCopy];
        [tempData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *tempDataa = @(-[obj integerValue] + 60);
            [tempData replaceObjectAtIndex:idx withObject:tempDataa];
        }];
        self.dataSource = tempData;
    };
    createData();
}

#pragma mark setter

- (NSDateFormatter*)dateFormmatterHeart
{
    if (!_dateFormmatterHeart) {
        _dateFormmatterHeart = [[NSDateFormatter alloc]init];
        [_dateFormmatterHeart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _dateFormmatterHeart.timeZone = self.tmZoneBase;
    }
    return _dateFormmatterHeart;
}
- (UITableView *)upTableView
{
    if (!_upTableView) {
        int height = self.datePicker.frame.size.height;
        _upTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64-height)];
        _upTableView.backgroundColor = [UIColor clearColor];
        _upTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _upTableView.delegate = self;
        _upTableView.dataSource = self;
        _upTableView.scrollEnabled = NO;
    }
    return _upTableView;
}

- (LeaveLive *)heartMoniterView
{
    
    if (!_heartMoniterView) {
        _heartMoniterView = [[LeaveLive alloc] initWithFrame:CGRectMake(LeftLivePadding, 10, LiveViewWidth, 200)];
        _heartMoniterView.backgroundColor = [UIColor clearColor];
    }
    return _heartMoniterView;
}

- (XCoordinatorView *)xRowView
{
    if (!_xRowView) {
        _xRowView = [[XCoordinatorView alloc]initWithFrame:CGRectMake(LeftLivePadding-2, 210, self.view.frame.size.width-LeftLivePadding -RigthLivePadding, 25)];
        _xRowView.backgroundColor = [UIColor clearColor];
//        _xRowView.xValues = @[@"5分前",@"4分前",@"3分前",@"2分前",@"1分前",@"现在"];
    }
    return _xRowView;
}

- (YCoordinatrorView *)yRowView
{
    if (!_yRowView) {
        _yRowView = [[YCoordinatrorView alloc]initWithFrame:CGRectMake(0, 10,30 , 202)];
        _yRowView.backgroundColor = [UIColor clearColor];
        _yRowView.yValues = @[@"1",@"0",@" "];
    }
    return _yRowView;
}

#pragma mark tableview 代理方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        static NSString *cellIndentifier = @"cell0";
        DataShowChartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[DataShowChartTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        }
        //timeSwitchButton
        cell.iconTitleName = [NSString stringWithFormat:@"icon_get_up_%d",selectedThemeIndex];
        cell.cellTitleName = @"离床";
        
        cell.cellData = [NSString stringWithFormat:@"%d次/天",self.data];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        static NSString *cellName = @"cellTitle";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        [cell addSubview:self.heartMoniterView];
        [cell addSubview:self.xRowView];
        [cell addSubview:self.yRowView];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    }else{
        return self.upTableView.frame.size.height-60;
    }
}

#pragma mark viewAppeare 函数
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self createWorkDataSourceWithTimeInterval:1];
    [self getDataFromSeaver];
//    [self getData];
//    self.getSleepTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(getSleepData) userInfo:nil repeats:YES];
}

//- (void)getSleepData
//{
//    
//}

#pragma mark 从服务器获取数据

- (void)getDataFromSeaver
{
    self.getDataTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getData) userInfo:nil repeats:YES];
}

- (void)createWorkDataSourceWithTimeInterval:(NSTimeInterval )timeInterval
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerTranslationFun) userInfo:nil repeats:YES];
}

- (void)getData
{
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataRealtime?UUID=%@&DataProperty=2&FromDate=&FromTime=",HardWareUUID];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetLeaveLiveDataAPI *client = [GetLeaveLiveDataAPI shareInstance];
    [client getLeaveLiveData:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200){
            if ([[[[resposeDic objectForKey:@"SensorData"] objectAtIndex:0] objectForKey:@"Data"] count]>0) {
                NSArray *arr = [[[resposeDic objectForKey:@"SensorData"] objectAtIndex:0] objectForKey:@"Data"];
//                int j = 0;
                for (int i=0; i<arr.count; i++) {
                    if (self.queryEndDateString) {
                        NSString *dateString = [[arr objectAtIndex:i]objectForKey:@"At"];
                        NSDate *date = [self.dateFormmatterHeart dateFromString:dateString];
                        if ([date timeIntervalSinceDate:self.queryEndDateString]>0) {
                            for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                                self.ceshiArr[i] = self.ceshiArr[i-1];
                            }
                            [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[[arr objectAtIndex:i] objectForKey:@"Value"] intValue]]];
                        }else{
                        }
                    }else {
                        //第一次请求
                        for (int i=0; i<230; i++) {
                        }
                        
                    }
                }
                NSString *s = [[arr lastObject] objectForKey:@"At"];
                self.queryEndDateString = [self.dateFormmatterHeart dateFromString:s];
                
            }else{
                
            }
        }else{
            
        }
        self.dataSource = self.ceshiArr;
    } failure:^(YTKBaseRequest *request) {
        
    }];
    //睡眠质量
    NSDate *newDate = [[NSDate date]dateByAddingTimeInterval:8*60*60];
    NSString *nowDate = [NSString stringWithFormat:@"%@",newDate];
    NSString *subString = [NSString stringWithFormat:@"%@%@%@",[nowDate substringWithRange:NSMakeRange(0, 4)],[nowDate substringWithRange:NSMakeRange(5, 2)],[nowDate substringWithRange:NSMakeRange(8, 2)]];
    NSString *urlString1 = [NSString stringWithFormat:@"v1/app/SleepQuality?UUID=%@&FromDate=%@&EndDate=%@&FromTime=&EndTime=",HardWareUUID,subString,subString];
    GetDefatultSleepAPI *client1 = [GetDefatultSleepAPI shareInstance];
    /*
     增加了一个判断当前的是不是在进行，进行的话终止
     */
    if ([client1 isExecuting]) {
        [client1 stop];
    }
    [client1 queryDefaultSleep:header withDetailUrl:urlString1];
    [client1 startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        //        [KVNProgress dismiss];
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200) {
            self.data =0;
            int data = [[resposeDic objectForKey:@"OutOfBedTimes"]intValue];
            self.data = data;
            [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        HaviLog(@"离床睡眠质量:%@",resposeDic);
    } failure:^(YTKBaseRequest *request) {
        
    }];
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}


//平移方式绘制
- (void)timerTranslationFun
{
    [[LeavePointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleTranslationPoint]];
    
    [self.heartMoniterView fireDrawingWithPoints:[[LeavePointContainer sharedContainer] translationPointContainer] pointsCount:[[LeavePointContainer sharedContainer] numberOfTranslationElements]];
    
}

- (CGPoint)bubbleTranslationPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    NSInteger pixelPerPoint = 1;
    static NSInteger xCoordinateInMoniter = 1;
    CGFloat height = CGRectGetHeight(self.heartMoniterView.frame);
    CGPoint targetPointToAdd = (CGPoint){LiveViewWidth - RightLiveLinePadding -xCoordinateInMoniter,(1-[self.dataSource[0] integerValue]) * (0.5*height)};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(LiveViewWidth - RightLiveLinePadding);
    for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
        self.ceshiArr[i] = self.ceshiArr[i-1];
    }
    [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
    self.dataSource = self.ceshiArr;
//    NSLog(@"离床吐出来的点:%@",NSStringFromCGPoint(targetPointToAdd));
    return targetPointToAdd;
}

#pragma mark view消失
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer1 invalidate];
    [self.getDataTimer invalidate];
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
