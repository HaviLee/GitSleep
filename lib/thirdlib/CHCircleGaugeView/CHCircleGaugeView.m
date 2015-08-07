//
//  CHCircleGaugeView.m
//
//  Copyright (c) 2014 ChaiOne <http://www.chaione.com/>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

// 版权属于原作者
// http://code4app.com(cn) http://code4app.net(en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "CHCircleGaugeView.h"
#import "CHCircleGaugeViewDebugMacros.h"
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "CirlcleView.h"
#import "UILabel+FlickerNumber.h"

static CGFloat const CHKeyAnimationDuration = 0.5f;
static CGFloat const CHKeyDefaultValue = 0.0f;
static CGFloat const CHKeyDefaultFontSize = 32.0f;
static CGFloat const CHKeyDefaultTrackWidth = 0.5f;
static CGFloat const CHKeyDefaultGaugeWidth = 2.0f;
static NSString * const CHKeyDefaultNAText = @"n/a";
static NSString * const CHKeyDefaultNoAnswersText = @"%";
#define CHKeyDefaultTrackTintColor [UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f]
#define CHKeyDefaultGaugeTintColor [UIColor whiteColor]
#define CHKeyDefaultTextColor [UIColor whiteColor]
#define CHKeyClockViewColor [UIColor colorWithRed:0.259f green:0.392f blue:0.498f alpha:1.00f]

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式
#define  PROGREESS_WIDTH 200 //圆直径
#define PROGRESS_LINE_WIDTH 10 //弧线的宽度

@interface CHCircleGaugeView ()
{
    NSInteger value1;
    
}

@property (nonatomic, strong) CAShapeLayer *trackCircleLayer;
@property (nonatomic, strong) CAShapeLayer *gaugeCircleLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CALayer *gradientLayer;
@property (nonatomic, assign) CGRect viewRect;
@property (nonatomic, strong) CirlcleView *cView;

@property (nonatomic, strong) UILabel *valueTextLabel;
@property (nonatomic, strong) UILabel *valueTitleLabel;//havi
@property (nonatomic, strong) UILabel *resposeTextLabel;
@property (nonatomic, strong) NSMutableArray *arrCircle;
@property (nonatomic, strong) NSArray *arrColor;

@end

@implementation CHCircleGaugeView

#pragma mark - View Initialization


- (instancetype)init {
    
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
   
    if (self) {
        self.viewRect = frame;
        [self initSetup];
        [self setClockViewLine];

    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self initSetup];
        [self setClockViewLine];
    }
    
    return self;
}

- (void)initSetup {
    
    _state = CHCircleGaugeViewStateNA;
    _value = CHKeyDefaultValue;
    _trackTintColor = CHKeyDefaultTrackTintColor;
    _gaugeTintColor = CHKeyDefaultGaugeTintColor;
    _textColor = CHKeyDefaultTextColor;
    _font = [UIFont systemFontOfSize:CHKeyDefaultFontSize];
    _trackWidth = CHKeyDefaultTrackWidth;
    _gaugeWidth = CHKeyDefaultGaugeWidth;
    _notApplicableString = CHKeyDefaultNAText;
    _noDataString = CHKeyDefaultNoAnswersText;
    //哈维
    _arrCircle = [[NSMutableArray alloc]init];
    _arrColor = @[[self colorWithHex:0x1b5e62 alpha:1],[self colorWithHex:0x1c5e62 alpha:1],[self colorWithHex:0x1c5f63 alpha:1],[self colorWithHex:0x1c5f62 alpha:1],[self colorWithHex:0x1c5c62 alpha:1],[self colorWithHex:0x1c5d62 alpha:1],[self colorWithHex:0x1d5761 alpha:1],[self colorWithHex:0x1e5361 alpha:1],[self colorWithHex:0x1e4e60 alpha:1],[self colorWithHex:0x1a4658 alpha:1]];
    [self createGauge];
}

//设置line
- (void)setClockViewLine
{
    CGFloat radius = (CGRectGetHeight(self.bounds) / 2.0f) - PROGRESS_LINE_WIDTH;
    UIView *leftView1 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 - radius , self.viewRect.size.height/2, 4, 1)];
    leftView1.backgroundColor = CHKeyClockViewColor;
    [self addSubview:leftView1];
    UIView *leftView2 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 + radius-4 , self.viewRect.size.height/2, 4, 1)];
    leftView2.backgroundColor = CHKeyClockViewColor;
    [self addSubview:leftView2];
    UIView *upView1 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 , PROGRESS_LINE_WIDTH, 1, 4)];
    upView1.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView1];
    UIView *upView2 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 ,self.viewRect.size.height- PROGRESS_LINE_WIDTH-4, 1, 4)];
    upView2.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView2];
    //
    UIView *upView3 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 - radius* cos(M_PI/6)-2 , PROGRESS_LINE_WIDTH+ radius - radius*sin(M_PI/6)+2, 4, 1)];
    upView3.transform = CGAffineTransformMakeRotation(M_PI/6);
    upView3.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView3];
    UIView *upView31 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 - radius* cos(M_PI/3)-2 , PROGRESS_LINE_WIDTH+ radius - radius*sin(M_PI/3)+2, 4, 1)];
    upView31.transform = CGAffineTransformMakeRotation(M_PI/3);
    upView31.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView31];
    
    UIView *upView4 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 + radius* cos(M_PI/6) -2, PROGRESS_LINE_WIDTH+ radius - radius*sin(M_PI/6)+2, 4, 1)];
    upView4.transform = CGAffineTransformMakeRotation(-M_PI/6);
    upView4.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView4];
    UIView *upView41 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 + radius* cos(M_PI/3) -2, PROGRESS_LINE_WIDTH+ radius - radius*sin(M_PI/3)+2, 4, 1)];
    upView41.transform = CGAffineTransformMakeRotation(-M_PI/3);
    upView41.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView41];
    
    UIView *upView5 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 - radius* cos(M_PI/6) , PROGRESS_LINE_WIDTH+ radius + radius*sin(M_PI/6)-2, 4, 1)];
    upView5.transform = CGAffineTransformMakeRotation(-M_PI/6);
    upView5.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView5];
    UIView *upView51 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 - radius* cos(M_PI/3) , PROGRESS_LINE_WIDTH+ radius + radius*sin(M_PI/3)-2, 4, 1)];
    upView51.transform = CGAffineTransformMakeRotation(-M_PI/3);
    upView51.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView51];
    
    UIView *upView6 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 + radius* cos(M_PI/3)-4, PROGRESS_LINE_WIDTH+ radius + radius*sin(M_PI/3), 4, 1)];
    upView6.transform = CGAffineTransformMakeRotation(M_PI/3);
    upView6.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView6];
    UIView *upView61 = [[UIView alloc]initWithFrame:CGRectMake(self.viewRect.size.width/2 + radius* cos(M_PI/6)-4, PROGRESS_LINE_WIDTH+ radius + radius*sin(M_PI/6), 4, 1)];
    upView61.transform = CGAffineTransformMakeRotation(M_PI/6);
    upView61.backgroundColor = CHKeyClockViewColor;
    [self addSubview:upView61];
}

- (UIColor*) colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

- (void)createGauge {
    
    [self.layer addSublayer:self.trackCircleLayer];
    [self addSubview:self.valueTextLabel];
    [self addSubview:self.valueTitleLabel];
    [self addSubview:self.resposeTextLabel];
    [self addSubview:self.cView];
    [self setupConstraints];
}

- (CirlcleView *)cView
{
    if (_cView == nil) {
        _cView = [[CirlcleView alloc]initWithFrame:CGRectMake((self.viewRect.size.width-self.viewRect.size.height)/2, 0, self.viewRect.size.height, self.viewRect.size.height)];
        _cView.layer.cornerRadius = self.viewRect.size.height/2;
        _cView.layer.masksToBounds = YES;
    }
    return _cView;
}
#pragma mark 改变主界面值
- (void)changeSleepQualityValue:(CGFloat)value
{
    [self.valueTextLabel dd_setNumber:[NSNumber numberWithFloat:value] duration:0.5];
}

- (void)changeSleepTimeValue:(CGFloat)value
{
    [self.cView setPercent:0 animated:YES];
    [self.cView setPercent:value animated:YES];
}

- (void)changeSleepLevelValue:(NSString *)valueString
{
    NSDictionary *stringAttributes = @{
                                       NSForegroundColorAttributeName : [UIColor colorWithRed:0.000f green:0.859f blue:0.573f alpha:1.00f],
                                       NSFontAttributeName : [UIFont systemFontOfSize:17]
                                       };
    self.resposeTextLabel.attributedText = [[NSAttributedString alloc] initWithString:valueString attributes:stringAttributes];
}

- (UIBezierPath *)outsideCirclePathIndex:(NSInteger)index {
    
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (CGRectGetHeight(self.bounds) / 2.0f)-PROGRESS_LINE_WIDTH +1.5+ (index*2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                        radius:radius
                                                    startAngle:(3.0f * M_PI_2)
                                                      endAngle:(3.0f * M_PI_2) + (2.0f * M_PI)
                                                     clockwise:YES];
    
    return path;
}

- (void)setupConstraints {
    
    NSDictionary *viewDictionary = @{@"valueText" : self.valueTextLabel};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[valueText]|" options:0 metrics:nil views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[valueText]|" options:0 metrics:nil views:viewDictionary]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleLabel]-0-|" options:0 metrics:nil views:@{@"titleLabel" : self.valueTitleLabel}]];
    
    // align layer from the top and bottom
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleLabel]-80-|" options:0 metrics:nil views:@{@"titleLabel" : self.valueTitleLabel}]];
    
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[responseLabel]-0-|" options:0 metrics:nil views:@{@"responseLabel" : self.resposeTextLabel}]];
    // align layer from the top and bottom
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[responseLabel]-0-|" options:0 metrics:nil views:@{@"responseLabel" : self.resposeTextLabel}]];
}

#pragma mark - Property Setters

- (void)setState:(CHCircleGaugeViewState)state {
    
    if (_state != state) {
        
        _state = state;
        
        switch (state) {
            case CHCircleGaugeViewStateNA: {
                [self updateGaugeWithValue:0 animated:NO];
                
                break;
            }
            case CHCircleGaugeViewStatePercentSign: {
                [self updateGaugeWithValue:0 animated:NO];
                
                break;
            }
            case CHCircleGaugeViewStateScore: {
                [self updateGaugeWithValue:self.value animated:NO];
                
                break;
            }
                
            default: {
                ALog(@"Missing gauge state.");
                
                break;
            }
        }
    }
}

- (void)setValue:(CGFloat)value {
    
    [self setValue:value animated:NO];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    
    self.state = CHCircleGaugeViewStateScore;
    
    if (value != _value) {
        
        [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
        value = MIN(1.0f, MAX(0.0f, value));
        [self updateGaugeWithValue:value animated:animated];
        _value = value;
        [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
    }
}

- (void)setUnitsString:(NSString *)unitsString {
    
    if ([_unitsString isEqualToString:unitsString] == NO) {
        _unitsString = [unitsString copy];
        self.valueTextLabel.attributedText = [self formattedStringForValue:self.value];
    }
}

//更新睡眠质量

- (void)updateSleepQuality:(CGFloat)value animated:(BOOL)animated {
    [UIView animateWithDuration:0.4 animations:^{
        self.valueTextLabel.attributedText = [self formattedStringForValue:value/100];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)updateGaugeWithValue:(CGFloat)value animated:(BOOL)animated {
    
    self.valueTextLabel.attributedText = [self formattedStringForValue:value];
    
    BOOL previousDisableActionsValue = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    self.gaugeCircleLayer.strokeEnd = value;
    if (animated) {
 
        self.gaugeCircleLayer.strokeEnd = value;
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = CHKeyAnimationDuration;
        pathAnimation.fromValue = [NSNumber numberWithFloat:self.value];
        pathAnimation.toValue = [NSNumber numberWithFloat:value];
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.gaugeCircleLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    }
    
    [CATransaction setDisableActions:previousDisableActionsValue];
    //
    [self.cView setPercent:value animated:YES];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    
    if (_trackTintColor != trackTintColor) {
        
        _trackTintColor = trackTintColor;
        self.trackCircleLayer.strokeColor = trackTintColor.CGColor;
    }
}

- (void)setGaugeTintColor:(UIColor *)gaugeTintColor {
    
    if (_gaugeTintColor != gaugeTintColor) {
        
        _gaugeTintColor = gaugeTintColor;
        self.gaugeCircleLayer.strokeColor = gaugeTintColor.CGColor;
    }
}

- (void)setTrackWidth:(CGFloat)trackWidth {
    
    if (_trackWidth != trackWidth) {
        
        _trackWidth = trackWidth;
        self.trackCircleLayer.lineWidth = trackWidth;
        [self.layer layoutSublayers];
    }
}

- (void)setGaugeWidth:(CGFloat)gaugeWidth {
    
    if (_gaugeWidth != gaugeWidth) {
        
        _gaugeWidth = gaugeWidth;
        self.gaugeCircleLayer.lineWidth = gaugeWidth;
        [self.layer layoutSublayers];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    
    if (_textColor != textColor) {
        
        _textColor = textColor;
        self.valueTextLabel.textColor = textColor;
    }
}
//这个是睡眠质量的label
- (void)setResponseColor:(UIColor *)responseColor
{
    if (_responseColor != responseColor) {
        
        _responseColor = responseColor;
        self.resposeTextLabel.textColor = responseColor;
    }
}

- (void)setRotationValue:(CGFloat)rotationValue
{
    if (_rotationValue != rotationValue) {
        _rotationValue = rotationValue;
        CGFloat rotation = (rotationValue) * M_PI / 180.0f;
        self.cView.transform = CGAffineTransformMakeRotation(rotation);
    }
}

- (void)setFont:(UIFont *)font {
    
    if (_font != font) {
        
        _font = font;
        self.valueTextLabel.font = font;
    }
}

- (void)setGaugeStyle:(CHCircleGaugeStyle)gaugeStyle {
    
    if (_gaugeStyle != gaugeStyle) {
        _gaugeStyle = gaugeStyle;
        [self.layer layoutSublayers];
    }
}

#pragma mark - Circle Shapes

- (CAShapeLayer *)trackCircleLayer {
    
    if (_trackCircleLayer == nil) {
        
        _trackCircleLayer = [CAShapeLayer layer];
        _trackCircleLayer.lineWidth = self.trackWidth;
        _trackCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _trackCircleLayer.strokeColor = self.trackTintColor.CGColor;
        _trackCircleLayer.path = [self insideCirclePath].CGPath;
    }

    return _trackCircleLayer;
}

- (CAShapeLayer *)gaugeCircleLayer {
    
    if (_gaugeCircleLayer == nil) {
        
        _gaugeCircleLayer = [CAShapeLayer layer];
        _gaugeCircleLayer.lineWidth = PROGRESS_LINE_WIDTH;
        _gaugeCircleLayer.fillColor = [UIColor clearColor].CGColor;
        _gaugeCircleLayer.strokeColor = self.gaugeTintColor.CGColor;
        _gaugeCircleLayer.strokeStart = 0.0f;
        _gaugeCircleLayer.strokeEnd = self.value;
        _gaugeCircleLayer.path = [self circlPathForCurrentGaugeStyle].CGPath;
    }
    
    return _gaugeCircleLayer;
}

- (UIBezierPath *)circlPathForCurrentGaugeStyle {
    
    switch (self.gaugeStyle) {
        case CHCircleGaugeStyleInside: {
            return [self insideCirclePath];
        }
        case CHCircleGaugeStyleOutside: {
            return [self outsideCirclePath];
        }
        default: {
            return nil;
        }
    }
}

- (UIBezierPath *)insideCirclePath {
    
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (CGRectGetHeight(self.bounds) / 2.0f) - PROGRESS_LINE_WIDTH;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                        radius:radius
                                                    startAngle:(3.0f * M_PI_2)
                                                      endAngle:(3.0f * M_PI_2) + (2.0f * M_PI)
                                                     clockwise:YES];
    
    return path;
}

- (UIBezierPath *)outsideCirclePath {
    
    CGPoint arcCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = (CGRectGetHeight(self.bounds) / 2.0f)-PROGRESS_LINE_WIDTH/2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                        radius:radius
                                                    startAngle:(3.0f * M_PI_2)
                                                      endAngle:(3.0f * M_PI_2) + (2.0f * M_PI)
                                                     clockwise:YES];
    
    return path;
}

#pragma mark - Text Label
//havi
- (UILabel *)valueTitleLabel
{
    if (_valueTitleLabel == nil) {
        _valueTitleLabel = [[UILabel alloc] init];
        [_valueTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _valueTitleLabel.textAlignment = NSTextAlignmentCenter;
        _valueTitleLabel.attributedText = [self formattedStringForGaugeState:CHCircleGaugeViewStateTitle];
    }
    return _valueTitleLabel;
}

- (UILabel *)resposeTextLabel
{
    if (_resposeTextLabel == nil) {
        _resposeTextLabel = [[UILabel alloc] init];
        [_resposeTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _resposeTextLabel.textAlignment = NSTextAlignmentCenter;
        _resposeTextLabel.attributedText = [self formattedStringForGaugeState:CHCircleGaugeViewStateStatus];
    }
    return _resposeTextLabel;
}

- (UILabel *)valueTextLabel {
    
    if (_valueTextLabel == nil) {
        
        _valueTextLabel = [[UILabel alloc] init];
        [_valueTextLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        _valueTextLabel.textAlignment = NSTextAlignmentCenter;
        _valueTextLabel.textColor = self.textColor;
        _valueTextLabel.attributedText = [self formattedStringForValue:self.value];
    }
    
    return _valueTextLabel;
}

- (NSAttributedString *)formattedStringForGaugeState:(CHCircleGaugeViewState)value {
    
    NSAttributedString *valueString;
    NSDictionary *stringAttributes = @{
                                       NSForegroundColorAttributeName : self.textColor,
                                       NSFontAttributeName : self.font
                                       };
    
    switch (value) {
        case CHCircleGaugeViewStateNA: {
            valueString = [[NSAttributedString alloc] initWithString:self.notApplicableString attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStatePercentSign: {
            valueString = [[NSAttributedString alloc] initWithString:self.noDataString attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStateScore: {
            NSString *suffix = self.unitsString ? self.unitsString : @"";
            valueString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f %@", value * 100.0f, suffix]
                                                          attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStateTitle: {
            stringAttributes = @{
                                 NSForegroundColorAttributeName : self.textColor,
                                 NSFontAttributeName : [UIFont systemFontOfSize:17]
                                 };
            valueString = [[NSAttributedString alloc] initWithString:@"睡眠指数" attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStateStatus: {
            stringAttributes = @{
                                 NSForegroundColorAttributeName : self.textColor,
                                 NSFontAttributeName : [UIFont systemFontOfSize:17]
                                 };
            valueString = [[NSAttributedString alloc] initWithString:@"非常好" attributes:stringAttributes];
            
            break;
        }
            
        default: {
            ALog(@"Missing gauge state.");
            
            break;
        }
    }
    
    return valueString;
}


- (NSAttributedString *)formattedStringForValue:(CGFloat)value {
    
    NSAttributedString *valueString;
    NSDictionary *stringAttributes = @{
                                       NSForegroundColorAttributeName : self.textColor,
                                       NSFontAttributeName : self.font
                                       };
    
    switch (self.state) {
        case CHCircleGaugeViewStateNA: {
            valueString = [[NSAttributedString alloc] initWithString:self.notApplicableString attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStatePercentSign: {
            valueString = [[NSAttributedString alloc] initWithString:self.noDataString attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStateScore: {
            NSString *suffix = self.unitsString ? self.unitsString : @"";
            valueString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.0f %@", value * 100.0f, suffix]
                                                          attributes:stringAttributes];
            
            break;
        }
        case CHCircleGaugeViewStateTitle: {
            valueString = [[NSAttributedString alloc] initWithString:@"睡眠指数" attributes:stringAttributes];
            
            break;
        }
            
        default: {
            ALog(@"Missing gauge state.");
            
            break;
        }
    }
    
    return valueString;
}

#pragma mark - KVO

// Handling KVO notifications for the value property, since
//   we're proxying with the setValue:animated: method.
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    
    if ([key isEqualToString:NSStringFromSelector(@selector(value))]) {
        
        return NO;
    } else {
        
        return [super automaticallyNotifiesObserversForKey:key];
    }
}

#pragma mark - CALayerDelegate

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    
    [super layoutSublayersOfLayer:layer];
    
    if (layer == self.layer) {
        
        self.trackCircleLayer.path = [self insideCirclePath].CGPath;
        self.gaugeCircleLayer.path = [self circlPathForCurrentGaugeStyle].CGPath;
    }
}

@end
