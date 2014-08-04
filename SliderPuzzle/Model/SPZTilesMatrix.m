//
//  SPTilesMatrix.m
//  SliderPuzzle
//
//
//  Created by HENRY CHAN on 11/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZTilesMatrix.h"
#import "SPZTile.h"
#import "SPZConstants.h"

typedef void (^SenderXBiggerBlock)(SPZTile* tile, NSInteger index);
typedef void (^SenderXSmallerBlock)(SPZTile* tile, NSInteger index);

typedef void (^SenderYBiggerBlock)(SPZTile* tile, NSInteger index);
typedef void (^SenderYSmallerBlock)(SPZTile* tile, NSInteger index);


@interface SPZTilesMatrix()

// 2D matrix of SPTile
@property(nonatomic, strong) NSMutableArray *matrix;

@end

@implementation SPZTilesMatrix

- (id)initWithNumColumns:(NSInteger)columns withNumRows:(NSInteger)rows
{
    self = [super init];
    if (self) {
        self.matrix = [[NSMutableArray alloc] initWithCapacity:rows];
        for (int i=0; i<rows; i++) {
            [self.matrix addObject:[[NSMutableArray alloc] initWithCapacity:columns]];
        }
    }
    return self;
}

// Return array of tiles
- (NSArray*)flattenTilesArray
{
    NSMutableArray *singleDimArray = [[NSMutableArray alloc] initWithCapacity:NumRows * NumColumns];
    
    for (NSArray *colArray in self.matrix) {
        [singleDimArray addObjectsFromArray:colArray];
    }
    
    return singleDimArray;
}

- (void)setSPTileWithXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPZTile*)tile
{
    NSMutableArray *rowArray = [self.matrix objectAtIndex:yPos];
    [rowArray setObject:tile atIndexedSubscript:xPos];
}

- (SPZTile*)getSPTileAtXPos:(NSInteger)xPos atYPos:(NSInteger)yPos
{
    NSMutableArray *rowArray = [self.matrix objectAtIndex:yPos];
    return [rowArray objectAtIndex:xPos];
}

- (BOOL)isMovementInRightDirection:(CGPoint)translation tile:(SPZTile*)tile;
{
    if ([tile hasXPosIntersect:self.spacer]) {
        return (self.spacer.yPos < tile.yPos && translation.y < 0) || (self.spacer.yPos > tile.yPos && translation.y > 0);
    } else if ([tile hasYPosIntersect:self.spacer]) {
        return (self.spacer.xPos < tile.xPos && translation.x < 0) || (self.spacer.xPos > tile.xPos && translation.x > 0);
    }
    
    return FALSE;
}

- (BOOL)isMovementMoreThanHalfWay:(CGPoint)translation tile:(SPZTile*)tile;
{
    if ([tile hasXPosIntersect:self.spacer]) {
        // movement should be in Y axis
        return fabs(translation.y) > tile.frame.size.height/2;
    } else if ([tile hasYPosIntersect:self.spacer]) {
        // movement should be in X axis
        return fabs(translation.x) > tile.frame.size.width/2;
    }
    
    return FALSE;
}

- (void)moveTileToXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPZTile*)tile
{
    [tile moveToXPos:xPos yPos:yPos];
    [self setSPTileWithXPos:xPos withYPos:yPos tile:tile];
}

- (void)iterateTile:(SPZTile*)tile senderYBiggerBlock:(SenderYBiggerBlock)senderYBiggerBlock senderYSmallerBlock:(SenderYSmallerBlock)senderYSmallerBlock senderXBiggerBlock:(SenderXBiggerBlock)senderXBiggerBlock senderXSmallerBlock:(SenderXSmallerBlock)senderXSmallerBlock
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;

    if ([tile hasXPosIntersect:self.spacer]) {
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPZTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                senderYBiggerBlock(fromTile, i);
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPZTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                senderYSmallerBlock(fromTile, i);
            }
            
        }
    } else if ([tile hasYPosIntersect:self.spacer]) {
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPZTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                senderXBiggerBlock(fromTile, i);
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPZTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                senderXSmallerBlock(fromTile, i);
            }
        }
    }

}

/**
 Move the tile and the tiles in between towards the position of the spacer tile
 */
- (void)slideTile:(SPZTile*)tile
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    
    [self iterateTile:tile senderYBiggerBlock:^(SPZTile *tile, NSInteger index) {
        NSInteger toTileYPos = index -1;
        [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:tile];

    } senderYSmallerBlock:^(SPZTile *tile, NSInteger index) {
        NSInteger toTileYPos = index + 1;
        [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:tile];
    
    } senderXBiggerBlock:^(SPZTile *tile, NSInteger index) {
        NSInteger toTileXPos = index -1;
        [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:tile];
    
    } senderXSmallerBlock:^(SPZTile *tile, NSInteger index) {
        NSInteger toTileXPos = index + 1;
        [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:tile];
    }];

    //shift spacer to the "tile" position
    [self moveTileToXPos:senderXPos withYPos:senderYPos tile:self.spacer];
}

/**
 Translate the tile and the tiles in between towards the position of the spacer tile
 */
- (void)translateTile:(SPZTile*)tile withX:(CGFloat)xDistance withY:(CGFloat)yDistance
{
    if (tile == self.spacer) {
        return;
    }
    
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;

    [self iterateTile:tile senderYBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile translateWithX:senderXPos Y:yDistance];

    } senderYSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile translateWithX:senderXPos Y:yDistance];
        
    } senderXBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile translateWithX:xDistance Y:senderYPos];
        
    } senderXSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile translateWithX:xDistance Y:senderYPos];
    }];
}

/**
 Save the state of the tile and the tiles in between it and the spacer tile
 */
- (void)saveTileState:(SPZTile*)tile
{
    [self iterateTile:tile senderYBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderYSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderXBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderXSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile saveState];
    }];
}

/**
 Restore the state of the tile and the tiles in between it and the spacer tile
 */
- (void)restoreTileState:(SPZTile*)tile
{
    [self iterateTile:tile senderYBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderYSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderXBiggerBlock:^(SPZTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderXSmallerBlock:^(SPZTile *tile, NSInteger index) {
        [tile restoreState];
    }];
}

@end
