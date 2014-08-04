//
//  SPTileAnimationIntention.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZTileAnimationIntention.h"
#import "SPZGameBoardModelContainer.h"


@interface SPZTileAnimationIntention()

@property (nonatomic, strong) IBOutlet SPZGameBoardModelContainer *model;

@end

@implementation SPZTileAnimationIntention

- (void)animateSlideTile:(SPZTile*)senderTile {
    [self animateSlideTile:senderTile completion:nil];
}

// Add animation to slide tile action
- (void)animateSlideTile:(SPZTile*)senderTile completion:(AnimateSlideCompletionBlock)completion
{
    // slide tile only if this tile has intersection with spacer tile and with animation
    if ([senderTile hasIntersect:self.model.tilesMatrix.spacer]) {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState|
         UIViewAnimationOptionAllowUserInteraction|
         UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.model.tilesMatrix slideTile:senderTile];
                         }
                         completion:completion];
    }
}

@end
