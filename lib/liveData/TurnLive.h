//
//  TurnLive.h
//  SleepRecoding
//
//  Created by Havi on 15/5/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TurnPointContainer : NSObject

@property (nonatomic , readonly) NSInteger numberOfRefreshElements;
@property (nonatomic , readonly) NSInteger numberOfTranslationElements;
@property (nonatomic , readonly) CGPoint *refreshPointContainer;
@property (nonatomic , readonly) CGPoint *translationPointContainer;

+ (TurnPointContainer *)sharedContainer;

//刷新变换
- (void)addPointAsRefreshChangeform:(CGPoint)point;
//平移变换
- (void)addPointAsTranslationChangeform:(CGPoint)point;

@end

@interface TurnLive : UIView

- (void)fireDrawingWithPoints:(CGPoint *)points pointsCount:(NSInteger)count;

@end
