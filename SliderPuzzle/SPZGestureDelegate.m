//
//  SPGestureDelegate.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 27/07/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZGestureDelegate.h"

@implementation SPZGestureDelegate


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

@end
