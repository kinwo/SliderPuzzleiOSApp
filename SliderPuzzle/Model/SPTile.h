//
//  SPTile.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTile : UIImageView

@property(nonatomic) NSInteger xPos;
@property(nonatomic) NSInteger yPos;

- (BOOL)hasIntersect:(SPTile*)otherTile;

- (void)moveToXPos:(NSInteger)xPos yPos:(NSInteger)yPos;

- (BOOL)hasXPosIntersect:(SPTile*)otherTile;

- (BOOL)hasYPosIntersect:(SPTile*)otherTile;


@end
