//
//  LiveHeartDataViewController.m
//  SleepRecoding
//
//  Created by Havi_li on 15/5/7.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "LiveHeartDataViewController.h"
#import "HeartLive.h"
#import "DataShowChartTableViewCell.h"
#import "XCoordinatorView.h"
#import "YCoordinatrorView.h"
#import "PaddingHeader.h"
//
#import "GetHeartLiveDataAPI.h"

@interface LiveHeartDataViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) HeartLive *heartMoniterView;
@property (nonatomic, strong) UITableView *upTableView;
//坐标轴
@property (nonatomic, strong) XCoordinatorView *xRowView;
@property (nonatomic, strong) YCoordinatrorView *yRowView;
@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, strong) NSTimer *getDataTimer;
//
@property (nonatomic, strong) NSMutableArray *ceshiArr;
@property (nonatomic,assign)  int data;

@property (nonatomic,strong) NSDate *queryEndDateString;
@property (nonatomic,strong) NSDateFormatter *dateFormmatterHeart;


@end

@implementation LiveHeartDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    self.ceshiArr = [[NSMutableArray alloc]init];
    for ( int i= 0; i<60; i++) {
        int num = [self getRandomNumber:39 to:39];
        [self.ceshiArr addObject:[NSNumber numberWithInt:num]];
    }
    //添加日历
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
            NSNumber *tempDataa = @([obj integerValue]);
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

- (HeartLive *)heartMoniterView
{
    
    if (!_heartMoniterView) {
        _heartMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(LeftLivePadding, 10, LiveViewWidth, 200)];
        _heartMoniterView.backgroundColor = [UIColor clearColor];
    }
    return _heartMoniterView;
}

- (XCoordinatorView *)xRowView
{
    if (!_xRowView) {
        _xRowView = [[XCoordinatorView alloc]initWithFrame:CGRectMake(LeftLivePadding-2, 210, self.view.frame.size.width-LeftLivePadding -RigthLivePadding, 25)];
        _xRowView.backgroundColor = [UIColor clearColor];
        _xRowView.xValues = @[@"5分钟",@"4分钟",@"3分钟",@"2分钟",@"1分钟",@"现在"];
    }
    return _xRowView;
}

- (YCoordinatrorView *)yRowView
{
    if (!_yRowView) {
        _yRowView = [[YCoordinatrorView alloc]initWithFrame:CGRectMake(0, 10,30 , 202)];
        _yRowView.backgroundColor = [UIColor clearColor];
        _yRowView.yValues = @[@"100",@"65",@"60",@"55",@"40"];
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
        cell.iconTitleName = [NSString stringWithFormat:@"icon_heart_rate_%d",selectedThemeIndex];
        cell.cellTitleName = @"心率";
        if (self.data < 40) {
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",0];
        }else{
            cell.cellData = [NSString stringWithFormat:@"%d次/分钟",self.data];
        }
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
    
}

#pragma mark 从服务器获取数据

- (void)getDataFromSeaver
{
    self.getDataTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getData) userInfo:nil repeats:YES];
}

- (void)createWorkDataSourceWithTimeInterval:(NSTimeInterval )timeInterval
{
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerTranslationFun) userInfo:nil repeats:YES];
}

//平移方式绘制
- (void)timerTranslationFun
{
    [[HeartPointContainer sharedContainer] addPointAsTranslationChangeform:[self bubbleTranslationPoint]];
    
    [self.heartMoniterView fireDrawingWithPoints:[[HeartPointContainer sharedContainer] translationPointContainer] pointsCount:[[HeartPointContainer sharedContainer] numberOfTranslationElements]];
    
}

- (CGPoint)bubbleTranslationPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    NSInteger pixelPerPoint = 1;
    static NSInteger xCoordinateInMoniter = 1;
    CGFloat height = CGRectGetHeight(self.heartMoniterView.frame);
    float value = (float)[self.dataSource[dataSourceCounterIndex] integerValue];
    CGFloat yCoor = [self getYCoordinate:value];
    CGPoint targetPointToAdd = (CGPoint){LiveViewWidth - RightLiveLinePadding -xCoordinateInMoniter,height - yCoor};
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(LiveViewWidth - RightLiveLinePadding);
    
//    NSLog(@"心率吐出来的点:%@",NSStringFromCGPoint(targetPointToAdd));
    self.data = (int)value;
    [self.upTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //modify
//    for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
//        self.ceshiArr[i] = self.ceshiArr[i-1];
//    }
//    [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:60]];
//    self.dataSource = self.ceshiArr;
    return targetPointToAdd;
}

- (CGFloat)getYCoordinate:(float)value
{
    CGFloat height = CGRectGetHeight(self.heartMoniterView.frame);
    CGFloat y = 0;
    CGFloat padding = height/4;
    if ((value>40 || value == 40)&&value<55) {
        y = padding/15*(value -40);
    }else if ((value == 55 ||value>55) && value<60){
        y = padding + (padding/5)*(value-55);
    }else if ((value>60 || value == 60) && value <65){
        y = 2*padding + (padding/5)*(value-60);
    }else if ((value>65||value == 65) && value<100){
        y = 3*padding + (padding/35)*(value-65);
    }else if ((value>100 || value == 100)){
        y = 4*padding;
    }else if (value<40){
        y= 0;
    }
    return y;
}
#pragma mark getData

- (void)getData
{
    NSDate *date = [NSDate date];
    //系统时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //和格林尼治时间差
    NSInteger timeOff = [zone secondsFromGMT]-60;
    //视察转化
    NSDate *timeOffDate = [date dateByAddingTimeInterval:timeOff];
    NSString *timeString = [NSString stringWithFormat:@"%@",timeOffDate];
    NSString *yearMonth = [NSString stringWithFormat:@"%@%@%@",[timeString substringWithRange:NSMakeRange(0, 4)],[timeString substringWithRange:NSMakeRange(5, 2)],[timeString substringWithRange:NSMakeRange(8, 2)]];
    NSString *secondAndHour = [timeString substringWithRange:NSMakeRange(11, 8)];
    NSLog(@"现在的时间是%@ he %@",yearMonth,secondAndHour);
    NSString *urlString = [NSString stringWithFormat:@"v1/app/SensorDataRealtime?UUID=%@&DataProperty=3&FromDate=&FromTime=",HardWareUUID];
    NSDictionary *header = @{
                             @"AccessToken":@"123456789"
                             };
    GetHeartLiveDataAPI *client = [GetHeartLiveDataAPI shareInstance];
    if ([client isExecuting]) {
        [client stop];
    }
    [client getHeartLiveData:header withDetailUrl:urlString];
    [client startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *resposeDic = (NSDictionary *)request.responseJSONObject;
        if ([[resposeDic objectForKey:@"ReturnCode"]intValue]==200){
            if ([[[[resposeDic objectForKey:@"SensorData"] objectAtIndex:0] objectForKey:@"Data"] count]>0) {
                NSArray *arr1 = [[[resposeDic objectForKey:@"SensorData"] objectAtIndex:0] objectForKey:@"Data"];
                //                int j = 0;
                NSArray *arr = [arr1 sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *p1, NSDictionary *p2){
                    return [[p1 objectForKey:@"At"] compare:[p2 objectForKey:@"At"]];
                    
                }];
                HaviLog(@"测试心率数组%@和时间%@",arr,self.queryEndDateString);
                NSString *dateString = [[arr lastObject]objectForKey:@"At"];
                NSDate *date = [self.dateFormmatterHeart dateFromString:dateString];
                NSDate *newDate = [[NSDate date]dateByAddingTimeInterval:8*60*60];
                if ([newDate timeIntervalSinceDate:date]<30) {
                    
                    for (int i=0; i<arr.count; i++) {
                        if (self.queryEndDateString) {
                            for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                                self.ceshiArr[i] = self.ceshiArr[i-1];
                            }
                            [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[[arr objectAtIndex:i] objectForKey:@"Value"] intValue]]];
                            
                            /*
                             NSString *dateString = [[arr objectAtIndex:i]objectForKey:@"At"];
                             NSDate *date = [self.dateFormmatterHeart dateFromString:dateString];
                             if ([date timeIntervalSinceDate:self.queryEndDateString]>0) {
                             for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                             self.ceshiArr[i] = self.ceshiArr[i-1];
                             }
                             [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[[[arr objectAtIndex:i] objectForKey:@"Value"] intValue]]];
                             }else{
                             
                             }
                             */
                        }else {
                            //第一次请求
                            if (i<60) {
                                [self.ceshiArr replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[[[arr objectAtIndex:i] objectForKey:@"Value"]intValue]]];
                            }
                        }
                    }
                    
                    NSString *s = [[arr lastObject] objectForKey:@"At"];
                    self.queryEndDateString = [self.dateFormmatterHeart dateFromString:s];
                }else{
                    
                    for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                        self.ceshiArr[i] = self.ceshiArr[i-1];
                    }
                    [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:39]];
                    
                }
//
            }else{
                //是200但是没有数据
                for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                    self.ceshiArr[i] = self.ceshiArr[i-1];
                }
                [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:39]];
            }
            
        }else{
           //这个是returncode 不是200
            for (int i =(int)self.ceshiArr.count-1; i>0; i--) {
                self.ceshiArr[i] = self.ceshiArr[i-1];
            }
            [self.ceshiArr replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:39]];
        }
        self.dataSource = self.ceshiArr;
    } failure:^(YTKBaseRequest *request) {
        
    }];
    
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

#pragma mark view消失
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer1 invalidate];
    [self.getDataTimer invalidate];
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
