//
//  SPTile.h
//  SliderPuzzle
//
//  A model class representing a UIView tile having xPos and yPos in a 2D matrix.
//  It provides basic operation against tile including: intersect checking, translate, save and restore state
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKParallaxView.h"

@interface SPTile : MKParallaxView

@property(nonatomic) NSInteger xPos;
@property(nonatomic) NSInteger yPos;

- (BOOL)hasIntersect:(SPTile*)otherTile;

- (void)moveToXPos:(NSInteger)xPos yPos:(NSInteger)yPos;

- (BOOL)hasXPosIntersect:(SPTile*)otherTile;

- (BOOL)hasYPosIntersect:(SPTile*)otherTile;

- (void)translateWithX:(CGFloat)xDistance Y:(CGFloat)yDistance;

- (void)saveState;

- (void)restoreState;


@end
