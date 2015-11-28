//
//  FriendMessageTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASwipeCell.h"
#import "JAActionButton.h"

@interface FriendMessageTableViewCell : JASwipeCell

@property (nonatomic ,strong) NSString *cellUserName;
@property (nonatomic ,strong) NSString *cellUserPhone;
@property (nonatomic ,strong) NSString *cellUserIcon;
@property (nonatomic ,strong) NSString *cellUserDescription;

@end
