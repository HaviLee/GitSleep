//
//  SelectThemeCollectionViewCell.m
//  IMFiveApp
//
//  Created by chen on 14-8-30.
//  Copyright (c) 2014年 chen. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "SelectThemeCollectionViewCell.h"
#import "QHConfiguredObj.h"

@implementation SelectThemeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.contentView.frame = CGRectMake(5, 0, self.frame.size.width, self.frame.size.height);
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.cornerRadius = 6;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    
    float w = self.frame.size.height/5;
    float wIV = w*4.3;
    
    UIImageView *titleIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, wIV)];
    [titleIV setBackgroundColor:[UIColor clearColor]];
    titleIV.tag = 11;
    titleIV.layer.cornerRadius = 6;
    titleIV.layer.masksToBounds = YES;
    [self.contentView addSubview:titleIV];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, titleIV.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height - titleIV.frame.size.height)];
    titleL.tag = 12;
    [titleL setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor]];
    [self.contentView addSubview:titleL];
    
    UIImage *i = [UIImage imageNamed:@"common_green_checkbox.png"];
    UIImageView *selectIV = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width  - titleL.frame.size.height/1.5, 2, titleL.frame.size.height/1.5, titleL.frame.size.height/1.5)];
    [selectIV setImage:i];

    selectIV.tag = 13;
    [self.contentView addSubview:selectIV];
}

- (void)setDataForView:(NSArray *)ar selected:(BOOL)bSelected
{
    UIImageView *titleIV = (UIImageView *)[self.contentView viewWithTag:11];
    [titleIV setImage:[UIImage imageNamed:[ar objectAtIndex:2]]];
    
    UILabel *titleL = (UILabel *)[self.contentView viewWithTag:12];
    [titleL setTextAlignment:NSTextAlignmentCenter];
    titleL.text = [ar objectAtIndex:0];
    [titleL setTextColor:selectedThemeIndex==0?DefaultColor:[UIColor whiteColor]];
    
    UIImageView *selectIV = (UIImageView *)[self.contentView viewWithTag:13];
    [selectIV setHidden:!bSelected];
}
//暂时没有使用
- (void)setDataForView:(NSArray *)ar index:(NSIndexPath *)indexPath
{
    if ([QHConfiguredObj defaultConfigure].nThemeIndex == indexPath.row)
        [self setDataForView:ar selected:YES];
    else
        [self setDataForView:ar selected:NO];
}

@end
