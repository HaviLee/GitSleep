//
//  DataShowTableViewCell.h
//  SleepRecoding
//
//  Created by Havi_li on 15/2/27.
//  Copyright (c) 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataShowTableViewCell : UITableViewCell
@property (nonatomic,strong) NSString *cellName;
@property (nonatomic,assign) SEL buttonTaped;
@property (nonatomic,strong) id target;
@property (nonatomic,strong) NSString *cellImageName;
@end
