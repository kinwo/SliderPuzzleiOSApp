//
//  SPShuffleIntention.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPShuffleIntention.h"
#import "SPTile.h"
#import "SPConstants.h"
#import "SPGameBoardModelContainer.h"
#import "SPTileAnimationIntention.h"

// Shuffle
NS_ENUM(NSInteger, ShuffleMove)
{
	NONE			= 0,
	UP				= 1,
	DOWN			= 2,
	LEFT			= 3,
	RIGHT			= 4
};



@interface SPShuffleIntention()

@property (nonatomic, strong) IBOutlet SPGameBoardModelContainer *model;
@property (nonatomic, strong) IBOutlet SPTileAnimationIntention *animationIntent;

@end

@implementation SPShuffleIntention

#pragma mark Shuffle moves
- (void)shuffle:(NSInteger)level
{
	NSMutableArray *validMoves = [[NSMutableArray alloc] init];
    
    NSInteger difficulty = [[NSUserDefaults standardUserDefaults] integerForKey:USER_PREF_GAMEDIFFICULTY];
    NSInteger shuffleNumber = 0;
    switch (difficulty) {
        case 0:
            shuffleNumber = SHUFFLE_EASY_NUMBER;
            break;
        case 1:
            shuffleNumber = SHUFFLE_MEDIUM_NUMBER;
            break;
        case 2:
            shuffleNumber = SHUFFLE_DIFFICULT_NUMBER;
            break;
        default:
            break;
    }
	
    shuffleNumber += (level * 3);
    
	for (int i=0; i<shuffleNumber; i++) {
		[validMoves removeAllObjects];
		
		// get all of the pieces that can move
		for (SPTile *tile in [self.model.tilesMatrix flattenTilesArray] ){
			if( [self validMove:tile] != NONE ){
				[validMoves addObject:tile];
			}
		}
		
		// randomly select a piece to move
		NSInteger pick = arc4random()%[validMoves count];
		[self movePiece:validMoves[pick]];
	}
}

- (enum ShuffleMove)validMove:(SPTile*)tile
{
    SPTile *spacer = self.model.tilesMatrix.spacer;
    
	// blank spot above current piece
	if (tile.xPos == spacer.xPos && tile.yPos == spacer.yPos+1 ){
		return UP;
	}
	
	// bank splot below current piece
	if (tile.xPos == spacer.xPos && tile.yPos == spacer.yPos-1) {
		return DOWN;
	}
	
	// bank spot left of the current piece
	if (tile.xPos == spacer.xPos+1 && tile.yPos == spacer.yPos) {
		return LEFT;
	}
	
	// bank spot right of the current piece
	if (tile.xPos == spacer.xPos-1 && tile.yPos == spacer.yPos) {
		return RIGHT;
	}
	
	return NONE;
}

- (void)movePiece:(SPTile*)tile
{
	switch ([self validMove:tile]) {
		case UP:
            [self.model.tilesMatrix translateTile:tile withX:0 withY:-1];
            [self.animationIntent animateSlideTile:tile];
			break;
		case DOWN:
            [self.model.tilesMatrix translateTile:tile withX:0 withY:1];
            [self.animationIntent animateSlideTile:tile];
			break;
		case LEFT:
            [self.model.tilesMatrix translateTile:tile withX:-1 withY:0];
            [self.animationIntent animateSlideTile:tile];
			break;
		case RIGHT:
            [self.model.tilesMatrix translateTile:tile withX:1 withY:0];
            [self.animationIntent animateSlideTile:tile];
			break;
		default:
			break;
	}
}

@end
