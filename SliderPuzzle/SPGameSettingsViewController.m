//
//  SPGameSettingsViewController.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 2/08/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPGameSettingsViewController.h"
#import <PixateFreestyle/PixateFreestyle.h>
#import <RESideMenu/RESideMenu.h>
#import <BFPaperButton/BFPaperButton.h>
#import "SPConstants.h"
#import "SKTAudio.h"

@interface SPGameSettingsViewController ()

@property (weak, nonatomic) IBOutlet BFPaperButton *soundOffButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameDifficulty;

@end

@implementation SPGameSettingsViewController

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

    // update soundOff
    BOOL soundOff = [[NSUserDefaults standardUserDefaults] boolForKey:USER_PREF_SOUNDOFF];
    self.soundOffButton.selected = soundOff;
    
    // update gameDifficulty
    NSInteger difficulty = [[NSUserDefaults standardUserDefaults] integerForKey:USER_PREF_GAMEDIFFICULTY];
    self.gameDifficulty.selectedSegmentIndex = difficulty;
}

#pragma mark IBActions
- (IBAction)showMenu:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (IBAction)onTapSoundVolume:(id)sender
{
    self.soundOffButton.selected = !self.soundOffButton.selected;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.soundOffButton.selected forKey:USER_PREF_SOUNDOFF];
    [userDefaults synchronize];
    
    if (self.soundOffButton.selected) {
        [[SKTAudio sharedInstance] pauseBackgroundMusic];
        [[SKTAudio sharedInstance] stopSoundEffect];
    } else {
        [[SKTAudio sharedInstance] playBackgroundMusic:BACKGROUND_MUSIC];
    }    
}

- (IBAction)onTapLevelSegment:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.gameDifficulty.selectedSegmentIndex forKey:USER_PREF_GAMEDIFFICULTY];
    [userDefaults synchronize];
}
@end
