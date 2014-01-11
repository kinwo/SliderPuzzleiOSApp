//
//  SPTilesMatrix.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 11/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTile.h"

@interface SPTilesMatrix : NSObject

@property(nonatomic, strong) SPTile *spacer;

- (id)initWithNumColumns:(NSInteger)columns withNumRows:(NSInteger)rows;

- (void)setSPTileWithXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPTile*)tile;

- (SPTile*)getSPTileAtXPos:(NSInteger)xPos atYPos:(NSInteger)yPos;

- (void)slideTile:(SPTile*)tile toSpacer:(SPTile*)spacer;

@end
