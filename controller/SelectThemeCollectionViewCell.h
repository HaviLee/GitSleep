//
//  SelectThemeCollectionViewCell.h
//  IMFiveApp
//
//  Created by chen on 14-8-30.
//  Copyright (c) 2014年 chen. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import <UIKit/UIKit.h>

@interface SelectThemeCollectionViewCell : UICollectionViewCell

- (void)setDataForView:(NSArray *)ar selected:(BOOL)bSelected;

- (void)setDataForView:(NSArray *)ar index:(NSIndexPath *)indexPath;

@end
