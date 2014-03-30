//
//  SPViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPViewController.h"

#import "UIImage+SliceImages.h"
#import "UIImage+ResizeImage.h"
#import "UIImage+Color.h"
#import "NSMutableArray+ScramblePosition.h"

#import "SPTile.h"
#import "SPTilesMatrix.h"
#import "SPPuzzleBoard.h"
#import "MKParallaxView.h"
#import "SPConstants.h"

#import <Socialize/Socialize.h>
@import CoreMotion;

@interface SPViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic) NSInteger sliceWidth;
@property(nonatomic) NSInteger sliceHeight;

@property (nonatomic, strong) SZActionBar *actionBar;
@property (nonatomic, strong) id<SZEntity> entity;
@property (nonatomic, strong) SPPuzzleBoard *puzzleBoardView;
@property (weak, nonatomic) IBOutlet MKParallaxView *originalView;
@property (weak, nonatomic) IBOutlet UIView *puzzleBoardContainer;


// properties for motion detection
@property (nonatomic) CGFloat accumDistance;
@property (nonatomic, strong) NSDate *lastUpdateTime;
@property (nonatomic) CGFloat averageXOffset;
@property (nonatomic) CGFloat averageYOffset;
@property (nonatomic, strong) SPTile *currentTile;


// Model for Puzzle tiles
@property(nonatomic, strong) SPTilesMatrix *tilesMatrix;

@property(nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation SPViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.tilesMatrix = [[SPTilesMatrix alloc] initWithNumColumns:NumColumns withNumRows:NumRows];
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
    
    [self addSocializeBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)initCommon
{
    self.lastUpdateTime = [NSDate date];
    self.accumDistance = 0;
    self.averageYOffset = 0.0f;
    self.averageXOffset = 0.0f;
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
    
    self.sliceWidth = (targetFrameWidth / NumColumns);
    self.sliceHeight = (targetFrameHeight / NumRows);
    
    NSMutableArray *sliceImageList = [resizedImage sliceImagesWithNumRows:NumRows numColumns:NumColumns];

    // randomize
    [sliceImageList scramble];
    
    // select top left corner element as spacer
    UIImage *spacerImage = [UIImage imageWithColor:[UIColor whiteColor] withFrame:CGRectMake(0, 0, self.sliceWidth, self.sliceHeight)];
    sliceImageList[spacerIndex] = spacerImage;
    
    NSInteger index=0;
    
    // add SPTile to container view
    for (int i=0; i<NumRows; i++) {
        for (int j=0; j<NumColumns; j++) {
            SPTile *tileImageView = [self createTile:sliceImageList[index] tileX:j tileY:i];
            [self addGestureRecogizer:tileImageView];
            [boardView addSubview:tileImageView];
            [self.tilesMatrix setSPTileWithXPos:j withYPos:i tile:tileImageView];
            
            if (index == spacerIndex) {
                [self.tilesMatrix setSpacer:tileImageView];
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
    NSInteger originX = xPos * self.sliceWidth;
    NSInteger originY = yPos * self.sliceHeight;
    CGRect frame = CGRectMake(originX, originY, self.sliceWidth, self.sliceHeight);
    
    SPTile *tile = [[SPTile alloc] initWithFrame:frame];
    tile.backgroundImage = sliceImage;
    tile.xPos = xPos;
    tile.yPos = yPos;
    
    return tile;
}


#pragma mark Social Bar
- (void)addSocializeBar
{
    if (self.actionBar == nil) {
        self.entity = [SZEntity entityWithKey:@"sp_board" name:@"Slider Puzzle Board"];
        self.actionBar = [SZActionBarUtils showActionBarWithViewController:self entity:self.entity options:nil];
        
        SZShareOptions *shareOptions = [SZShareUtils userShareOptions];
        shareOptions.dontShareLocation = YES;
        
        shareOptions.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
            if (network == SZSocialNetworkTwitter) {
                NSString *entityURL = [[postData.propagationInfo objectForKey:@"twitter"] objectForKey:@"entity_url"];
                NSString *displayName = [postData.entity displayName];
                NSString *customStatus = [NSString stringWithFormat:@"Custom status for %@ with url %@", displayName, entityURL];
                
                [postData.params setObject:customStatus forKey:@"status"];
                
            } else if (network == SZSocialNetworkFacebook) {
                NSString *entityURL = [[postData.propagationInfo objectForKey:@"facebook"] objectForKey:@"entity_url"];
                NSString *displayName = [postData.entity displayName];
                NSString *customMessage = [NSString stringWithFormat:@"Custom status for %@ ", displayName];
                
                [postData.params setObject:customMessage forKey:@"message"];
                [postData.params setObject:entityURL forKey:@"link"];
                [postData.params setObject:@"A caption" forKey:@"caption"];
                [postData.params setObject:@"Custom Name" forKey:@"name"];
                [postData.params setObject:@"A Site" forKey:@"description"];
            }
        };
        
        [self.actionBar setBackgroundColor:[UIColor colorWithRed:0.994 green:0.693 blue:0.036 alpha:1.000]];
        
        self.actionBar.shareOptions = shareOptions;
    }
}

#pragma mark Tiles Movement
- (void)moveTileVertically:(SPTile*)slideTile acceleration:(CGFloat)acceleration
{
    if (self.accumDistance == 0) {
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
        }
        
        // NSLog(@"Start sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        [self.tilesMatrix saveTileState:slideTile];
        self.accumDistance += -(acceleration*StepMoveFactor);
        [self.tilesMatrix translateTile:slideTile withX:0 withY:self.accumDistance];
        self.currentTile = slideTile;
        
    } else if (fabs(self.accumDistance) >= TileSwitchOverTheshold) {
        // NSLog(@"Finish sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
        } else {
            [self.tilesMatrix saveTileState:slideTile];
            // finish the sliding
            [self animateSlideTile:slideTile];
        }
        
        self.accumDistance = 0;
        self.currentTile = nil;
        
    } else {
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
            self.currentTile = nil;
        } else {
            self.accumDistance += -(acceleration*StepMoveFactor);
            [self.tilesMatrix translateTile:slideTile withX:0 withY:self.accumDistance];
        }
    }
}

- (void)moveTileHorizontally:(SPTile*)slideTile acceleration:(CGFloat)acceleration
{
    if (self.accumDistance == 0) {
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
        }
        
        // NSLog(@"Start sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        [self.tilesMatrix saveTileState:slideTile];
        self.accumDistance += -(acceleration*StepMoveFactor);
        [self.tilesMatrix translateTile:slideTile withX:self.accumDistance withY:0];
        self.currentTile = slideTile;
        
    } else if (fabs(self.accumDistance) >= TileSwitchOverTheshold) {
        // NSLog(@"Finish sliding tile x=%d, y=%d", slideTile.xPos, slideTile.yPos);
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
        } else {
            [self.tilesMatrix saveTileState:slideTile];
            // finish the sliding
            [self animateSlideTile:slideTile];
        }
        
        self.accumDistance = 0;
        self.currentTile = nil;
        
    } else {
        if (self.currentTile && self.currentTile != slideTile) {
            [self.currentTile restoreState];
            self.currentTile = nil;
        } else {
            self.accumDistance += -(acceleration*StepMoveFactor);
            [self.tilesMatrix translateTile:slideTile withX:self.accumDistance withY:0];
        }
    }
}

- (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * 180 / M_PI;
}

// Add animation to slide tile action
- (void)animateSlideTile:(SPTile*)senderTile
{
    // slide tile only if this tile has intersection with spacer tile and with animation
    if ([senderTile hasIntersect:self.tilesMatrix.spacer]) {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState|
                                    UIViewAnimationOptionAllowUserInteraction|
                                    UIViewAnimationOptionCurveEaseOut
                         animations:^{
                                [self.tilesMatrix slideTile:senderTile];
                         }
                         completion:nil];
    }
}

# pragma mark IBActions
- (IBAction)chooseNewPuzzleImage:(id)sender {
    UIImagePickerController *imagePickerVC = [[UIImagePickerController alloc] init];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)calibrateMotionDetection:(id)sender {
    self.averageXOffset = 0.0f;
    self.averageYOffset = 0.0f;
}

- (IBAction)toggleOriginalImage:(UIGestureRecognizer*)gestureRecognizer {
    BOOL isShowOriginalImage = NO;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        isShowOriginalImage = YES;
    }
    
    UILabel *senderLabel = (UILabel*)gestureRecognizer.view;
    senderLabel.highlighted = isShowOriginalImage;
    self.originalView.hidden = !isShowOriginalImage;
    self.puzzleBoardView.hidden = isShowOriginalImage;
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
    [self animateSlideTile:senderTile];
}

- (void)handleTileDrag:(UIPanGestureRecognizer*)dragGestureRecognizer
{
    SPTile *senderTile = (SPTile*) dragGestureRecognizer.view;

    if (dragGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        // save original tile state
        [self.tilesMatrix saveTileState:senderTile];
        [self.motionManager stopAccelerometerUpdates];

    } if (dragGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];

        if ([self.tilesMatrix isMovementInRightDirection:translation tile:senderTile]) {
            [self.tilesMatrix translateTile:senderTile withX:translation.x withY:translation.y];
        }

    } else if (dragGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [dragGestureRecognizer translationInView:dragGestureRecognizer.view];

        if ([self.tilesMatrix isMovementInRightDirection:translation tile:senderTile] && [self.tilesMatrix isMovementMoreThanHalfWay:translation tile:senderTile]) {
            // finish the sliding
            [self animateSlideTile:senderTile];
        } else {
            // restore original tile state
            [self.tilesMatrix restoreTileState:senderTile];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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
    
    if (self.averageYOffset == 0.0f) {
        self.averageYOffset = yAcceleration;
    }
    yAcceleration = yAcceleration - self.averageYOffset;
    
    if (self.averageXOffset == 0.0f) {
        self.averageXOffset = xAcceleration;
    }
    xAcceleration = xAcceleration - self.averageXOffset;
    
    
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
        SPTile *slideTile = self.currentTile;
        SPTile *spacer = self.tilesMatrix.spacer;
        
        if (!slideTile) {
            if (xAcceleration > self.averageXOffset) {
                NSInteger slideTileX = spacer.xPos + 1;
                NSInteger slideTileY = spacer.yPos;
                
                if (slideTileX < NumRows) {
                    slideTile = [self.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
                
            } else {
                NSInteger slideTileX = spacer.xPos - 1;
                NSInteger slideTileY = spacer.yPos;
                
                if (slideTileX >= 0) {
                    slideTile = [self.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
            }
        }
        
        if (slideTile) {
            CGRect rect = slideTile.frame;
            
            // X axis
            float movetoX = rect.origin.x + (-xAcceleration * StepMoveFactor);
            float maxX = rect.origin.x + (float)self.sliceWidth;
            
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
        SPTile *slideTile = self.currentTile;
        SPTile *spacer = self.tilesMatrix.spacer;
        
        if (!slideTile) {
            if (yAcceleration > self.averageYOffset) {
                NSInteger slideTileX = spacer.xPos;
                NSInteger slideTileY = spacer.yPos + 1;
                
                if (slideTileY < NumColumns) {
                    slideTile = [self.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
                
            } else {
                NSInteger slideTileX = spacer.xPos;
                NSInteger slideTileY = spacer.yPos - 1;
                
                if (slideTileY >= 0) {
                    slideTile = [self.tilesMatrix getSPTileAtXPos:slideTileX atYPos:slideTileY];
                }
            }
        }
        
        if (slideTile) {
            CGRect rect = slideTile.frame;
            
            // Y axis
            float movetoY = (rect.origin.y + rect.size.height) - (-yAcceleration * StepMoveFactor);
            float maxY = (rect.origin.y + rect.size.height) + (float)self.sliceHeight;
            
            if (movetoY < 0) {
                movetoY = 0.01;
            }
            
            if (movetoY > maxY) {
                movetoY = maxY;
            }
            
            [self moveTileVertically:slideTile acceleration:yAcceleration];
        }
    }
    
    self.lastUpdateTime = [NSDate date];
    
}

@end
