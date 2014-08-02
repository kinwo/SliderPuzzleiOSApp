//
//  SPRESideMenuViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 31/07/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPRESideMenuViewController.h"

@interface SPRESideMenuViewController ()

@end

@implementation SPRESideMenuViewController

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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)awakeFromNib
{
    self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentViewController"];
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"leftMenuController"];

}

@end
