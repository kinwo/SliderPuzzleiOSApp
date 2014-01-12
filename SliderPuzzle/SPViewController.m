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

static NSInteger const NumRows = 4;
static NSInteger const NumColumns = 4;
static NSString* const SourceImage = @"globe.jpg";
static NSInteger const TargetImageWidth = 310;
static NSInteger const TargetImageHeight= 310;
static NSInteger const spacerIndex = 0;

@interface SPViewController ()

@property(nonatomic) NSInteger sliceWidth;
@property(nonatomic) NSInteger sliceHeight;

// Model for Puzzle tiles
@property(nonatomic, strong) SPTilesMatrix *tilesMatrix;

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
    
    // resize to fit into the container
    UIImage *resizedImage = [[UIImage imageNamed:SourceImage] resizeImageToSize:CGSizeMake(TargetImageWidth, TargetImageHeight)];
    
    // display slice images for the resized image
    [self displaySliceImagesFor:resizedImage];
}

- (void)displaySliceImagesFor:(UIImage*)srcImage
{
    CGRect containerFrame = CGRectMake(5, 100, srcImage.size.width, srcImage.size.height);
    SPPuzzleBoard *boardView = [[SPPuzzleBoard alloc] initWithFrame:containerFrame];
    
    self.sliceWidth = srcImage.size.width / NumColumns;
    self.sliceHeight = srcImage.size.width / NumRows;
    
    NSMutableArray *sliceImageList = [srcImage sliceImagesWithNumRows:NumRows numColumns:NumColumns];

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
    
    [self.view addSubview:boardView];
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
    tile.image = sliceImage;
    tile.xPos = xPos;
    tile.yPos = yPos;
    
    return tile;
}

// Add animation to slide tile action
- (void)animateSlideTile:(SPTile*)senderTile
{
    // slide tile only if this tile has intersection with spacer tile and with animation
    if ([senderTile hasIntersect:self.tilesMatrix.spacer]) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.tilesMatrix slideTile:senderTile];
        }];
    }
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

@end
