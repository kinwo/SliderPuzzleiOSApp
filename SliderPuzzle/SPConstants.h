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

static NSString* const GA_TRACKING_ID = @"UA-39157126-9";
static NSString* const TESTFLIGHT_ID = @"36f82601-5c77-46cc-877a-f42659eb685c";

static NSInteger const NumRows = 3;
static NSInteger const NumColumns = 3;
static NSInteger const PuzzleBoardFrameX = 0;
static NSInteger const PuzzleBoardFrameY = 0;

static NSString* const SourceImage = @"Puzzle";
static NSInteger const spacerIndex = 0;
static NSInteger const NumSourceImage = 8;

static NSString* const USER_PREF_SOUNDOFF = @"soundOff";
static NSString* const USER_PREF_GAMEDIFFICULTY = @"gameDifficulty";

static NSInteger const DEFAULT_GAMEDIFFICULTY = 0;
static BOOL const DEFAULT_SOUNDOFF = FALSE;

static NSInteger const SHUFFLE_EASY_NUMBER = 5;
static NSInteger const SHUFFLE_MEDIUM_NUMBER = 100;
static NSInteger const SHUFFLE_DIFFICULT_NUMBER = 1000;

static NSString* const BACKGROUND_MUSIC = @"Retro Game Music.mp3";
static NSString* const SUCCESS_MUSIC = @"8 bit level cleared and lost.mp3";

static CGFloat StepMoveFactor = 8;
static CGFloat MotionDetectionSensitivity = 0.13;
static CGFloat TileSwitchOverTheshold = 20;

#endif
