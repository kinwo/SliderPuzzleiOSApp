//
//  UIImage+SliceImages.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 10/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "UIImage+SliceImages.h"

@implementation UIImage (SliceImages)

-(NSMutableArray *)sliceImagesWithNumRows:(NSInteger)rows numColumns:(NSInteger)columns
{
    NSMutableArray *slicedImages = [NSMutableArray array];
    CGSize imageSize = self.size;
    
    CGFloat originX = 0.0, originY = 0.0;
    CGFloat sliceWidth = imageSize.width/rows;
    CGFloat sliceHeight = imageSize.height/columns;
    
    // create
    for (int y=0; y<columns; y++) {
        originX = 0.0;
        
        for (int x = 0; x<rows; x++) {
            UIImage *sliceImage = [self createSliceImage:self originX:originX originY:originY width:sliceWidth height:sliceHeight];
            [slicedImages addObject:sliceImage];
            originX += sliceWidth;
        }
        
        originY += sliceHeight;
    }
    
    return slicedImages;
}

- (UIImage*)createSliceImage:(UIImage*)srcImage originX:(CGFloat)xPos originY:(CGFloat)yPos width:(CGFloat)sliceWidth height:(CGFloat)sliceHeight
{
    CGRect sliceRect = CGRectMake(xPos, yPos, sliceWidth, sliceHeight);
    CGImageRef srcImageRef = [srcImage CGImage];
    CGImageRef imageRef = CGImageCreateWithImageInRect(srcImageRef, sliceRect);

    UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return newImage;
}

@end
