//
//  BreathGraphView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "BreathGraphView.h"
#import "ChartViewDefine.h"

@interface BreathGraphView ()
@property (nonatomic) CGContextRef context;

@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary   *textStyleDict;
@property (assign, nonatomic) CGFloat maxYValue;

@property (strong, nonatomic) NSMutableArray *funcPoints;
// 左边间距要根据具体的坐标值去计算
@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) BOOL islineDrawDone;
@property (nonatomic, strong) NSMutableArray *viewArr;
//
@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UIImageView *rightImage;
@end

@implementation BreathGraphView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+(instancetype)breathGraphView
{
    BreathGraphView *chartView = [[self alloc] init];
    // 默认值
    chartView.frame = CGRectMake(10, 70, 300, 220);
    return chartView;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawCoorPointAndDashLine];
}

#pragma mark setter meathod

- (UIImageView *)leftImage
{
    if (_leftImage == nil) {
        _leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin, 5, xCoordinateWidth/2+2, yCoordinateHeight)];
        _leftImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_night_%d",selectedThemeIndex]];
    }
    return _leftImage;
}

- (UIImageView *)rightImage
{
    if (_rightImage == nil) {
        _rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin+xCoordinateWidth/2+2, 5, xCoordinateWidth/2, yCoordinateHeight)];
        _rightImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_day_%d",selectedThemeIndex]];
    }
    return _rightImage;
}

- (void)setDataValues:(NSMutableArray *)dataValues
{
    if (!_funcPoints) {
        _funcPoints = [[NSMutableArray alloc]init];
    }
    if (_funcPoints.count>0) {
        [_funcPoints removeAllObjects];
    }
    for (int i = 0; i<dataValues.count; i++) {
        [_funcPoints addObject:[dataValues objectAtIndex:i]];
    }
}

- (MPGraphView *)heartView
{
    if (_heartView==nil) {
        _heartView=[[MPGraphView alloc] initWithFrame:CGRectMake(self.leftLineMargin, 5, xCoordinateWidth, yCoordinateHeight)];
        _heartView.waitToUpdate=NO;
        _heartView.lineWidth = 0.5;
        _heartView.backgroundColor = [UIColor clearColor];
        //                _heartView.values=@[@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,];
    }
    return _heartView;
}

- (CGContextRef)context
{
    if (!_context) {
        _context = UIGraphicsGetCurrentContext();
    }
    return _context;
}

-(NSDictionary *)textStyleDict
{
    if (!_textStyleDict) {
        UIFont *font = [UIFont systemFontOfSize:13];
        NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init]; // 段落样式
        style.alignment = NSTextAlignmentCenter;
        _textStyleDict = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor],};
    }
    return _textStyleDict;
}

- (void)setXValues:(NSArray *)xValues
{
    _xValues = xValues;
    if (self.yValues.count != 0) {
        [self setUpCoordinateSystem];
    }
}

-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    // 算出合理的左边距
    CGFloat maxStrWidth = 0;
    for (NSString *yValue in yValues) {
        CGSize size = [yValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
        // 得到文本的最大宽度
        if (size.width > maxStrWidth) {
            maxStrWidth = size.width;
        }
    }
    
    self.leftLineMargin = maxStrWidth + 6;
    if (self.xValues.count != 0) {
        [self setUpCoordinateSystem];
    }
}

- (NSMutableArray *)viewArr
{
    if (_viewArr == nil) {
        _viewArr = [[NSMutableArray alloc]init];
    }
    return _viewArr;
}

#pragma mark - 懒加载

-(NSMutableArray *)xPoints
{
    if (!_xPoints) {
        _xPoints = [NSMutableArray array];
    }
    return _xPoints;
}

-(NSMutableArray *)yPoints
{
    if (!_yPoints) {
        _yPoints = [NSMutableArray array];
    }
    return _yPoints;
}



#pragma mark - 创建坐标系
-(void)setUpCoordinateSystem // 利用UIView作为坐标轴动态画出坐标系
{
    UIView *xCoordinate = [self getLineCoor];
    UIView *yCoordinate = [self getLineCoor];
    [self addSubview:xCoordinate];
    [self addSubview:yCoordinate];
    [UIView animateWithDuration:0.0 animations:^{
        CGRect rect1 = xCoordinate.frame;
        rect1.size.width = xCoordinateWidth + 2;
        xCoordinate.frame = rect1;
        CGRect rect2 = yCoordinate.frame;
        rect2.size.height = - yCoordinateHeight - 2;
        yCoordinate.frame = rect2;
    } completion:^(BOOL finished) {
        //画箭头
        self.islineDrawDone = YES;
        [self createAnimation];
        [self setNeedsDisplay];
        [self layoutIfNeeded];
    }];
}

#pragma mark 创建坐标轴刻度
-(void)drawCoorPointAndDashLine
{
    // 根据值画x/y轴的值
    [self setUpXcoorWithValues:self.xValues];
    [self setUpYcoorWithValues:self.yValues];
    [self drawDashLine];
    if (isUserDefaultTime) {
        
    }else{
        [self setBackImage];
    }
    self.heartView.graphColor= selectedThemeIndex == 0?DefaultColor:[UIColor whiteColor];
    self.heartView.curved=YES;
    [self addSubview:self.heartView];
    [self drawHorironLineView];
    [self drawBackColor];
}

#pragma mark 创建水平线
- (void)drawHorironLineView
{
    UIView *horironLine = [[UIView alloc]init];
    horironLine.frame = CGRectMake(0, yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*self.horizonLine-0.5, self.heartView.frame.size.width, 1);
    horironLine.backgroundColor = RGBA(251, 82, 106, 0.5) ;
    [self.heartView addSubview:horironLine];
}
#pragma mark 创建标准线范围
- (void)drawBackColor
{
    UIView *backView = [[UIView alloc]init];
    CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
    float width = maxXPoint.x - self.leftLineMargin;
    float x = self.leftLineMargin;
    float y1 = yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*self.backMinValue + 5;
    float y2 = yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*self.backMaxValue + 5;
    
    backView.frame = CGRectMake(x, y1, width, y2-y1);
    backView.backgroundColor = [UIColor lightGrayColor];
    backView.alpha = 0.3;
    [self addSubview:backView];
}
/*旧的方法不再使用
- (void)drawHrizonerLine
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
    // 设置上下文环境 属性
    CGFloat dashLineWidth = 1;
    [selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, dashLineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetAlpha(ctx, 0.6);
    CGFloat alilengths[2] = {1, 0};
    CGContextSetLineDash(ctx, 0, alilengths, 2);
    
    float yValue = yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*60 + 5;
    CGPoint yPoint = CGPointMake(self.leftLineMargin, yValue);
    //    CGPoint yPoint = [yP CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y );
    CGPathAddLineToPoint(path, nil, maxXPoint.x - 5, yPoint.y );
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGPathRelease(path);
}
 */

- (void)setBackImage
{
    
    [self addSubview:self.leftImage];
    
    [self addSubview:self.rightImage];
}

//睡眠指数label

- (void)reloadChartView
{
    //    [self drawFuncLine];
    [self setUpYcoorWithValues:self.yValues];
    
}
#pragma mark 绘制网格竖虚线
-(void)drawDashLine
{
    if (self.xPoints.count != 0 && self.yPoints.count != 0) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        //        CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
        //        CGPoint minYPoint = [[self.yPoints firstObject] CGPointValue];
        
        // 设置上下文环境 属性
        CGFloat dashLineWidth = 1;
        [selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] setStroke];
        CGContextSetLineWidth(ctx, dashLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetAlpha(ctx, 1);
        CGFloat alilengths[2] = {1, 0};
        CGContextSetLineDash(ctx, 0, alilengths, 2);
        
        // 画竖虚线
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        if ([self.xValues[0] isEqualToString:@"0"]){
            [localXpoints removeObjectAtIndex:0];
        }
        for (NSValue *xP in localXpoints) {
            CGPoint xPoint = [xP CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            
            CGPathMoveToPoint(path, nil, xPoint.x, yCoordinateHeight+5);
            CGPathAddLineToPoint(path, nil, xPoint.x,yCoordinateHeight);
            
            //            CGPathMoveToPoint(path, nil, xPoint.x, xPoint.y);
            //            CGPathAddLineToPoint(path, nil, xPoint.x, minYPoint.y);
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
        }
        // 画横虚线
        for (NSValue *yP in self.yPoints) {
            CGPoint yPoint = [yP CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y );
            CGPathAddLineToPoint(path, nil, self.leftLineMargin +5, yPoint.y );
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
        }
    }
}

#pragma mark 通过UIView得到x y轴坐标轴
-(UIView *)getLineCoor
{
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    lineView.alpha = 0.3;
    lineView.frame = CGRectMake(self.leftLineMargin, self.frame.size.height - bottomLineMargin, coorLineWidth, coorLineWidth);
    return lineView;
}

#pragma mark - 添加坐标轴的值
-(void)setUpXcoorWithValues:(NSArray *)values
{
    for (UIView *view in self.subviews) {
        if (view.tag ==1000) {
            [view removeFromSuperview];
        }
    }
    if (values.count){
        NSUInteger count = values.count;
        for (int i = 0; i < count; i++) {
            NSString *xValue = values[i];
            
            CGFloat cX = 0;
            if ([values[0] isEqualToString:@"0"]) { // 第一个坐标值是0
                cX = (xCoordinateWidth / (count - 1)) * i + self.leftLineMargin;
            }else{ // 第一个坐标值不是0
                cX = (xCoordinateWidth / (count-1)) * (i) + self.leftLineMargin + 2;
            }
            CGFloat cY = self.frame.size.height - bottomLineMargin;
            // 收集坐标点
            [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
            CGSize size = [xValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
            if (i == 0 && [values[0] isEqualToString:@"0"]) continue;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cX - size.width * 0.5, cY + 5, ((xCoordinateWidth)/(count-1)), 10)];
            label.text = xValue;
            label.tag = 1000;
            label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentLeft;
            [self addSubview:label];
        }
    }
}

-(void)setUpYcoorWithValues:(NSArray *)values
{
    if (values.count) {
        NSUInteger count = self.yValues.count;
        if (self.yValueCount) {
            count = self.yValueCount;
        }
        NSString *maxValue = values[0];
        for (int i = 1; i < count; i++) {
            if ([maxValue floatValue] < [values[i] floatValue]) {
                maxValue = values[i];
            }
        }
        self.maxYValue = [maxValue floatValue];
        CGFloat scale = [maxValue floatValue] / count;
        for (int i = 0; i < count; i++) {
            NSString *yValue = [NSString stringWithFormat:@"%.0f", [maxValue floatValue] - (i * scale)];
            CGFloat cX = self.leftLineMargin;
            CGFloat cY = i * (yCoordinateHeight / count) + 5;
            CGSize size = [yValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
            [yValue drawAtPoint:CGPointMake(cX - size.width - 5, cY - size.height * 0.5 + 1) withAttributes:self.textStyleDict];
            // 收集坐标点
            [self.yPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
        }
    }
}

#pragma mark - 创建坐标系出现的动画
-(void)createAnimation
{
    CATransition *transition = [[CATransition alloc] init];
    //    transition.type = @"rippleEffect";
    transition.type = kCATransitionFade;
    transition.duration = 1.0;
    [self.layer addAnimation:transition forKey:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
