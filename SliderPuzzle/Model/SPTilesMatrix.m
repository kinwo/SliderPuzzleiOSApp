//
//  SPTilesMatrix.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 11/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPTilesMatrix.h"
#import "SPTile.h"

typedef void (^SenderXBiggerBlock)(SPTile* tile, NSInteger index);
typedef void (^SenderXSmallerBlock)(SPTile* tile, NSInteger index);

typedef void (^SenderYBiggerBlock)(SPTile* tile, NSInteger index);
typedef void (^SenderYSmallerBlock)(SPTile* tile, NSInteger index);


@interface SPTilesMatrix()

// 2D matrix of SPTile
@property(nonatomic, strong) NSMutableArray *matrix;

@end

@implementation SPTilesMatrix

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

- (void)setSPTileWithXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPTile*)tile
{
    NSMutableArray *rowArray = [self.matrix objectAtIndex:yPos];
    [rowArray setObject:tile atIndexedSubscript:xPos];
}

- (SPTile*)getSPTileAtXPos:(NSInteger)xPos atYPos:(NSInteger)yPos
{
    NSMutableArray *rowArray = [self.matrix objectAtIndex:yPos];
    return [rowArray objectAtIndex:xPos];
}

- (BOOL)isMovementInRightDirection:(CGPoint)translation tile:(SPTile*)tile;
{
    if ([tile hasXPosIntersect:self.spacer]) {
        return (self.spacer.yPos < tile.yPos && translation.y < 0) || (self.spacer.yPos > tile.yPos && translation.y > 0);
    } else if ([tile hasYPosIntersect:self.spacer]) {
        return (self.spacer.xPos < tile.xPos && translation.x < 0) || (self.spacer.xPos > tile.xPos && translation.x > 0);
    }
    
    return FALSE;
}

- (BOOL)isMovementMoreThanHalfWay:(CGPoint)translation tile:(SPTile*)tile;
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

- (void)moveTileToXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPTile*)tile
{
    [tile moveToXPos:xPos yPos:yPos];
    [self setSPTileWithXPos:xPos withYPos:yPos tile:tile];
}

- (void)iterateTile:(SPTile*)tile senderYBiggerBlock:(SenderYBiggerBlock)senderYBiggerBlock senderYSmallerBlock:(SenderYSmallerBlock)senderYSmallerBlock senderXBiggerBlock:(SenderXBiggerBlock)senderXBiggerBlock senderXSmallerBlock:(SenderXSmallerBlock)senderXSmallerBlock
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;

    if ([tile hasXPosIntersect:self.spacer]) {
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                senderYBiggerBlock(fromTile, i);
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                senderYSmallerBlock(fromTile, i);
            }
            
        }
    } else if ([tile hasYPosIntersect:self.spacer]) {
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                senderXBiggerBlock(fromTile, i);
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                senderXSmallerBlock(fromTile, i);
            }
        }
    }

}

/**
 Move the tile and the tiles in between towards the position of the spacer tile
 */
- (void)slideTile:(SPTile*)tile
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    
    [self iterateTile:tile senderYBiggerBlock:^(SPTile *tile, NSInteger index) {
        NSInteger toTileYPos = index -1;
        [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:tile];

    } senderYSmallerBlock:^(SPTile *tile, NSInteger index) {
        NSInteger toTileYPos = index + 1;
        [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:tile];
    
    } senderXBiggerBlock:^(SPTile *tile, NSInteger index) {
        NSInteger toTileXPos = index -1;
        [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:tile];
    
    } senderXSmallerBlock:^(SPTile *tile, NSInteger index) {
        NSInteger toTileXPos = index + 1;
        [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:tile];
    }];

    //shift spacer to the "tile" position
    [self moveTileToXPos:senderXPos withYPos:senderYPos tile:self.spacer];
}

/**
 Translate the tile and the tiles in between towards the position of the spacer tile
 */
- (void)translateTile:(SPTile*)tile withX:(CGFloat)xDistance withY:(CGFloat)yDistance
{
    if (tile == self.spacer) {
        return;
    }
    
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;

    [self iterateTile:tile senderYBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile translateWithX:senderXPos Y:yDistance];

    } senderYSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile translateWithX:senderXPos Y:yDistance];
        
    } senderXBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile translateWithX:xDistance Y:senderYPos];
        
    } senderXSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile translateWithX:xDistance Y:senderYPos];
    }];
}

/**
 Save the state of the tile and the tiles in between it and the spacer tile
 */
- (void)saveTileState:(SPTile*)tile
{
    [self iterateTile:tile senderYBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderYSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderXBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile saveState];
        
    } senderXSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile saveState];
    }];
}

/**
 Restore the state of the tile and the tiles in between it and the spacer tile
 */
- (void)restoreTileState:(SPTile*)tile
{
    [self iterateTile:tile senderYBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderYSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderXBiggerBlock:^(SPTile *tile, NSInteger index) {
        [tile restoreState];
        
    } senderXSmallerBlock:^(SPTile *tile, NSInteger index) {
        [tile restoreState];
    }];
}

@end
