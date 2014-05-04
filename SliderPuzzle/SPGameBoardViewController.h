//
//  SPViewController.h
//  SliderPuzzle
//
// The main view controller responsible for showing Puzzle board and tiles and manage
// interactions among them.
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GameKit;

@interface SPGameBoardViewController : UIViewController

@property(nonatomic, strong) GKTurnBasedMatch *match;
@property(nonatomic, strong) NSMutableDictionary *gameDictionary;
@property(nonatomic, strong) NSString *myPlayerCharacter;
@property(nonatomic, strong) IBOutlet UILabel *identifyUserLabel;

@end
