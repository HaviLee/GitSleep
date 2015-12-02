//
//  MessageShowTableViewCell.h
//  SleepRecoding
//
//  Created by Havi on 15/11/11.
//  Copyright © 2015年 Havi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageShowTableViewCell;

@protocol CustomMessageProtocol

- (void)customMessageAcceptCell:(MessageShowTableViewCell *)cell didTapButton:(UIButton *)button;
- (void)customMessageRefuseCell:(MessageShowTableViewCell *)cell didTapButton:(UIButton *)button;

@end

@interface MessageShowTableViewCell : UITableViewCell

@property (nonatomic, strong) id <CustomMessageProtocol> delegate;

@property (nonatomic, strong) UIButton *messageAccepteButton;
@property (nonatomic, strong) UIButton *messageRefuseButton;
@property (nonatomic, strong) UIImageView *statusImageView;
//
@property (nonatomic ,strong) NSString *cellUserName;
@property (nonatomic ,strong) NSString *cellUserPhone;
@property (nonatomic ,strong) NSString *cellUserIcon;
@property (nonatomic ,strong) NSString *cellRequreTime;
@property (nonatomic ,strong) NSString *messageShowString;
@property (nonatomic, strong) UIColor *cellDataColor;

@end
