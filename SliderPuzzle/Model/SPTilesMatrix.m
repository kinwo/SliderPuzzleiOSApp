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

/**
 Move tile and the tiles in between towards the position of the spacer tile
 */
- (void)slideTile:(SPTile*)tile toSpacer:(SPTile*)spacer
{
    NSInteger senderXPos = tile.xPos;
    NSInteger senderYPos = tile.yPos;
    NSInteger spacerXPos = spacer.xPos;
    NSInteger spacerYPos = spacer.yPos;

    if ([tile hasXPosIntersect:spacer]) {
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
    } else if ([tile hasYPosIntersect:spacer]) {
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
    
    //set spacer
    [self moveTileToXPos:senderXPos withYPos:senderYPos tile:self.spacer];
}

- (void)moveTileToXPos:(NSInteger)xPos withYPos:(NSInteger)yPos tile:(SPTile*)tile
{
    [tile moveToXPos:xPos yPos:yPos];
    [self setSPTileWithXPos:xPos withYPos:yPos tile:tile];
}



@end
