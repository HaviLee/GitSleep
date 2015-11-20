//
//  SearchUserTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/12.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchUserTableViewCell;

@protocol CustomCellProtocol

- (void)customCell:(SearchUserTableViewCell *)cell didTapButton:(UIButton *)button;

@end

@interface SearchUserTableViewCell : UITableViewCell

@property (nonatomic, strong) id <CustomCellProtocol> delegate;
@property (nonatomic ,strong) NSString *cellUserName;
@property (nonatomic ,strong) NSString *cellUserPhone;
@property (nonatomic ,strong) NSString *cellUserIcon;
@property (nonatomic, strong) UIButton *messageSendButton;



@end
