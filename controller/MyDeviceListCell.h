//
//  MyDeviceListCell.h
//  SleepRecoding
//
//  Created by Havi on 15/12/2.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import "JASwipeCell.h"

@interface MyDeviceListCell : JASwipeCell

@property (nonatomic ,strong) NSString *cellUserDescription;
@property (nonatomic ,strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *cellIconImageView;

@end
