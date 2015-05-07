//
//  ImageUtil.h
//  ET
//
//  Created by centling on 13-11-5.
//  Copyright (c) 2013年 Will Fu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage(UIImageScale)
-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;
//-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
@end

@interface UIImage (fixOrientation)
- (UIImage *)fixOrientation;
@end
