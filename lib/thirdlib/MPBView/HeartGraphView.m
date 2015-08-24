//
//  HeartGraphView.m
//  SleepRecoding
//
//  Created by Havi on 15/8/14.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "HeartGraphView.h"
#import "ChartViewDefine.h"

@interface HeartGraphView ()
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

@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UIImageView *rightImage;

@end

@implementation HeartGraphView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.isDrawDashLine = YES;
    }
    return self;
}

- (NSMutableArray *)viewArr
{
    if (_viewArr == nil) {
        _viewArr = [[NSMutableArray alloc]init];
    }
    return _viewArr;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.isDrawDashLine = YES;
    }
    return self;
}

+(instancetype)heartGraphView
{
    HeartGraphView *chartView = [[self alloc] init];
    // 默认值
    chartView.frame = CGRectMake(10, 70, 300, 220);
    return chartView;
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
//    if (self.xValues.count != 0) {
//        if (!self.shutDefaultAnimation) {
//            [self setUpCoordinateSystem];
//        }
//    }
}

- (CGContextRef)context
{
    if (!_context) {
        _context = UIGraphicsGetCurrentContext();
    }
    return _context;
}
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self drawCoorPointAndDashLine];
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

-(NSDictionary *)textStyleDict
{
    if (!_textStyleDict) {
        UIFont *font = [UIFont systemFontOfSize:13];
        NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init]; // 段落样式
        style.alignment = NSTextAlignmentCenter;
        _textStyleDict = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor],
                           };
    }
    return _textStyleDict;
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

-(void)drawCoorPointAndDashLine
{
    // 根据值画x/y轴的值
    [self setUpXcoorWithValues:self.xValues];
    [self setUpYcoorWithValues:self.yValues];
    if (self.isDrawDashLine) {
        // 绘制网格竖线
        [self drawDashLine];
    }
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

- (void)drawHorironLineView
{
    UIView *horironLine = [[UIView alloc]init];
    horironLine.frame = CGRectMake(0, yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*self.horizonLine-0.5, self.heartView.frame.size.width, 1);
    horironLine.backgroundColor = RGBA(251, 82, 106, 0.5) ;
    [self.heartView addSubview:horironLine];
}

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
    backView.alpha = 0.2;
    [self addSubview:backView];
}


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
- (void)setBackImage
{
    
    [self addSubview:self.leftImage];
    
    [self addSubview:self.rightImage];
}
#pragma mark setter meathod

- (UIImageView *)leftImage
{
    if (_leftImage == nil) {
        _leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin, 5, xCoordinateWidth/2+2, yCoordinateHeight)];
        _leftImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_night_%d",selectedThemeIndex]];
        _leftImage.tag = 2001;
    }
    return _leftImage;
}

- (UIImageView *)rightImage
{
    if (_rightImage == nil) {
        _rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin+xCoordinateWidth/2+2, 5, xCoordinateWidth/2, yCoordinateHeight)];
        _rightImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_day_%d",selectedThemeIndex]];
        _rightImage.tag = 2001;
    }
    return _rightImage;
}

- (MPGraphView *)heartView
{
    if (_heartView==nil) {
        _heartView=[[MPGraphView alloc] initWithFrame:CGRectMake(self.leftLineMargin, 5, xCoordinateWidth, yCoordinateHeight)];
        _heartView.waitToUpdate=NO;
        _heartView.lineWidth = 0.5;
        _heartView.backgroundColor = [UIColor clearColor];
//        _heartView.values=@[@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@60,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,@56,@57,@55,@59,@60,@64,@78,@65,@78,@56,];
    }
    return _heartView;
}
//作图
/*
- (void)drawFuncLine
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[PNBarNew class]]) {
            [view removeFromSuperview];
        }
    }
    
    
    for (int i=0; i<_funcPoints.count; i++) {
        int gradePercent = [[_funcPoints objectAtIndex:i]intValue];
        CGPoint xPoint = [[self.xPoints objectAtIndex:i]CGPointValue];
        __block PNBarNew *bar = [[PNBarNew alloc] initWithFrame:CGRectMake(xPoint.x+15, 20+(yCoordinateHeight-15)/5*(5-gradePercent), (xCoordinateWidth-15-6)/_funcPoints.count-30,(yCoordinateHeight-15)/5*gradePercent)];
        bar.alpha = 0;
        [UIView animateWithDuration:1.0 animations:^{
            bar.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        
        /*
         PNBar * bar = [[PNBar alloc] initWithFrame:CGRectMake(xPoint.x+5, 20+(yCoordinateHeight-15)/5*(5-gradePercent), (xCoordinateWidth-15-6)/_funcPoints.count-10, (yCoordinateHeight-15)/5*gradePercent)];
         //顺序决定了颜色
         bar.barColor = [self returnColorWithSleepLevel:gradePercent];
         bar.grade = gradePercent;
         if (gradePercent!=0) {
         UILabel *label = [self getTopLabelWithLevel:gradePercent andColor:[self returnColorWithSleepLevel:gradePercent] andFrame:CGRectMake(xPoint.x, 20+(yCoordinateHeight-15)/5*(5-gradePercent)- 20, (xCoordinateWidth-15-6)/_funcPoints.count, 20)];
         label.tag = 999;
         [self addSubview:label];
         }
        [self addSubview:bar];
    }
    
}
*/


-(CAShapeLayer *)setUpLineLayer
{
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinBevel;
    
    lineLayer.strokeEnd   = 0.0;
    if (self.chartColor) {
        lineLayer.strokeColor = self.chartColor.CGColor;
    }else{
        lineLayer.strokeColor = RandomColor.CGColor;
    }
    if (self.chartWidth) {
        lineLayer.lineWidth   = self.chartWidth;
    }else{
        lineLayer.lineWidth   = 1.0;
    }
    return lineLayer;
}

- (void)drawHorironLineWithColorView
{
    for (UIView *view in self.viewArr) {
        [view removeFromSuperview];
    }
    [self.viewArr removeAllObjects];
    for (int i=0; i<self.yPoints.count; i++) {
        UIView *horironLine = [[UIView alloc]init];
        horironLine.backgroundColor = [UIColor colorWithRed:0.569f green:0.765f blue:0.867f alpha:1.00f] ;
        CGPoint yPoint = [[self.yPoints objectAtIndex:i] CGPointValue];
        horironLine.frame = CGRectMake(self.leftLineMargin, yPoint.y, 2, 1);
        [self addSubview:horironLine];
        [self.viewArr addObject:horironLine];
        
    }
}

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}
// 绘制网格竖虚线
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
//        for (NSValue *xP in localXpoints) {
//            CGPoint xPoint = [xP CGPointValue];
//            CGMutablePathRef path = CGPathCreateMutable();
//            
//            CGPathMoveToPoint(path, nil, xPoint.x, yCoordinateHeight+5);
//            CGPathAddLineToPoint(path, nil, xPoint.x,yCoordinateHeight);
//            
//            //            CGPathMoveToPoint(path, nil, xPoint.x, xPoint.y);
//            //            CGPathAddLineToPoint(path, nil, xPoint.x, minYPoint.y);
//            CGContextAddPath(ctx, path);
//            CGContextDrawPath(ctx, kCGPathFillStroke);
//            CGPathRelease(path);
//        }
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


// 通过UIView得到x y轴坐标轴
-(UIView *)getLineCoor
{
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    lineView.alpha = 0.3;
    lineView.frame = CGRectMake(self.leftLineMargin, self.frame.size.height - bottomLineMargin, coorLineWidth, coorLineWidth);
    return lineView;
}

// 通过coreGraphics画坐标轴
-(void)drawCoordinateXy
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef xPath = CGPathCreateMutable();
    CGPathMoveToPoint(xPath, nil, self.leftLineMargin, self.frame.size.height - bottomLineMargin);
    CGPathAddLineToPoint(xPath, nil, self.leftLineMargin + xCoordinateWidth + 2, self.frame.size.height - bottomLineMargin);
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetAlpha(ctx, 0.6);
    CGContextAddPath(ctx, xPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(xPath);
    CGMutablePathRef yPath = CGPathCreateMutable();
    CGPathMoveToPoint(yPath, nil, self.leftLineMargin, self.frame.size.height - bottomLineMargin);
    CGPathAddLineToPoint(yPath, nil, self.leftLineMargin, self.frame.size.height - bottomLineMargin - yCoordinateHeight - 2);
    CGContextAddPath(ctx, yPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGPathRelease(yPath);
    
}
//刷新x轴
- (void)reloadGraphXValueArr:(NSArray *)arr
{
    [self setUpXcoorWithValues:arr];
}


#pragma mark - 添加坐标轴的值
-(void)setUpXcoorWithValues:(NSArray *)values
{
    for (UIView *view in self.subviews) {
        if (view.tag ==1000 || view.tag == 1009|| view.tag == 2001) {
            [view removeFromSuperview];
        }
    }
    
    if (isUserDefaultTime) {
        
    }else{
        [self setBackImage];
    }
    if (values.count){
        [self.xPoints removeAllObjects];
        NSUInteger count = values.count;
        for (int i = 0; i < count; i++) {
            NSString *xValue = values[i];
            
            CGFloat cX = 0;
            if ([values[0] isEqualToString:@"0"]) { // 第一个坐标值是0
                cX = (xCoordinateWidth / (count - 1)) * i + self.leftLineMargin;
            }else{ // 第一个坐标值不是0
                cX = (xCoordinateWidth / (count-1)) * (i) + self.leftLineMargin +1;
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
            //            [xValue drawAtPoint:CGPointMake(cX - size.width * 0.7 - ((xCoordinateWidth-15)/(count-1))/2, cY + 5) withAttributes:self.textStyleDict];
        }
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        if ([self.xValues[0] isEqualToString:@"0"]){
            [localXpoints removeObjectAtIndex:0];
        }
        for (NSValue *xP in localXpoints) {
            
            CGPoint xPoint = [xP CGPointValue];
            UIView *lineView = [[UIView alloc]init];
            lineView.frame = CGRectMake(xPoint.x, yCoordinateHeight+2, 1, 3);
            lineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            lineView.tag = 1009;
            [self addSubview:lineView];
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
