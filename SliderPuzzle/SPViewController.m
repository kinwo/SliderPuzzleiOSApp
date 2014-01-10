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

static NSInteger const NumRows = 4;
static NSInteger const NumColumns = 4;
static NSString* const SourceImage = @"globe.jpg";
static NSInteger const TargetImageWidth = 310;
static NSInteger const TargetImageHeight= 310;
static NSInteger const spacerIndex = 0;
static NSInteger const spacerX = 0;
static NSInteger const spacerY = 0;

@interface SPViewController ()

@end

@implementation SPViewController

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
    UIView *containerView = [self createContainerView:srcImage];
    
    NSInteger sliceWidth = srcImage.size.width / NumColumns;
    NSInteger sliceHeight = srcImage.size.width / NumRows;
    
    NSMutableArray *sliceImageList = [srcImage sliceImagesWithNumRows:NumRows numColumns:NumColumns];

    // randomize
    [sliceImageList scramble];
    
    // select top left corner element as spacer
    UIImage *spacerImage = [UIImage imageWithColor:[UIColor whiteColor] withFrame:CGRectMake(0, 0, sliceWidth, sliceHeight)];
    sliceImageList[spacerIndex] = spacerImage;
    
    
    NSInteger originX = 0;
    NSInteger originY = 0;
    
    NSInteger index=0;
    for (int i=0; i<NumRows; i++) {
        originY = i * sliceHeight;
        
        for (int j=0; j<NumColumns; j++) {
            originX = j * sliceWidth;
            
            UIImageView *sliceImageView = [self createSliceImageView:sliceImageList[index] sliceFrame:CGRectMake(originX, originY, sliceWidth, sliceHeight)];
            [containerView addSubview:sliceImageView];
            
            index++;
        }
    }
    
    [self.view addSubview:containerView];
}

- (UIImageView*)createSliceImageView:(UIImage*)sliceImage sliceFrame:(CGRect)frame
{
    UIImageView *sliceImageView = [[UIImageView alloc] initWithFrame:frame];
    sliceImageView.contentMode = UIViewContentModeCenter;
    sliceImageView.image = sliceImage;
    
    // shadow
    sliceImageView.layer.shadowColor = [UIColor orangeColor].CGColor;
    sliceImageView.layer.shadowOffset = CGSizeMake(0, 1);
    sliceImageView.layer.shadowOpacity = 2;
    sliceImageView.layer.shadowRadius = 2;
    
    return sliceImageView;
}

- (UIView*)createContainerView:(UIImage*)srcImage;
{
    CGRect containerFrame = CGRectMake(5, 100, srcImage.size.width, srcImage.size.height);
    UIView *containerView = [[UIView alloc] initWithFrame:containerFrame];
    containerView.contentMode = UIViewContentModeCenter;
    
    // shadow
    containerView.layer.shadowColor = [UIColor grayColor].CGColor;
    containerView.layer.shadowOffset = CGSizeMake(0, 2);
    containerView.layer.shadowOpacity = 3;
    containerView.layer.shadowRadius = 5;
    
    return containerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
