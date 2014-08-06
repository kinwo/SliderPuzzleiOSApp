//
//  SPHowToPlayViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 2/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZHowToPlayViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import <RESideMenu/RESideMenu.h>
#import <MYBlurIntroductionView/MYIntroductionPanel.h>
#import <MYBlurIntroductionView/MYBlurIntroductionView.h>
#import <PixateFreestyle/PixateFreestyle.h>

@interface SPZHowToPlayViewController ()<MYIntroductionDelegate>

@property (nonatomic, strong) MYBlurIntroductionView *introductionView;

@end

@implementation SPZHowToPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"How To Play View";
    [self buildIntro];
}

#pragma mark IBActions
- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

#pragma mark - Build MYBlurIntroductionView

-(void)buildIntro
{
    if (self.introductionView) {
        [self.introductionView removeFromSuperview];
    }
    
    //Create Stock Panel With Image
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Touch Friendly" description:@"Tap, Swipe or Drag and Drop to move squares." image:[UIImage imageNamed:@"TourTheApp1"]];
    [self updatePanelUI:panel1];
    
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Get Hints" description:@"Touch & hold on 'Peek' button to get hints." image:[UIImage imageNamed:@"TourTheApp3"]];
    [self updatePanelUI:panel2];
    
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Choose difficulties" description:@"Choose among Easy, Medium and Difficult." image:[UIImage imageNamed:@"TourTheApp2"]];
    [self updatePanelUI:panel3];
    
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Play all levels" description:@"Tap 'More' button to switch to new levels." image:[UIImage imageNamed:@"TourTheApp4"]];
    [self updatePanelUI:panel4];

    MYIntroductionPanel *panel5 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"No score but a timer." description:@"Yes. We don't count your scores but we show you the Timer!" image:[UIImage imageNamed:@"TourTheApp5"]];
    [self updatePanelUI:panel5];
    
    MYIntroductionPanel *panel6 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Ready?" description:@"Enjoy playing Squarez!" image:[UIImage imageNamed:@"TourTheApp6"]];
    [self updatePanelUI:panel6];
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3, panel4, panel5, panel6];
    
    //Create the introduction view and set its delegate
    self.introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.introductionView.delegate = self;
    self.introductionView.PageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#fbbf26"];
    self.introductionView.PageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#75b744"];
    self.introductionView.RightSkipButton.titleLabel.textColor = [UIColor darkGrayColor];
    
    //Build the introduction with desired panels
    [self.introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:self.introductionView];
}

-(void)updatePanelUI:(MYIntroductionPanel*)panel
{
    panel.PanelTitleLabel.textColor = [UIColor colorWithHexString:@"#75b744"];
    panel.PanelDescriptionLabel.textColor = [UIColor darkGrayColor];
    panel.PanelImageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex
{
    
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType
{
    [self showMenu:self];
}


@end
