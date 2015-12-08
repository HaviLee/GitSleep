//
//  ContainerTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/12/8.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerTableViewCell : UITableViewCell

@property (nonatomic ,strong) NSString *cellUserDescription;
@property (nonatomic ,strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *cellIconImageView;

@end
