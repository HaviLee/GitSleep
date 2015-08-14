//
//  Header.h
//  SleepRecoding
//
//  Created by Havi on 15/4/4.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#ifndef SleepRecoding_Header_h
#define SleepRecoding_Header_h

#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/155.0 green:arc4random_uniform(255)/155.0 blue:arc4random_uniform(255)/155.0 alpha:0.7]

#define coorLineWidth 1
#define bottomLineMargin 20
#define coordinateOriginFrame CGRectMake(self.leftLineMargin, self.frame.size.height - bottomLineMargin, coorLineWidth, coorLineWidth)  // 原点坐标
#define xCoordinateWidth (self.frame.size.width - 22.5 - 5)
#define yCoordinateHeight (self.frame.size.height - bottomLineMargin - 5)

#endif
