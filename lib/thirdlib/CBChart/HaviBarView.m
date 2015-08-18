//
//  HaviBarView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/2.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "HaviBarView.h"
#import "ChartViewDefine.h"
#import "PNBar.h"

@interface HaviBarView ()

@property (nonatomic) CGContextRef context;
@property (nonatomic) CGGradientRef gradient;

@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary   *textStyleDict;
@property (assign, nonatomic) CGFloat maxYValue;

@property (strong, nonatomic) NSMutableArray *funcPoints;


// 左边间距要根据具体的坐标值去计算
@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) BOOL islineDrawDone;

@end

@implementation HaviBarView
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

+(instancetype)barView
{
    HaviBarView *barView = [[self alloc] init];
    // 默认值
    barView.frame = CGRectMake(10, 70, 300, 220);
    return barView;
}

- (CGGradientRef )gradient
{
    if (!_gradient) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //blue gradient
        CGFloat locations[] = {0.0, 0.5, 1.0};
        CGFloat colorComponents[] = {
            0.639, 0.769, 0.604, 1.0, //red, green, blue, alpha
            0.404, 0.733, 0.510, 1.0,
            0.325, 0.718, 0.475, 1.0
        };
        size_t count = 3;
        CGGradientRef defaultGradient = CGGradientCreateWithColorComponents(colorSpace, colorComponents, locations, count);
        _gradient = defaultGradient;
        CGColorSpaceRelease(colorSpace);

    }
    return _gradient;
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

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.context = UIGraphicsGetCurrentContext();
    if (self.shutDefaultAnimation) {
        [self drawCoordinateXy];
    }
    
    if (self.islineDrawDone) {
        [self drawCoorPointAndDashLine];
    }
}

- (void)setDataValues:(NSArray *)dataValues
{
    if (_funcPoints) {
        _funcPoints = nil;
    }
    if (dataValues.count>0) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:@"GMT"];
        [NSTimeZone setDefaultTimeZone:tzGMT];
        
        if (!_funcPoints) {
            _funcPoints = [[NSMutableArray alloc]init];
        }
        for (int i = 0; i<dataValues.count ; i++) {
            HaviLog(@"日期值是%@",[[dataValues objectAtIndex:i] objectForKey:@"At"]);
            if (i+1<dataValues.count) {
                NSDate *startDate = [dateFormatter dateFromString:[[dataValues objectAtIndex:i] objectForKey:@"At"]];
                NSDate *endDate = [dateFormatter dateFromString:[[dataValues objectAtIndex:i+1] objectForKey:@"At"]];
                double dateTime = [endDate timeIntervalSinceDate:startDate];
                NSDictionary *dicInfo = @{@"At" : startDate, @"Value":[NSNumber numberWithFloat:dateTime/60]};
                [_funcPoints addObject:dicInfo];
                i+=1;
            }
        }
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
//    [self setUpYcoorWithValues:self.yValues];
    [self drawHrizonerLine];
//    [self drawBackColor];
    if (self.isDrawDashLine) {
        // 绘制网格
        [self drawDashLine];
    }
    // 画曲线
    [self drawFuncLine];
    if (isUserDefaultTime) {
        
    }else{
        [self setBackImage];
    }}

- (void)setBackImage
{
    UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin, 5, xCoordinateWidth/2+2, yCoordinateHeight)];
    leftImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_night_%d",selectedThemeIndex]];
    [self addSubview:leftImage];
    UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin+xCoordinateWidth/2+2, 5, xCoordinateWidth/2, yCoordinateHeight)];
    rightImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_day_%d",selectedThemeIndex]];
    [self addSubview:rightImage];
}

- (void)reloadChartView
{
    [self drawFuncLine];
}

-(void)drawFuncLine
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[PNBar class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i= 0; i<_funcPoints.count; i++) {
        NSString *time = [NSString stringWithFormat:@"%@",[[_funcPoints objectAtIndex:i]objectForKey:@"At"]];
        int durationTime = [[NSString stringWithFormat:@"%@",[[_funcPoints objectAtIndex:i]objectForKey:@"Value"]] intValue];
        float pointX = 0;
        NSString *start = [time substringWithRange:NSMakeRange(11, 5)];
        float lengthHour = [[start substringWithRange:NSMakeRange(0, 2)] floatValue];
        float lenghtMitue = [[start substringWithRange:NSMakeRange(3, 2)] floatValue];
        if (isUserDefaultTime) {
            NSString *startTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultStartTime];
            int num1 = [[startTime substringToIndex:2]intValue];
            NSString *endTime = [[NSUserDefaults standardUserDefaults]objectForKey:UserDefaultEndTime];
            int num2 = [[endTime substringToIndex:2]intValue];
            int longTime = 0;//区间长度
            if (num1<num2) {
                longTime = num2 - num1;
            }else if (num1>num2){
                longTime = 24 -num1 +num2;
            }else{
                longTime = 24;
            }
            
//            int num = num1;
            int duration = 0;
            if (num1<num2) {
                duration = lengthHour - num1;
            }else{
                if (lengthHour>24) {
                    duration = 24 - num1 + lengthHour;
                }else{
                    duration = lengthHour - num1;
                }
            }
            float longTime1 = duration+lenghtMitue/60;
            pointX = xCoordinateWidth/longTime*longTime1 +self.leftLineMargin;
        }else{
            int num = 18;
            int duration = 0;
            if (lenghtMitue>0 && lengthHour>18 ) {
                duration = 0;
            }else if(lengthHour<18){
                duration = 24;
            }else if (lengthHour==18&&lenghtMitue>0){
                duration = 0;
            }
            float longTime = (lengthHour + duration -num)+lenghtMitue/60;
            pointX = xCoordinateWidth/24*longTime +self.leftLineMargin;
        }
        float width = xCoordinateWidth/24*(durationTime/60);//柱状图宽度
        if (width<1) {
            width = 1;
        }
        CGRect rect = CGRectMake(pointX, yCoordinateHeight/3*2, width, yCoordinateHeight/3+5);
        HaviLog(@"第%d个柱状图位置%lf,%lf,%lf,%lf",i,rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        PNBar * bar = [[PNBar alloc] initWithFrame:rect];
        //顺序决定了颜色
        bar.barColor = [UIColor redColor];
        [self addSubview:bar];
//        [self drawRectangle:rect context:self.context];
    }
}

- (void)drawRectangle:(CGRect)rect context:(CGContextRef)context
{
    CGContextSaveGState(self.context);
    CGContextAddRect(self.context, rect);
    CGContextClipToRect(self.context, rect);
    CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint endPoint = CGPointMake(rect.origin.x , rect.origin.y + rect.size.height);
    CGContextDrawLinearGradient(self.context, self.gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(self.context);
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
- (void)drawHrizonerLine
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPoint maxXPoint = [[self.xPoints lastObject] CGPointValue];
    // 设置上下文环境 属性
    CGFloat dashLineWidth = 1;
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(ctx, dashLineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetAlpha(ctx, 0.6);
    CGFloat alilengths[2] = {3, 5};
    CGContextSetLineDash(ctx, 0, alilengths, 2);
    float yValue = yCoordinateHeight /3*2;
    CGPoint yPoint = CGPointMake(self.leftLineMargin, yValue);
    //    CGPoint yPoint = [yP CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, yPoint.x, yPoint.y );
    CGPathAddLineToPoint(path, nil, maxXPoint.x - 5, yPoint.y );
    CGContextAddPath(ctx, path);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    CGPathRelease(path);
}

// 绘制网格
-(void)drawDashLine
{
    if (self.xPoints.count != 0 ) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        // 设置上下文环境 属性
        CGFloat dashLineWidth = 1;
        [selectedThemeIndex==0?DefaultColor:[UIColor whiteColor] setStroke];
        CGContextSetLineWidth(ctx, dashLineWidth);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetAlpha(ctx, 1);
        CGFloat alilengths[2] = {1, 0};
        CGContextSetLineDash(ctx, 0, alilengths, 2);
        
        // 画竖虚线
//        NSMutableArray *localXpoints = [self.xPoints mutableCopy];
//        if ([self.xValues[0] isEqualToString:@"0"]){
//            [localXpoints removeObjectAtIndex:0];
//        }
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

//刷新x轴
- (void)reloadGraphXValueArr:(NSArray *)arr
{
    [self setUpXcoorWithValues:arr];
}
#pragma mark - 添加坐标轴的值
-(void)setUpXcoorWithValues:(NSArray *)values
{
    for (UIView *view in self.subviews) {
        if (view.tag ==1000 || view.tag == 1009) {
            [view removeFromSuperview];
        }
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
