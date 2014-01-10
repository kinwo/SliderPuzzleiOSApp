//
//  NSMutableArray+ScramblePosition.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 10/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "NSMutableArray+ScramblePosition.h"

@implementation NSMutableArray (ScramblePosition)

- (void)scramble
{
    NSUInteger arraySize = [self count];
    
    for (NSUInteger i = 0; i < arraySize; ++i) {
        NSInteger nElements = arraySize - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
