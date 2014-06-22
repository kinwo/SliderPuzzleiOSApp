//
//  SPTileAnimationIntention.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPTileAnimationIntention.h"
#import "SPGameBoardModelContainer.h"

@interface SPTileAnimationIntention()

@property (nonatomic, strong) IBOutlet SPGameBoardModelContainer *model;

@end

@implementation SPTileAnimationIntention

// Add animation to slide tile action
- (void)animateSlideTile:(SPTile*)senderTile
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
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

@end
