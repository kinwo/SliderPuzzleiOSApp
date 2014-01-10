//
//  UIImage+SliceImages.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 10/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SliceImages)

-(NSMutableArray *)sliceImagesWithNumRows:(NSInteger)rows numColumns:(NSInteger)columns;

@end
