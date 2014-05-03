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

@import GameKit;

@interface SPHomeViewController() <GKTurnBasedMatchmakerViewControllerDelegate>

@end

@implementation SPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController
                                               object:nil];
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)showAuthenticationViewController
{
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [self presentViewController:gameKitHelper.authenticationViewController animated:YES completion:nil];
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
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
    [self dismissViewControllerAnimated:YES completion:nil];

    SPGameBoardViewController *gameBoardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GameBoardVC"];
    [self presentViewController:gameBoardVC animated:YES completion:nil];
}

- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
