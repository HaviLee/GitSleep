//
//  NewHeartGrapheView.m
//  SleepRecoding
//
//  Created by Havi on 15/9/17.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import "NewHeartGrapheView.h"
#import "ReportViewDefine.h"
@interface NewHeartGrapheView ()

@property (strong, nonatomic) NSDictionary   *textStyleDict;
@property (strong, nonatomic) NSMutableArray *xPoints;
@property (strong, nonatomic) NSMutableArray *funcPoints;
@property (nonatomic, strong) UIImageView *leftImage;
@property (nonatomic, strong) UIImageView *rightImage;


@end

@implementation NewHeartGrapheView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = selectedThemeIndex==0?[UIColor colorWithRed:0.059f green:0.141f blue:0.231f alpha:1.00f]:[UIColor colorWithRed:0.475f green:0.686f blue:0.820f alpha:1.00f];
        [self setUpCoordinateSystem];
        [self setBackImage];
        [self addSubview:self.heartView];
    }
    return self;
}

- (void)setBackImage
{
    
    [self addSubview:self.leftImage];
    
    [self addSubview:self.rightImage];
}
#pragma mark setter meathod



/**
 *  创建x轴坐标
 */
-(void)setUpCoordinateSystem // 利用UIView作为坐标轴动态画出坐标系
{
    UIView *xCoordinate = [self getLineCoor];
    [self addSubview:xCoordinate];
    
}
/**
 *  创建x轴
 *
 *  @return UIView
 */
-(UIView *)getLineCoor
{
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
    lineView.alpha = 0.3;
    lineView.frame = CGRectMake(0, self.frame.size.height - bottomLineMargin, self.frame.size.width, 1);
    return lineView;
}



#pragma mark - 添加坐标轴的值

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

-(void)setXValues:(NSArray *)values
{
    for (UIView *view in self.subviews) {
        if (view.tag == 1001||view.tag==1002) {
            [view removeFromSuperview];
        }
    }
    if (values.count){
        NSUInteger count = values.count;
        for (int i = 0; i < count; i++) {
            NSString *xValue = values[i];
            
            CGFloat cX = 0;
            cX = ((xCoordinateWidth) / (count)) * i;
            
            CGFloat cY = self.frame.size.height - bottomLineMargin;
            // 收集坐标点
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(cX, cY+3, ((xCoordinateWidth)/(count)), 10)];
            label.backgroundColor = [UIColor clearColor];
            label.text = xValue;
            label.tag = 1001;
            label.textColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentCenter;
            [self addSubview:label];
            //
            UILabel *labelLine = [[UILabel alloc]initWithFrame:CGRectMake(cX+(xCoordinateWidth)/(count)/2, cY-2, 1, 2)];
            labelLine.backgroundColor = selectedThemeIndex==0?DefaultColor:[UIColor whiteColor];
            labelLine.tag = 1002;
            //
            [self.xPoints addObject:[NSValue valueWithCGPoint:CGPointMake(labelLine.frame.origin.x, cY)]];
            [self addSubview:labelLine];
        }
        //设置分割线
    }
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

#pragma mark setter

- (UIImageView *)leftImage
{
    if (_leftImage == nil) {
        _leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, xCoordinateWidth/2, yCoordinateHeight)];
        _leftImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_night1_%d",selectedThemeIndex]];
        _leftImage.tag = 2001;
    }
    return _leftImage;
}

- (UIImageView *)rightImage
{
    if (_rightImage == nil) {
//        _rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.leftLineMargin+xCoordinateWidth/2+2, 5, xCoordinateWidth/2, yCoordinateHeight)];
//        _rightImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"pic_day_%d",selectedThemeIndex]];
//        _rightImage.tag = 2001;
    }
    return _rightImage;
}
- (MPGraphView *)heartView
{
    if (_heartView==nil) {
        _heartView=[[MPGraphView alloc] initWithFrame:CGRectMake(0, 5, xCoordinateWidth, yCoordinateHeight)];
        _heartView.waitToUpdate=NO;
        _heartView.lineWidth = 0.5;
        _heartView.backgroundColor = [UIColor clearColor];
    }
    return _heartView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
