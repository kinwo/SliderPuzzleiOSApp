//
//  SPTilesMatrix.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 11/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPTilesMatrix.h"
#import "SPTile.h"

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

/**
 Move the tile and the tiles in between towards the position of the spacer tile
 */
- (void)slideTile:(SPTile*)tile
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;

    if ([tile hasXPosIntersect:self.spacer]) {
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                NSInteger toTileYPos = i -1;
                [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:fromTile];
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                NSInteger toTileYPos = i + 1;
                [self moveTileToXPos:senderXPos withYPos:toTileYPos tile:fromTile];
            }
            
        }
    } else if ([tile hasYPosIntersect:self.spacer]) {
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                NSInteger toTileXPos = i -1;
                [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:fromTile];
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                NSInteger toTileXPos = i + 1;
                [self moveTileToXPos:toTileXPos withYPos:senderYPos tile:fromTile];
            }
        }
    }
    
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
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;
    
    if ([tile hasXPosIntersect:self.spacer]) {
        // movement should be in Y axis
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile translateWithX:senderXPos Y:yDistance];
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile translateWithX:senderXPos Y:yDistance];
            }
        }
        
    } else if ([tile hasYPosIntersect:self.spacer]) {
        // movement should be in X axis
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile translateWithX:xDistance Y:senderYPos];
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile translateWithX:xDistance Y:senderYPos];
            }
        }
        
    }
    
}

/**
 Save the state of the tile and the tiles in between it and the spacer tile
 */
- (void)saveTileState:(SPTile*)tile
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;
    
    if ([tile hasXPosIntersect:self.spacer]) {
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile saveState];
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile saveState];
            }
            
        }
    } else if ([tile hasYPosIntersect:self.spacer]) {
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile saveState];
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile saveState];
            }
        }
    }
    
    //shift spacer
    [self.spacer saveState];
}

/**
 Restore the state of the tile and the tiles in between it and the spacer tile
 */
- (void)restoreTileState:(SPTile*)tile
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = self.spacer.xPos;
    NSInteger spacerYPos = self.spacer.yPos;
    
    if ([tile hasXPosIntersect:self.spacer]) {
        if (senderYPos >= spacerYPos) {
            for (NSInteger i=spacerYPos+1; i<=senderYPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile restoreState];
            }
            
        } else {
            for (NSInteger i=spacerYPos-1; i>=senderYPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:senderXPos atYPos:i];
                [fromTile restoreState];
            }
            
        }
    } else if ([tile hasYPosIntersect:self.spacer]) {
        if (senderXPos >= spacerXPos) {
            for (NSInteger i=spacerXPos+1; i<=senderXPos; i++) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile restoreState];
            }
            
        } else {
            for (NSInteger i=spacerXPos-1; i>=senderXPos; i--) {
                SPTile *fromTile = [self getSPTileAtXPos:i atYPos:senderYPos];
                [fromTile restoreState];
            }
        }
    }
    
    //shift spacer
    [self.spacer restoreState];
}



@end
