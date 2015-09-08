//
//  TitleViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/9/8.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleViewCell : UIView
@property (nonatomic,strong) NSString *iconTitleName;
@property (nonatomic,strong) NSString *cellTitleName;
@property (nonatomic,strong) NSString *cellData;

- (instancetype)initWithFrame:(CGRect)frame;
@end
