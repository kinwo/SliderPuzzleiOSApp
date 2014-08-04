//
//  SPTileAnimationIntention.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPZTile.h"

typedef void (^AnimateSlideCompletionBlock)(BOOL finished);

@interface SPZTileAnimationIntention : NSObject

- (void)animateSlideTile:(SPZTile*)senderTile;

- (void)animateSlideTile:(SPZTile*)senderTile completion:(AnimateSlideCompletionBlock)completion;

@end
