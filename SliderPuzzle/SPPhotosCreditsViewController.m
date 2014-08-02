//
//  SPPhotosCreditsViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 2/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPPhotosCreditsViewController.h"
#import <RESideMenu/RESideMenu.h>

@interface SPPhotosCreditsViewController ()

@end

@implementation SPPhotosCreditsViewController

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
- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

@end
