//
//  SPMenuContentViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 2/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPMenuContentViewController.h"
#import <RESideMenu/RESideMenu.h>
#import <Instabug/Instabug.h>

@interface SPMenuContentViewController ()

@end

@implementation SPMenuContentViewController

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

#pragma mark IBActions
- (IBAction)showGameBoard:(id)sender
{
    [self presentVC:@"contentViewController"];
}

- (IBAction)showHowToPlay:(id)sender
{
    [self presentVC:@"howToPlayVC"];
}

- (IBAction)showGameSettings:(id)sender
{
    [self presentVC:@"gameSettingsVC"];
}

- (IBAction)showPhotosCredits:(id)sender
{
    [self presentVC:@"photosCreditsVC"];
}

- (IBAction)showUserVoice:(id)sender
{
    [Instabug invoke];
}

- (void)presentVC:(NSString*)storyBoardId
{
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:storyBoardId];
    if (vc && self.sideMenuViewController.contentViewController.class != vc.class) {
        [self.sideMenuViewController setContentViewController:vc animated:YES];
    }
    [self.sideMenuViewController hideMenuViewController];
}


@end
