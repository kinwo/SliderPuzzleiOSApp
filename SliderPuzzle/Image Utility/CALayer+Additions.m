//
//  CALayer+Additions.m
//  MeetPeople
//
//  Created by HENRY CHAN on 19/07/2014.
//  Copyright (c) 2014 New Team. All rights reserved.
//

#import "CALayer+Additions.h"

@implementation CALayer (Additions)

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}

@end
