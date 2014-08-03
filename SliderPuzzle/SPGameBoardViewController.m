//
//  SPViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPGameBoardViewController.h"

#import "UIImage+SliceImages.h"
#import "UIImage+ResizeImage.h"
#import "UIImage+Color.h"
#import <RESideMenu/RESideMenu.h>

#import "SPTile.h"
#import "SPTilesMatrix.h"
#import "SPPuzzleBoard.h"
#import "SPGameBoardModelContainer.h"
#import "SPTileAnimationIntention.h"
#import "SPShuffleIntention.h"
#import "SPConstants.h"
#import "SPMultiGameHomeViewController.h"
#import "NSObject+SoundPlay.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import "SPGestureDelegate.h"
#import "SKTAudio.h"
#import "CALayer+Additions.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "UIViewController+Analytics.h"

@interface SPGameBoardViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SPPuzzleBoard *puzzleBoardView;
@property (weak, nonatomic) IBOutlet UIImageView *originalView;
@property (weak, nonatomic) IBOutlet UIView *puzzleBoardContainer;

@property (nonatomic, strong) IBOutlet SPGameBoardModelContainer *model;
@property (nonatomic, strong) IBOutlet SPTileAnimationIntention *animationIntent;
@property (nonatomic, strong) IBOutlet SPShuffleIntention *shuffleIntent;
@property (weak, nonatomic) IBOutlet UILabel *levelTitle;
@property (weak, nonatomic) IBOutlet UILabel *timerTitle;

@property (atomic, assign) NSInteger secondsAccum;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentPuzzleSourceImageIndex;

@end

@implementation SPGameBoardViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.currentPuzzleSourceImageIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // display slice images for the resized image
    NSString *initialSourceImage = [NSString stringWithFormat:@"%@%ld", SourceImage, (long)self.currentPuzzleSourceImageIndex];
    
    [self logWithCategory:@"ui_action" action:@"show_puzzle" label:[NSString stringWithFormat:@"image-%ld", (long)self.currentPuzzleSourceImageIndex]];
    
    [self displaySliceImagesFor:[UIImage imageNamed:initialSourceImage]];
    
    [self playBackgroundMusic];

    [self startTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Main Game Board View";
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)initCommon
{
    self.model.tilesMatrix = nil;
    self.model.tilesMatrix = [[SPTilesMatrix alloc] initWithNumColumns:NumColumns withNumRows:NumRows];
    self.model.lastUpdateTime = [NSDate date];
    self.model.accumDistance = 0;
    self.model.averageYOffset = 0.0f;
    self.model.averageXOffset = 0.0f;
}

- (void)displaySliceImagesFor:(UIImage*)srcImage
{
    if (self.puzzleBoardView) {
        [self.puzzleBoardView removeFromSuperview];
        self.puzzleBoardView = nil;
    }
    
    [self initCommon];
    
    // PuzzleBoard target High-res image width
    NSInteger HighResTargetImageWidth = self.puzzleBoardContainer.frame.size.width * 2;
    NSInteger HighResTargetImageHeight = self.puzzleBoardContainer.frame.size.height * 2;
    
    // resize to fit into the container
    UIImage *resizedImage = [srcImage resizeImageToSize:CGSizeMake(HighResTargetImageWidth, HighResTargetImageHeight)];
    self.originalView.image = resizedImage;
    
    float targetFrameWidth = resizedImage.size.width / 2;
    float targetFrameHeight = resizedImage.size.height / 2;
    
    CGRect containerFrame = CGRectMake(PuzzleBoardFrameX, PuzzleBoardFrameY, targetFrameWidth, targetFrameHeight);
    SPPuzzleBoard *boardView = [[SPPuzzleBoard alloc] initWithFrame:containerFrame];
    
    self.model.sliceWidth = (targetFrameWidth / NumColumns);
    self.model.sliceHeight = (targetFrameHeight / NumRows);
    
    NSMutableArray *sliceImageList = [resizedImage sliceImagesWithNumRows:NumRows numColumns:NumColumns];
    NSInteger index=0;
    
    // add SPTile to container view
    for (int i=0; i<NumRows; i++) {
        for (int j=0; j<NumColumns; j++) {
            SPTile *tileImageView = [self createTile:sliceImageList[index] tileX:j tileY:i];
            [self addGestureRecogizer:tileImageView];
            [boardView addSubview:tileImageView];
            [self.model.tilesMatrix setSPTileWithXPos:j withYPos:i tile:tileImageView];
            
            if (index == spacerIndex) {
                tileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                tileImageView.layer.borderWidth = 5.0;
                tileImageView.alpha = 0.25;
                [self.model.tilesMatrix setSpacer:tileImageView];
            }
            
            index++;
        }
    }
    
    // shuffle tilesMatrix
    [self.shuffleIntent shuffle:self.currentPuzzleSourceImageIndex];
    
    self.puzzleBoardView = boardView;
    [self.puzzleBoardContainer addSubview:boardView];
    
    // update level title
    self.levelTitle.text = [NSString stringWithFormat:@"Level %ld", self.currentPuzzleSourceImageIndex + 1];
    
}

- (SPTile*)createTile:(UIImage*)sliceImage tileX:(NSInteger)xPos tileY:(NSInteger)yPos
{
    NSInteger originX = xPos * self.model.sliceWidth;
    NSInteger originY = yPos * self.model.sliceHeight;
    CGRect frame = CGRectMake(originX, originY, self.model.sliceWidth, self.model.sliceHeight);
    
    SPTile *tile = [[SPTile alloc] initWithFrame:frame];
    tile.image = sliceImage;
    tile.xPos = xPos;
    tile.yPos = yPos;
    tile.xMatchPos = xPos;
    tile.yMatchPos = yPos;
    
    return tile;
}

#pragma mark Timer
- (void)updateCountdown {
    NSInteger hours, minutes, seconds;
    
    self.secondsAccum++;
    hours = self.secondsAccum / 3600;
    minutes = (self.secondsAccum % 3600) / 60;
    seconds = (self.secondsAccum % 3600) % 60;
    self.timerTitle.text = [NSString stringWithFormat:@"%02ld %02ld %02ld", (long)hours, (long)minutes, (long)seconds];
}

- (void)startTimer
{
    self.secondsAccum = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
}

- (void)stopTimer
{
    [self.timer invalidate];
}

- (void)resetTimer
{
    [self stopTimer];
    [self startTimer];
}

#pragma mark Music
- (void)playBackgroundMusic
{
    [[SKTAudio sharedInstance] stopSoundEffect];
    [[SKTAudio sharedInstance] playBackgroundMusic:BACKGROUND_MUSIC];
}

- (void)playAllMatchesMusic
{
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [[SKTAudio sharedInstance] playSoundEffect:SUCCESS_MUSIC];
}

#pragma mark Game Rules
- (void)checkPuzzlesMatching
{
    // play success music if all tiles are matched
    for (SPTile *tile in [self.model.tilesMatrix flattenTilesArray] ){
        if (![tile isMatched]) {
            return;
        }
    }

    [self stopTimer];

    // ALL GOOD ! Play success music
    [self playAllMatchesMusic];
    
    // show original image
    self.originalView.hidden = NO;
    self.puzzleBoardView.hidden = YES;
}

# pragma mark IBActions
- (IBAction)chooseNewPuzzleImage:(id)sender
{
    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)toggleOriginalImage:(UIGestureRecognizer*)gestureRecognizer
{
    BOOL isShowOriginalImage = NO;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        isShowOriginalImage = YES;
    }
    
    UILabel *senderLabel = (UILabel*)gestureRecognizer.view;
    senderLabel.highlighted = isShowOriginalImage;
    self.originalView.hidden = !isShowOriginalImage;
    self.puzzleBoardView.hidden = isShowOriginalImage;
}

- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark Gesture handler
// register Tap and Dragging gestures to a tile
- (void)addGestureRecogizer:(SPTile*)tile
{
    // tap
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTileTap:)];
    [tile addGestureRecognizer:tapGesture];
    
    // dragging
    UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTileDrag:)];
    dragGesture.minimumNumberOfTouches = 1;
    [tile addGestureRecognizer:dragGesture];
}

- (void)cleanupTiles
{
    for (SPTile *tile in [self.model.tilesMatrix flattenTilesArray] ){
        for (UIGestureRecognizer *recognizer in [tile gestureRecognizers]) {
            [tile removeGestureRecognizer:recognizer];
            [tile removeFromSuperview];
        }
    }
}

- (void)handleTileTap:(UIGestureRecognizer*)gestureRecognizer
{
    SPTile *senderTile = (SPTile*) gestureRecognizer.view;
    [self.animationIntent animateSlideTile:senderTile completion:^(BOOL finished) {
        [self checkPuzzlesMatching];
    }];
}

- (void)handleTileDrag:(UIPanGestureRecognizer*)dragGestureRecognizer
{
    SPTile *senderTile = (SPTile*) dragGestureRecognizer.view;

    if (dragGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // save original tile state
        [self.model.tilesMatrix saveTileState:senderTile];

    } else if (dragGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];
        if ([self.model.tilesMatrix isMovementInRightDirection:translation tile:senderTile]) {
            [self.model.tilesMatrix translateTile:senderTile withX:translation.x withY:translation.y];
        }

    } else if (dragGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];
        if ([self.model.tilesMatrix isMovementInRightDirection:translation tile:senderTile] && [self.model.tilesMatrix isMovementMoreThanHalfWay:translation tile:senderTile]) {
            // finish the sliding
            [self.animationIntent animateSlideTile:senderTile completion:^(BOOL finished) {
                [self checkPuzzlesMatching];
            }];
        } else {
            // restore original tile state
            [self.model.tilesMatrix restoreTileState:senderTile];
        }
    }
}

- (IBAction)handleSwipeRight:(id)sender
{
    NSInteger nextSourceImageIndex = self.currentPuzzleSourceImageIndex - 1;
    [self displayNextSourceImageBy:nextSourceImageIndex];
}

- (IBAction)handleSwipeLeft:(id)sender
{
    NSInteger nextSourceImageIndex = self.currentPuzzleSourceImageIndex + 1;
    [self displayNextSourceImageBy:nextSourceImageIndex];
}

- (void)displayNextSourceImageBy:(NSInteger)nextSourceImageIndex
{
    // make sure original image is hidden
    self.originalView.hidden = YES;
    self.puzzleBoardView.hidden = NO;
    [self resetTimer];
    [self playBackgroundMusic];
    
    if (nextSourceImageIndex < 0) {
        nextSourceImageIndex = NumSourceImage-1;
    } else {
        nextSourceImageIndex = nextSourceImageIndex % NumSourceImage;
    }
    
    self.currentPuzzleSourceImageIndex = nextSourceImageIndex;
    
    [self logWithCategory:@"ui_action" action:@"show_puzzle" label:[NSString stringWithFormat:@"image-%ld", (long)self.currentPuzzleSourceImageIndex]];
    
    NSString *sourceImage = [NSString stringWithFormat:@"%@%ld", SourceImage, (long)nextSourceImageIndex];
    
    [self cleanupTiles];
    
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self displaySliceImagesFor:[UIImage imageNamed:sourceImage]];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

#pragma mark Game Center integration
- (IBAction)forfeitGame:(id)sender
{
    if (![self isGameCenterMatch]) {
        return;
    }
    
    if ([self isCurrentPlayer]) {
//        GKTurnBasedParticipant *nextParticipant = [self nextParticipant];
//        
//        if(self.match.currentParticipant == [self.match.participants objectAtIndex:0]) {
//            nextParticipant = [[self.match participants] lastObject];
//        } else {
//            nextParticipant = [[self.match participants] objectAtIndex:0];
//        }
//        
//        [self.match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:@[nextParticipant] turnTimeout:360000 matchData:self.match.matchData completionHandler:^(NSError *error) {
//            if(error) {
//                NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
//            }
//            
//        }];
        
    } else {
        [self.match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
            if(error) {
                NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
            }
        }];
    }
    
}

- (GKTurnBasedParticipant*)nextParticipant
{
    NSUInteger currentIndex = [self.match.participants
                               indexOfObject:self.match.currentParticipant];
    GKTurnBasedParticipant *nextParticipant = [self.match.participants objectAtIndex:
                                               ((currentIndex + 1) % [self.match.participants count ])];
    return nextParticipant;
}

- (IBAction)nextTurn:(id)sender
{
    [self.match endTurnWithNextParticipants:@[[self nextParticipant]] turnTimeout:360000 matchData:self.match.matchData completionHandler:^(NSError *error) {
        if(error) {
            NSLog(@"An error occurred updating turn: %@", [error localizedDescription]);
        }
        
    }];
}

- (BOOL)isCurrentPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    return [self.match.currentParticipant.playerID isEqualToString:localPlayer.playerID];
}

- (BOOL)isGameCenterMatch
{
    return self.match != nil;
}

# pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [self displaySliceImagesFor:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
