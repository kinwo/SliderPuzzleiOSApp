//
//  SPTileAnimationIntention.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTile.h"

typedef void (^AnimateSlideCompletionBlock)(BOOL finished);

@interface SPTileAnimationIntention : NSObject

- (void)animateSlideTile:(SPTile*)senderTile;

- (void)animateSlideTile:(SPTile*)senderTile completion:(AnimateSlideCompletionBlock)completion;

@end
