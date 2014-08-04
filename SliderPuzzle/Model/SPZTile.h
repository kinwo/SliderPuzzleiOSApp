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

@interface SPZTile : UIImageView

@property(nonatomic) NSInteger xPos;
@property(nonatomic) NSInteger yPos;

@property(nonatomic) NSInteger xMatchPos;
@property(nonatomic) NSInteger yMatchPos;

- (BOOL)isMatched;

- (BOOL)hasIntersect:(SPZTile*)otherTile;

- (void)moveToXPos:(NSInteger)xPos yPos:(NSInteger)yPos;

- (BOOL)hasXPosIntersect:(SPZTile*)otherTile;

- (BOOL)hasYPosIntersect:(SPZTile*)otherTile;

- (void)translateWithX:(CGFloat)xDistance Y:(CGFloat)yDistance;

- (void)saveState;

- (void)restoreState;


@end
