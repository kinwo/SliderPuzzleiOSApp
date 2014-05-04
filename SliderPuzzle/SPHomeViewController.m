//
//  SPHomeViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 3/05/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPHomeViewController.h"
#import "SPGameBoardViewController.h"
#import "GameKitHelper.h"
#import "NSObject+SoundPlay.h"
#import "SPAlertPresenter.h"

@import GameKit;

@interface SPHomeViewController() <GKTurnBasedMatchmakerViewControllerDelegate>

@end

@implementation SPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTurnEventForMatch)
                                                 name:ReceiveTurnEventForMatch
                                               object:nil];

    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
}

- (void)receiveTurnEventForMatch
{
    [self joinChessMatch];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)joinChessMatch
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;
    
    GKTurnBasedMatchmakerViewController *mmvc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
    [self presentViewController:mmvc animated:YES completion:nil];
}

#pragma mark IBAction
- (IBAction)createNewSinglePlayerGame:(id)sender
{
    [self playButtonPressed];
    SPGameBoardViewController *gameBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardVC"];
    [self presentViewController:gameBoardVC animated:YES completion:nil];
}

- (IBAction)createNewMatchedGame:(id)sender
{
    [self playButtonPressed];
    [self joinChessMatch];
}

- (IBAction)gameCenter:(id)sender {
    [self playButtonPressed];
    [[GameKitHelper sharedGameKitHelper] showGKGameCenterViewController:self];
}

#pragma mark GKTurnBasedMatchmakerViewControllerDelegate
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Turned Based Matchmaker Failed with Error: %@", [error localizedDescription]);
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    GKTurnBasedParticipant *firstParticipant = [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate) {
        NSLog(@"existing Match");
    } else {
        NSLog(@"new Match");
    }
    
    switch(match.status) {
        case GKTurnBasedMatchStatusOpen: {
            GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
            if ([localPlayer.playerID isEqualToString:match.currentParticipant.playerID]) {
                [self startGame:match];
            } else {
                [self showAlertMessage:@"Your opponent is playing the turn."];
            }
            break;
        }
        case GKTurnBasedMatchStatusMatching: {
            [self showAlertMessage:@"The game is searching for player."];
            break;
        }
        case GKTurnBasedMatchStatusUnknown: {
        }
        case GKTurnBasedMatchStatusEnded: {
        }
        default: {
            [self showAlertMessage:@"The game has ended."];
        }
    }
}

- (void)startGame:(GKTurnBasedMatch*)match
{
    // Current player - My Turn, show game board
    [self dismissViewControllerAnimated:NO completion:^{
        SPGameBoardViewController *gameBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardVC"];
        gameBoardVC.match = match;
        [self presentViewController:gameBoardVC animated:YES completion:nil];
    }];
}

- (void)showAlertMessage:(NSString*)message
{
    [[SPAlertPresenter sharedInstance] showAlertMessage:message];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:match.participants turnTimeout:360000 matchData:match.matchData completionHandler:^(NSError *error) {
        if(error) {
            NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
        }
        
        
    }];
}

@end
