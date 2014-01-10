//
//  UIImage+ResizeImage.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 10/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "UIImage+ResizeImage.h"

@implementation UIImage (ResizeImage)

- (UIImage*)resizeImageToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


@end
