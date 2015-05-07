//
//  TableViewCell.m
//  UUChartView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "TableViewCell.h"
#import "UUChart.h"

@interface TableViewCell ()<UUChartDataSource>
{
    NSIndexPath *path;
    UUChart *chartView;
}
@property (assign) UUChartStyle chartStyle;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style withFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)configUI:(NSIndexPath *)indexPath
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
    path = indexPath;
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, self.contentView.frame.size.height)
                                              withSource:self
                                               withStyle:indexPath.section==1?UUChartBarStyle:UUChartLineStyle];
    [chartView showInView:self.contentView];
}

- (void)configCellUI:(HaviChartStyle)ChartStyle withData:(NSArray *)dataArrayIn
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
//    path = indexPath;
    if (self.dataArray) {
        self.dataArray = nil;
        self.dataArray = [[NSMutableArray alloc]initWithArray:dataArrayIn];
    }else{
        self.dataArray = [[NSMutableArray alloc]initWithArray:dataArrayIn];
    }
    if (ChartStyle == HaviChartLineStyle) {
        self.chartStyle = UUChartLineStyle;
    }else if (ChartStyle == HaviChartBarStyle){
        self.chartStyle = UUChartBarStyle;
    }
    
    chartView = [[UUChart alloc]initwithUUChartDataFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, self.frame.size.height-20)
                                              withSource:self
                                               withStyle:self.chartStyle];
//    chartView = [[UUChart alloc]init];
//    chartView.chartStyle = self.chartStyle;
//    chartView.dataSource = self;
    NSLog(@"自身cell的frame%f,%f,%f,%f",self.contentView.frame.origin.x,self.contentView.frame.origin.y,self.frame.size.height,self.contentView.frame.size.width);
    [chartView showInView:self];
}

- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        NSString * str = [NSString stringWithFormat:@"R-%d",i];
        [xTitles addObject:str];
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{

    if (self.chartStyle == UUChartBarStyle) {
        return [self getXTitles:(int)_dataArray.count];
    }else if (self.chartStyle == UUChartLineStyle){
        return [self getXTitles:(int)_dataArray.count];
    }
//    if (path.section==0) {
//        switch (path.row) {
//            case 0:
//                return [self getXTitles:5];
//            case 1:
//                return [self getXTitles:11];
//            case 2:
//                return [self getXTitles:7];
//            case 3:
//                return [self getXTitles:7];
//            default:
//                break;
//        }
//    }else{
//        switch (path.row) {
//            case 0:
//                return [self getXTitles:11];
//            case 1:
//                return [self getXTitles:7];
//            default:
//                break;
//        }
//    }
    return [self getXTitles:20];
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
//    NSArray *ary = @[@"22",@"44",@"15",@"40",@"42"];
//    NSArray *ary1 = @[@"22",@"54",@"15",@"30",@"42",@"77",@"43"];
    NSArray *ary2 = @[@"76",@"34",@"54",@"23",@"16",@"32",@"17"];
//    NSArray *ary3 = @[@"3",@"12",@"25",@"55",@"52"];
//    NSArray *ary4 = @[@"23",@"42",@"25",@"15",@"30",@"42",@"32",@"40",@"42",@"25",@"33"];
    if (self.chartStyle == UUChartLineStyle) {
        return @[_dataArray];
    }else{
        return @[_dataArray];
    }
//    if (path.section==0) {
//        switch (path.row) {
//            case 0:
//                return @[ary];
//            case 1:
//                return @[ary4];
//            case 2:
//                return @[ary1,ary2];
//            default:
//                return @[ary1,ary2,ary3];
//        }
//    }else{
//        if (path.row) {
//            return @[ary1,ary2];
//        }else{
//            return @[ary4];
//        }
//    }
}

#pragma mark - @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    if (self.chartStyle == UUChartLineStyle) {
        return CGRangeMake(100, 0);
    }else{
        return CGRangeMake(60, 10);
    }
//    if (path.section==0 && (path.row==0|path.row==1)) {
//        return CGRangeMake(60, 10);
//    }
//    if (path.section==1 && path.row==0) {
//        return CGRangeMake(60, 10);
//    }
//    if (path.row==2) {
//        return CGRangeMake(100, 0);
//    }
    return CGRangeZero;
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    if (path.row==2) {
        return CGRangeMake(25, 75);
    }
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return path.row==2;
}
@end
