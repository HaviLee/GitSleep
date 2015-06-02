//
//  HeartChartView.m
//  SleepRecoding
//
//  Created by Havi_li on 15/4/24.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "HeartChartView.h"
#import "ChartViewDefine.h"

@interface HeartChartView ()
@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *yPoints;
@property (strong, nonatomic) NSDictionary   *textStyleDict;
@property (assign, nonatomic) CGFloat maxYValue;

@property (strong, nonatomic) NSMutableArray *funcPoints;


// 左边间距要根据具体的坐标值去计算
@property (assign, nonatomic) CGFloat leftLineMargin;
@property (assign, nonatomic) BOOL islineDrawDone;
@end
@implementation HeartChartView
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

+(instancetype)charView
{
    HeartChartView *chartView = [[self alloc] init];
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
    CGRect myRect = CGRectMake(0, self.frame.size.height - bottomLineMargin - 10 , self.leftLineMargin, bottomLineMargin);
    [@"0" drawInRect:myRect withAttributes:self.textStyleDict];
    // 根据值画x/y轴的值
    [self setUpXcoorWithValues:self.xValues];
    [self setUpYcoorWithValues:self.yValues];
    [self drawHrizonerLine];
    [self drawBackColor];
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

-(void)drawFuncLine
{
    if (self.xValues.count != 0 && self.yValues.count != 0) {
        if (!_funcPoints) {
            _funcPoints = [[NSMutableArray alloc]init];
        }
        //havi
        NSInteger pointCount = self.dataValues.count;
        [[UIColor clearColor] set];
        for (int i = 0; i < pointCount; i++) {
            //            CGFloat funcXPoint = [self.xPoints[i] CGPointValue].x;
            CGFloat funcXPoint;
            if (self.startTime && self.endTime) {
                int duration = ([self.endTime intValue]<12 ?([self.endTime intValue] + 24):[self.endTime intValue]) -[self.startTime intValue];
                float xWidth = xCoordinateWidth/24*duration;
                funcXPoint = ((xWidth)/pointCount)*(i+1)+self.leftLineMargin + xCoordinateWidth/24*([self.startTime intValue]-12);
            }else{
                funcXPoint = ((xCoordinateWidth)/pointCount)*(i+1)+self.leftLineMargin;
            }
            // 微调由于线条太粗而引起的起始点和结束点的丑陋
            if (i == 0) {
                funcXPoint += 3;
            }
            if (i == pointCount - 1) {
                funcXPoint -= 3;
            }
            CGFloat yValue = [self.dataValues[i] floatValue];
            CGFloat funcYPoint = yCoordinateHeight - (yCoordinateHeight/self.maxYValue* yValue)+5;
            [_funcPoints addObject:[NSValue valueWithCGPoint:CGPointMake(funcXPoint, funcYPoint)]];
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor whiteColor] setStroke];
        //content
        CGContextSetLineWidth(context, 1);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        int index = 0;
        for (index = 1; index<_funcPoints.count; index++) {
            CGPoint linePoint = [[_funcPoints objectAtIndex:index] CGPointValue];
            if (linePoint.y< (yCoordinateHeight - (yCoordinateHeight/self.maxYValue* [self.alarmMaxValue floatValue])+5)) {
                if (linePoint.y <yCoordinateHeight) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(0, 0, 3, 3);
                    button.layer.cornerRadius = 1.5;
                    button.layer.masksToBounds = YES;
                    [button setBackgroundColor:self.chartColor];
                    button.center = linePoint;
                    [self addSubview:button];
                    //
                    UIButton *buttonImage = [UIButton buttonWithType:UIButtonTypeCustom];
                    buttonImage.frame = CGRectMake(0, 0, 10, 10);
                    [buttonImage setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"icon_fatal_exception_0"]] forState:UIControlStateNormal];
                    CGPoint new = CGPointMake(linePoint.x, linePoint.y-5);
                    [buttonImage addTarget:self action:@selector(showAlarm:) forControlEvents:UIControlEventTouchUpInside];
                    buttonImage.center = new;
                    [self addSubview:buttonImage];
                }
            }
            if (linePoint.y>(yCoordinateHeight - (yCoordinateHeight/self.maxYValue* [self.alarmMinValue floatValue])+5)) {
                if (linePoint.y <yCoordinateHeight) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(0, 0, 3, 3);
                    button.layer.cornerRadius = 1.5;
                    button.layer.masksToBounds = YES;
                    [button setBackgroundColor:self.chartColor];
                    button.center = linePoint;
                    [self addSubview:button];
                    UIButton *buttonImage = [UIButton buttonWithType:UIButtonTypeCustom];
                    buttonImage.frame = CGRectMake(0, 0, 10, 10);
                    [buttonImage setBackgroundImage:[UIImage imageNamed:@"icon_abnormal_0"] forState:UIControlStateNormal];
                    CGPoint new = CGPointMake(linePoint.x, linePoint.y+5);
                    [buttonImage addTarget:self action:@selector(showAlarm:) forControlEvents:UIControlEventTouchUpInside];
                    buttonImage.center = new;
                    [self addSubview:buttonImage];
                }
            }
            if ((linePoint.y != yCoordinateHeight+5) && ([[_funcPoints objectAtIndex:index-1]CGPointValue].y != yCoordinateHeight+5)) {
                CGContextAddLineToPoint(context, linePoint.x, linePoint.y);
            }else if (linePoint.y>0&&linePoint.y!=yCoordinateHeight +5){
                CGPoint linePoint = [[_funcPoints objectAtIndex:index] CGPointValue];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0, 0, 3, 3);
                button.layer.cornerRadius = 1.5;
                button.layer.masksToBounds = YES;
                [button setBackgroundColor:self.chartColor];
                button.center = linePoint;
                [self addSubview:button];

            }
            CGContextMoveToPoint(context,linePoint.x, linePoint.y);
            
            //
        }
//        CGContextClosePath(context);
        
        [UIView animateWithDuration:0.5 animations:^{
            CGContextStrokePath(context);
        }];
    }
}

- (void)showAlarm:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter]postNotificationName:PostHeartEmergencyNoti object:nil];
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
    
    float yValue = yCoordinateHeight - (yCoordinateHeight / self.maxYValue)*self.horizonLine + 5;
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
            //            [xValue drawAtPoint:CGPointMake(cX - size.width * 0.7 - ((xCoordinateWidth-15)/(count-1))/2, cY + 5) withAttributes:self.textStyleDict];
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
    transition.duration = 0.5;
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
