//
//  WeekReportView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/13.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "WeekReportView.h"
#import "ChartViewDefine.h"
#import "PNBar.h"
@interface WeekReportView ()

@property (nonatomic) CGContextRef context;

@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary   *textStyleDict;
@property (assign, nonatomic) CGFloat maxYValue;

@property (strong, nonatomic) NSMutableArray *funcPoints;
// 左边间距要根据具体的坐标值去计算
@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) BOOL islineDrawDone;

@end

@implementation WeekReportView
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        //        self.layer.backgroundColor = [UIColor purpleColor].CGColor;
        //        self.layer.opacity = 0.2;
        self.isDrawDashLine = YES;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.isDrawDashLine = YES;
    }
    return self;
}

+(instancetype)weekReportView
{
    WeekReportView *chartView = [[self alloc] init];
    // 默认值
    chartView.frame = CGRectMake(10, 70, 300, 220);
    return chartView;
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
        if (!self.shutDefaultAnimation) {
            [self setUpCoordinateSystem];
        }
    }
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
    
    if (self.shutDefaultAnimation) {
        [self drawCoordinateXy];
    }
    
    if (self.islineDrawDone) {
        [self drawCoorPointAndDashLine];
        
    }
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
        _textStyleDict = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor],};
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

- (void)drawArrow:(CGPoint)point context:(CGContextRef)context
{
    //利用path进行绘制三角形
    CGPoint sPoints[3];//坐标点
    sPoints[0] =CGPointMake(self.leftLineMargin+1 -5 , 5);//坐标1
    sPoints[1] =CGPointMake(self.leftLineMargin+1 , 0);//坐标2
    sPoints[2] =CGPointMake(self.leftLineMargin+1+5, 5);//坐标3
    CGContextAddLines(self.context, sPoints, 3);//添加线
    CGContextSetLineWidth(self.context, 1);
//    CGContextClosePath(self.context);//封起来
    CGContextDrawPath(self.context, kCGPathFillStroke); //根据坐标绘制路径
}

-(void)drawCoorPointAndDashLine
{
    // 根据值画x/y轴的值
    [self setUpXcoorWithValues:self.xValues];
    [self setUpYcoorWithValues:self.yValues];
    if (self.isDrawDashLine) {
        // 绘制网格竖线
        [self drawDashLine];
//        横线
        [self drawHorironLineWithColor];
    }
    //添加睡眠指数
    [self setYCoorLabel];
    //添加箭头
    [self drawArrow:CGPointMake(self.leftLineMargin, 0) context:self.context];
    // 画曲线
    [self drawFuncLine];
}
//睡眠指数label
- (void)setYCoorLabel
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, -30, 60, 30)];
    label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    CGPoint center = label.center;
    center.x = self.leftLineMargin;
    label.center = center;
    label.text = @"睡眠指数";
    label.font = [UIFont systemFontOfSize:12];
    [self addSubview:label];
    
}

- (void)reloadChartView
{
    [self drawFuncLine];
}
//作图
- (void)drawFuncLine
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[PNBar class]]) {
            [view removeFromSuperview];
        }
        if (view.tag ==999) {
            [view removeFromSuperview];
        }
    }
    for (int i=0; i<_funcPoints.count; i++) {
        int gradePercent = [[_funcPoints objectAtIndex:i]intValue];
        CGPoint xPoint = [[self.xPoints objectAtIndex:i]CGPointValue];
//        PNBar * bar = [[PNBar alloc] initWithFrame:CGRectMake(xPoint.x+5, 20+(yCoordinateHeight-15)/5*(5-gradePercent), (xCoordinateWidth-15-6)/_funcPoints.count-10, (yCoordinateHeight-15)/5*gradePercent)];
        PNBar * bar = [[PNBar alloc] initWithFrame:CGRectMake(xPoint.x+(xCoordinateWidth - 56)/14, 20+(yCoordinateHeight-15)/5*(5-gradePercent), 8, (yCoordinateHeight-15)/5*gradePercent)];
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

- (UILabel *)getTopLabelWithLevel:(int)level andColor:(UIColor*)scolor andFrame:(CGRect )frame
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.text = [self changeNumToWord:level];
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = scolor;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (NSString *)changeNumToWord:(int)level
{
    switch (level) {
        case 1:{
            return @"非常差";
            break;
        }
        case 2:{
            return @"差";
            break;
        }
        case 3:{
            return @"一般";
            break;
        }
        case 4:{
            return @"好";
            break;
        }
        case 5:{
            return @"非常好";
            break;
        }
            
        default:
            return @"";
            break;
    }
}

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

- (void)drawHorironLineWithColor
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
    // 设置上下文环境 属性
    CGFloat dashLineWidth = 2;
    [selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, dashLineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetAlpha(ctx, 0.6);
    CGFloat alilengths[2] = {1, 0};
    CGContextSetLineDash(ctx, 0, alilengths, 2);
    
    for (int i=0; i<self.yPoints.count; i++) {
        CGContextStrokePath(ctx);
        /*
        switch (i) {
            case 0:{
                [[self colorWithHex:0x33cc00 alpha:0.3]setStroke];
                break;
            }
            case 1:{
                [[self colorWithHex:0xff9900 alpha:0.3]setStroke];
                break;
            }
            case 2:{
                [[self colorWithHex:0xc9c9c9 alpha:0.3]setStroke];
                break;
            }
            case 3:{
                [[self colorWithHex:0x34cacc alpha:0.3]setStroke];
                break;
            }
            case 4:{
                [[self colorWithHex:0x535353 alpha:0.3]setStroke];
                break;
            }
                
            default:
                break;
        }
        */
        [[UIColor colorWithRed:0.569f green:0.765f blue:0.867f alpha:1.00f] setStroke];
        CGPoint yPoint = [[self.yPoints objectAtIndex:i] CGPointValue];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, yPoint.x+1, yPoint.y );
        CGPathAddLineToPoint(path, nil, self.leftLineMargin +4, yPoint.y );
        /*
        CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y );
        CGPathAddLineToPoint(path, nil, maxXPoint.x+15, yPoint.y);
         */
        CGContextAddPath(ctx, path);
        CGContextDrawPath(ctx, kCGPathFillStroke);
        CGPathRelease(path);
        
    }
    
}

- (UIColor *)returnColorWithSleepLevel:(int)colorIndex
{
    switch (colorIndex) {
        case 1:{
            return [self colorWithHex:0x3D4E5E alpha:1.0];
            break;
        }
        case 2:{
            return [self colorWithHex:0x8AB8E2 alpha:1.0];
            break;
        }
        case 3:{
            return [self colorWithHex:0xFCAE3C alpha:1.0];
            break;
        }
        case 4:{
            return [self colorWithHex:0x23A7E4 alpha:1.0];
            break;
        }
        case 5:{
            return [self colorWithHex:0x30C704 alpha:1.0];
            break;
        }
            
        default:
            return [UIColor clearColor];
            break;
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
        CGFloat dashLineWidth = 2;
        [[UIColor colorWithRed:0.569f green:0.765f blue:0.867f alpha:1.00f] setStroke];
        CGContextSetLineWidth(ctx, dashLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetAlpha(ctx, 1);
        CGFloat alilengths[2] = {1.5, 1};
        CGContextSetLineDash(ctx, 0, alilengths, 2);
        
        // 画竖虚线
        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
        if ([self.xValues[0] isEqualToString:@"0"]){
            [localXpoints removeObjectAtIndex:0];
        }
        for (int i=0; i<localXpoints.count; i++) {
            CGPoint xPoint = [[localXpoints objectAtIndex:i]CGPointValue];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, nil, xPoint.x, yCoordinateHeight+5);
            CGPathAddLineToPoint(path, nil, xPoint.x,yCoordinateHeight);
            /*
            CGPathMoveToPoint(path, nil, xPoint.x, xPoint.y);
            CGPathAddLineToPoint(path, nil, xPoint.x, minYPoint.y -15);
             */
            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
        }
        //        for (NSValue *xP in localXpoints) {
        //            CGPoint xPoint = [xP CGPointValue];
        //
        //        }
        //        // 画横虚线
        //        for (NSValue *yP in self.yPoints) {
        //            CGPoint yPoint = [yP CGPointValue];
        //            CGMutablePathRef path = CGPathCreateMutable();
        //            CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y );
        //            CGPathAddLineToPoint(path, nil, xCoordinateWidth, yPoint.y );
        //            CGContextAddPath(ctx, path);
        //            CGContextDrawPath(ctx, kCGPathFillStroke);
        //            CGPathRelease(path);
        //        }
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
    CGContextSetLineWidth(ctx, 2);
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

#pragma mark - 添加坐标轴的值
-(void)setUpXcoorWithValues:(NSArray *)values
{
    if (values.count){
        NSUInteger count = values.count;
        for (int i = 0; i < count; i++) {
            NSString *xValue = values[i];
            
            CGFloat cX = 0;
            if ([values[0] isEqualToString:@"0"]) { // 第一个坐标值是0
                cX = ((xCoordinateWidth-15) / (count - 1)) * i + self.leftLineMargin;
                if(i==0){
                    cX = cX+1;
                }
            }else{ // 第一个坐标值不是0
                cX = ((xCoordinateWidth-15) / (count)) * (i) + self.leftLineMargin + 2;
            }
            CGFloat cY = self.frame.size.height - bottomLineMargin;
            // 收集坐标点
            [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(cX, cY)]];
            if (i == 0 && [values[0] isEqualToString:@"0"]) continue;
            CGSize size = [xValue boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textStyleDict context:nil].size;
            [xValue drawAtPoint:CGPointMake(cX - size.width * 0.5 - ((xCoordinateWidth-15)/(count-1))/2, cY + 5) withAttributes:self.textStyleDict];
        }
    }
}

-(void)setUpYcoorWithValues:(NSArray *)values
{
    if (values.count) {
        NSUInteger count = self.yValues.count;
        for (int i = 0; i < count; i++) {
            NSString *yValue = [NSString stringWithFormat:@"%@",values[count-i-1]];
            CGFloat cX = self.leftLineMargin;
            CGFloat cY = i * ((yCoordinateHeight-15) / count) +20;
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
