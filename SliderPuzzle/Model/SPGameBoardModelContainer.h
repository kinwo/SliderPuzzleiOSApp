//
//  SPGameBoardModelContainer.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTile.h"
#import "SPTilesMatrix.h"

@interface SPGameBoardModelContainer : NSObject

@property(nonatomic) NSInteger sliceWidth;
@property(nonatomic) NSInteger sliceHeight;

@property (nonatomic) CGFloat averageXOffset;
@property (nonatomic) CGFloat averageYOffset;

// properties for motion detection
@property (nonatomic) CGFloat accumDistance;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic, strong) SPTile *currentTile;

// Model for Puzzle tiles
@property(nonatomic, strong) SPTilesMatrix *tilesMatrix;


@end
