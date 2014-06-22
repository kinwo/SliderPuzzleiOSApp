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
#import "NSMutableArray+ScramblePosition.h"

#import "SPTile.h"
#import "SPTilesMatrix.h"
#import "SPPuzzleBoard.h"
#import "SPGameBoardModelContainer.h"
#import "SPTileMotionHandler.h"
#import "SPTileAnimationIntention.h"
#import "MKParallaxView.h"
#import "SPConstants.h"
#import "SPHomeViewController.h"
#import "NSObject+SoundPlay.h"

@interface SPGameBoardViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SPPuzzleBoard *puzzleBoardView;
@property (weak, nonatomic) IBOutlet MKParallaxView *originalView;
@property (weak, nonatomic) IBOutlet UIView *puzzleBoardContainer;

@property (nonatomic, strong) IBOutlet SPGameBoardModelContainer *model;
@property (nonatomic, strong) IBOutlet SPTileMotionHandler *motionHandler;
@property (nonatomic, strong) IBOutlet SPTileAnimationIntention *animationIntent;

@end

@implementation SPGameBoardViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self initCommon];
    
    // display slice images for the resized image
    [self displaySliceImagesFor:[UIImage imageNamed:SourceImage]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)initCommon
{
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
    }
    
    // PuzzleBoard target High-res image width
    NSInteger HighResTargetImageWidth = self.puzzleBoardContainer.frame.size.width * 2;
    NSInteger HighResTargetImageHeight = self.puzzleBoardContainer.frame.size.height * 2;
    
    // resize to fit into the container
    UIImage *resizedImage = [srcImage resizeImageToSize:CGSizeMake(HighResTargetImageWidth, HighResTargetImageHeight)];
    self.originalView.backgroundImage = resizedImage;
    
    float targetFrameWidth = resizedImage.size.width / 2;
    float targetFrameHeight = resizedImage.size.height / 2;
    
    CGRect containerFrame = CGRectMake(PuzzleBoardFrameX, PuzzleBoardFrameY, targetFrameWidth, targetFrameHeight);
    SPPuzzleBoard *boardView = [[SPPuzzleBoard alloc] initWithFrame:containerFrame];
    
    self.model.sliceWidth = (targetFrameWidth / NumColumns);
    self.model.sliceHeight = (targetFrameHeight / NumRows);
    
    NSMutableArray *sliceImageList = [resizedImage sliceImagesWithNumRows:NumRows numColumns:NumColumns];

    // randomize
    [sliceImageList scramble];
    
    // select top left corner element as spacer
    UIImage *spacerImage = [UIImage imageWithColor:[UIColor whiteColor] withFrame:CGRectMake(0, 0, self.model.sliceWidth, self.model.sliceHeight)];
    sliceImageList[spacerIndex] = spacerImage;
    
    NSInteger index=0;
    
    // add SPTile to container view
    for (int i=0; i<NumRows; i++) {
        for (int j=0; j<NumColumns; j++) {
            SPTile *tileImageView = [self createTile:sliceImageList[index] tileX:j tileY:i];
            [self addGestureRecogizer:tileImageView];
            [boardView addSubview:tileImageView];
            [self.model.tilesMatrix setSPTileWithXPos:j withYPos:i tile:tileImageView];
            
            if (index == spacerIndex) {
                [self.model.tilesMatrix setSpacer:tileImageView];
            }
            
            index++;
        }
    }
    
    self.puzzleBoardView = boardView;
    [self.puzzleBoardContainer addSubview:boardView];
}

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

- (SPTile*)createTile:(UIImage*)sliceImage tileX:(NSInteger)xPos tileY:(NSInteger)yPos
{
    NSInteger originX = xPos * self.model.sliceWidth;
    NSInteger originY = yPos * self.model.sliceHeight;
    CGRect frame = CGRectMake(originX, originY, self.model.sliceWidth, self.model.sliceHeight);
    
    SPTile *tile = [[SPTile alloc] initWithFrame:frame];
    tile.backgroundImage = sliceImage;
    tile.xPos = xPos;
    tile.yPos = yPos;
    
    return tile;
}

- (CGFloat)radiansToDegrees:(CGFloat)radians
{
    return radians * 180 / M_PI;
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

- (IBAction)calibrateMotionDetection:(id)sender
{
    self.model.averageXOffset = 0.0f;
    self.model.averageYOffset = 0.0f;
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

- (IBAction)backToHome:(id)sender
{
    [self playButtonPressed];
    SPHomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
    [self presentViewController:homeVC animated:YES completion:nil];
}

- (IBAction)forfeitGame:(id)sender
{
    if (![self isGameCenterMatch]) {
        return;
    }
    
    if ([self isCurrentPlayer]) {
        GKTurnBasedParticipant *nextParticipant = [self nextParticipant];
        
        if(self.match.currentParticipant == [self.match.participants objectAtIndex:0]) {
            nextParticipant = [[self.match participants] lastObject];
        } else {
            nextParticipant = [[self.match participants] objectAtIndex:0];
        }
        
        [self.match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit nextParticipants:@[nextParticipant] turnTimeout:360000 matchData:self.match.matchData completionHandler:^(NSError *error) {
            if(error) {
                NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
            }
            
        }];

    } else {
        [self.match participantQuitOutOfTurnWithOutcome:GKTurnBasedMatchOutcomeQuit withCompletionHandler:^(NSError *error) {
             if(error) {
                 NSLog(@"An error occurred ending match: %@", [error localizedDescription]);
             }
         }];
    }
    
    [self backToHome:self];

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
         
         [self backToHome:self];
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark Gesture handler
- (void)handleTileTap:(UIGestureRecognizer*)gestureRecognizer
{
    SPTile *senderTile = (SPTile*) gestureRecognizer.view;
    [self.animationIntent animateSlideTile:senderTile];
}

- (void)handleTileDrag:(UIPanGestureRecognizer*)dragGestureRecognizer
{
    SPTile *senderTile = (SPTile*) dragGestureRecognizer.view;

    if (dragGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // save original tile state
        [self.model.tilesMatrix saveTileState:senderTile];
        [self.motionHandler.motionManager stopAccelerometerUpdates];

    } if (dragGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];

        if ([self.model.tilesMatrix isMovementInRightDirection:translation tile:senderTile]) {
            [self.model.tilesMatrix translateTile:senderTile withX:translation.x withY:translation.y];
        }

    } else if (dragGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];

        if ([self.model.tilesMatrix isMovementInRightDirection:translation tile:senderTile] && [self.model.tilesMatrix isMovementMoreThanHalfWay:translation tile:senderTile]) {
            // finish the sliding
            [self.animationIntent animateSlideTile:senderTile];
        } else {
            // restore original tile state
            [self.model.tilesMatrix restoreTileState:senderTile];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
