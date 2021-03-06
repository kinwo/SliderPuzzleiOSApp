//
//  SPTile.m
//  SliderPuzzle
//
//  Basic Tile model that stores image, coordinate and model behaviour
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZTile.h"
#import "UIImage+Color.h"

@interface SPZTile()

@property(nonatomic) CGFloat orgXInFrame;
@property(nonatomic) CGFloat orgYInFrame;

@end

@implementation SPZTile

/**
 Initialize with 0 xPos and 0 yPos
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.xPos = 0;
        self.yPos = 0;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.userInteractionEnabled = YES;
        [self addShadow];
    }
    return self;
}

- (BOOL)isMatched
{
    return self.xPos == self.xMatchPos && self.yPos == self.yMatchPos;
}

- (void)addShadow
{
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 2;
    self.layer.shadowRadius = 2;
}

- (void)saveState
{
    self.orgXInFrame = self.frame.origin.x;
    self.orgYInFrame = self.frame.origin.y;
}

- (void)restoreState
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = self.orgXInFrame;
    newFrame.origin.y = self.orgYInFrame;
    self.frame = newFrame;
}

- (BOOL)hasIntersect:(SPZTile*)otherTile
{
    return [self hasXPosIntersect:otherTile] || [self hasYPosIntersect:otherTile];
}

- (BOOL)hasXPosIntersect:(SPZTile*)otherTile
{
    return self.xPos == otherTile.xPos;
}

- (BOOL)hasYPosIntersect:(SPZTile*)otherTile
{
    return self.yPos == otherTile.yPos;
}

- (void)moveToXPos:(NSInteger)xPos yPos:(NSInteger)yPos
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = xPos * newFrame.size.width;
    newFrame.origin.y = yPos * newFrame.size.height;
    self.frame = newFrame;
    
    // update coordinate
    self.xPos = xPos;
    self.yPos = yPos;
}

- (void)translateWithX:(CGFloat)xDistance Y:(CGFloat)yDistance
{
    CGRect newFrame = self.frame;
    newFrame.origin.x = self.orgXInFrame + xDistance;
    newFrame.origin.y = self.orgYInFrame + yDistance;
    self.frame = newFrame;
}


@end
