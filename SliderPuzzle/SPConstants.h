//
//  SPConstants.h
//  SliderPuzzle
//
//  Created by HENRY CHAN on 22/02/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#ifndef SliderPuzzle_SPConstants_h
#define SliderPuzzle_SPConstants_h

#define CORE_MOTION_UPDATE_INTERVAL (1.0f / 10.0f)

static NSInteger const NumRows = 3;
static NSInteger const NumColumns = 3;
static NSInteger const PuzzleBoardFrameX = 0;
static NSInteger const PuzzleBoardFrameY = 0;

static NSString* const SourceImage = @"Puzzle";
static NSInteger const spacerIndex = 0;
static NSInteger const NumSourceImage = 8;

static CGFloat StepMoveFactor = 8;
static CGFloat MotionDetectionSensitivity = 0.13;
static CGFloat TileSwitchOverTheshold = 20;

#endif
