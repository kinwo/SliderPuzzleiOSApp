//
//  SPTilesMatrix.h
//  SliderPuzzle
//
//  A model class responsible for storing and retrieving of Tiles as well as operation against the matrix
//  including: slide, translate, save state, restore state etc.
//
//  Created by HENRY CHAN on 11/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPZTile.h"

@interface SPZTilesMatrix : NSObject

@property(nonatomic, strong) SPZTile *spacer;

- (NSArray*)flattenTilesArray;

- (id)initWithNumColumns:(NSInteger)columns withNumRows:(NSInteger)rows;

- (void)setSPTileWithXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPZTile*)tile;

- (SPZTile*)getSPTileAtXPos:(NSInteger)xPos atYPos:(NSInteger)yPos;

- (BOOL)isMovementInRightDirection:(CGPoint)translation tile:(SPZTile*)tile;

- (BOOL)isMovementMoreThanHalfWay:(CGPoint)translation tile:(SPZTile*)tile;

/**
 Move the tile and the tiles in between towards the position of the spacer tile
 */
- (void)slideTile:(SPZTile*)tile;

/**
 Translate the tile and the tiles in between towards the position of the spacer tile
 */
- (void)translateTile:(SPZTile*)tile withX:(CGFloat)xDistance withY:(CGFloat)yDistance;

/**
 Save the state of the tile and the tiles in between it and the spacer tile
 */
- (void)saveTileState:(SPZTile*)tile;

/**
 Restore the state of the tile and the tiles in between it and the spacer tile
 */
- (void)restoreTileState:(SPZTile*)tile;


@end
