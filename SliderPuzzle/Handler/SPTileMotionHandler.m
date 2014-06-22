//
//  SPTileMotionHandler.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/06/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPTileMotionHandler.h"
#import "SPConstants.h"
#import "SPTile.h"
#import "SPGameBoardModelContainer.h"
#import "SPTileAnimationIntention.h"

@interface SPTileMotionHandler()

@property (nonatomic, strong) IBOutlet SPGameBoardModelContainer *model;
@property (nonatomic, strong) IBOutlet SPTileAnimationIntention *animationIntent;

@end

@implementation SPTileMotionHandler

#pragma mark Motion Detection
- (void)startDeviceMotionUpdate
{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = CORE_MOTION_UPDATE_INTERVAL;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self respondToMotionUpdate:accelerometerData];
                           });
        }
    }];
    
}

- (void)respondToMotionUpdate:(CMAccelerometerData*)motionData
{
    // Response Algorithm
    CGFloat xAcceleration = -motionData.acceleration.x;
    CGFloat yAcceleration = motionData.acceleration.y;
    
    if (self.model.averageYOffset == 0.0f) {
        self.model.averageYOffset = yAcceleration;
    }
    yAcceleration = yAcceleration - self.model.averageYOffset;
    
    if (self.model.averageXOffset == 0.0f) {
        self.model.averageXOffset = xAcceleration;
    }
    xAcceleration = xAcceleration - self.model.averageXOffset;
    
    
    BOOL isXAccerleration = YES;
    CGFloat selectedAcceleration = xAcceleration;
    
    if (fabs(yAcceleration) > fabs(xAcceleration)) {
        isXAccerleration = NO;
        selectedAcceleration = yAcceleration;
    }
    
    // skip if acceleration is below the threshold
    if (fabs(selectedAcceleration) < MotionDetectionSensitivity) {
        return;
    }
    
    // if X rotation, get tile on right of spacer if accleration > 0, else get tile on left
    if (isXAccerleration) {
        SPTile *slideTile = self.model.currentTile;
        SPTile *spacer = self.model.tilesMatrix.spacer;
        
        if (!slideTile) {
            if (xAcceleration > self.model.averageXOffset) {
                NSInteger slideTileX = spacer.xPos + 1;
                NSInteger slideTileY = spacer.yPos;
                
                if (slideTileX < NumRows) {
                    slideTile = [self.model.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
                
            } else {
                NSInteger slideTileX = spacer.xPos - 1;
                NSInteger slideTileY = spacer.yPos;
                
                if (slideTileX >= 0) {
                    slideTile = [self.model.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
            }
        }
        
        if (slideTile) {
            CGRect rect = slideTile.frame;
            
            // X axis
            float movetoX = rect.origin.x + (-xAcceleration * StepMoveFactor);
            float maxX = rect.origin.x + (float)self.model.sliceWidth;
            
            if (movetoX < 0) {
                movetoX = 0.01;
            }
            
            if (movetoX > maxX) {
                movetoX = maxX;
            }
            
            [self moveTileHorizontally:slideTile acceleration:xAcceleration];
        }
        
    } else {
        // if Y rotation, get tile on top of spacer if acceleration > 0, else get tile on bottom
        SPTile *slideTile = self.model.currentTile;
        SPTile *spacer = self.model.tilesMatrix.spacer;
        
        if (!slideTile) {
            if (yAcceleration > self.model.averageYOffset) {
                NSInteger slideTileX = spacer.xPos;
                NSInteger slideTileY = spacer.yPos + 1;
                
                if (slideTileY < NumColumns) {
                    slideTile = [self.model.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
                
            } else {
                NSInteger slideTileX = spacer.xPos;
                NSInteger slideTileY = spacer.yPos - 1;
                
                if (slideTileY >= 0) {
                    slideTile = [self.model.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
            }
        }
        
        if (slideTile) {
            CGRect rect = slideTile.frame;
            
            // Y axis
            float movetoY = (rect.origin.y + rect.size.height) - (-yAcceleration * StepMoveFactor);
            float maxY = (rect.origin.y + rect.size.height) + (float)self.model.sliceHeight;
            
            if (movetoY < 0) {
                movetoY = 0.01;
            }
            
            if (movetoY > maxY) {
                movetoY = maxY;
            }
            
            [self moveTileVertically:slideTile acceleration:yAcceleration];
        }
    }
    
    self.model.lastUpdateTime = [NSDate date];
    
}

#pragma mark Tiles Movement
- (void)moveTileVertically:(SPTile*)slideTile acceleration:(CGFloat)acceleration
{
    SPTile *currentTile = self.model.currentTile;
    
    if (self.model.accumDistance == 0) {
        if (currentTile && currentTile != slideTile) {
            [currentTile restoreState];
        }
        
        // NSLog(@"Start sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        [self.model.tilesMatrix saveTileState:slideTile];
        self.model.accumDistance += -(acceleration*StepMoveFactor);
        [self.model.tilesMatrix translateTile:slideTile withX:0 withY:self.model.accumDistance];
        self.model.currentTile = slideTile;
        
    } else if (fabs(self.model.accumDistance) >= TileSwitchOverTheshold) {
        // NSLog(@"Finish sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        if (currentTile && currentTile != slideTile) {
            [currentTile restoreState];
        } else {
            [self.model.tilesMatrix saveTileState:slideTile];
            // finish the sliding
            [self.animationIntent animateSlideTile:slideTile];
        }
        
        self.model.accumDistance = 0;
        self.model.currentTile = nil;
        
    } else {
        if (currentTile && currentTile != slideTile) {
            [currentTile restoreState];
            self.model.currentTile = nil;
        } else {
            self.model.accumDistance += -(acceleration*StepMoveFactor);
            [self.model.tilesMatrix translateTile:slideTile withX:0 withY:self.model.accumDistance];
        }
    }
}

- (void)moveTileHorizontally:(SPTile*)slideTile acceleration:(CGFloat)acceleration
{
    SPTile *currentTile = self.model.currentTile;
    
    if (self.model.accumDistance == 0) {
        if (currentTile && currentTile != slideTile) {
            [currentTile restoreState];
        }
        
        // NSLog(@"Start sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        [self.model.tilesMatrix saveTileState:slideTile];
        self.model.accumDistance += -(acceleration*StepMoveFactor);
        [self.model.tilesMatrix translateTile:slideTile withX:self.model.accumDistance withY:0];
        self.model.currentTile = slideTile;
        
    } else if (fabs(self.model.accumDistance) >= TileSwitchOverTheshold) {
        // NSLog(@"Finish sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        if (currentTile != slideTile) {
            [currentTile restoreState];
        } else {
            [self.model.tilesMatrix saveTileState:slideTile];
            // finish the sliding
            [self.animationIntent animateSlideTile:slideTile];
        }
        
        self.model.accumDistance = 0;
        self.model.currentTile = nil;
        
    } else {
        if (currentTile && currentTile != slideTile) {
            [currentTile restoreState];
            self.model.currentTile = nil;
        } else {
            self.model.accumDistance += -(acceleration*StepMoveFactor);
            [self.model.tilesMatrix translateTile:slideTile withX:self.model.accumDistance withY:0];
        }
    }
}


@end
