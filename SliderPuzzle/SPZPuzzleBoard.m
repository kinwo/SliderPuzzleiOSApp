//
//  SPPuzzleBoard.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 10/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZPuzzleBoard.h"

@implementation SPZPuzzleBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeCenter;
        
        // shadow
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowOpacity = 3;
        self.layer.shadowRadius = 5;
    }
    return self;
}

@end
