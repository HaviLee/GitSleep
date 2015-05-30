//
//  BreathLive.h
//  SleepRecoding
//
//  Created by Havi on 15/5/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BreathPointContainer : NSObject

@property (nonatomic , readonly) NSInteger numberOfRefreshElements;
@property (nonatomic , readonly) NSInteger numberOfTranslationElements;
@property (nonatomic , readonly) CGPoint *refreshPointContainer;
@property (nonatomic , readonly) CGPoint *translationPointContainer;

+ (BreathPointContainer *)sharedContainer;

//刷新变换
- (void)addPointAsRefreshChangeform:(CGPoint)point;
//平移变换
- (void)addPointAsTranslationChangeform:(CGPoint)point;

@end


@interface BreathLive : UIView

- (void)fireDrawingWithPoints:(CGPoint *)points pointsCount:(NSInteger)count;

@end
