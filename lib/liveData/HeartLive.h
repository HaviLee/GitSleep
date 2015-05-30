//
//  HeartLive.h
//  HeartRateCurve
//
//  Created by IOS－001 on 14-4-23.
//  Copyright (c) 2014年 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeartPointContainer : NSObject

@property (nonatomic , readonly) NSInteger numberOfRefreshElements;
@property (nonatomic , readonly) NSInteger numberOfTranslationElements;
@property (nonatomic , readonly) CGPoint *refreshPointContainer;
@property (nonatomic , readonly) CGPoint *translationPointContainer;

+ (HeartPointContainer *)sharedContainer;

//刷新变换
- (void)addPointAsRefreshChangeform:(CGPoint)point;
//平移变换
- (void)addPointAsTranslationChangeform:(CGPoint)point;

@end



@interface HeartLive : UIView

- (void)fireDrawingWithPoints:(CGPoint *)points pointsCount:(NSInteger)count;

@end

